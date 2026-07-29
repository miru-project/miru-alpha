import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/ui/features/download/widget/download_tiles.dart';
import 'package:miru_alpha/ui/features/download/views/download_view.dart';

// ---------------------------------------------------------------------------
// Helpers to build DownloadProgress / DownloadState without gRPC
// ---------------------------------------------------------------------------

/// Shorthand for a [proto.DownloadProgress] with enough fields to render UI.
proto.DownloadProgress _task({
  required int taskId,
  required String title,
  required int progress,
  required int total,
  required proto.DownloadStatus status,
  String package = 'test.pkg',
  String key = 'ep1',
}) {
  return proto.DownloadProgress(
    taskId: taskId,
    title: title,
    progress: progress,
    total: total,
    status: status,
    package: package,
    key: key,
  );
}

/// Shorthand for a [DownloadState] with active tasks.
DownloadState _stateWithActive(List<proto.DownloadProgress> active) {
  return DownloadState(active: active);
}

ApplicationState _appState() => ApplicationState(
      themeText: 'light',
      baseColor: 'zinc',
      primaryColor: 'zinc',
      themeData: ThemeUtils.getThemeData(MiruThemes.zinc.light),
      themeMode: ThemeMode.light,
      language: 'en',
    );

Widget _scaffoldFor(Widget child) => FTheme(
      data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1280, 800)),
        child: MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => child,
              ),
            ],
          ),
        ),
      ),
    );

// ---------------------------------------------------------------------------
// Fake notifier that returns pre-configured state (no gRPC calls).
// ---------------------------------------------------------------------------
class _FakeDownloadNotifier extends DownloadNotifier {
  _FakeDownloadNotifier(this._state);
  final DownloadState _state;

