import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/download_provider.dart';

// ---------------------------------------------------------------------------
// Helpers to build DownloadProgress / DownloadState without gRPC
// ---------------------------------------------------------------------------

/// Shorthand for a [proto.DownloadProgress] with enough fields to simulate state.
proto.DownloadProgress _task({
  required int taskId,
  required String title,
  required int progress,
  required int total,
  required proto.DownloadStatus status,
  String package = 'test.pkg',
  String key = 'ep1',
  String mediaType = 'hls',
  String url = '',
  String error = '',
}) {
  return proto.DownloadProgress(
    taskId: taskId,
    title: title,
    progress: progress,
    total: total,
    status: status,
    package: package,
    key: key,
    mediaType: downloadMediaTypeFromString(mediaType),
    url: url,
    error: error,
  );
}

/// Shorthand for a [DownloadState] with active tasks.
DownloadState _stateWithActive(List<proto.DownloadProgress> active) {
  return DownloadState(active: active);
}

// ---------------------------------------------------------------------------
// mergeProgress re-implementation for testing
// ---------------------------------------------------------------------------

/// Same contract as [DownloadNotifier._mergeProgress]: keep the higher
/// [progress] when status hasn't changed.
Iterable<proto.DownloadProgress> _mergeProgress(
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

// ---------------------------------------------------------------------------
// Torrent/magnet status transition detection re-implementation
// ---------------------------------------------------------------------------

/// Same contract as [DownloadNotifier._handleStatusTransitions].
List<
  ({
    String action,
    String title,
    String mediaType,
    int taskId,
    String url,
    String error,
  })
>
_detectStatusChanges(
  Iterable<proto.DownloadProgress> tasks,
  Map<int, proto.DownloadStatus> previousStatuses,
) {
  final actions =
      <
        ({
          String action,
          String title,
          String mediaType,
          int taskId,
          String url,
          String error,
        })
      >[];

  for (final task in tasks) {
    final previousStatus = previousStatuses[task.taskId];
    previousStatuses[task.taskId] = task.status;

    if (task.status == proto.DownloadStatus.FAILED &&
        previousStatus != null &&
        previousStatus != proto.DownloadStatus.FAILED) {
      actions.add((
        action: 'failed',
        title: task.title,
        mediaType: task.mediaType.name,
        taskId: task.taskId,
        url: task.url,
        error: task.error,
      ));
    }

    if (task.status == proto.DownloadStatus.COMPLETED &&
        previousStatus != null &&
        previousStatus != proto.DownloadStatus.COMPLETED) {
      actions.add((
        action: 'completed',
        title: task.title,
        mediaType: task.mediaType.name,
        taskId: task.taskId,
        url: task.url,
        error: task.error,
      ));
    }
  }

  return actions;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // 1. MergeProgress logic — works identically for all media types
  // =========================================================================

  group('MergeProgress logic', () {
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

        final incoming = [
          _task(
            taskId: 1,
            title: 'Test',
            progress: 0,
            total: 100,
            status: proto.DownloadStatus.PAUSED,
          ),
        ];

        final result = _mergeProgress(incoming, state).toList();
        expect(result.length, 1);
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

        final result = _mergeProgress(incoming, state).toList();
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

        final result = _mergeProgress(incoming, state).toList();
        expect(result[0].progress, 75);
      });
    });

    group('preserves across status transitions', () {
      test('different status → always uses incoming', () {
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
            progress: 50,
            total: 100,
            status: proto.DownloadStatus.PAUSED,
          ),
        ];

        final result = _mergeProgress(incoming, state).toList();
        expect(result[0].progress, 50);
        expect(result[0].status, proto.DownloadStatus.PAUSED);
      });

      test('DOWNGRADE: lower progress + different status → accept', () {
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

        final result = _mergeProgress(incoming, state).toList();
        expect(result[0].progress, 0);
        expect(result[0].status, proto.DownloadStatus.QUEUED);
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

        final result = _mergeProgress(incoming, state).toList();
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
          _task(
            taskId: 1,
            title: 'Task 1',
            progress: 40,
            total: 100,
            status: proto.DownloadStatus.DOWNLOADING,
          ),
          _task(
            taskId: 2,
            title: 'Task 2',
            progress: 10,
            total: 100,
            status: proto.DownloadStatus.QUEUED,
          ),
        ];

        final result = _mergeProgress(incoming, state).toList();
        expect(result.length, 2);
        expect(result[0].progress, 50);
        expect(result[1].progress, 10);
      });

      test('empty incoming list', () {
        final existing = _task(
          taskId: 1,
          title: 'Test',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.PAUSED,
        );
        final state = _stateWithActive([existing]);
        final result = _mergeProgress([], state).toList();
        expect(result, isEmpty);
      });

      test('empty existing state → returns incoming as-is', () {
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

        final result = _mergeProgress(incoming, state).toList();
        expect(result[0].progress, 0);
      });
    });
  });

  // =========================================================================
  // 2. MergeProgress across all media types — identical behavior
  // =========================================================================

  group('MergeProgress across media types', () {
    test('HLS progress updates flow through mergeProgress', () {
      var current = _stateWithActive([
        _task(
          taskId: 1,
          title: 'HLS Episode',
          progress: 0,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
          mediaType: 'hls',
        ),
      ]);

      var incoming = [
        _task(
          taskId: 1,
          title: 'HLS Episode',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
          mediaType: 'hls',
        ),
      ];
      var merged = _mergeProgress(incoming, current).toList();
      expect(merged[0].progress, 50);
      current = _stateWithActive(merged);

      incoming = [
        _task(
          taskId: 1,
          title: 'HLS Episode',
          progress: 80,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
          mediaType: 'hls',
        ),
      ];
      merged = _mergeProgress(incoming, current).toList();
      expect(merged[0].progress, 80);
    });

    test('torrent progress updates flow through mergeProgress', () {
      var current = _stateWithActive([
        _task(
          taskId: 1,
          title: 'Torrent',
          progress: 0,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
          mediaType: 'torrent',
        ),
      ]);

      var incoming = [
        _task(
          taskId: 1,
          title: 'Torrent',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
          mediaType: 'torrent',
        ),
      ];
      var merged = _mergeProgress(incoming, current).toList();
      expect(merged[0].progress, 50);
      current = _stateWithActive(merged);

      incoming = [
        _task(
          taskId: 1,
          title: 'Torrent',
          progress: 80,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
          mediaType: 'torrent',
        ),
      ];
      merged = _mergeProgress(incoming, current).toList();
      expect(merged[0].progress, 80);
    });

    test('magnet progress updates flow through mergeProgress', () {
      var current = _stateWithActive([
        _task(
          taskId: 1,
          title: 'Magnet',
          progress: 20,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
          mediaType: 'magnet',
        ),
      ]);

      final incoming = [
        _task(
          taskId: 1,
          title: 'Magnet',
          progress: 60,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
          mediaType: 'magnet',
        ),
      ];
      final merged = _mergeProgress(incoming, current).toList();
      expect(merged[0].progress, 60);
      expect(merged[0].mediaType.name, 'magnet');
    });

    test('mp4 progress updates flow through mergeProgress', () {
      var current = _stateWithActive([
        _task(
          taskId: 1,
          title: 'Big Buck Bunny MP4',
          progress: 0,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
          mediaType: 'mp4',
        ),
      ]);

      var incoming = [
        _task(
          taskId: 1,
          title: 'Big Buck Bunny MP4',
          progress: 30,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
          mediaType: 'mp4',
        ),
      ];
      var merged = _mergeProgress(incoming, current).toList();
      expect(merged[0].progress, 30);
      current = _stateWithActive(merged);

      incoming = [
        _task(
          taskId: 1,
          title: 'Big Buck Bunny MP4',
          progress: 75,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
          mediaType: 'mp4',
        ),
      ];
      merged = _mergeProgress(incoming, current).toList();
      expect(merged[0].progress, 75);
    });

    test('regression protection works identically for all media types', () {
      for (final mediaType in ['hls', 'torrent', 'magnet', 'mp4']) {
        final existing = _task(
          taskId: 1,
          title: 'Test $mediaType',
          progress: 80,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
          mediaType: mediaType,
        );
        final state = _stateWithActive([existing]);

        // Backend re-emits stale 0% tick
        final incoming = [
          _task(
            taskId: 1,
            title: 'Test $mediaType',
            progress: 0,
            total: 100,
            status: proto.DownloadStatus.DOWNLOADING,
            mediaType: mediaType,
          ),
        ];

        final merged = _mergeProgress(incoming, state).toList();
        expect(
          merged[0].progress,
          80,
          reason: '$mediaType must keep 80% not regress to 0%',
        );
      }
    });
  });

  // =========================================================================
  // 3. DownloadState helpers
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
      final activeIds = active.map((t) => t.taskId).toSet();
      expect(activeIds, containsAll([1, 2, 4, 5, 6]));
      expect(activeIds, isNot(contains(3)));
    });

    test('filterActive empty input returns empty', () {
      expect(DownloadNotifier.filterActive([]), isEmpty);
    });

    test('filterActive works for all media types', () {
      final tasks = [
        _task(
          taskId: 1,
          title: 'HLS',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
          mediaType: 'hls',
        ),
        _task(
          taskId: 2,
          title: 'Torrent',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
          mediaType: 'torrent',
        ),
        _task(
          taskId: 3,
          title: 'Magnet',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
          mediaType: 'magnet',
        ),
        _task(
          taskId: 4,
          title: 'MP4',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
          mediaType: 'mp4',
        ),
      ];

      final active = DownloadNotifier.filterActive(tasks);
      expect(active.length, 4);
    });
  });

  group('DownloadFileExists', () {
    test('null or empty path returns true', () async {
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

  group('discoverHlsSegments', () {
    test('discovers segment files sorted by numeric index', () async {
      final dir = Directory.systemTemp.createTempSync('hls_test_');
      addTearDown(() => dir.deleteSync(recursive: true));

      for (final name in ['2.ts', '0.ts', '1.ts']) {
        File('${dir.path}/$name').writeAsBytesSync([0]);
      }

      final segments = await DownloadNotifier.discoverHlsSegments(dir.path);

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

      final segments = await DownloadNotifier.discoverHlsSegments(dir.path);

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

      final segments = await DownloadNotifier.discoverHlsSegments(dir.path);

      expect(segments.length, 2);
    });
  });

  // =========================================================================
  // 4. isActive / retry behavior tests
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

    test('QUEUED isActive allows retry', () {
      expect(proto.DownloadStatus.QUEUED.isActive, isTrue);
    });
  });

  // =========================================================================
  // 5. Status transition detection — all media types
  // =========================================================================

  group('Status transition detection — all media types', () {
    test('torrent DOWNLOADING → FAILED triggers failure action', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'Torrent Episode',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.FAILED,
          mediaType: 'torrent',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 1);
      expect(actions[0].action, 'failed');
      expect(actions[0].title, 'Torrent Episode');
      expect(actions[0].mediaType, 'torrent');
    });

    test('magnet DOWNLOADING → FAILED triggers failure action', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'Magnet Episode',
          progress: 30,
          total: 100,
          status: proto.DownloadStatus.FAILED,
          mediaType: 'magnet',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 1);
      expect(actions[0].action, 'failed');
      expect(actions[0].title, 'Magnet Episode');
      expect(actions[0].mediaType, 'magnet');
    });

    test('torrent QUEUED → FAILED triggers failure action', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.QUEUED,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'Queued Torrent',
          progress: 0,
          total: 100,
          status: proto.DownloadStatus.FAILED,
          mediaType: 'torrent',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 1);
      expect(actions[0].action, 'failed');
    });

    test('torrent DOWNLOADING → COMPLETED triggers completion action', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'Completed Torrent',
          progress: 100,
          total: 100,
          status: proto.DownloadStatus.COMPLETED,
          mediaType: 'torrent',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 1);
      expect(actions[0].action, 'completed');
      expect(actions[0].title, 'Completed Torrent');
    });

    test('magnet DOWNLOADING → COMPLETED triggers completion action', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'Completed Magnet',
          progress: 100,
          total: 100,
          status: proto.DownloadStatus.COMPLETED,
          mediaType: 'magnet',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 1);
      expect(actions[0].action, 'completed');
    });

    test('HLS DOWNLOADING → FAILED triggers failure action', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'HLS Episode',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.FAILED,
          mediaType: 'hls',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 1);
      expect(actions[0].action, 'failed');
      expect(actions[0].mediaType, 'hls');
    });

    test('HLS DOWNLOADING → COMPLETED triggers completion action', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'HLS Episode',
          progress: 100,
          total: 100,
          status: proto.DownloadStatus.COMPLETED,
          mediaType: 'hls',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 1);
      expect(actions[0].action, 'completed');
      expect(actions[0].mediaType, 'hls');
    });

    test('mp4 DOWNLOADING → FAILED triggers failure action', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'MP4 Episode',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.FAILED,
          mediaType: 'mp4',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 1);
      expect(actions[0].action, 'failed');
      expect(actions[0].mediaType, 'mp4');
    });

    test('no previous status for torrent → no action (initial load)', () {
      final previousStatuses = <int, proto.DownloadStatus>{};
      final tasks = [
        _task(
          taskId: 1,
          title: 'New Torrent',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.FAILED,
          mediaType: 'torrent',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions, isEmpty);
    });

    test('same status (no transition) → no action', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.FAILED,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'Already Failed',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.FAILED,
          mediaType: 'torrent',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions, isEmpty);
    });

    test('FAILED → DOWNLOADING (retry) does not trigger action', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.FAILED,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'Retrying Torrent',
          progress: 0,
          total: 100,
          status: proto.DownloadStatus.DOWNLOADING,
          mediaType: 'torrent',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions, isEmpty);
    });

    test('multiple tasks with mixed transitions', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
        2: proto.DownloadStatus.DOWNLOADING,
        3: proto.DownloadStatus.DOWNLOADING,
        4: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'Torrent Failed',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.FAILED,
          mediaType: 'torrent',
        ),
        _task(
          taskId: 2,
          title: 'Magnet Completed',
          progress: 100,
          total: 100,
          status: proto.DownloadStatus.COMPLETED,
          mediaType: 'magnet',
        ),
        _task(
          taskId: 3,
          title: 'HLS Failed',
          progress: 75,
          total: 100,
          status: proto.DownloadStatus.FAILED,
          mediaType: 'hls',
        ),
        _task(
          taskId: 4,
          title: 'MP4 Completed',
          progress: 100,
          total: 100,
          status: proto.DownloadStatus.COMPLETED,
          mediaType: 'mp4',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 4);
      expect(actions[0].action, 'failed');
      expect(actions[0].mediaType, 'torrent');
      expect(actions[1].action, 'completed');
      expect(actions[1].mediaType, 'magnet');
      expect(actions[2].action, 'failed');
      expect(actions[2].mediaType, 'hls');
      expect(actions[3].action, 'completed');
      expect(actions[3].mediaType, 'mp4');
    });

    test('empty task list → no actions', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final actions = _detectStatusChanges([], previousStatuses);
      expect(actions, isEmpty);
    });

    test('previous statuses are updated correctly', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'Torrent',
          progress: 100,
          total: 100,
          status: proto.DownloadStatus.COMPLETED,
          mediaType: 'torrent',
        ),
      ];

      _detectStatusChanges(tasks, previousStatuses);
      expect(previousStatuses[1], proto.DownloadStatus.COMPLETED);
    });
  });

  // =========================================================================
  // 6. Progress sync simulation — all media types
  // =========================================================================

  group('Progress sync to frontend — all media types', () {
    test('HLS progress syncs through state updates', () {
      var state = DownloadState(
        active: [
          _task(
            taskId: 1,
            title: 'HLS Episode',
            progress: 0,
            total: 100,
            status: proto.DownloadStatus.QUEUED,
            mediaType: 'hls',
          ),
        ],
      );
      expect(state.active[0].progress, 0);

      // Tick 1: downloading starts at 25%
      state = state.copyWith(
        active: [
          _task(
            taskId: 1,
            title: 'HLS Episode',
            progress: 25,
            total: 100,
            status: proto.DownloadStatus.DOWNLOADING,
            mediaType: 'hls',
          ),
        ],
      );
      expect(state.active[0].progress, 25);

      // Tick 2: progress to 50%
      state = state.copyWith(
        active: [
          _task(
            taskId: 1,
            title: 'HLS Episode',
            progress: 50,
            total: 100,
            status: proto.DownloadStatus.DOWNLOADING,
            mediaType: 'hls',
          ),
        ],
      );
      expect(state.active[0].progress, 50);

      // Tick 3: segments downloaded, converting
      state = state.copyWith(
        active: [
          _task(
            taskId: 1,
            title: 'HLS Episode',
            progress: 100,
            total: 100,
            status: proto.DownloadStatus.CONVERTING,
            mediaType: 'hls',
          ),
        ],
      );
      expect(state.active[0].status, proto.DownloadStatus.CONVERTING);

      // Tick 4: conversion done, completed → removed from active
      state = state.copyWith(active: []);
      expect(state.active, isEmpty);
    });

    test('torrent progress syncs through state updates', () {
      var state = DownloadState(
        active: [
          _task(
            taskId: 1,
            title: 'Big Buck Bunny',
            progress: 0,
            total: 276000000,
            status: proto.DownloadStatus.QUEUED,
            mediaType: 'torrent',
          ),
        ],
      );

      // Simulate real torrent download progress ticks
      for (final pct in [10, 25, 50, 75, 90]) {
        state = state.copyWith(
          active: [
            _task(
              taskId: 1,
              title: 'Big Buck Bunny',
              progress: 276000000 * pct ~/ 100,
              total: 276000000,
              status: proto.DownloadStatus.DOWNLOADING,
              mediaType: 'torrent',
            ),
          ],
        );
        expect(state.active[0].progress, 276000000 * pct ~/ 100);
      }

      // Completed
      state = state.copyWith(active: []);
      expect(state.active, isEmpty);
    });

    test('magnet progress syncs through state updates', () {
      var state = DownloadState(
        active: [
          _task(
            taskId: 1,
            title: 'Big Buck Bunny Magnet',
            progress: 0,
            total: 276000000,
            status: proto.DownloadStatus.DOWNLOADING,
            mediaType: 'magnet',
          ),
        ],
      );

      for (final pct in [5, 20, 60, 100]) {
        state = state.copyWith(
          active: [
            _task(
              taskId: 1,
              title: 'Big Buck Bunny Magnet',
              progress: 276000000 * pct ~/ 100,
              total: 276000000,
              status: proto.DownloadStatus.DOWNLOADING,
              mediaType: 'magnet',
            ),
          ],
        );
        expect(state.active[0].progress, 276000000 * pct ~/ 100);
      }

      state = state.copyWith(active: []);
      expect(state.active, isEmpty);
    });

    test('mp4 progress syncs through state updates', () {
      const totalBytes = 5000000; // 5MB test file
      var state = DownloadState(
        active: [
          _task(
            taskId: 1,
            title: 'Big Buck Bunny MP4',
            progress: 0,
            total: totalBytes,
            status: proto.DownloadStatus.DOWNLOADING,
            mediaType: 'mp4',
          ),
        ],
      );

      // Simulate chunked download progress (like readAndSavePartial does)
      var downloaded = 0;
      const chunkSize = 1024 * 1024; // 1MB chunks
      while (downloaded < totalBytes) {
        downloaded += chunkSize;
        if (downloaded > totalBytes) downloaded = totalBytes;

        state = state.copyWith(
          active: [
            _task(
              taskId: 1,
              title: 'Big Buck Bunny MP4',
              progress: downloaded,
              total: totalBytes,
              status: proto.DownloadStatus.DOWNLOADING,
              mediaType: 'mp4',
            ),
          ],
        );
        expect(state.active[0].progress, downloaded);
      }

      expect(state.active[0].progress, totalBytes);
    });

    test('mixed media types progress independently in state', () {
      var state = DownloadState(
        active: [
          _task(
            taskId: 1,
            title: 'HLS',
            progress: 0,
            total: 100,
            status: proto.DownloadStatus.DOWNLOADING,
            mediaType: 'hls',
          ),
          _task(
            taskId: 2,
            title: 'Torrent',
            progress: 0,
            total: 276000000,
            status: proto.DownloadStatus.DOWNLOADING,
            mediaType: 'torrent',
          ),
          _task(
            taskId: 3,
            title: 'Magnet',
            progress: 0,
            total: 276000000,
            status: proto.DownloadStatus.DOWNLOADING,
            mediaType: 'magnet',
          ),
          _task(
            taskId: 4,
            title: 'MP4',
            progress: 0,
            total: 5000000,
            status: proto.DownloadStatus.DOWNLOADING,
            mediaType: 'mp4',
          ),
        ],
      );

      // Each media type progresses independently
      state = state.copyWith(
        active: [
          _task(
            taskId: 1,
            title: 'HLS',
            progress: 50,
            total: 100,
            status: proto.DownloadStatus.DOWNLOADING,
            mediaType: 'hls',
          ),
          _task(
            taskId: 2,
            title: 'Torrent',
            progress: 100000000,
            total: 276000000,
            status: proto.DownloadStatus.DOWNLOADING,
            mediaType: 'torrent',
          ),
          _task(
            taskId: 3,
            title: 'Magnet',
            progress: 50000000,
            total: 276000000,
            status: proto.DownloadStatus.DOWNLOADING,
            mediaType: 'magnet',
          ),
          _task(
            taskId: 4,
            title: 'MP4',
            progress: 3000000,
            total: 5000000,
            status: proto.DownloadStatus.DOWNLOADING,
            mediaType: 'mp4',
          ),
        ],
      );

      expect(state.active[0].progress, 50);
      expect(state.active[1].progress, 100000000);
      expect(state.active[2].progress, 50000000);
      expect(state.active[3].progress, 3000000);
    });

    test('torrent appears and disappears in state simulation', () {
      var state = DownloadState(active: []);
      expect(state.active, isEmpty);

      // Tick 1: queued
      state = state.copyWith(
        active: [
          _task(
            taskId: 1,
            title: 'Torrent',
            progress: 0,
            total: 100,
            status: proto.DownloadStatus.QUEUED,
            mediaType: 'torrent',
          ),
        ],
      );
      expect(state.active.length, 1);

      // Tick 2: downloading
      state = state.copyWith(
        active: [
          _task(
            taskId: 1,
            title: 'Torrent',
            progress: 50,
            total: 100,
            status: proto.DownloadStatus.DOWNLOADING,
            mediaType: 'torrent',
          ),
        ],
      );
      expect(state.active[0].progress, 50);

      // Tick 3: failed (retry possible)
      state = state.copyWith(
        active: [
          _task(
            taskId: 1,
            title: 'Torrent',
            progress: 50,
            total: 100,
            status: proto.DownloadStatus.FAILED,
            mediaType: 'torrent',
          ),
        ],
      );
      expect(state.active[0].status, proto.DownloadStatus.FAILED);

      // Tick 4: removed from active after cancellation
      state = state.copyWith(active: []);
      expect(state.active, isEmpty);
    });

    test('mp4 download failure preserves progress', () {
      final state = DownloadState(
        active: [
          _task(
            taskId: 1,
            title: 'Big Buck Bunny MP4',
            progress: 3000000,
            total: 5000000,
            status: proto.DownloadStatus.FAILED,
            mediaType: 'mp4',
          ),
        ],
      );

      expect(state.active[0].progress, 3000000);
      expect(state.active[0].status, proto.DownloadStatus.FAILED);
      expect(state.active[0].mediaType.name, 'mp4');
    });

    test('hls failure preserves progress', () {
      final state = DownloadState(
        active: [
          _task(
            taskId: 1,
            title: 'HLS Episode',
            progress: 75,
            total: 100,
            status: proto.DownloadStatus.FAILED,
            mediaType: 'hls',
          ),
        ],
      );

      expect(state.active[0].progress, 75);
      expect(state.active[0].status, proto.DownloadStatus.FAILED);
    });

    test('torrent failure preserves progress', () {
      final state = DownloadState(
        active: [
          _task(
            taskId: 1,
            title: 'Torrent Episode',
            progress: 50,
            total: 100,
            status: proto.DownloadStatus.FAILED,
            mediaType: 'torrent',
          ),
        ],
      );

      expect(state.active[0].progress, 50);
      expect(state.active[0].status, proto.DownloadStatus.FAILED);
    });

    test('magnet failure preserves progress', () {
      final state = DownloadState(
        active: [
          _task(
            taskId: 1,
            title: 'Magnet Episode',
            progress: 30,
            total: 100,
            status: proto.DownloadStatus.FAILED,
            mediaType: 'magnet',
          ),
        ],
      );

      expect(state.active[0].progress, 30);
      expect(state.active[0].status, proto.DownloadStatus.FAILED);
    });

    test('progress percentage calculation for all media types', () {
      for (final mediaType in ['hls', 'torrent', 'magnet', 'mp4']) {
        final state = DownloadState(
          active: [
            _task(
              taskId: 1,
              title: 'Test $mediaType',
              progress: 3,
              total: 10,
              status: proto.DownloadStatus.DOWNLOADING,
              mediaType: mediaType,
            ),
          ],
        );

        final ratio =
            state.active[0].progress /
            (state.active[0].total == 0 ? 1 : state.active[0].total);
        expect(
          ratio,
          closeTo(0.3, 0.01),
          reason: '$mediaType progress ratio should be ~30%',
        );
      }
    });

    test('total=0 guard prevents division by zero for all media types', () {
      for (final mediaType in ['hls', 'torrent', 'magnet', 'mp4']) {
        final state = DownloadState(
          active: [
            _task(
              taskId: 1,
              title: 'Test $mediaType',
              progress: 0,
              total: 0,
              status: proto.DownloadStatus.QUEUED,
              mediaType: mediaType,
            ),
          ],
        );

        final total = state.active[0].total;
        final ratio = state.active[0].progress / (total == 0 ? 1 : total);
        expect(ratio, 0.0, reason: '$mediaType with total=0 should not crash');
      }
    });
  });

  // =========================================================================
  // 7. Torrent/magnet failure + notification simulation
  // =========================================================================

  group('Torrent/magnet failure notification simulation', () {
    test('torrent failure detected from state transition', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'Big Buck Bunny',
          progress: 50,
          total: 276000000,
          status: proto.DownloadStatus.FAILED,
          mediaType: 'torrent',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 1);
      expect(actions[0].action, 'failed');
      expect(actions[0].title, 'Big Buck Bunny');
      expect(actions[0].mediaType, 'torrent');
    });

    test('magnet failure detected from state transition', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'Big Buck Bunny Magnet',
          progress: 30,
          total: 276000000,
          status: proto.DownloadStatus.FAILED,
          mediaType: 'magnet',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 1);
      expect(actions[0].action, 'failed');
      expect(actions[0].mediaType, 'magnet');
    });

    test('torrent completion detected from state transition', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'Big Buck Bunny',
          progress: 276000000,
          total: 276000000,
          status: proto.DownloadStatus.COMPLETED,
          mediaType: 'torrent',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 1);
      expect(actions[0].action, 'completed');
      expect(actions[0].mediaType, 'torrent');
    });

    test('magnet completion detected from state transition', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'Big Buck Bunny Magnet',
          progress: 276000000,
          total: 276000000,
          status: proto.DownloadStatus.COMPLETED,
          mediaType: 'magnet',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 1);
      expect(actions[0].action, 'completed');
    });

    test('all media type failures trigger notifications', () {
      for (final mediaType in ['hls', 'mp4', 'torrent', 'magnet']) {
        final previousStatuses = <int, proto.DownloadStatus>{
          1: proto.DownloadStatus.DOWNLOADING,
        };
        final tasks = [
          _task(
            taskId: 1,
            title: 'Test $mediaType',
            progress: 50,
            total: 100,
            status: proto.DownloadStatus.FAILED,
            mediaType: mediaType,
          ),
        ];

        final actions = _detectStatusChanges(tasks, previousStatuses);
        expect(
          actions.length,
          1,
          reason: '$mediaType failure should trigger notification',
        );
        expect(actions[0].action, 'failed');
        expect(actions[0].mediaType, mediaType);
      }
    });
  });

  // =========================================================================
  // 8. URL and error logging on failure
  // =========================================================================

  group('URL and error on failure', () {
    test('torrent failure includes URL and error', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'Big Buck Bunny',
          progress: 50,
          total: 276000000,
          status: proto.DownloadStatus.FAILED,
          mediaType: 'torrent',
          url: 'https://example.com/big-buck-bunny.torrent',
          error: 'Write error: disk full',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 1);
      expect(actions[0].action, 'failed');
      expect(actions[0].url, 'https://example.com/big-buck-bunny.torrent');
      expect(actions[0].error, 'Write error: disk full');
    });

    test('magnet failure includes URL and error', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'Big Buck Bunny Magnet',
          progress: 30,
          total: 276000000,
          status: proto.DownloadStatus.FAILED,
          mediaType: 'magnet',
          url: 'magnet:?xt=urn:btih:abc123',
          error: 'Failed to create directory: permission denied',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 1);
      expect(actions[0].url, 'magnet:?xt=urn:btih:abc123');
      expect(actions[0].error, 'Failed to create directory: permission denied');
    });

    test('hls failure includes URL and error', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'HLS Episode',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.FAILED,
          mediaType: 'hls',
          url: 'https://example.com/playlist.m3u8',
          error: 'Error downloading segment: timeout',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 1);
      expect(actions[0].url, 'https://example.com/playlist.m3u8');
      expect(actions[0].error, 'Error downloading segment: timeout');
    });

    test('mp4 failure includes URL and error', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'MP4 Episode',
          progress: 50,
          total: 100,
          status: proto.DownloadStatus.FAILED,
          mediaType: 'mp4',
          url: 'https://example.com/video.mp4',
          error: 'Read torrent error: connection reset',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 1);
      expect(actions[0].url, 'https://example.com/video.mp4');
      expect(actions[0].error, 'Read torrent error: connection reset');
    });

    test('failure with empty URL and error is handled gracefully', () {
      final previousStatuses = <int, proto.DownloadStatus>{
        1: proto.DownloadStatus.DOWNLOADING,
      };
      final tasks = [
        _task(
          taskId: 1,
          title: 'Unknown Failure',
          progress: 0,
          total: 100,
          status: proto.DownloadStatus.FAILED,
          mediaType: 'torrent',
        ),
      ];

      final actions = _detectStatusChanges(tasks, previousStatuses);
      expect(actions.length, 1);
      expect(actions[0].url, isEmpty);
      expect(actions[0].error, isEmpty);
    });
  });
}
