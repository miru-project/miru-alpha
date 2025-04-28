import 'dart:ffi';

import 'package:ffi/ffi.dart';

typedef StartNative = Int32 Function(Int32 num, Pointer<Pointer<Utf8>> files);
typedef Start = int Function(int num, Pointer<Pointer<Utf8>> files);

class FFMpegUtils {
  static late Start start;
  static late DynamicLibrary _lib;

  static void openlib() {
    _lib = DynamicLibrary.open('libffmpeg_merge.so');
    start = _lib.lookupFunction<StartNative, Start>('start');
  }

  static void ensureInitialized() {
    openlib();
  }

  static void combineTsToMp4(List<String> inputFile, String outputName) {
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
