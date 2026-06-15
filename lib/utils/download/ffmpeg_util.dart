import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import '../core/log.dart';

typedef StartNative = Int32 Function(Int32 num, Pointer<Pointer<Utf8>> files);
typedef Start = int Function(int num, Pointer<Pointer<Utf8>> files);

/// Native function binding via Dart hooks (Android only).
/// The asset ID matches the CodeAsset registered in hook/build.dart.
@Native<StartNative>(assetId: 'package:miru_alpha/ffmpeg_merge')
external int _startNative(int num, Pointer<Pointer<Utf8>> files);

class FFMpegUtils {
  static late Start start;
  static late DynamicLibrary _lib;
  static bool _isInitialized = false;
  static bool get isAvailable => _isInitialized;

  static void openlib() {
    if (Platform.isMacOS || Platform.isFuchsia) {
      return;
    }

    // On Android, use the hooks-integrated @Native binding
    if (Platform.isAndroid) {
      try {
        start = (int num, Pointer<Pointer<Utf8>> files) =>
            _startNative(num, files);
        _isInitialized = true;
        logger.info('FFmpeg merge loaded via native asset hooks.');
        return;
      } catch (e) {
        logger.severe('Failed to load via native asset hooks: $e');
        // Fall through to DynamicLibrary.open() as fallback
      }
    }

    String libName = Platform.isWindows
        ? 'ffmpeg_merge.dll'
        : 'libffmpeg_merge.so';

    try {
      _lib = DynamicLibrary.open(libName);
      start = _lib.lookupFunction<StartNative, Start>('start');
      _isInitialized = true;
    } catch (e) {
      logger.severe(e);
    }
  }

  static void ensureInitialized() {
    if (_isInitialized) return;
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
