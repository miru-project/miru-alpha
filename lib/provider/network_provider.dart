import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/utils/core/log.dart';

/// A resolved playback source: the variant URL the player loads and the
/// variant map for the manual quality menu.
typedef PlaybackSource = ({Map<String, String> qualityMap, String playbackUrl});

/// Fetches and parses [url]'s HLS manifest ONCE, then decides what the
/// player loads. A multi-variant master playlist collapses to its FIRST
/// media playlist: handing mdk/ffmpeg a master makes them probe EVERY
/// variant on open (all playlists + segments of each bitrate — ~5x the
/// bandwidth and seconds of start delay), while this app switches quality
/// by URL itself. Media playlists, non-HLS urls and any failure come back
/// unchanged.
Future<PlaybackSource> resolvePlayback(
  String url,
  Map<String, dynamic> headers,
) async {
  final fallback = (qualityMap: <String, String>{'': url}, playbackUrl: url);
  final response = await MiruRequest.get(
    url,
    options: Options(headers: headers, responseType: ResponseType.stream),
  );
  final contentType = response.headers.value('content-type')?.toLowerCase();
  if (contentType == null ||
      !contentType.contains('mpegurl') &&
          !contentType.contains('m3u8') &&
          !contentType.contains('mp2t')) {
    return fallback;
  }
  final completer = Completer<String>();

  final stream = response.data.stream;
  final buffer = StringBuffer();
  stream.listen(
    (data) {
      buffer.write(utf8.decode(data));
    },
    onDone: () {
      completer.complete(buffer.toString());
    },
    onError: (error) {
      completer.completeError(error);
    },
  );

  final m3u8Content = await completer.future;
  if (m3u8Content.isEmpty) {
    return fallback;
  }
  late HlsPlaylist playlist;
  try {
    playlist = await HlsPlaylistParser.create().parseString(
      response.realUri,
      m3u8Content,
    );
  } on ParserException catch (e) {
    logger.severe(e);
    return fallback;
  }

  if (playlist is! HlsMasterPlaylist) {
    return fallback;
  }
  final urlList = playlist.mediaPlaylistUrls.map((e) => e.toString()).toList();
  if (urlList.isEmpty) {
    return fallback;
  }
  final resolution = playlist.variants.map(
    (it) => '${it.format.width}x${it.format.height}',
  );
  return (
    qualityMap: Map.fromIterables(resolution, urlList),
    playbackUrl: urlList.first,
  );
}

/// The variant map for the manual quality menu (quality/mirror switches).
Future<Map<String, String>> getQuality(
  String url,
  Map<String, dynamic> headers,
) async => (await resolvePlayback(url, headers)).qualityMap;
