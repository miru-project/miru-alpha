import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

typedef StartNative = Int32 Function(Int32 num, Pointer<Pointer<Utf8>> files);
typedef Start = int Function(int num, Pointer<Pointer<Utf8>> files);

class FFMpegUtils {
  static late Start start;
  static late DynamicLibrary _lib;

  static void openlib() {
    if (Platform.isMacOS || Platform.isFuchsia) {
      return;
    }

    String libName = Platform.isWindows
        ? 'ffmpeg_merge.dll'
        : 'libffmpeg_merge.so';

    try {
      // Try default loading first
      _lib = DynamicLibrary.open(libName);
    } catch (e) {
      if (Platform.isWindows) {
        // Diagnostic: Check if the file actually exists in the app root
        final exeFolder = File(Platform.resolvedExecutable).parent.path;
        final dllPath = '$exeFolder\\$libName';

        if (File(dllPath).existsSync()) {
          // If the file exists but fails to load with 126, it's a MISSING DEPENDENCY
          stderr.writeln(
            'FFMpegUtils: $libName exists at $dllPath but failed to load (Error 126).',
          );
          stderr.writeln(
            'This usually means a dependent DLL (e.g., avcodec-*.dll, avutil-*.dll, or MinGW runtimes) is missing from the application folder.',
          );

          // Try loading with absolute path as a fallback
          try {
            _lib = DynamicLibrary.open(dllPath);
          } catch (e2) {
            stderr.writeln(
              'FFMpegUtils: Failed to load even with absolute path: $e2',
            );
            rethrow;
          }
        } else {
          stderr.writeln(
            'FFMpegUtils: $libName NOT found in executable directory: $exeFolder',
          );
          rethrow;
        }
      } else {
        rethrow;
      }
    }
    start = _lib.lookupFunction<StartNative, Start>('start');
  }

  static void ensureInitialized() {
    if (Platform.isMacOS || Platform.isFuchsia) {
      return;
    }
    openlib();
  }

  static void combineToMp4(List<String> inputFile, String outputName) {
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
