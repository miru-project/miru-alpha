import 'package:dio/dio.dart';
import 'package:miru_app_new/miru_core/core.dart';
import 'package:miru_app_new/model/model.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'dart:async';
import 'dart:convert';
import 'package:miru_app_new/miru_core/grpc_client.dart';
import 'package:miru_app_new/miru_core/proto/proto.dart' as proto;

late final Dio dio;

/// Endpoint helpers for application settings
class AppSettingEndpoint {
  /// Fetch all application settings from /appSetting
  /// The server returns an array of objects like {"key": "someKey", "value": "someValue"}
  static Future<Map<String, String>> getAll() async {
    try {
      final response = await MiruGrpcClient.appSettingClient.getAppSetting(
        proto.GetAppSettingRequest(),
      );
      final Map<String, String> result = {};
      for (final s in response.settings) {
        result[s.key] = s.value;
      }
      return result;
    } catch (e) {
      logger.info('Failed to fetch app settings via gRPC: $e');
      return {};
    }
  }
}

class CoreMessage {
  final String? msg;
  final dynamic data;

  CoreMessage(this.msg, this.data);
}

class CoreNetwork {
  static String get baseUrl => "http://${Core.host}:${Core.port}";
  static Future<dynamic> requestJSON(String path) async {
    return await dio
        .get('$baseUrl/$path')
        .then((response) => response.data["data"]);
  }

  static Future<dynamic> requestRaw(
    String path, {
    Object? data,
    String method = 'GET',
  }) async {
    return await dio
        .request(
          '$baseUrl/$path',
          data: data,
          options: Options(method: method),
        )
        .then((response) => response.data);
  }

  static Future<CoreMessage> requestFormData(
    String path,
    Map<String, dynamic> data, {
    String method = 'POST',
  }) async {
    final formData = FormData.fromMap(data);
    final response = await dio.request(
      '$baseUrl/$path',
      data: formData,
      options: Options(method: method, contentType: 'multipart/form-data'),
    );
    return CoreMessage(
      response.data["message"]?.toString(),
      response.data["data"],
    );
  }

