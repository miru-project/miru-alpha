import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/common.pb.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/events.pb.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart';

// Local helper to map a raw media-type string to the proto enum without pulling
// in model.dart (which would collide with the unprefixed proto imports below).
DownloadMediaType _mt(String s) {
  switch (s) {
    case 'hls':
      return DownloadMediaType.hls;
    case 'mp4':
      return DownloadMediaType.mp4;
    case 'torrent':
      return DownloadMediaType.torrent;
    case 'magnet':
      return DownloadMediaType.magnet;
    default:
      return DownloadMediaType.media_type_unspecified;
  }
}

DownloadEvent makeDownloadEvent(
  int taskId,
  String title,
  int progress,
  int total,
  DownloadStatus status,
  String package,
  String key, {
  List<String> names = const [],
  String currentDownloading = '',
  String mediaType = '',
}) {
  final event = DownloadEvent();
  final p = DownloadProgress()
    ..taskId = taskId
    ..title = title
    ..progress = progress
    ..total = total
    ..status = status
    ..package = package
    ..key = key
    ..names.addAll(names)
    ..currentDownloading = currentDownloading
    ..mediaType = _mt(mediaType);
  event.downloadStatus[taskId] = p;
  return event;
}

void main() {
  group('WatchEventsResponse streaming', () {
    test('DownloadEvent with sanitized torrent names round-trips', () {
      final event = WatchEventsResponse(
        downloadEvent: makeDownloadEvent(
          1,
          'Episode with Japanese title',
          50,
          100,
          DownloadStatus.DOWNLOADING,
          'test.pkg',
          'ep1',
          names: ['日本語ファイル.mkv', 'English_File.mp4'],
          currentDownloading: '日本語ファイル.mkv',
        ),
      );

      final buffer = event.writeToBuffer();
      final decoded = WatchEventsResponse.fromBuffer(buffer);

      expect(decoded.hasDownloadEvent(), isTrue);
      final downloadEvent = decoded.downloadEvent;
      expect(downloadEvent.downloadStatus.length, equals(1));

      final progress = downloadEvent.downloadStatus[1]!;
      expect(progress.taskId, equals(1));
      expect(progress.title, equals('Episode with Japanese title'));
      expect(progress.progress, equals(50));
      expect(progress.names.length, equals(2));
      expect(progress.names[0], equals('日本語ファイル.mkv'));
      expect(progress.names[1], equals('English_File.mp4'));
      expect(progress.currentDownloading, equals('日本語ファイル.mkv'));
    });

    test('ExtensionEvent with CJK metadata round-trips', () {
      final event = WatchEventsResponse(
        extensionEvent: ExtensionEvent(
          extensionMeta: [
            ExtensionMeta(
              name: '日本語拡張',
              version: '1.0.0',
              author: '著者',
              license: 'MIT',
              lang: 'ja',
              package: 'jp.example.ext',
              webSite: 'https://example.com',
              description: 'テスト説明',
              tags: ['アニメ', 'ドラマ'],
              api: '2',
              type: 'bangumi',
            ),
          ],
        ),
      );

      final buffer = event.writeToBuffer();
      final decoded = WatchEventsResponse.fromBuffer(buffer);

      expect(decoded.hasExtensionEvent(), isTrue);
      final extEvent = decoded.extensionEvent;
      expect(extEvent.extensionMeta.length, equals(1));

      final meta = extEvent.extensionMeta[0];
      expect(meta.name, equals('日本語拡張'));
      expect(meta.author, equals('著者'));
      expect(meta.description, equals('テスト説明'));
      expect(meta.tags.length, equals(2));
      expect(meta.tags[0], equals('アニメ'));
    });

    test('DevNetworkEvent with binary-like data round-trips', () {
      final event = WatchEventsResponse(
        devNetworkEvent: DevNetworkEvent(
          package: 'test.pkg',
          url: 'https://example.com/api',
          method: 'GET',
          status: 200,
          timestamp: Int64(1234567890),
          responseBody: '{"result": "ok"}',
        ),
      );

      final buffer = event.writeToBuffer();
      final decoded = WatchEventsResponse.fromBuffer(buffer);

      expect(decoded.hasDevNetworkEvent(), isTrue);
      final networkEvent = decoded.devNetworkEvent;
      expect(networkEvent.url, equals('https://example.com/api'));
      expect(networkEvent.status, equals(200));
      expect(networkEvent.responseBody, equals('{"result": "ok"}'));
    });

    test('multiple events stream correctly', () async {
      final controller = StreamController<WatchEventsResponse>();

      final futureEvents = controller.stream.toList();

      controller.add(
        WatchEventsResponse(
          downloadEvent: makeDownloadEvent(
            1,
            'Task 1',
            0,
            100,
            DownloadStatus.DOWNLOADING,
            'pkg1',
            'k1',
          ),
        ),
      );

      controller.add(
        WatchEventsResponse(
          downloadEvent: makeDownloadEvent(
            1,
            'Task 1',
            50,
            100,
            DownloadStatus.DOWNLOADING,
            'pkg1',
            'k1',
          ),
        ),
      );

      controller.add(
        WatchEventsResponse(
          downloadEvent: makeDownloadEvent(
            1,
            'Task 1',
            100,
            100,
            DownloadStatus.COMPLETED,
            'pkg1',
            'k1',
          ),
        ),
      );

      await controller.close();
      final events = await futureEvents;
      expect(events.length, equals(3));
      expect(events[0].downloadEvent.downloadStatus[1]!.progress, equals(0));
      expect(events[1].downloadEvent.downloadStatus[1]!.progress, equals(50));
      expect(events[2].downloadEvent.downloadStatus[1]!.progress, equals(100));
      expect(
        events[2].downloadEvent.downloadStatus[1]!.status,
        equals(DownloadStatus.COMPLETED),
      );
    });
  });

  group('DownloadProgress torrent data', () {
    test('progress with torrent file names serializes correctly', () {
      final progress = DownloadProgress(
        taskId: 42,
        title: '[SubGroup] 日本語アニメ 第01話',
        progress: 500000,
        total: 1000000,
        status: DownloadStatus.DOWNLOADING,
        package: 'anime.pkg',
        key: 'AABBCCDD11223344',
        names: ['[SubGroup] 日本語アニメ 第01話/[SubGroup]_EP01.mkv'],
        currentDownloading: '[SubGroup] 日本語アニメ 第01話/[SubGroup]_EP01.mkv',
        mediaType: DownloadMediaType.torrent,
      );

      final buffer = progress.writeToBuffer();
      final decoded = DownloadProgress.fromBuffer(buffer);

      expect(decoded.taskId, equals(42));
      expect(decoded.names.length, equals(1));
      expect(
        decoded.names[0],
        equals('[SubGroup] 日本語アニメ 第01話/[SubGroup]_EP01.mkv'),
      );
      expect(
        decoded.currentDownloading,
        equals('[SubGroup] 日本語アニメ 第01話/[SubGroup]_EP01.mkv'),
      );
      expect(decoded.progress, equals(500000));
      expect(decoded.total, equals(1000000));
    });
  });

  group('ExtensionBangumiWatchTorrent URL construction', () {
    test('builds correct torrent data URL for video player', () {
      const baseUrl = 'http://127.0.0.1:3000';
      const infoHash = 'AABBCCDD11223344';

      final torrent = ExtensionBangumiWatchTorrent()
        ..infoHash = infoHash
        ..detail = (ExtensionBangumiWatchTorrentDetail()
          ..name = 'Test Anime'
          ..length = Int64(2147483648))
        ..files.addAll([
          'Test Anime/Episode 01.mkv',
          'Test Anime/subs/eng.ass',
        ]);

      const videoExtensions = [
        'mp4',
        'webm',
        'ogg',
        'flv',
        'mov',
        'ts',
        '3gp',
        'avi',
        'wmv',
        'mkv',
        'mpg',
        'mpeg',
        'm4v',
        'mvp',
        'flac',
        'mp3',
        'wav',
        'm4a',
      ];

      String? streamUrl;
      for (final file in torrent.files) {
        final ext = file.split('.').last.toLowerCase();
        if (videoExtensions.contains(ext)) {
          streamUrl =
              '$baseUrl/torrent/data/$infoHash/${Uri.encodeComponent(file)}';
          break;
        }
      }

      expect(streamUrl, isNotNull);
      expect(
        streamUrl,
        equals(
          'http://127.0.0.1:3000/torrent/data/AABBCCDD11223344'
          '/Test%20Anime%2FEpisode%2001.mkv',
        ),
      );
    });

    test('handles torrent with CJK filenames correctly', () {
      const baseUrl = 'http://127.0.0.1:3000';
      const infoHash = 'CJK12345';

      final torrent = ExtensionBangumiWatchTorrent()
        ..infoHash = infoHash
        ..detail = (ExtensionBangumiWatchTorrentDetail()
          ..name = '日本語アニメ'
          ..length = Int64(1000000))
        ..files.addAll(['日本語アニメ/第01話.mkv', '日本語アニメ/字幕/eng.ass']);

      const videoExtensions = [
        'mp4',
        'webm',
        'ogg',
        'flv',
        'mov',
        'ts',
        '3gp',
        'avi',
        'wmv',
        'mkv',
        'mpg',
        'mpeg',
        'm4v',
        'mvp',
        'flac',
        'mp3',
        'wav',
        'm4a',
      ];

      String? streamUrl;
      for (final file in torrent.files) {
        final ext = file.split('.').last.toLowerCase();
        if (videoExtensions.contains(ext)) {
          streamUrl =
              '$baseUrl/torrent/data/$infoHash/${Uri.encodeComponent(file)}';
          break;
        }
      }

      expect(streamUrl, isNotNull);
      expect(streamUrl, contains('CJK12345'));
    });

    test('torrent with single file (no directory structure)', () {
      const baseUrl = 'http://127.0.0.1:3000';
      const infoHash = 'SINGLE';

      final torrent = ExtensionBangumiWatchTorrent()
        ..infoHash = infoHash
        ..detail = (ExtensionBangumiWatchTorrentDetail()
          ..name = 'single_video.mp4'
          ..length = Int64(500000))
        ..files.addAll(['single_video.mp4']);

      const videoExtensions = [
        'mp4',
        'webm',
        'ogg',
        'flv',
        'mov',
        'ts',
        '3gp',
        'avi',
        'wmv',
        'mkv',
        'mpg',
        'mpeg',
        'm4v',
        'mvp',
        'flac',
        'mp3',
        'wav',
        'm4a',
      ];

      String? streamUrl;
      for (final file in torrent.files) {
        final ext = file.split('.').last.toLowerCase();
        if (videoExtensions.contains(ext)) {
          streamUrl =
              '$baseUrl/torrent/data/$infoHash/${Uri.encodeComponent(file)}';
          break;
        }
      }

      expect(streamUrl, isNotNull);
      expect(
        streamUrl,
        equals('http://127.0.0.1:3000/torrent/data/SINGLE/single_video.mp4'),
      );
    });
  });

  group('WatchEvents streaming with sanitized torrent data', () {
    test(
      'stream of download events with CJK torrent names maintains order',
      () async {
        final controller = StreamController<WatchEventsResponse>();

        final futureEvents = controller.stream.toList();

        for (var progress = 0; progress <= 100; progress += 50) {
          final epNum = progress ~/ 50 + 1;
          controller.add(
            WatchEventsResponse(
              downloadEvent: makeDownloadEvent(
                1,
                '[SubGroup] 日本語アニメ EP0$epNum',
                progress,
                100,
                progress < 100
                    ? DownloadStatus.DOWNLOADING
                    : DownloadStatus.COMPLETED,
                'anime.pkg',
                'AABBCCDD',
                names: ['[SubGroup] 日本語アニメ/EP0$epNum.mkv'],
                currentDownloading: '[SubGroup] 日本語アニメ/EP0$epNum.mkv',
                mediaType: 'torrent',
              ),
            ),
          );
        }

        await controller.close();
        final events = await futureEvents;
        expect(events.length, equals(3));

        for (final event in events) {
          final buffer = event.writeToBuffer();
          final decoded = WatchEventsResponse.fromBuffer(buffer);

          expect(decoded.hasDownloadEvent(), isTrue);
          final progress = decoded.downloadEvent.downloadStatus[1]!;
          expect(progress.names[0], contains('日本語アニメ'));
        }
      },
    );

    test('DownloadEvent with special characters in torrent filenames', () {
      final event = WatchEventsResponse(
        downloadEvent: makeDownloadEvent(
          1,
          '[SubGroup] 日本語 - 01 [1080p] (CRC32)',
          50,
          100,
          DownloadStatus.DOWNLOADING,
          'test.pkg',
          'AABB',
          names: [
            '[SubGroup] 日本語 - 01 [1080p] (CRC32)/[SubGroup]_EP01.mkv',
            '[SubGroup] 日本語 - 01 [1080p] (CRC32)/[SubGroup]_EP01.ass',
          ],
          currentDownloading:
              '[SubGroup] 日本語 - 01 [1080p] (CRC32)/[SubGroup]_EP01.mkv',
          mediaType: 'torrent',
        ),
      );

      final buffer = event.writeToBuffer();
      final decoded = WatchEventsResponse.fromBuffer(buffer);

      expect(decoded.hasDownloadEvent(), isTrue);
      final progress = decoded.downloadEvent.downloadStatus[1]!;
      expect(progress.names.length, equals(2));
      expect(
        progress.names[0],
        equals('[SubGroup] 日本語 - 01 [1080p] (CRC32)/[SubGroup]_EP01.mkv'),
      );
      expect(
        progress.currentDownloading,
        equals('[SubGroup] 日本語 - 01 [1080p] (CRC32)/[SubGroup]_EP01.mkv'),
      );
    });
  });

  group('Torrent URL construction with sanitized invalid UTF-8 filenames', () {
    test('sanitized torrent filenames produce valid URL components', () {
      const baseUrl = 'http://127.0.0.1:3000';
      const infoHash = 'SANITIZED123';

      final torrent = ExtensionBangumiWatchTorrent()
        ..infoHash = infoHash
        ..detail = (ExtensionBangumiWatchTorrentDetail()
          ..name = 'テスト\ufffdアニメ'
          ..length = Int64(1000000))
        ..files.addAll([
          'テスト\ufffdアニメ/EP01.mkv',
          'テスト\ufffdアニメ/字幕/eng.ass',
          'bad\ufffdfile.mkv',
        ]);

      const videoExtensions = [
        'mp4',
        'webm',
        'ogg',
        'flv',
        'mov',
        'ts',
        '3gp',
        'avi',
        'wmv',
        'mkv',
        'mpg',
        'mpeg',
        'm4v',
        'mvp',
        'flac',
        'mp3',
        'wav',
        'm4a',
      ];

      String? streamUrl;
      for (final file in torrent.files) {
        final ext = file.split('.').last.toLowerCase();
        if (videoExtensions.contains(ext)) {
          streamUrl =
              '$baseUrl/torrent/data/$infoHash/${Uri.encodeComponent(file)}';
          break;
        }
      }

      expect(streamUrl, isNotNull);
      final parsed = Uri.parse(streamUrl!);
      expect(parsed.hasAbsolutePath, isTrue);
      expect(parsed.path, contains('SANITIZED123'));
      expect(streamUrl, contains('%EF%BF%BD'));
    });

    test('torrent with only non-video files returns no stream URL', () {
      const baseUrl = 'http://127.0.0.1:3000';
      const infoHash = 'NOVIDEO';

      final torrent = ExtensionBangumiWatchTorrent()
        ..infoHash = infoHash
        ..detail = (ExtensionBangumiWatchTorrentDetail()
          ..name = 'Test Torrent'
          ..length = Int64(100000))
        ..files.addAll(['Subs/eng.ass', 'README.txt', 'cover.jpg']);

      const videoExtensions = [
        'mp4',
        'webm',
        'ogg',
        'flv',
        'mov',
        'ts',
        '3gp',
        'avi',
        'wmv',
        'mkv',
        'mpg',
        'mpeg',
        'm4v',
        'mvp',
        'flac',
        'mp3',
        'wav',
        'm4a',
      ];

      String? streamUrl;
      for (final file in torrent.files) {
        final ext = file.split('.').last.toLowerCase();
        if (videoExtensions.contains(ext)) {
          streamUrl =
              '$baseUrl/torrent/data/$infoHash/${Uri.encodeComponent(file)}';
          break;
        }
      }

      expect(streamUrl, isNull);
    });

    test('multiple video files picks first video file', () {
      const baseUrl = 'http://127.0.0.1:3000';
      const infoHash = 'MULTI';

      final torrent = ExtensionBangumiWatchTorrent()
        ..infoHash = infoHash
        ..detail = (ExtensionBangumiWatchTorrentDetail()
          ..name = 'Multi Video'
          ..length = Int64(2000000))
        ..files.addAll([
          'Bonus/preview.mp4',
          'Main/episode01.mkv',
          'Main/episode02.mkv',
        ]);

      const videoExtensions = [
        'mp4',
        'webm',
        'ogg',
        'flv',
        'mov',
        'ts',
        '3gp',
        'avi',
        'wmv',
        'mkv',
        'mpg',
        'mpeg',
        'm4v',
        'mvp',
        'flac',
        'mp3',
        'wav',
        'm4a',
      ];

      String? streamUrl;
      for (final file in torrent.files) {
        final ext = file.split('.').last.toLowerCase();
        if (videoExtensions.contains(ext)) {
          streamUrl =
              '$baseUrl/torrent/data/$infoHash/${Uri.encodeComponent(file)}';
          break;
        }
      }

      expect(streamUrl, isNotNull);
      expect(streamUrl, contains('preview.mp4'));
      expect(streamUrl, contains('MULTI'));
    });
  });
}
