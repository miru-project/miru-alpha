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

class MiruCoreIsolateData {
  final String configPath;
  final RootIsolateToken token;
  final SendPort sendPort;

  MiruCoreIsolateData(this.configPath, this.token, this.sendPort);
}

class Core {
  // config location
  static String configLoc = '';
  static late Map<String, dynamic> configData;
  static bool isInit = false;
  static String get port => configData['port'] ?? '3000';
  static String get host => configData['address'] ?? '127.0.0.1';
  static String get baseUrl => 'http://$host:$port';
  static late String extensionPath;

  static String get getExtensionPath => extensionPath;
  static Future<void> ensureInitialized() async {
    await CoreNetwork.ensureInitialized();
    await CoreNetwork.waitForServerLoaded();
    await MiruSettings.ensureInitialized();
  }

  static void loadConfig() {
    final appSupportDir = MiruDirectory.getDirectory;

    configLoc = p.join(appSupportDir, 'config.json');
    extensionPath = p.join(appSupportDir, 'extensions');

    bool shouldWrite = false;
    if (File(configLoc).existsSync()) {
      logger.info('Config file exists: $configLoc');
      configData = jsonDecode(File(configLoc).readAsStringSync());
    } else {
      logger.info('Config file does not exist, creating: $configLoc');
      final configDir = Directory(appSupportDir);
      if (!configDir.existsSync()) {
        configDir.createSync(recursive: true);
      }
      configData = {};
      shouldWrite = true;
    }

    // Apply defaults for missing fields so the config always contains the
    // full set of keys the Go backend + Dart gRPC client rely on.
    final defaultConfig = {
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
      "extensionPath": extensionPath,
      "address": "127.0.0.1",
      "port": "3000",
      "gRPCPort": "3001",
    };

    defaultConfig.forEach((key, value) {
      if (!configData.containsKey(key)) {
        logger.info('Config missing "$key", applying default: $value');
        configData[key] = value;
        shouldWrite = true;
      }
    });
    // Also ensure the fields are non-empty, e.g. an old config could carry an
    // empty string that would otherwise break port resolution on the backend.
    for (final key in ["address", "port", "gRPCPort"]) {
      final v = configData[key];
      if (v == null || (v is String && v.isEmpty)) {
        logger.info(
          'Config "$key" empty, applying default: ${defaultConfig[key]}',
        );
        configData[key] = defaultConfig[key];
        shouldWrite = true;
      }
    }

    if (shouldWrite) {
      final configDir = Directory(appSupportDir);
      if (!configDir.existsSync()) {
        configDir.createSync(recursive: true);
      }
      File(configLoc).writeAsStringSync(jsonEncode(configData));
      logger.info('Configuration written to: $configLoc');
    }
  }

  static Future<void> startIsolateNativeMiruCore(
    MiruCoreIsolateData data,
  ) async {
    final configPath = data.configPath;
    final token = data.token;
    final sendPort = data.sendPort;
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    await MiruDirectory.ensureInitialized();
    MiruLog.initForIsolate(sendPort);
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
      sendPort.send({
        'level': 'SHOUT',
        'message': 'Miru Core isolate crashed: $e',
        'stack': s.toString(),
        'crash': true,
      });
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
    final receivePort = ReceivePort();
    final sendPort = receivePort.sendPort;

    receivePort.listen((message) {
      if (message is Map<String, dynamic>) {
        final level = Level.LEVELS.firstWhere(
          (l) => l.name == message['level'],
          orElse: () => Level.INFO,
        );
        if (message['crash'] == true) {
          MiruLog.recordCrash(
            message['message'].toString(),
            StackTrace.fromString(message['stack']?.toString() ?? ''),
            source: 'miru-core',
          );
        }
        // Log to the main isolate's logger
        logger.log(level, message['message']);
      }
    });

    // Capture uncaught errors thrown inside the core isolate after it has
    // started (outside the setup try/catch). addErrorListener redirects them
    // here so they are forwarded "outside the isolate" into the main crash
    // log instead of silently terminating the isolate.
    final errorPort = ReceivePort();
    errorPort.listen((message) {
      Object? error = 'unknown isolate error';
      StackTrace stack = StackTrace.empty;
      if (message is List) {
        if (message.isNotEmpty) error = message[0];
        if (message.length > 1 && message[1] is String) {
          stack = StackTrace.fromString(message[1] as String);
        }
      } else if (message != null) {
        error = message;
      }
      MiruLog.recordCrash(
        error.toString(),
        stack,
        source: 'miru-core-isolate',
      );
    });

    final isolate = await Isolate.spawn(
      startIsolateNativeMiruCore,
      MiruCoreIsolateData(location, token, sendPort),
    );
    isolate.addErrorListener(errorPort.sendPort);
    return;
  }
}
