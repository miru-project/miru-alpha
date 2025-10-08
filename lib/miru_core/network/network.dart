import 'dart:isolate';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/model.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'dart:async';
import 'dart:convert';

late final Dio dio;

/// Endpoint helpers for application settings
class AppSettingEndpoint {
  /// Fetch all application settings from /appSetting
  /// The server returns an array of objects like {"key": "someKey", "value": "someValue"}
  static Future<Map<String, String>> getAll() async {
    final jsResult = await CoreNetwork.requestJSON('appSetting');

    // jsResult is expected to be a List of maps with keys 'key' and 'value'
    final Map<String, String> result = {};
    try {
      if (jsResult is List) {
        for (final item in jsResult) {
          if (item is Map) {
            final k = item['key']?.toString();
            final v = item['value']?.toString();
            if (k != null && v != null) {
              result[k] = v;
            }
          }
        }
      }
    } catch (e) {
      logger.info('Failed to parse app settings from /appSetting: $e');
    }
    return result;
  }
}

class CoreMessage {
  final String? msg;
  final dynamic data;

  CoreMessage(this.msg, this.data);
}

class CoreNetwork {
  static String get baseUrl => 'http://127.127.127.127:12777';
  static String get port => '12777';
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
        await requestJSON("");
        return;
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  static Future<void> ensureInitialized() async {
    dio = Dio();
    await waitForServerLoaded();
    logger.info('Miru_core initialized with base URL: $baseUrl');
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
        final data = await CoreNetwork.requestJSON("");

        // Handle  meta data
        final List<dynamic> extList = data['extensionMeta'] ?? [];

        final extMetaList = extList
            .map((e) => ExtensionMeta.fromJson(e))
            .toList();

        // Use the size of the data structure to determine if it has changed
        final metaSize = Uint8List.fromList(
          utf8.encode(extMetaList.toString()),
        ).length;
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
}

class ExtensionEndpoint {
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
    final jsResult = await CoreNetwork.requestFormData(watchUrl, {
      'url': url,
      'pkg': pkg,
    }, method: "GET");
    final data = jsResult.data;

    switch (type) {
      case ExtensionType.bangumi:
        final result = ExtensionBangumiWatch.fromJson(data);
        // result.headers ??= await _defaultHeaders;
        return result;
      case ExtensionType.manga:
        final result = ExtensionMangaWatch.fromJson(data);
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
    final jsResult = await CoreNetwork.requestFormData(detailUrl, {
      'url': url,
      'pkg': pkg,
    }, method: 'GET');

    return ExtensionDetail.fromJson(jsResult.data);
  }

  static Future<List<ExtensionListItem>> search(
    String pkg,
    String kw,
    int page, {
    Map<String, ExtensionFilter>? filter,
  }) async {
    final jsResult = await CoreNetwork.requestFormData(searchUrl, {
      'pkg': pkg,
      'kw': kw,
      'page': page,
      if (filter != null) 'filter': jsonEncode(filter),
    }, method: 'GET');
    List<ExtensionListItem> result = jsResult.data.map<ExtensionListItem>((e) {
      return ExtensionListItem.fromJson(e);
    }).toList();
    return result;
  }

  static Future<List<ExtensionListItem>> latest(String pkg, int page) async {
    final jsResult = await CoreNetwork.requestFormData(latestBaseUrl, {
      'pkg': pkg,
      'page': page,
    }, method: 'GET');
    List<ExtensionListItem> result = jsResult.data.map<ExtensionListItem>((e) {
      return ExtensionListItem.fromJson(e);
    }).toList();
    return result;
  }

  static Future<void> setRepo(String repoUrl, String name) async {
    await CoreNetwork.requestFormData(setRepoUrl, {
      'repoUrl': repoUrl,
      'name': name,
    });
  }

  static Future<void> removeRepo(String repoUrl) async {
    await CoreNetwork.requestFormData(setRepoUrl, {
      'repoUrl': repoUrl,
    }, method: 'DELETE');
  }

  static Future<dynamic> getRepo() async {
    return await CoreNetwork.requestJSON(setRepoUrl);
  }

  static Future<dynamic> fetchRepo() async {
    return await CoreNetwork.requestJSON(repoListUrl);
  }

  static Future<void> deleteRepo(String repoUrl) async {
    return await CoreNetwork.requestFormData('ext/repo', {
      'repoUrl': repoUrl,
    }, method: 'DELETE').then((value) => value.msg);
  }

  static Future<void> downloadExtension(String repoUrl, String package) async {
    return await CoreNetwork.requestFormData("download/extension", {
      'repoUrl': repoUrl,
      'pkg': package,
    }).then((value) => value.msg);
  }

  static Future<void> removeExtension(String package) async {
    return CoreNetwork.requestFormData("rm/extension", {
      'pkg': package,
    }, method: 'DELETE').then((value) => value.msg);
  }
}

class DownloadController {
  static final StreamController<String> _downloadController =
      StreamController<String>.broadcast();
  static Stream<String> get downloadStream => _downloadController.stream;
}
