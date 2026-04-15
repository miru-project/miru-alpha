import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/utils/core/log.dart';

Future<Map<String, String>> getQuality(
  String url,
  Map<String, dynamic> headers,
) async {
  final defaultRes = <String, String>{"": url};
  final response = await dio.get(
    url,
    options: Options(headers: headers, responseType: ResponseType.stream),
  );
  final contentType = response.headers.value('content-type')?.toLowerCase();
  if (contentType == null ||
      !contentType.contains('mpegurl') &&
          !contentType.contains('m3u8') &&
          !contentType.contains('mp2t')) {
    return defaultRes;
  }
  final completer = Completer<String>();

  final stream = response.data.stream;
  final buffer = StringBuffer();
  stream.listen(
    (data) {
      buffer.write(utf8.decode(data));
    },
    onDone: () {
      final m3u8Content = buffer.toString();
      completer.complete(m3u8Content);
    },
    onError: (error) {
      completer.completeError(error);
    },
  );

  final m3u8Content = await completer.future;
  if (m3u8Content.isEmpty) {
    return defaultRes;
  }
  late HlsPlaylist playlist;
  try {
    playlist = await HlsPlaylistParser.create().parseString(
      response.realUri,
      m3u8Content,
    );
  } on ParserException catch (e) {
    logger.severe(e);
    return defaultRes;
  }

  if (playlist is HlsMasterPlaylist) {
    final urlList = playlist.mediaPlaylistUrls
        .map((e) => e.toString())
        .toList();
    final resolution = playlist.variants.map(
      (it) => "${it.format.width}x${it.format.height}",
    );
    final qualityMap = <String, String>{};
    qualityMap.addAll(Map.fromIterables(resolution, urlList));
    return qualityMap;
  }
  return defaultRes;
}
