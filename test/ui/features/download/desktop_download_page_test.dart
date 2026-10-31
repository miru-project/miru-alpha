import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/ui/features/download/download_page.dart';
import 'package:miru_alpha/ui/features/download/widget/download_tiles.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';

/// A path that does not exist, used to exercise the "hide missing files" logic.
const String _missingPath = '/tmp/miru_test_does_not_exist_xyz/file.mp4';

/// Seeds the in-memory [MiruSettings] cache so that `getSettingSync` (used by
/// the download page header) does not throw in a widget-test context where the
/// gRPC settings backend is unavailable.
void _seedSettings() {
  MiruSettings.seedDefaultsForTest();
}

DownloadState _buildState({
  List<proto.DownloadProgress> active = const [],
  List<proto.Download> history = const [],
  bool hasMore = false,
}) => DownloadState(active: active, history: history, hasMore: hasMore);

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
        routes: [GoRoute(path: '/', builder: (context, state) => child)],
      ),
    ),
  ),
);

void main() {
  late final String existingPath;

  setUpAll(() {
    _seedSettings();
    // Create a real file so the "hide missing files" logic has something that
    // genuinely exists on disk to keep visible.
    existingPath = File(
      '${Directory.systemTemp.path}/miru_present_${DateTime.now().microsecondsSinceEpoch}.mp4',
    ).absolute.path;
    File(existingPath).createSync(recursive: true);
  });

  tearDownAll(() {
    final f = File(existingPath);
    if (f.existsSync()) f.deleteSync();
  });

  // =========================================================================
  // Tests for DownloadPageDesktopLayout
  // =========================================================================

  group('DownloadPageDesktopLayout', () {
    testWidgets('pinned header shows Download title and clock button', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          downloadProvider.overrideWith(
            () => _FakeDownloadNotifier(
              _buildState(
                active: [
                  proto.DownloadProgress(
                    taskId: 1,
                    title: 'Episode 1',
                    progress: 50,
                    total: 100,
                    status: proto.DownloadStatus.DOWNLOADING,
                  ),
                ],
              ),
            ),
          ),
          applicationControllerProvider.overrideWith(
            () => _FakeApplicationController(_appState()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _scaffoldFor(const DownloadPageDesktopLayout()),
        ),
      );
      await tester.pumpAndSettle();

      // Pinned header shows "Download" title.
      expect(find.text('common.download'.i18n), findsOneWidget);
      // Folder open buttons (select dir + open dir).
      expect(find.byIcon(FLucideIcons.folderOpen), findsWidgets);
    });

    testWidgets('renders active task tiles with history section', (
      WidgetTester tester,
    ) async {
      final active = [
        proto.DownloadProgress(
          taskId: 1,
          title: 'Active Download One',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
        ),
        proto.DownloadProgress(
          taskId: 2,
          title: 'Paused Download Two',
          progress: 20,
          total: 100,
          status: proto.DownloadStatus.PAUSED,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          downloadProvider.overrideWith(
            () => _FakeDownloadNotifier(_buildState(active: active)),
          ),
          applicationControllerProvider.overrideWith(
            () => _FakeApplicationController(_appState()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _scaffoldFor(const DownloadPageDesktopLayout()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DownloadPageDesktopLayout), findsOneWidget);
      expect(find.text('common.active_tasks'.i18n), findsOneWidget);
      expect(find.byType(DownloadProcessTile), findsNWidgets(active.length));
      // History section header should also be visible.
      expect(find.text('common.history'.i18n), findsOneWidget);
    });

    testWidgets('drag handles exist for every active task', (
      WidgetTester tester,
    ) async {
      final active = [
        proto.DownloadProgress(
          taskId: 1,
          title: 'A',
          progress: 10,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
        ),
        proto.DownloadProgress(
          taskId: 2,
          title: 'B',
          progress: 20,
          total: 100,
          status: proto.DownloadStatus.PAUSED,
        ),
        proto.DownloadProgress(
          taskId: 3,
          title: 'C',
          progress: 30,
          total: 100,
          status: proto.DownloadStatus.QUEUED,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          downloadProvider.overrideWith(
            () => _FakeDownloadNotifier(_buildState(active: active)),
          ),
          applicationControllerProvider.overrideWith(
            () => _FakeApplicationController(_appState()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _scaffoldFor(const DownloadPageDesktopLayout()),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byType(ReorderableDelayedDragStartListener),
        findsNWidgets(active.length),
      );
    });

    testWidgets('shows empty state when no active tasks', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          downloadProvider.overrideWith(
            () => _FakeDownloadNotifier(_buildState()),
          ),
          applicationControllerProvider.overrideWith(
            () => _FakeApplicationController(_appState()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _scaffoldFor(const DownloadPageDesktopLayout()),
        ),
      );
      await tester.pumpAndSettle();

      // No active task tiles should appear.
      expect(find.byType(DownloadProcessTile), findsNothing);
      // History section header should always be visible.
      expect(find.text('common.history'.i18n), findsOneWidget);
      // History is empty, so the empty history message should show.
      expect(find.text('download.no_download_history'.i18n), findsOneWidget);
    });
  });

  // =========================================================================
  // Tests for DesktopFinishedDownloadSection (history section)
  // =========================================================================

  group('DesktopFinishedDownloadSection', () {
    testWidgets('renders all history entries', (WidgetTester tester) async {
      final history = [
        proto.Download(
          id: 10,
          package: 'test.pkg',
          title: 'Finished Episode A',
          status: proto.DownloadStatus.COMPLETED,
          savePath: existingPath,
          detailUrl: 'https://example.com/a',
        ),
        proto.Download(
          id: 11,
          package: 'test.pkg',
          title: 'Missing Episode B',
          status: proto.DownloadStatus.FAILED,
          savePath: _missingPath,
          detailUrl: 'https://example.com/b',
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          downloadProvider.overrideWith(
            () => _FakeDownloadNotifier(_buildState(history: history)),
          ),
          applicationControllerProvider.overrideWith(
            () => _FakeApplicationController(_appState()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _scaffoldFor(const DesktopFinishedDownloadSection()),
        ),
      );
      await tester.pumpAndSettle();

      // Both entries should be visible.
      expect(find.text('Finished Episode A'), findsOneWidget);
      expect(find.text('Missing Episode B'), findsOneWidget);
      expect(find.byType(DownloadHistoryTile), findsNWidgets(2));
    });

    testWidgets('shows empty state when no download history', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          downloadProvider.overrideWith(
            () => _FakeDownloadNotifier(_buildState()),
          ),
          applicationControllerProvider.overrideWith(
            () => _FakeApplicationController(_appState()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _scaffoldFor(const DesktopFinishedDownloadSection()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DownloadHistoryTile), findsNothing);
      expect(find.text('download.no_download_history'.i18n), findsOneWidget);
    });
  });
}
