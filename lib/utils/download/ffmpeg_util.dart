import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

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

  /// Chain of in-flight merges. The native ffmpeg_merge library keeps
  /// conversion state in globals, and every isolate in the process shares
  /// one dlopen'd copy of the library, so merges must run one at a time.
  static Future<void> _mergeChain = Future<void>.value();

  /// Runs [combineToMp4] on a short-lived worker isolate so a long merge
  /// never blocks the UI thread (a frozen "Converting" tile previously let
  /// stray cancel taps race the post-conversion cleanup).
  ///
  /// Calls are serialized through an internal queue: only one merge executes
  /// at a time because of the shared native globals. Any error thrown by the
  /// merge is rethrown to the awaiting caller.
  static Future<void> combineToMp4Async(
    List<String> inputFile,
    String outputName,
  ) async {
    final gate = Completer<void>();
    final previous = _mergeChain;
    _mergeChain = gate.future;
    await previous;
    try {
      await Isolate.run(() {
        // Statics are per-isolate: the library must be opened here too.
        ensureInitialized();
        combineToMp4(inputFile, outputName);
      });
    } finally {
      gate.complete();
    }
  }
}
