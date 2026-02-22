import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:miru_app_new/miru_core/grpc_client.dart';
import 'package:miru_app_new/miru_core/network.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/utils/network/index.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/miru_core/proto/proto.dart' as proto;
part 'network_provider.g.dart';

@riverpod
Future<Object> watch(
  Ref ref,
  String watchUrl,
  String detailUrl,
  String pkg,
  ExtensionType type,
) async {
  try {
    final downloaded = await MiruGrpcClient.downloadClient
        .getDownloadByPackageWatchUrlDetailUrl(
          proto.GetDownloadByPackageWatchUrlDetailUrlRequest(
            package: pkg,
            watchUrl: watchUrl,
            detailUrl: detailUrl,
          ),
        );
    final savePath = downloaded.download.savePath;
    final isExists = File(savePath).existsSync();
    if (isExists) {
      return downloaded.download;
    }
    throw Exception('Download file not found');
  } catch (e) {
    final result = await MiruCoreEndpoint.watch(watchUrl, pkg, type);
    return result;
  }
}

@riverpod
Future<List<ExtensionRepo>> fetchExtensionRepo(Ref ref) async {
  final result = await GithubNetwork.fetchRepo();
  return result;
}

Future<Detail?> fetchDetailFromExtension(String pkg, String url) async {
  final data = await MiruCoreEndpoint.detail(pkg, url);

  await MiruCoreEndpoint.upsertDbDetail(data);
  return data;
}

Future<Detail?> fetchDetailFromDb(String pkg, String detailUrl) async {
  final dbDetail = await MiruCoreEndpoint.getDbDetail(pkg, detailUrl);
  if (dbDetail != null) {
    return dbDetail;
  } else {
    return null;
  }
}

@riverpod
Future<Detail> fetchDetail(
  Ref ref,
  String pkg,
  String url, {
  bool force = false,
}) async {
  if (force) {
    final detail = await fetchDetailFromExtension(pkg, url);
    return detail!;
  }
  final detail =
      await fetchDetailFromDb(pkg, url) ??
      await fetchDetailFromExtension(pkg, url);
  return detail!;
}

@riverpod
Future<List<ExtensionListItem>> fetchExtensionLatest(
  Ref ref,
  String pkg,
  int page,
) async {
  return await MiruCoreEndpoint.latest(pkg, page);
}

@riverpod
Future<List<ExtensionListItem>> fetchExtensionSearch(
  Ref ref,
  String package,
  String query,
  int page, {
  Map<String, ExtensionFilter>? filter,
}) async {
  final result = await MiruCoreEndpoint.search(
    package,
    query,
    page,
    filter: filter,
  );
  return result;
}

@riverpod
Future<List<ExtensionListItem>> fetchExtensionSearchLatest(
  Ref ref,
  String package,

  int page, {
  String? query,
  Map<String, ExtensionFilter>? filter,
}) async {
  if (query == null || query.isEmpty) {
    final result = await MiruCoreEndpoint.latest(package, page);
    return result;
  }
  final result = await MiruCoreEndpoint.search(
    package,
    query,
    page,
    filter: filter,
  );
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
