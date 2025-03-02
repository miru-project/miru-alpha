import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miru_app_new/utils/log.dart';
import 'package:miru_app_new/utils/network/index.dart';
import 'package:miru_app_new/utils/network/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_app_new/utils/extension/extension_service.dart';
import 'package:miru_app_new/model/index.dart';

part 'network_provider.g.dart';

@riverpod
Future<ExtensionBangumiWatch> videoLoad(
  Ref ref,
  String url,
  ExtensionApiV1 service,
) async {
  final result = await service.watch(url) as ExtensionBangumiWatch;
  return result;
}

@riverpod
Future<List<GithubExtension>> fetchExtensionRepo(Ref ref) async {
  final result = await GithubNetwork.fetchRepo();
  return result;
}

@riverpod
Future<ExtensionDetail> fetchExtensionDetail(
  Ref ref,
  ExtensionApiV1 extensionService,
  String url,
) async {
  final result = await extensionService.detail(url);
  return result;
}

@riverpod
Future<List<ExtensionListItem>> fetchExtensionLatest(
  Ref ref,
  ExtensionApiV1 extensionService,
  int page,
) async {
  final result = await extensionService.latest(page);
  debugPrint('fetchExtensionLatest: ${extensionService.extension.name}');
  return result;
}

@riverpod
Future<List<ExtensionListItem>> fetchExtensionSearch(
  Ref ref,
  ExtensionApiV1 extensionService,
  String query,
  int page, {
  Map<String, List<String>>? filter,
}) async {
  final result = await extensionService.search(query, page, filter: filter);
  return result;
}

@riverpod
Future<ExtensionMangaWatch> mangaLoad(
  Ref ref,
  String url,
  ExtensionApiV1 service,
) async {
  final result = await service.watch(url) as ExtensionMangaWatch;
  return result;
}

@riverpod
Future<ExtensionFikushonWatch> fikushonLoad(
  Ref ref,
  String url,
  ExtensionApiV1 service,
) async {
  final result = await service.watch(url) as ExtensionFikushonWatch;
  return result;
}

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
    final urlList =
        playlist.mediaPlaylistUrls.map((e) => e.toString()).toList();
    final resolution = playlist.variants.map(
      (it) => "${it.format.width}x${it.format.height}",
    );
    final qualityMap = <String, String>{};
    qualityMap.addAll(Map.fromIterables(resolution, urlList));
    return qualityMap;
  }
  return defaultRes;
}
