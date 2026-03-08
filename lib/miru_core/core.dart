import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'package:miru_alpha/generated_bindings.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/store/storage_index.dart';
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

  static Future<void> startIsolateNativeMiruCore(
    String configPath,
    RootIsolateToken token,
  ) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    await MiruDirectory.ensureInitialized();
    MiruLog.ensureInitialized();
    logger.info('loading miru core isolate');
    late final ffi.DynamicLibrary lib;
    final libName = Platform.isWindows ? 'miru_core.dll' : 'libmiru_core.so';

    try {
      if (Platform.isWindows || Platform.isLinux) {
        final exeFolder = File(Platform.resolvedExecutable).parent.path;

        final depPrefixes = Platform.isWindows
            ? ['libgcc_s', 'libstdc++-6']
            : ['libgcc_s', 'libstdc++'];

        final allFiles = Directory(exeFolder).listSync();

        for (var prefix in depPrefixes) {
          try {
            final depFile = allFiles.firstWhere(
              (f) =>
                  f.path.toLowerCase().contains(prefix.toLowerCase()) &&
                  (f.path.endsWith('.dll') || f.path.endsWith('.so')),
            );
            logger.info('Pre-loading dependency: ${depFile.path}');
            ffi.DynamicLibrary.open(depFile.path);
          } catch (_) {}
        }
      }

      // 2. Load the main library
      try {
        lib = ffi.DynamicLibrary.open(libName);
      } catch (e) {
        if (Platform.isWindows) {
          final exeFolder = File(Platform.resolvedExecutable).parent.path;
          final dllPath = p.join(exeFolder, libName);
          if (File(dllPath).existsSync()) {
            logger.severe('$libName exists but failed to load (Error 126).');
            logger.severe('Attempting load with absolute path...');
            lib = ffi.DynamicLibrary.open(dllPath);
          } else {
            logger.severe('$libName NOT found in $exeFolder');
            rethrow;
          }
        } else {
          rethrow;
        }
      }

      using((Arena arena) {
        final configPathPointer = configPath
            .toNativeUtf8(allocator: arena)
            .cast<ffi.Char>();
        final core = MiruCore(lib);
        core.initDyLib(configPathPointer);
      });
      logger.info('miru core isolate loaded');
    } catch (e, s) {
      logger.severe('Error: $e');
      logger.severe(s.toString());
      exit(1);
    }
  }

  static Future<void> loadMiruCore() async {
    logger.info('Loading Miru Core...');
    final location = configLoc;
    if (Platform.isAndroid) {
      final platform = MethodChannel('miru.alpha/miru_core');
      await platform.invokeMethod('InitAAR', location);
      return;
    }
    final token = RootIsolateToken.instance!;
    Isolate.run(() => startIsolateNativeMiruCore(location, token));
    return;
  }
}
