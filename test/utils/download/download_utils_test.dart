import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/utils/download/download_utils.dart';
import 'package:path/path.dart' as p;

void main() {
  group('DownloadUtils.categoryFolder', () {
    test('maps content categories to user-facing folder names', () {
      expect(
        DownloadUtils.categoryFolder(proto.DownloadCategory.video),
        'Bangumi',
      );
      expect(
        DownloadUtils.categoryFolder(proto.DownloadCategory.manga),
        'Manga',
      );
      expect(
        DownloadUtils.categoryFolder(proto.DownloadCategory.novel),
        'Fikushon',
      );
      expect(
        DownloadUtils.categoryFolder(proto.DownloadCategory.unspecified),
        'Other',
      );
    });
  });

  group('DownloadUtils.filter', () {
    test('removes illegal filename characters', () {
      expect(DownloadUtils.filter('test<>:"/\\|?*file'), 'testfile');
      expect(
        DownloadUtils.filter('normal_file-2024.mp4'),
        'normal_file-2024.mp4',
      );
    });
  });

  group('DownloadUtils.buildTargetPath', () {
    test('builds nested path category/package/title/episode', () {
      final path = DownloadUtils.buildTargetPath(
        root: '/downloads',
        category: proto.DownloadCategory.video,
        package: 'nyaa',
        title: 'My Show',
        epKey: 'Ep 1',
        extension: '.mp4',
      );
      expect(
        path,
        equals(p.join('/downloads', 'Bangumi', 'nyaa', 'My Show', 'Ep 1.mp4')),
      );
    });

    test('omits epGroup when null or empty', () {
      final withGroup = DownloadUtils.buildTargetPath(
        root: '/d',
        category: proto.DownloadCategory.manga,
        package: 'pkg',
        title: 'Title',
        epGroup: 'Season 1',
        epKey: 'Ch 1',
        extension: '.png',
      );
      final withoutGroup = DownloadUtils.buildTargetPath(
        root: '/d',
        category: proto.DownloadCategory.manga,
        package: 'pkg',
        title: 'Title',
        epGroup: '',
        epKey: 'Ch 1',
        extension: '.png',
      );
      expect(
        withGroup,
        equals(p.join('/d', 'Manga', 'pkg', 'Title', 'Season 1', 'Ch 1.png')),
      );
      expect(
        withoutGroup,
        equals(p.join('/d', 'Manga', 'pkg', 'Title', 'Ch 1.png')),
      );
    });

    test('sanitizes each segment via filter', () {
      final path = DownloadUtils.buildTargetPath(
        root: '/d',
        category: proto.DownloadCategory.novel,
        package: 'pkg/a',
        title: 'Ti:tle',
        epKey: 'ep*1',
        extension: '.txt',
      );
      // 'pkg/a' -> 'pkga', 'Ti:tle' -> 'Title', 'ep*1' -> 'ep1'
      expect(
        path,
        equals(p.join('/d', 'Fikushon', 'pkga', 'Title', 'ep1.txt')),
      );
    });

    test('falls back to episode name when epKey is empty after filter', () {
      final path = DownloadUtils.buildTargetPath(
        root: '/d',
        category: proto.DownloadCategory.unspecified,
        package: 'pkg',
        title: 'Title',
        epKey: '***',
        extension: '.mp4',
      );
      expect(
        path,
        equals(p.join('/d', 'Other', 'pkg', 'Title', 'episode.mp4')),
      );
    });
  });

  group('DownloadUtils.handleFile', () {
    test('returns nested target and creates parent dirs (non-HLS)', () async {
      final root = Directory.systemTemp.createTempSync('test_handle_');
      final current = File(p.join(root.path, 'video.ts'))..createSync();
      try {
        final result = await DownloadUtils.handleFile(
          taskId: '1',
          currentPath: current.path,
          targetDir: root.path,
          isHls: false,
          title: 'My Video',
          category: proto.DownloadCategory.video,
          package: 'pkg',
          epKey: 'ep1',
        );
        expect(
          result,
          equals(p.join(root.path, 'Bangumi', 'pkg', 'My Video', 'ep1.ts')),
        );
        expect(await Directory(p.dirname(result)).exists(), isTrue);
      } finally {
        root.deleteSync(recursive: true);
      }
    });

    test('uses mp4 extension for HLS', () async {
      final root = Directory.systemTemp.createTempSync('test_handle_');
      try {
        final result = await DownloadUtils.handleFile(
          taskId: '2',
          currentPath: '${root.path}/dir',
          targetDir: root.path,
          isHls: true,
          title: 'HLS Show',
          category: proto.DownloadCategory.video,
          package: 'pkg',
          epKey: 'ep1',
        );
        expect(result, endsWith('.mp4'));
        expect(result, contains('HLS Show'));
      } finally {
        root.deleteSync(recursive: true);
      }
    });

    test('uses mp4 extension when current has no extension', () async {
      final root = Directory.systemTemp.createTempSync('test_handle_');
      try {
        final result = await DownloadUtils.handleFile(
          taskId: '3',
          currentPath: '/some/file',
          targetDir: root.path,
          isHls: false,
          title: 'No Extension',
          category: proto.DownloadCategory.video,
          package: 'pkg',
          epKey: 'ep1',
        );
        expect(result, endsWith('.mp4'));
      } finally {
        root.deleteSync(recursive: true);
      }
    });

    test('throws when target directory is empty', () {
      expect(
        () => DownloadUtils.handleFile(
          taskId: '4',
          currentPath: '/file',
          targetDir: '',
          isHls: false,
          title: 'Title',
          category: proto.DownloadCategory.video,
          package: 'pkg',
          epKey: 'ep1',
        ),
        throwsException,
      );
    });
  });

  group('DownloadUtils.safeDeletePath (temp cleanup)', () {
    test('removes a file and its now-empty parent dir', () {
      final dir = Directory.systemTemp.createTempSync('test_clean_');
      final file = File(p.join(dir.path, 'seg.ts'))..createSync();
      DownloadUtils.safeDeletePath(file.path);
      expect(file.existsSync(), isFalse);
      expect(dir.existsSync(), isFalse);
    });

    test('removes an HLS segment directory recursively', () {
      final dir = Directory.systemTemp.createTempSync('test_clean_');
      File(p.join(dir.path, 'a.ts')).createSync();
      File(p.join(dir.path, 'b.ts')).createSync();
      DownloadUtils.safeDeletePath(dir.path);
      expect(dir.existsSync(), isFalse);
    });

    test('ignores a missing path without throwing', () {
      expect(
        () => DownloadUtils.safeDeletePath('/nonexistent/path/xyz'),
        returnsNormally,
      );
    });
  });

  group('DownloadUtils.statusToI18N', () {
    test('returns non-empty i18n keys for all statuses', () {
      final statusMap = {
        proto.DownloadStatus.QUEUED: 'download.status.queued',
        proto.DownloadStatus.DOWNLOADING: 'download.status.downloading',
        proto.DownloadStatus.PAUSED: 'download.status.paused',
        proto.DownloadStatus.COMPLETED: 'download.status.completed',
        proto.DownloadStatus.FAILED: 'download.status.failed',
        proto.DownloadStatus.CANCELLED: 'download.status.cancelled',
        proto.DownloadStatus.CONVERTING: 'download.status.converting',
      };
      for (final entry in statusMap.entries) {
        expect(
          DownloadUtils.statusToI18N(entry.key),
          entry.value,
          reason: 'Status ${entry.key} should map to ${entry.value}',
        );
      }
    });
  });
}
