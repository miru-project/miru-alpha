import 'dart:isolate';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/utils/log.dart';
import 'package:miru_app_new/utils/network/request.dart';
import 'dart:async';
import 'dart:convert';
import 'package:miru_app_new/provider/extension_page_provider.dart';

class CoreNetwork {
  static String get baseUrl => 'http://127.127.127.127:12777';
  static String get port => '12777';
  static Future<dynamic> requestJSON(String path) async {
    return await dio
        .get('$baseUrl/$path')
        .then((response) => response.data["data"]);
  }

  static Future<dynamic> requestRaw(String path) async {
    return await dio.get('$baseUrl/$path');
  }

  static Future<dynamic> requestFormData(
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
    return response.data["data"];
  }

  static void ensureInitialized() {
    logger.info('Miru_core initialized with base URL: $baseUrl');
    startPollRootInIsolate(interval: const Duration(milliseconds: 200));
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

        final extMetaList =
            extList.map((e) => ExtensionMeta.fromJson(e)).toList();

        // Use the size of the data structure to determine if it has changed
        final metaSize =
            Uint8List.fromList(utf8.encode(extMetaList.toString())).length;
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

  static void startPollRootInIsolate({
    Duration interval = const Duration(milliseconds: 200),
  }) async {
    final receivePort = ReceivePort();
    // await Isolate.spawn(_pollRootIsolateEntry, [receivePort.sendPort, interval]);
    _pollRootIsolateEntry([receivePort.sendPort, interval]);

    receivePort.listen((data) {
      if (data is List<ExtensionMeta>) {
        MetaDataController.update(data);

        _extensionNotifier?.setMetaData(data);
      } else if (data is String) {
        logger.info('Error received: $data');
      } else {
        logger.info('Unknown data type received: $data');
      }
    });
  }

  static ExtensionPageNotifier? _extensionNotifier;

  static void setExtensionNotifier(ExtensionPageNotifier notifier) {
    _extensionNotifier = notifier;
  }
}

class MetaDataController {
  // single updater callback registered by the UI/provider layer
  static void Function(List<ExtensionMeta>? data)? _updater;

  static void registerUpdater(
    void Function(List<ExtensionMeta>? data) updater,
  ) {
    _updater = updater;
  }

  static void update(List<ExtensionMeta>? data) {
    if (_updater == null) return;
    try {
      _updater!(data);
    } catch (e) {
      logger.info('Failed to call MetaDataController updater: $e');
    }
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

  static Future<String> latest(String pkg, int page) async {
    return await CoreNetwork.requestRaw(
      '$latestBaseUrl/$pkg/$page',
    ).then((response) => response.data);
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
    }, method: 'DELETE');
  }

  static Future<void> downloadExtension(String repoUrl, String package) async {
    return CoreNetwork.requestFormData("download/extension", {
      'repoUrl': repoUrl,
      'pkg': package,
    });
  }

  static Future<void> removeExtension(String package) async {
    return CoreNetwork.requestFormData("rm/extension", {
      'pkg': package,
    }, method: 'DELETE');
  }
}

class DownloadController {
  static final StreamController<String> _downloadController =
      StreamController<String>.broadcast();
  static Stream<String> get downloadStream => _downloadController.stream;
}