  static Future<void> waitForServerLoaded() async {
    while (true) {
      try {
        await MiruGrpcClient.coreClient.helloMiru(proto.HelloMiruRequest());
        logger.info('Miru core loaded (gRPC)');
        return;
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  static Future<void> ensureInitialized() async {
    dio = Dio();
  }
}

class MiruCoreEndpoint {
  static String get extensionPathUrl => 'ext';
  static String get searchUrl => '$extensionPathUrl/search';
  static String get latestBaseUrl => '$extensionPathUrl/latest';
  static String get detailUrl => '$extensionPathUrl/detail';
  static String get watchUrl => '$extensionPathUrl/watch';
  static String get downloadUrl => '$extensionPathUrl/download';
  static String get setRepoUrl => 'ext/repo';
  static String get repoListUrl => 'ext/repolist';

  static Detail _detailFromProto(proto.Detail p) {
    return Detail(
      id: p.id,
      title: p.hasTitle() ? p.title : "",
      cover: p.hasCover() ? p.cover : null,
      desc: p.hasDesc() ? p.desc : null,
      downloaded: p.downloaded,
      detailUrl: p.detailUrl,
      package: p.package,
      episodes: p.hasEpisodes()
          ? (jsonDecode(p.episodes) as List)
                .map((e) => ExtensionEpisodeGroup.fromJson(e))
                .toList()
          : null,
      headers: p.hasHeaders()
          ? (jsonDecode(p.headers) as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, v.toString()),
            )
          : null,
    );
  }

  static Future<Detail?> getDbDetail(String pkg, String url) async {
    final response = await MiruGrpcClient.dbClient.getDetail(
      proto.GetDetailRequest(package: pkg, detailUrl: url),
    );
    if (!response.hasDetail() || response.detail.package.isEmpty) return null;
    return _detailFromProto(response.detail);
  }

  static Future<Detail> upsertDbDetail(Detail detail) async {
    final response = await MiruGrpcClient.dbClient.upsertDetail(
      proto.UpsertDetailRequest(
        title: detail.title,
        cover: detail.cover,
        desc: detail.desc,
        detailUrl: detail.detailUrl,
        package: detail.package,
        downloaded: detail.downloaded,
        episodes: detail.episodes != null ? jsonEncode(detail.episodes) : null,
        headers: detail.headers != null ? jsonEncode(detail.headers) : null,
      ),
    );
    return _detailFromProto(response.detail);
  }

  static Future<Object> watch(
    String url,
    String pkg,
    ExtensionType type,
  ) async {
    final response = await MiruGrpcClient.extensionClient.watch(
      proto.WatchRequest(url: url, pkg: pkg),
    );
    final data = jsonDecode(response.data);

    switch (type) {
      case ExtensionType.bangumi:
        final result = ExtensionBangumiWatch.fromJson(data);
        return result;
      case ExtensionType.manga:
        final result = ExtensionMangaWatch.fromJson(data);
        return result;
      case ExtensionType.fikushon:
        final result = ExtensionFikushonWatch.fromJson(data);
        return result;
      default:
        throw (Exception('Unknown media type'));
    }
  }

  static Future<Map<String, ExtensionFilter>> createFilter(
    String pkg, {
    Map<String, List<String>>? filter,
  }) async {
    throw UnimplementedError('createFilter method not implemented');
  }

  static Future<ExtensionDetail> detail(String pkg, String url) async {
    final response = await MiruGrpcClient.extensionClient.detail(
      proto.DetailRequest(pkg: pkg, url: url),
    );

    return ExtensionDetail.fromJson(jsonDecode(response.data));
  }

  static Future<List<ExtensionListItem>> search(
    String pkg,
    String kw,
    int page, {
    Map<String, ExtensionFilter>? filter,
  }) async {
    final response = await MiruGrpcClient.extensionClient.search(
      proto.SearchRequest(
        pkg: pkg,
        kw: kw,
        page: page,
        filter: filter != null ? jsonEncode(filter) : "",
      ),
    );

    return response.items.map((e) {
      return ExtensionListItem(
        title: e.title,
        url: e.url,
        cover: e.cover,
        update: e.update,
      );
    }).toList();
  }

  static Future<List<ExtensionListItem>> latest(String pkg, int page) async {
    final response = await MiruGrpcClient.extensionClient.latest(
      proto.LatestRequest(pkg: pkg, page: page),
    );

    return response.items.map((e) {
      return ExtensionListItem(
        title: e.title,
        url: e.url,
        cover: e.cover,
        update: e.update,
      );
    }).toList();
  }

  static Future<void> setRepo(String repoUrl, String name) async {
    await MiruGrpcClient.repoClient.setRepo(
      proto.SetRepoRequest(repoUrl: repoUrl, name: name),
    );
  }

  static Future<dynamic> getRepos() async {
    final response = await MiruGrpcClient.repoClient.getRepos(
      proto.GetReposRequest(),
    );
    return jsonDecode(response.data);
  }

  static Future<dynamic> fetchRepoList() async {
    final response = await MiruGrpcClient.repoClient.fetchRepoList(
      proto.FetchRepoListRequest(),
    );
    return jsonDecode(response.data);
  }

  static Future<String?> deleteRepo(String repoUrl) async {
    final response = await MiruGrpcClient.repoClient.deleteRepo(
      proto.DeleteRepoRequest(repoUrl: repoUrl),
    );
    return response.message;
  }

  static Future<void> downloadExtension(String repoUrl, String package) async {
    await MiruGrpcClient.extensionClient.downloadExtension(
      proto.DownloadExtensionRequest(repoUrl: repoUrl, pkg: package),
    );
  }

  static Future<void> removeExtension(String package) async {
    await MiruGrpcClient.extensionClient.removeExtension(
      proto.RemoveExtensionRequest(pkg: package),
    );
  }

  static Future<void> setCookie(String cookie, String url) async {
    await MiruGrpcClient.networkClient.setCookie(
      proto.SetCookieRequest(cookie: cookie, url: url),
    );
  }
}

class DownloadController {
  static final StreamController<String> _downloadController =
      StreamController<String>.broadcast();
  static Stream<String> get downloadStream => _downloadController.stream;
}
