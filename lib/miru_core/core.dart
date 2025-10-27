import 'dart:async';
import 'dart:developer';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:integral_isolates/integral_isolates.dart';

import 'package:miru_app_new/generated_bindings.dart';
import 'package:miru_app_new/miru_core/network.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/utils/store/storage_index.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';

class Core {
  // config location
  static String configLoc = '';
  static late Map<String, dynamic> configData;
  static bool isInit = false;
  static String get port => configData['port'] ?? '3000';
  static String get host => configData['address'] ?? '127.0.0.1';

  static Future<void> ensureInitialized() async {
    await CoreNetwork.ensureInitialized();
    await loadMiruCore(configLoc);
    await CoreNetwork.waitForServerLoaded();
    await MiruSettings.ensureInitialized();
  }

  static void loadConfig() {
    final appSupportDir = MiruDirectory.getDirectory;

    configLoc = p.join(appSupportDir, 'config.json');
    if (File(configLoc).existsSync()) {
      logger.info('Config file exists: $configLoc');
      configData = jsonDecode(File(configLoc).readAsStringSync());
    } else {
      logger.info('Config file does not exist, creating: $configLoc');
      final configDir = Directory(appSupportDir);
      if (!configDir.existsSync()) {
        configDir.createSync(recursive: true);
      }
      configData = {
        "database": {
          "driver": "sqlite3",
          "host": "localhost",
          "port": 5432,
          "user": "miru",
          "password": "",
          "dbname": p.join(appSupportDir, 'miru.db'),
          "sslmode": "disable",
        },
        "cookieStoreLocation": Platform.isAndroid ? appSupportDir : "",
        "extensionPath": p.join(appSupportDir, 'extensions'),
        "address": "127.0.0.1",
        "port": "3000",
      };

      File(configLoc).writeAsStringSync(jsonEncode(configData));
      logger.info('Default configuration written to config file');
      logger.info('Config file created: $configLoc');
    }
  }

  static Future<void> startNativeMiruCore(
    String configPath,
    // RootIsolateToken rootIsolateToken,
  ) async {
    late final ffi.DynamicLibrary lib;
    // if (Platform.isAndroid) {
    //   BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    //   final platform = MethodChannel('com.miru.alpha/miru_core');
    //   await platform.invokeMethod('InitAAR', configPath);
    //   return;
    // }
    if (Platform.isWindows) {
      lib = ffi.DynamicLibrary.open('miru_core.dll');
    } else if (Platform.isLinux) {
      lib = ffi.DynamicLibrary.open('libmiru_core.so');
    } else {
      throw UnsupportedError(
        'Unsupported platform: ${Platform.operatingSystem}',
      );
    }

    using((Arena arena) {
      final configPathPointer = configPath
          .toNativeUtf8(allocator: arena)
          .cast<ffi.Char>();
      final core = MiruCore(lib);
      core.initDyLib(configPathPointer);
      // final error = res.cast<Utf8>().toDartString();
      // debugger();
      // CoreNetwork.setPort(port.toString());
    });
  }

  static Future<void> loadMiruCore(String configPath) async {
    if (Platform.isAndroid) {
      // BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
      final platform = MethodChannel('com.miru.alpha/miru_core');
      await platform.invokeMethod('InitAAR', configPath);
      return;
    }
    // final statefulIsolate = TailoredStatefulIsolate<String, Future<void>>();
    // statefulIsolate.compute(startNativeMiruCore, configPath);
    Isolate.run(() => startNativeMiruCore(configPath));
    // startNativeMiruCore(configPath);
    return;
  }
}