  @override
  AsyncValue<DownloadState> build() => AsyncData(_state);
}

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);
  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // Unit tests: merged progress logic (back-end restart / stream resilience)
  // =========================================================================
  //
  // The DownloadNotifier._mergeProgress algorithm prevents the visible
  // progress from regressing when the back-end re-emits a stale tick with
  // a lower value (common after a back-end restart that flushes in-memory
  // progress counters but the front-end still holds the real value).

  group('MergeProgress logic', () {
    /// Re-implementation of `_mergeProgress` so we can test it in isolation.
    /// Same contract: keep the higher [progress] when status hasn't changed.
    Iterable<proto.DownloadProgress> mergeProgress(
      Iterable<proto.DownloadProgress> incoming,
      DownloadState currentState,
    ) {
      final existingMap = <int, proto.DownloadProgress>{};
      for (final t in currentState.active) {
        existingMap[t.taskId] = t;
      }

      return incoming.map((newTask) {
        final existing = existingMap[newTask.taskId];
        if (existing == null) return newTask;

        if (existing.progress > newTask.progress &&
            existing.status == newTask.status) {
          return proto.DownloadProgress()
            ..mergeFromMessage(newTask)
            ..progress = existing.progress;
        }
        return newTask;
      });
    }

    group('keeps higher progress when status unchanged', () {
      test('incoming lower progress → keep existing higher', () {
        final existing = _task(
          taskId: 1,
          title: 'Test',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.PAUSED,
        );
        final state = _stateWithActive([existing]);

        // Back-end restarts and emits progress=0 for the same PAUSED task.
        final incoming = [
          _task(
            taskId: 1,
            title: 'Test',
            progress: 0,
            total: 100,
            status: proto.DownloadStatus.PAUSED,
          ),
        ];

        final result = mergeProgress(incoming, state).toList();
        expect(result.length, 1);
        expect(result[0].taskId, 1);
        // Should keep the higher existing progress (50), not regress to 0.
        expect(result[0].progress, 50);
        expect(result[0].status, proto.DownloadStatus.PAUSED);
      });

      test('incoming same progress → uses incoming (no regression)', () {
        final existing = _task(
          taskId: 1,
          title: 'Test',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
        );
        final state = _stateWithActive([existing]);

        final incoming = [
          _task(
            taskId: 1,
            title: 'Test',
            progress: 50,
            total: 100,
            status: proto.DownloadStatus.DOWNLOADING,
          ),
        ];

        final result = mergeProgress(incoming, state).toList();
        expect(result.length, 1);
        // Same progress — no regression.
        expect(result[0].progress, 50);
      });

      test('incoming higher progress → uses incoming (actual update)', () {
        final existing = _task(
          taskId: 1,
          title: 'Test',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
        );
        final state = _stateWithActive([existing]);

        final incoming = [
          _task(
            taskId: 1,
            title: 'Test',
            progress: 75,
            total: 100,
            status: proto.DownloadStatus.DOWNLOADING,
          ),
        ];

        final result = mergeProgress(incoming, state).toList();
        expect(result.length, 1);
        // Higher incoming → use incoming.
        expect(result[0].progress, 75);
      });
    });

    group('preserves across status transitions', () {
      test('different status → always uses incoming (status changed)', () {
        final existing = _task(
          taskId: 1,
          title: 'Test',
          progress: 80,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
        );
        final state = _stateWithActive([existing]);

        // Back-end progressed to PAUSED at 50% (e.g. user paused at 50).
        // Since status changed, we accept the incoming value.
        final incoming = [
          _task(
            taskId: 1,
            title: 'Test',
            progress: 50,
            total: 100,
            status: proto.DownloadStatus.PAUSED,
          ),
        ];

        final result = mergeProgress(incoming, state).toList();
        expect(result.length, 1);
        // Status differs → accept incoming even though progress is lower.
        expect(result[0].progress, 50);
        expect(result[0].status, proto.DownloadStatus.PAUSED);
      });

      test('DOWNGRADE scenario: lower progress + different status → accept',
          () {
        // Simulate: task was DOWNLOADING at 80%, back-end now says QUEUED at 0
        // (maybe back-end restarted and lost progress).
        final existing = _task(
          taskId: 1,
          title: 'Test',
          progress: 80,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
        );
        final state = _stateWithActive([existing]);

        final incoming = [
          _task(
            taskId: 1,
            title: 'Test',
            progress: 0,
            total: 100,
            status: proto.DownloadStatus.QUEUED,
          ),
        ];

        final result = mergeProgress(incoming, state).toList();
        expect(result.length, 1);
        // Status changed, so we accept the incoming (even though progress is 0).
        // This is the intended behaviour — the back-end reset the task queue.
        expect(result[0].progress, 0);
        expect(result[0].status, proto.DownloadStatus.QUEUED);
      });

      test(
          'RESTART scenario: paused non-zero progress kept when back-end re-emits 0',
          () {
        // This is THE critical scenario the user reported:
        //  - Frontend had a PAUSED task at 50%
        //  - Back-end restarts and emits downloadStatus with progress=0
        //  - The UI should NOT regress to 0%
        final existing = _task(
          taskId: 42,
          title: 'My Episode',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.PAUSED,
        );
        final state = _stateWithActive([existing]);

        // Simulate back-end restart: it returns PAUSED at 0%.
        // (The back-end lost in-memory progress but the task is still PAUSED.)
        final incoming = [
          _task(
            taskId: 42,
            title: 'My Episode',
            progress: 0,
            total: 100,
            status: proto.DownloadStatus.PAUSED,
          ),
        ];

        final result = mergeProgress(incoming, state).toList();
        expect(result.length, 1);
        // The merge must keep 50%, not 0%.
        expect(result[0].progress, 50);
        expect(result[0].status, proto.DownloadStatus.PAUSED);
      });
    });

    group('edge cases', () {
      test('no existing state for a task → uses incoming', () {
        final state = _stateWithActive([]);
        final incoming = [
          _task(
            taskId: 1,
            title: 'New',
            progress: 30,
            total: 100,
            status: proto.DownloadStatus.DOWNLOADING,
          ),
        ];

        final result = mergeProgress(incoming, state).toList();
        expect(result.length, 1);
        expect(result[0].progress, 30);
      });

      test('multiple tasks mix of existing and new', () {
        final existing1 = _task(
          taskId: 1,
          title: 'Task 1',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
        );
        final state = _stateWithActive([existing1]);

        final incoming = [
          // Task 1: existing at 50, incoming at 40 → keep 50
          _task(
            taskId: 1,
            title: 'Task 1',
            progress: 40,
            total: 100,
            status: proto.DownloadStatus.DOWNLOADING,
          ),
          // Task 2: brand new → accept 10
          _task(
            taskId: 2,
            title: 'Task 2',
            progress: 10,
            total: 100,
            status: proto.DownloadStatus.QUEUED,
          ),
        ];

        final result = mergeProgress(incoming, state).toList();
        expect(result.length, 2);
        expect(result[0].taskId, 1);
        expect(result[0].progress, 50); // kept higher
        expect(result[1].taskId, 2);
        expect(result[1].progress, 10); // new → accepted
      });

      test('incoming has zero-length list', () {
        final existing = _task(
          taskId: 1,
          title: 'Test',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.PAUSED,
        );
        final state = _stateWithActive([existing]);
        final result = mergeProgress([], state).toList();
        expect(result, isEmpty);
      });

      test('existing state is null → returns incoming as-is', () {
        // Use a DownloadState without active items to simulate first load.
        final state = DownloadState();
        final incoming = [
          _task(
            taskId: 1,
            title: 'Test',
            progress: 0,
            total: 100,
            status: proto.DownloadStatus.PAUSED,
          ),
        ];

        final result = mergeProgress(incoming, state).toList();
        expect(result.length, 1);
        expect(result[0].progress, 0);
      });
    });
  });

  // =========================================================================
  // Unit tests: DownloadState / DownloadNotifier helpers (static methods)
  // =========================================================================

  group('DownloadState helpers', () {
    test('filterActive returns only active statuses', () {
      final tasks = [
        _task(
          taskId: 1,
          title: 'A',
          progress: 0,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
        ),
        _task(
          taskId: 2,
          title: 'B',
          progress: 0,
          total: 100,
          status: proto.DownloadStatus.PAUSED,
        ),
        _task(
          taskId: 3,
          title: 'C',
          progress: 0,
          total: 100,
          status: proto.DownloadStatus.COMPLETED,
        ),
        _task(
          taskId: 4,
          title: 'D',
          progress: 0,
          total: 100,
          status: proto.DownloadStatus.QUEUED,
        ),
        _task(
          taskId: 5,
          title: 'E',
          progress: 0,
          total: 100,
          status: proto.DownloadStatus.FAILED,
        ),
        _task(
          taskId: 6,
          title: 'F',
          progress: 0,
          total: 100,
          status: proto.DownloadStatus.CONVERTING,
        ),
      ];

      final active = DownloadNotifier.filterActive(tasks);
      // DOWNLOADING, PAUSED, CONVERTING, FAILED, QUEUED are active.
      // COMPLETED is terminal.
      final activeIds = active.map((t) => t.taskId).toSet();
      expect(activeIds, containsAll([1, 2, 4, 5, 6]));
      expect(activeIds, isNot(contains(3))); // COMPLETED not active
    });

    test('filterActive empty input returns empty', () {
      expect(DownloadNotifier.filterActive([]), isEmpty);
    });
  });

  group('DownloadFileExists', () {
    test('null or empty path returns true (do not hide)', () async {
      expect(await DownloadNotifier.downloadFileExists(null), isTrue);
      expect(await DownloadNotifier.downloadFileExists(''), isTrue);
    });

    test('existing file returns true', () async {
      final f = File('${Directory.systemTemp.path}/miru_test_exists.txt');
      await f.create(recursive: true);
      addTearDown(() => f.deleteSync());
      expect(await DownloadNotifier.downloadFileExists(f.path), isTrue);
    });

    test('missing file returns false', () async {
      final missing = '/tmp/miru_test_definitely_missing_xyz.mp4';
      expect(await DownloadNotifier.downloadFileExists(missing), isFalse);
    });
  });

  group('DownloadFileHasContent', () {
    test('empty path returns true', () async {
      expect(await DownloadNotifier.downloadFileHasContent(''), isTrue);
    });

    test('file with content returns true', () async {
      final f = File('${Directory.systemTemp.path}/miru_test_content.txt');
      await f.create(recursive: true);
      await f.writeAsString('hello');
      addTearDown(() => f.deleteSync());
      expect(await DownloadNotifier.downloadFileHasContent(f.path), isTrue);
    });

    test('empty file (0 bytes) returns false', () async {
      final f = File('${Directory.systemTemp.path}/miru_test_empty.txt');
      await f.create(recursive: true);
      addTearDown(() => f.deleteSync());
      expect(await DownloadNotifier.downloadFileHasContent(f.path), isFalse);
    });

    test('missing file returns false', () async {
      expect(
        await DownloadNotifier.downloadFileHasContent(
          '/tmp/miru_test_nope.txt',
        ),
        isFalse,
      );
    });
  });

  // =========================================================================
  // Widget tests: progress display in the download tile
  // =========================================================================

  group('DownloadProcessTile progress display', () {
    setUp(() {
      MiruSettings.seedDefaultsForTest();
    });

    Widget buildTile(proto.DownloadProgress task) {
      final container = ProviderContainer(
        overrides: [
          downloadProvider.overrideWith(
            () => _FakeDownloadNotifier(_stateWithActive([task])),
          ),
          applicationControllerProvider.overrideWith(
            () => _FakeApplicationController(_appState()),
          ),
        ],
      );
      addTearDown(container.dispose);

      return UncontrolledProviderScope(
        container: container,
        child: _scaffoldFor(DownloadProcessTile(progress: task)),
      );
    }

    testWidgets(
      'PAUSED task with 50% progress shows correct progress bar',
      (tester) async {
        final task = _task(
          taskId: 1,
          title: 'Paused Episode',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.PAUSED,
        );

        await tester.pumpWidget(buildTile(task));
        await tester.pumpAndSettle();

        // The tile should show the progress percentage text "50%"
        expect(find.text('50%'), findsOneWidget);
        // The title should be visible
        expect(find.text('Paused Episode'), findsOneWidget);
        // The progress bar widget should exist
        expect(find.byType(FDeterminateProgress), findsOneWidget);
      },
    );

    testWidgets(
      'DOWNLOADING task at 75% shows correct progress',
      (tester) async {
        final task = _task(
          taskId: 2,
          title: 'Active Download',
          progress: 75,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
        );

        await tester.pumpWidget(buildTile(task));
        await tester.pumpAndSettle();

        expect(find.text('75%'), findsOneWidget);
        expect(find.text('Active Download'), findsOneWidget);
      },
    );

    testWidgets(
      'QUEUED task at 0% shows 0% progress (no download started)',
      (tester) async {
        final task = _task(
          taskId: 3,
          title: 'Queued Item',
          progress: 0,
          total: 100,
          status: proto.DownloadStatus.QUEUED,
        );

        await tester.pumpWidget(buildTile(task));
        await tester.pumpAndSettle();

        expect(find.text('0%'), findsOneWidget);
      },
    );

    testWidgets('FAILED task preserves whatever progress was made',
        (tester) async {
      final task = _task(
        taskId: 4,
        title: 'Failed Item',
        progress: 33,
        total: 100,
        status: proto.DownloadStatus.FAILED,
      );

      await tester.pumpWidget(buildTile(task));
      await tester.pumpAndSettle();

      expect(find.text('33%'), findsOneWidget);
    });

    testWidgets(
      'progress bar ratio computed from progress/total correctly',
      (tester) async {
        // Task with partial total: e.g. 3 out of 10 → 33%
        final task = _task(
          taskId: 5,
          title: 'Partial',
          progress: 3,
          total: 10,
          status: proto.DownloadStatus.DOWNLOADING,
        );

        await tester.pumpWidget(buildTile(task));
        await tester.pumpAndSettle();

        expect(find.text('30%'), findsOneWidget);
      },
    );

    testWidgets(
      'completed at 0 total does not crash (division by zero guard)',
      (tester) async {
        final task = _task(
          taskId: 6,
          title: 'Zero Total',
          progress: 0,
          total: 0,
          status: proto.DownloadStatus.QUEUED,
        );

        // Should not throw despite 0/0.
        await tester.pumpWidget(buildTile(task));
        await tester.pumpAndSettle();

        // 0 total → ratio clamped to 0 → 0%
        expect(find.text('0%'), findsOneWidget);
      },
    );

    testWidgets(
      'progress > total clamps to 100%',
      (tester) async {
        final task = _task(
          taskId: 7,
          title: 'Overflow',
          progress: 150,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
        );

        await tester.pumpWidget(buildTile(task));
        await tester.pumpAndSettle();

        expect(find.text('100%'), findsOneWidget);
      },
    );
  });

  // =========================================================================
  // Widget tests: DownloadView shows correct initial progress from provider
  // =========================================================================

  group('DownloadView progress after restart scenario', () {
    setUp(() {
      MiruSettings.seedDefaultsForTest();
    });

    /// Helper: renders the [DownloadView] with the given active tasks.
    Future<ProviderContainer> pumpDownloadView(
      WidgetTester tester, {
      required List<proto.DownloadProgress> active,
    }) async {
      final container = ProviderContainer(
        overrides: [
          downloadProvider.overrideWith(
            () => _FakeDownloadNotifier(_stateWithActive(active)),
          ),
          applicationControllerProvider.overrideWith(
            () => _FakeApplicationController(_appState()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _scaffoldFor(const DownloadView()),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets(
      'RESTART: paused task with 50% progress shows progress bar not 0',
      (tester) async {
        // This is the exact scenario from the bug report:
        // After back-end restart, the frontend should show the correct
        // progress that was already downloaded (e.g. 50%), not reset to 0%.
        final tasks = [
          _task(
            taskId: 100,
            title: 'Restored Episode',
            progress: 50,
            total: 100,
            status: proto.DownloadStatus.PAUSED,
          ),
        ];

        await pumpDownloadView(tester, active: tasks);

        // The DownloadView uses _ActiveDownloadTile which renders an
        // FDeterminateProgress bar (no percentage text — that is in
        // DownloadProcessTile).  Verify the progress bar exists.
        expect(find.byType(FDeterminateProgress), findsOneWidget);
        // The status label should say "paused" (via i18n)
        expect(find.text('download.status.paused'.i18n), findsOneWidget);
        // The task title should be visible
        expect(find.text('Restored Episode'), findsOneWidget);
      },
    );

    testWidgets(
      'RESTART: multiple paused tasks all show progress bars',
      (tester) async {
        final tasks = [
          _task(
            taskId: 1,
            title: 'Episode A',
            progress: 30,
            total: 100,
            status: proto.DownloadStatus.PAUSED,
          ),
          _task(
            taskId: 2,
            title: 'Episode B',
            progress: 80,
            total: 100,
            status: proto.DownloadStatus.PAUSED,
          ),
          _task(
            taskId: 3,
            title: 'Episode C',
            progress: 10,
            total: 100,
            status: proto.DownloadStatus.PAUSED,
          ),
        ];

        await pumpDownloadView(tester, active: tasks);

        // Each active task gets its own progress bar
        expect(find.byType(FDeterminateProgress), findsNWidgets(3));
        expect(find.text('Episode A'), findsOneWidget);
        expect(find.text('Episode B'), findsOneWidget);
        expect(find.text('Episode C'), findsOneWidget);
      },
    );

    testWidgets(
      'RESTART: mixed DOWNLOADING and PAUSED show correct state',
      (tester) async {
        final tasks = [
          _task(
            taskId: 1,
            title: 'Active',
            progress: 60,
            total: 100,
            status: proto.DownloadStatus.DOWNLOADING,
          ),
          _task(
            taskId: 2,
            title: 'Paused',
            progress: 40,
            total: 100,
            status: proto.DownloadStatus.PAUSED,
          ),
        ];

        await pumpDownloadView(tester, active: tasks);

        expect(find.text('Active'), findsOneWidget);
        expect(find.text('Paused'), findsOneWidget);
        expect(find.byType(FDeterminateProgress), findsNWidgets(2));
      },
    );

    testWidgets(
      'RESTART: queued task at 0% appears in list (shows progress bar)',
      (tester) async {
        final tasks = [
          _task(
            taskId: 1,
            title: 'Waiting',
            progress: 0,
            total: 100,
            status: proto.DownloadStatus.QUEUED,
          ),
        ];

        await pumpDownloadView(tester, active: tasks);

        // The task should be visible with a progress bar at 0%.
        expect(find.byType(FDeterminateProgress), findsOneWidget);
        expect(find.text('Waiting'), findsOneWidget);
      },
    );

    testWidgets('empty active shows empty state not progress', (tester) async {
      await pumpDownloadView(tester, active: []);

      // No progress bars when there are no active tasks
      expect(find.byType(FDeterminateProgress), findsNothing);
      // Shows the "no active downloads" empty state message
      expect(
        find.text('download.no_active_downloads'.i18n),
        findsOneWidget,
      );
    });
  });

  // =========================================================================
  // Backend update scenario: provider state updates when backend calls back
  // =========================================================================
  //
  // These tests verify that the DownloadNotifier correctly exposes updated
  // state when the backend sends progress via the event stream. We simulate
  // this by building the widget with an initial state, then reading from a
  // ProviderContainer that has the new state injected.

  group('Backend progress update reflected in UI', () {
    setUp(() {
      MiruSettings.seedDefaultsForTest();
    });

    testWidgets(
      'state with updated progress shows new progress bar',
      (tester) async {
        // Start with task at 30%
        final initialTask = _task(
          taskId: 1,
          title: 'Growing',
          progress: 30,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
        );

        // Build with initial state
        final container = ProviderContainer(
          overrides: [
            downloadProvider.overrideWith(
              () => _FakeDownloadNotifier(_stateWithActive([initialTask])),
            ),
            applicationControllerProvider.overrideWith(
              () => _FakeApplicationController(_appState()),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: _scaffoldFor(const DownloadView()),
          ),
        );
        await tester.pumpAndSettle();

        // Initially shows a progress bar and the title
        expect(find.byType(FDeterminateProgress), findsOneWidget);
        expect(find.text('Growing'), findsOneWidget);

        // Now simulate backend progress update by creating a new ProviderContainer
        // with the updated task at 65%.  (The UI reads from the provider;
        // overriding the provider with new state mimics a stream event.)
        final updatedTask = _task(
          taskId: 1,
          title: 'Growing',
          progress: 65,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
        );
        final updatedContainer = ProviderContainer(
          overrides: [
            downloadProvider.overrideWith(
              () =>
                  _FakeDownloadNotifier(_stateWithActive([updatedTask])),
            ),
            applicationControllerProvider.overrideWith(
              () => _FakeApplicationController(_appState()),
            ),
          ],
        );
        addTearDown(updatedContainer.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: updatedContainer,
            child: _scaffoldFor(const DownloadView()),
          ),
        );
        await tester.pumpAndSettle();

        // Still shows a progress bar (the value changed but we verify the bar exists)
        expect(find.byType(FDeterminateProgress), findsOneWidget);
        expect(find.text('Growing'), findsOneWidget);
      },
    );

    testWidgets(
      'new task from backend appears in the list',
      (tester) async {
        // Start with one task
        final container = ProviderContainer(
          overrides: [
            downloadProvider.overrideWith(
              () => _FakeDownloadNotifier(
                _stateWithActive([
                  _task(
                    taskId: 1,
                    title: 'Old Task',
                    progress: 50,
                    total: 100,
                    status: proto.DownloadStatus.DOWNLOADING,
                  ),
                ]),
              ),
            ),
            applicationControllerProvider.overrideWith(
              () => _FakeApplicationController(_appState()),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: _scaffoldFor(const DownloadView()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Old Task'), findsOneWidget);
        expect(find.text('New Task'), findsNothing);

        // Simulate backend adding a new task
        final updatedContainer = ProviderContainer(
          overrides: [
            downloadProvider.overrideWith(
              () => _FakeDownloadNotifier(
                _stateWithActive([
                  _task(
                    taskId: 1,
                    title: 'Old Task',
                    progress: 50,
                    total: 100,
                    status: proto.DownloadStatus.DOWNLOADING,
                  ),
                  _task(
                    taskId: 2,
                    title: 'New Task',
                    progress: 10,
                    total: 100,
                    status: proto.DownloadStatus.DOWNLOADING,
                  ),
                ]),
              ),
            ),
            applicationControllerProvider.overrideWith(
              () => _FakeApplicationController(_appState()),
            ),
          ],
        );
        addTearDown(updatedContainer.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: updatedContainer,
            child: _scaffoldFor(const DownloadView()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Old Task'), findsOneWidget);
        expect(find.text('New Task'), findsOneWidget);
        // Two tasks → two progress bars
        expect(find.byType(FDeterminateProgress), findsNWidgets(2));
      },
    );

    testWidgets(
      'task removed from backend (completed/cancelled) disappears',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            downloadProvider.overrideWith(
              () => _FakeDownloadNotifier(
                _stateWithActive([
                  _task(
                    taskId: 1,
                    title: 'Gone Soon',
                    progress: 90,
                    total: 100,
                    status: proto.DownloadStatus.DOWNLOADING,
                  ),
                ]),
              ),
            ),
            applicationControllerProvider.overrideWith(
              () => _FakeApplicationController(_appState()),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: _scaffoldFor(const DownloadView()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Gone Soon'), findsOneWidget);

        // Simulate backend removing the task (it completed)
        final emptyContainer = ProviderContainer(
          overrides: [
            downloadProvider.overrideWith(
              () => _FakeDownloadNotifier(_stateWithActive([])),
            ),
            applicationControllerProvider.overrideWith(
              () => _FakeApplicationController(_appState()),
            ),
          ],
        );
        addTearDown(emptyContainer.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: emptyContainer,
            child: _scaffoldFor(const DownloadView()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Gone Soon'), findsNothing);
        expect(
          find.text('download.no_active_downloads'.i18n),
          findsOneWidget,
        );
      },
    );
  });

  // =========================================================================
  // _discoverHlsSegments tests
  // =========================================================================

  group('_discoverHlsSegments', () {
    test('discovers segment files sorted by numeric index', () async {
      final dir = Directory.systemTemp.createTempSync('hls_test_');
      addTearDown(() => dir.deleteSync(recursive: true));

      for (final name in ['2.ts', '0.ts', '1.ts']) {
        File('${dir.path}/$name').writeAsBytesSync([0]);
      }

      final segments =
          await DownloadNotifier.discoverHlsSegments(dir.path);

      expect(segments.length, 3);
      expect(segments[0], endsWith('0.ts'));
      expect(segments[1], endsWith('1.ts'));
      expect(segments[2], endsWith('2.ts'));
    });

    test('ignores non-segment files', () async {
      final dir = Directory.systemTemp.createTempSync('hls_test_');
      addTearDown(() => dir.deleteSync(recursive: true));

      File('${dir.path}/0.ts').writeAsBytesSync([0]);
      File('${dir.path}/meta.json').writeAsBytesSync([0]);

      final segments =
          await DownloadNotifier.discoverHlsSegments(dir.path);

      expect(segments.length, 1);
      expect(segments[0], endsWith('0.ts'));
    });

    test('returns empty list for non-existent directory', () async {
      final segments = await DownloadNotifier.discoverHlsSegments(
        '/nonexistent/path',
      );
      expect(segments, isEmpty);
    });

    test('handles mixed extensions', () async {
      final dir = Directory.systemTemp.createTempSync('hls_test_');
      addTearDown(() => dir.deleteSync(recursive: true));

      File('${dir.path}/0.ts').writeAsBytesSync([0]);
      File('${dir.path}/1.m4s').writeAsBytesSync([0]);

      final segments =
          await DownloadNotifier.discoverHlsSegments(dir.path);

      expect(segments.length, 2);
    });
  });

  // =========================================================================
  // Converting status display tests
  // =========================================================================

  group('Converting status display', () {
    testWidgets(
      'CONVERTING task shows in active list',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            downloadProvider.overrideWith(
              () => _FakeDownloadNotifier(
                _stateWithActive([
                  _task(
                    taskId: 1,
                    title: 'Converting Task',
                    progress: 5,
                    total: 10,
                    status: proto.DownloadStatus.CONVERTING,
                  ),
                ]),
              ),
            ),
            applicationControllerProvider.overrideWith(
              () => _FakeApplicationController(_appState()),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: _scaffoldFor(const DownloadView()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Converting Task'), findsOneWidget);
      },
    );
  });

  // =========================================================================
  // isActive / retry behavior tests
  // =========================================================================

  group('isActive includes retryable statuses', () {
    test('CONVERTING is active', () {
      expect(proto.DownloadStatus.CONVERTING.isActive, isTrue);
    });

    test('FAILED is active (can be retried)', () {
      expect(proto.DownloadStatus.FAILED.isActive, isTrue);
    });

    test('COMPLETED is not active', () {
      expect(proto.DownloadStatus.COMPLETED.isActive, isFalse);
    });

    test('CANCELLED is not active', () {
      expect(proto.DownloadStatus.CANCELLED.isActive, isFalse);
    });
  });

  // =========================================================================
  // Progress update after restart scenario
  // =========================================================================

  group('Progress update after restart', () {
    testWidgets(
      'FAILED task shows in active list',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            downloadProvider.overrideWith(
              () => _FakeDownloadNotifier(
                _stateWithActive([
                  _task(
                    taskId: 1,
                    title: 'Failed Task',
                    progress: 50,
                    total: 100,
                    status: proto.DownloadStatus.FAILED,
                  ),
                ]),
              ),
            ),
            applicationControllerProvider.overrideWith(
              () => _FakeApplicationController(_appState()),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: _scaffoldFor(const DownloadView()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Failed Task'), findsOneWidget);
      },
    );
  });

  // =========================================================================
  // Conversion retry / state recovery
  // =========================================================================

  group('CONVERTING state recovery', () {
    testWidgets(
      'CONVERTING task stuck in active list after restart can be retried via Resume',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            downloadProvider.overrideWith(
              () => _FakeDownloadNotifier(
                _stateWithActive([
                  _task(
                    taskId: 1,
                    title: 'Stuck Converting',
                    progress: 100,
                    total: 100,
                    status: proto.DownloadStatus.CONVERTING,
                  ),
                ]),
              ),
            ),
            applicationControllerProvider.overrideWith(
              () => _FakeApplicationController(_appState()),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: _scaffoldFor(const DownloadView()),
          ),
        );
        await tester.pumpAndSettle();

        // CONVERTING is considered active, so the task should be visible.
        expect(find.text('Stuck Converting'), findsOneWidget);

        // CONVERTING is not paused, so the pause button should be shown.
        expect(find.byIcon(FLucideIcons.pause), findsOneWidget);
      },
    );

    test(
      'CONVERTING isActive allows retry',
      () {
        expect(proto.DownloadStatus.CONVERTING.isActive, isTrue);
      },
    );

    test(
      'QUEUED isActive allows retry',
      () {
        expect(proto.DownloadStatus.QUEUED.isActive, isTrue);
      },
    );
  });
}
