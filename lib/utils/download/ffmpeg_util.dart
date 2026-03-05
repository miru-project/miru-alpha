import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import '../core/log.dart';

typedef StartNative = Int32 Function(Int32 num, Pointer<Pointer<Utf8>> files);
typedef Start = int Function(int num, Pointer<Pointer<Utf8>> files);

class FFMpegUtils {
  static late Start start;
  static late DynamicLibrary _lib;
  static bool _isInitialized = false;
  static bool get isAvailable => _isInitialized;

  static void openlib() {
    if (Platform.isMacOS || Platform.isFuchsia) {
      return;
    }

    String libName = Platform.isWindows
        ? 'ffmpeg_merge.dll'
        : 'libffmpeg_merge.so';

    try {
      if (Platform.isWindows) {
        final exeFolder = File(Platform.resolvedExecutable).parent.path;

        // 1. Load identified FFmpeg dependencies in order
        // Based on objdump: avutil, avcodec, avformat are direct deps
        final depPrefixes = ['avutil', 'avcodec', 'avformat'];
        final allFiles = Directory(exeFolder).listSync();

        for (var prefix in depPrefixes) {
          try {
            final depFile = allFiles.firstWhere(
              (f) =>
                  f.path.toLowerCase().contains(prefix.toLowerCase()) &&
                  f.path.endsWith('.dll'),
            );
            logger.info('Pre-loading dependency: ${depFile.path}');
            DynamicLibrary.open(depFile.path);
          } catch (_) {}
        }

        // 2. Check for MSVC Runtime (Common cause of Error 126)
        final runtimeDeps = [
          'msvcp140.dll',
          'vcruntime140.dll',
          'vcruntime140_1.dll',
        ];
        for (var runtime in runtimeDeps) {
          try {
            DynamicLibrary.open(runtime);
          } catch (_) {
            logger.severe(
              'CRITICAL: Missing Visual C++ Runtime: $runtime. Please install Microsoft Visual C++ Redistributable.',
            );
          }
        }
      }

      // 2. Now load the main library
      _lib = DynamicLibrary.open(libName);
      start = _lib.lookupFunction<StartNative, Start>('start');
      _isInitialized = true;
    } catch (e) {
      if (Platform.isWindows) {
        final exeFolder = File(Platform.resolvedExecutable).parent.path;
        final dllPath = '$exeFolder\\$libName';

        if (File(dllPath).existsSync()) {
          logger.severe('$libName exists but failed to load (Error 126).');
          logger.severe(
            'REQUIRED: You MUST include the FFmpeg core DLLs (avcodec, avformat, etc.) in the app folder.',
          );

          try {
            _lib = DynamicLibrary.open(dllPath);
            start = _lib.lookupFunction<StartNative, Start>('start');
            _isInitialized = true;
          } catch (e2) {
            logger.severe(
              'Failed to load even with absolute path. Feature disabled.',
            );
          }
        } else {
          logger.severe('$libName NOT found. Feature disabled.');
        }
      }
    }
  }

  static void ensureInitialized() {
    if (_isInitialized) return;
    openlib();
  }

  static void combineToMp4(List<String> inputFile, String outputName) {
    if (!_isInitialized) {
      throw Exception('FFMpegUtils is not available on this system.');
    }
    final processFile = [outputName, ...inputFile];
    final inputFilesUtf8 = processFile.map((f) => f.toNativeUtf8()).toList();
    final array = calloc<Pointer<Utf8>>(processFile.length);

    for (var i = 0; i < processFile.length; i++) {
      array[i] = inputFilesUtf8[i];
    }

    try {
      final inputFileNum = processFile.length;
      final result = start(inputFileNum, array);
      if (result != 0) {
        throw Exception('Failed to combine videos: error code $result');
      }
    } finally {
      for (var ptr in inputFilesUtf8) {
        calloc.free(ptr);
      }
      calloc.free(array);
    }
  }
}
