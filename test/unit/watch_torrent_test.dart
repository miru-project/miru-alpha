import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;
import 'package:miru_alpha/domain/models/watch.dart';
import 'package:miru_alpha/model/watch_result.dart';

void main() {
  group('ExtensionBangumiWatchTorrent protobuf serialization', () {
    test('round-trips valid UTF-8 torrent data', () {
      final torrent = pb_extension.ExtensionBangumiWatchTorrent()
        ..infoHash = 'ABCDEF1234567890ABCDEF1234567890ABCDEF12'
        ..detail = (pb_extension.ExtensionBangumiWatchTorrentDetail()
          ..pieceLength = 262144
          ..name = 'Example Anime S01'
          ..length = Int64(1073741824))
        ..files.addAll([
          'Example Anime S01/Episode 01.mkv',
          'Example Anime S01/Episode 02.mkv',
          'Example Anime S01/subtitle_en.ass',
        ]);

      final buffer = torrent.writeToBuffer();
      final decoded = pb_extension.ExtensionBangumiWatchTorrent.fromBuffer(
        buffer,
      );

      expect(
        decoded.infoHash,
        equals('ABCDEF1234567890ABCDEF1234567890ABCDEF12'),
      );
      expect(decoded.files.length, equals(3));
      expect(decoded.files[0], equals('Example Anime S01/Episode 01.mkv'));
      expect(decoded.files[1], equals('Example Anime S01/Episode 02.mkv'));
      expect(decoded.files[2], equals('Example Anime S01/subtitle_en.ass'));
    });

    test('round-trips CJK UTF-8 torrent filenames', () {
      final torrent = pb_extension.ExtensionBangumiWatchTorrent()
        ..infoHash = 'DEADBEEF1234567890ABCDEF1234567890ABCDEF'
        ..detail = (pb_extension.ExtensionBangumiWatchTorrentDetail()
          ..pieceLength = 262144
          ..name = '日本語アニメ'
          ..length = Int64(2147483648))
        ..files.addAll([
          '日本語アニメ/第01話.mkv',
          '日本語アニメ/第02話.mkv',
          '日本語アニメ/字幕_ja.ass',
        ]);

      final buffer = torrent.writeToBuffer();
      final decoded = pb_extension.ExtensionBangumiWatchTorrent.fromBuffer(
        buffer,
      );

      expect(
        decoded.infoHash,
        equals('DEADBEEF1234567890ABCDEF1234567890ABCDEF'),
      );
      expect(decoded.files.length, equals(3));
      expect(decoded.files[0], equals('日本語アニメ/第01話.mkv'));
      expect(decoded.detail.name, equals('日本語アニメ'));
    });

    test('empty files list serializes correctly', () {
      final torrent = pb_extension.ExtensionBangumiWatchTorrent()
        ..infoHash = 'AABB'
        ..detail = (pb_extension.ExtensionBangumiWatchTorrentDetail()
          ..name = 'single_file'
          ..length = Int64(100));

      final buffer = torrent.writeToBuffer();
      final decoded = pb_extension.ExtensionBangumiWatchTorrent.fromBuffer(
        buffer,
      );

      expect(decoded.files.length, equals(0));
      expect(decoded.infoHash, equals('AABB'));
    });
  });

  group('ExtensionBangumiWatch protobuf with torrent', () {
    test('watch response carries torrent metadata', () {
      final watch = pb_extension.ExtensionBangumiWatch()
        ..type = 'torrent'
        ..url = 'magnet:?xt=urn:btih:ABCDEF1234567890'
        ..headers['Referer'] = 'https://example.com'
        ..torrent = (pb_extension.ExtensionBangumiWatchTorrent()
          ..infoHash = 'ABCDEF1234567890ABCDEF1234567890ABCDEF12'
          ..detail = (pb_extension.ExtensionBangumiWatchTorrentDetail()
            ..name = 'Test Torrent'
            ..length = Int64(5000000))
          ..files.addAll(['file1.mp4', 'file2.mkv']));

      final buffer = watch.writeToBuffer();
      final decoded = pb_extension.ExtensionBangumiWatch.fromBuffer(buffer);

      expect(decoded.type, equals('torrent'));
      expect(decoded.url, contains('magnet:'));
      expect(decoded.hasTorrent(), isTrue);
      expect(
        decoded.torrent.infoHash,
        equals('ABCDEF1234567890ABCDEF1234567890ABCDEF12'),
      );
      expect(decoded.torrent.files.length, equals(2));
      expect(decoded.torrent.files[0], equals('file1.mp4'));
      expect(decoded.headers['Referer'], equals('https://example.com'));
    });

    test('watch response without torrent (plain stream)', () {
      final watch = pb_extension.ExtensionBangumiWatch()
        ..type = 'hls'
        ..url = 'https://stream.example.com/index.m3u8'
        ..headers['User-Agent'] = 'Mozilla/5.0';

      final buffer = watch.writeToBuffer();
      final decoded = pb_extension.ExtensionBangumiWatch.fromBuffer(buffer);

      expect(decoded.type, equals('hls'));
      expect(decoded.hasTorrent(), isFalse);
      expect(decoded.url, contains('.m3u8'));
    });
  });

  group('WatchEventsResponse streaming deserialization', () {
    test('DownloadEvent with torrent progress deserializes correctly', () {
      final response = pb_extension.ExtensionBangumiWatch()
        ..type = 'torrent'
        ..url = 'magnet:?xt=urn:btih:TEST'
        ..torrent = (pb_extension.ExtensionBangumiWatchTorrent()
          ..infoHash = 'TESTHASH'
          ..detail = (pb_extension.ExtensionBangumiWatchTorrentDetail()
            ..name = 'Episode 1'
            ..length = Int64(1024000))
          ..files.addAll(['ep1.mkv', 'ep1_sub.ass']));

      final watchResult = WatchResult(data: response);
      expect(watchResult.data, isA<pb_extension.ExtensionBangumiWatch>());

      final bangumiWatch =
          watchResult.data as pb_extension.ExtensionBangumiWatch;
      expect(bangumiWatch.type, equals('torrent'));
      expect(bangumiWatch.torrent.files.length, equals(2));
      expect(bangumiWatch.torrent.files[0], equals('ep1.mkv'));
      expect(bangumiWatch.torrent.files[1], equals('ep1_sub.ass'));
    });
  });

  group('DomainBangumiTorrent.fromProto', () {
    test('converts torrent proto to domain model', () {
      final torrent = pb_extension.ExtensionBangumiWatchTorrent()
        ..infoHash = 'DEAD1234'
        ..detail = (pb_extension.ExtensionBangumiWatchTorrentDetail()
          ..pieceLength = 256000
          ..name = 'Anime Series'
          ..length = Int64(5000000)
          ..nameUtf8 = 'Anime Series'
          ..source = 'example.com'
          ..metaVersion = 1)
        ..files.addAll([
          'Anime Series/ep01.mkv',
          'Anime Series/ep02.mkv',
          'Anime Series/cover.jpg',
        ]);

      final domain = DomainBangumiTorrent.fromProto(torrent);

      expect(domain.infoHash, equals('DEAD1234'));
      expect(domain.files?.length, equals(3));
      expect(domain.files?[0], equals('Anime Series/ep01.mkv'));
      expect(domain.detail.name, equals('Anime Series'));
      expect(domain.detail.pieceLength, equals(256000));
      expect(domain.detail.length, equals(5000000));
    });

    test('converts torrent with empty files to null files list', () {
      final torrent = pb_extension.ExtensionBangumiWatchTorrent()
        ..infoHash = 'SINGLE'
        ..detail = (pb_extension.ExtensionBangumiWatchTorrentDetail()
          ..name = 'single'
          ..length = Int64(100));

      final domain = DomainBangumiTorrent.fromProto(torrent);

      expect(domain.files, isNull);
    });
  });

  group('DomainBangumiWatch.fromProto', () {
    test('converts bangumi watch with torrent to domain model', () {
      final protoWatch = pb_extension.ExtensionBangumiWatch()
        ..type = 'torrent'
        ..url = 'magnet:?xt=urn:btih:AA'
        ..headers['Referer'] = 'https://example.com'
        ..torrent = (pb_extension.ExtensionBangumiWatchTorrent()
          ..infoHash = 'AA'
          ..detail = (pb_extension.ExtensionBangumiWatchTorrentDetail()
            ..name = 'Test'
            ..length = Int64(500))
          ..files.addAll(['ep1.mkv']))
        ..subtitles.addAll([
          pb_extension.ExtensionBangumiWatchSubtitle()
            ..language = 'en'
            ..title = 'English'
            ..url = 'https://sub.example.com/en.vtt',
        ]);

      final domain = DomainBangumiWatch.fromProto(protoWatch);

      expect(domain.type, equals('torrent'));
      expect(domain.url, contains('magnet:'));
      expect(domain.torrent, isNotNull);
      expect(domain.torrent!.infoHash, equals('AA'));
      expect(domain.torrent!.files, equals(['ep1.mkv']));
      expect(domain.subtitles?.length, equals(1));
      expect(domain.subtitles?[0].language, equals('en'));
    });
  });

  group('Torrent URL construction', () {
    test('constructs correct torrent data URL', () {
      const baseUrl = 'http://127.0.0.1:3000';
      const infoHash = 'ABCDEF1234567890';
      const fileName = 'episode01.mkv';

      final encodedFile = Uri.encodeComponent(fileName);
      final url = '$baseUrl/torrent/data/$infoHash/$encodedFile';

      expect(
        url,
        equals(
          'http://127.0.0.1:3000/torrent/data/ABCDEF1234567890/episode01.mkv',
        ),
      );
    });

    test('constructs torrent URL with CJK filename', () {
      const baseUrl = 'http://127.0.0.1:3000';
      const infoHash = 'DEADBEEF';
      const fileName = '第01話.mkv';

      final encodedFile = Uri.encodeComponent(fileName);
      final url = '$baseUrl/torrent/data/$infoHash/$encodedFile';

      expect(url, contains('DEADBEEF'));
      expect(url, contains(encodedFile));
      // Uri.encodeComponent preserves CJK characters (they are valid URI chars)
      expect(
        url,
        equals(
          'http://127.0.0.1:3000/torrent/data/DEADBEEF/${Uri.encodeComponent(fileName)}',
        ),
      );
    });

    test('constructs torrent URL with special characters', () {
      const baseUrl = 'http://127.0.0.1:3000';
      const infoHash = 'AABB';
      const fileName = '[SubGroup] Anime - 01 [1080p].mkv';

      final encodedFile = Uri.encodeComponent(fileName);
      final url = '$baseUrl/torrent/data/$infoHash/$encodedFile';

      expect(url, contains('AABB'));
      expect(url, contains(encodedFile));
      // The encoded URL should be parseable
      final parsed = Uri.parse(url);
      expect(parsed.hasAbsolutePath, isTrue);
    });

    test('finds video file from torrent files list', () {
      final files = [
        'Subs/[SubGroup] ep01.ass',
        'Video/ep01.mkv',
        'README.txt',
      ];

      const videoExtensions = ['mp4', 'webm', 'ogg', 'flv', 'mov', 'ts', 'mkv'];

      String? videoUrl;
      for (final file in files) {
        final ext = file.split('.').last.toLowerCase();
        if (videoExtensions.contains(ext)) {
          videoUrl = file;
          break;
        }
      }

      expect(videoUrl, isNotNull);
      expect(videoUrl, equals('Video/ep01.mkv'));
    });

    test('skips non-video files in torrent', () {
      final files = ['Subs/[SubGroup] ep01.ass', 'README.txt', 'cover.jpg'];

      const videoExtensions = ['mp4', 'webm', 'ogg', 'flv', 'mov', 'ts', 'mkv'];

      String? videoUrl;
      for (final file in files) {
        final ext = file.split('.').last.toLowerCase();
        if (videoExtensions.contains(ext)) {
          videoUrl = file;
          break;
        }
      }

      expect(videoUrl, isNull);
    });
  });
}
