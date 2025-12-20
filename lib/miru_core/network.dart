import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:miru_app_new/miru_core/core.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/model.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'dart:async';
import 'dart:convert';
import 'package:miru_app_new/miru_core/grpc_client.dart';
import 'package:miru_app_new/miru_core/proto/miru_core_service.pbgrpc.dart'
    as proto;

late final Dio dio;

/// Endpoint helpers for application settings
class AppSettingEndpoint {
  /// Fetch all application settings from /appSetting
  /// The server returns an array of objects like {"key": "someKey", "value": "someValue"}
  static Future<Map<String, String>> getAll() async {
    try {
      final response = await MiruGrpcClient.client.getAppSetting(
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
        await MiruGrpcClient.client.helloMiru(proto.HelloMiruRequest());
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

  // Run inside seperate isolate to handle json unmarshalling from the miru-core  response
  // Update different part of streamcontroller  by sending data to the main isolate
  static Future<void> _pollRootIsolateEntry(List args) async {
    final SendPort sendPort = args[0];
    final Duration interval = args[1];
    int prevMetaSize = 0;
    while (true) {
      final int t1 = DateTime.now().millisecondsSinceEpoch;
      try {
        final response = await MiruGrpcClient.client.helloMiru(
          proto.HelloMiruRequest(),
        );

        // Handle meta data
        final List<proto.ExtensionMeta> extList = response.extensionMeta;

        final extMetaList = extList
            .map(
              (e) => ExtensionMeta(
                name: e.name,
                version: e.version,
                author: e.author,
                license: e.license,
                lang: e.lang,
                icon: e.icon,
                packageName: e.package,
                webSite: e.webSite,
                description: e.description,
                tags: e.tags,
                api: e.api,
                type: _extensionTypeFromProto(e.type),
              ),
            )
            .toList();

        // Use the size of the data structure to determine if it has changed
        final metaSize = response.writeToBuffer().length;
        if (metaSize != prevMetaSize) {
          prevMetaSize = metaSize;
          sendPort.send(extMetaList);
        }
      } catch (e) {
        // send message if show error
        sendPort.send('Error: $e');
      }
      final deltaT = DateTime.now().millisecondsSinceEpoch - t1;

      // Make sure that we wait for the full interval minus the time taken to process
      await Future.delayed(
        Duration(
          milliseconds: (interval.inMilliseconds - deltaT).clamp(
            0,
            interval.inMilliseconds,
          ),
        ),
      );
    }
  }

  static void startPollRootInIsolate(
    void Function(dynamic) callback, {
    Duration interval = const Duration(milliseconds: 200),
  }) async {
    final receivePort = ReceivePort();
    // await Isolate.spawn(_pollRootIsolateEntry, [receivePort.sendPort, interval]);
    _pollRootIsolateEntry([receivePort.sendPort, interval]);

    receivePort.listen(callback);
  }

  static ExtensionType _extensionTypeFromProto(String value) {
    return switch (value.toLowerCase()) {
      'manga' => ExtensionType.manga,
      'fikushon' => ExtensionType.fikushon,
      'bangumi' => ExtensionType.bangumi,
      'unknown' => ExtensionType.unknown,
      _ => ExtensionType.unknown,
    };
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
  static Future<Object> watch(
    String url,
    String pkg,
    ExtensionType type,
  ) async {
    final response = await MiruGrpcClient.client.watch(
      proto.WatchRequest(url: url, pkg: pkg),
    );
    final data = jsonDecode(response.data);

    switch (type) {
      case ExtensionType.bangumi:
        final result = ExtensionBangumiWatch.fromJson(data);
        // result.headers ??= await _defaultHeaders;
        return result;
      case ExtensionType.manga:
        final result = ExtensionMangaWatch.fromJson(data);
        // result.headers ??= await _defaultHeaders;
        return result;
      case ExtensionType.fikushon:
        final result = ExtensionFikushonWatch.fromJson(data);
        // result.headers ??= await _defaultHeaders;
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
    // final jsResult = await CoreNetwork.requestRaw(
    //   '$searchUrl/filter/$pkg',
    //   data: filter,
    //   method: 'GET',
    // );
    // Map<String, ExtensionFilter> result = {};
    // jsResult.forEach((key, value) {
    //   result[key] = ExtensionFilter.fromJson(value);
    // });
    // return result;
  }

  static Future<ExtensionDetail> detail(String pkg, String url) async {
    final response = await MiruGrpcClient.client.detail(
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
    final response = await MiruGrpcClient.client.search(
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
    final response = await MiruGrpcClient.client.latest(
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
    await MiruGrpcClient.client.setRepo(
      proto.SetRepoRequest(repoUrl: repoUrl, name: name),
    );
  }

  static Future<void> removeRepo(String repoUrl) async {
    await MiruGrpcClient.client.deleteRepo(
      proto.DeleteRepoRequest(repoUrl: repoUrl),
    );
  }

  static Future<dynamic> getRepo() async {
    final response = await MiruGrpcClient.client.getRepos(
      proto.GetReposRequest(),
    );
    return jsonDecode(response.data);
  }

  static Future<dynamic> fetchRepo() async {
    final response = await MiruGrpcClient.client.fetchRepoList(
      proto.FetchRepoListRequest(),
    );
    return jsonDecode(response.data);
  }

  static Future<String?> deleteRepo(String repoUrl) async {
    final response = await MiruGrpcClient.client.deleteRepo(
      proto.DeleteRepoRequest(repoUrl: repoUrl),
    );
    return response.message;
  }

  static Future<void> downloadExtension(String repoUrl, String package) async {
    await MiruGrpcClient.client.downloadExtension(
      proto.DownloadExtensionRequest(repoUrl: repoUrl, pkg: package),
    );
  }

  static Future<void> removeExtension(String package) async {
    await MiruGrpcClient.client.removeExtension(
      proto.RemoveExtensionRequest(pkg: package),
    );
  }

  static Future<void> setCookie(String cookie, String url) async {
    await MiruGrpcClient.client.setCookie(
      proto.SetCookieRequest(cookie: cookie, url: url),
    );
  }
}

class DownloadController {
  static final StreamController<String> _downloadController =
      StreamController<String>.broadcast();
  static Stream<String> get downloadStream => _downloadController.stream;
}
