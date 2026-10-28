import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import '../core/log.dart';

typedef StartNative = Int32 Function(Int32 num, Pointer<Pointer<Utf8>> files);
typedef Start = int Function(int num, Pointer<Pointer<Utf8>> files);

typedef DlnaStreamOpenNative =
    Int32 Function(
      Pointer<Utf8> url,
      Double startSec,
      Int32 prebufferBytes,
      Pointer<Utf8> videoFilter,
      Pointer<Utf8> assSubtitle,
      Pointer<Utf8> httpHeaders,
      Pointer<Utf8> videoCodec,
      Pointer<Utf8> audioCodec,
      Pointer<Pointer<Void>> outStream,
    );
typedef DlnaStreamOpen =
    int Function(
      Pointer<Utf8>,
      double,
      int,
      Pointer<Utf8>,
      Pointer<Utf8>,
      Pointer<Utf8>,
      Pointer<Utf8>,
      Pointer<Utf8>,
      Pointer<Pointer<Void>>,
    );

typedef DlnaHasLibassNative = Int32 Function();
typedef DlnaHasLibass = int Function();

typedef DlnaStreamPumpNative =
    Int32 Function(Pointer<Void> stream, Pointer<Uint8> buf, Int32 cap);
typedef DlnaStreamPump = int Function(Pointer<Void>, Pointer<Uint8>, int);

typedef DlnaStreamSeekNative = Int32 Function(Pointer<Void> stream, Double sec);
typedef DlnaStreamSeek = int Function(Pointer<Void>, double);

typedef DlnaStreamPositionNative = Double Function(Pointer<Void> stream);
typedef DlnaStreamPosition = double Function(Pointer<Void>);

typedef DlnaStreamCloseNative = Void Function(Pointer<Void> stream);
typedef DlnaStreamClose = void Function(Pointer<Void>);

class FFMpegUtils {
  static late Start start;
  static late DlnaStreamOpen streamOpen;
  static late DlnaStreamPump streamPump;
  static late DlnaStreamSeek streamSeek;
  static late DlnaStreamPosition streamPosition;
  static late DlnaStreamClose streamClose;
  static late DynamicLibrary _lib;
  static bool _isInitialized = false;
  static bool _streamsAvailable = false;
  static bool _libassAvailable = false;

  /// True when a loadable libass exists (engine dlna_has_libass): subtitle
  /// burn should pass the subtitle TEXT (libass-direct) instead of building
  /// a drawtext graph.
  static bool get libassAvailable => _libassAvailable;
  static bool get isAvailable => _isInitialized;

  /// True when the native lib carries the dlna_stream_* DLNA streaming API.
  /// False on a stale libffmpeg_merge — the merge path keeps working.
  static bool get streamsAvailable => _streamsAvailable;

  static void openlib() {
    if (Platform.isMacOS || Platform.isFuchsia) {
      return;
    }

    String libName = Platform.isWindows
        ? 'ffmpeg_merge.dll'
        : 'libffmpeg_merge.so';

    try {
      _lib = DynamicLibrary.open(libName);
    } catch (e) {
      // `flutter test` builds the code asset but its hooks_runner output
      // directory is not on the dynamic linker's path — locate the newest
      // build output and open it by absolute path. Production bundles find
      // the plain name on the first attempt.
      final located = _locateHookLib(libName);
      if (located == null) {
        logger.severe(e);
        return;
      }
      try {
        _lib = DynamicLibrary.open(located);
      } catch (e2) {
        logger.severe(e2);
        return;
      }
    }
    start = _lib.lookupFunction<StartNative, Start>('start');
    _isInitialized = true;
    // The streaming API is newer than the merge API; a stale native lib
    // must not take the merge path down with it.
    try {
      streamOpen = _lib.lookupFunction<DlnaStreamOpenNative, DlnaStreamOpen>(
        'dlna_stream_open',
      );
      streamPump = _lib.lookupFunction<DlnaStreamPumpNative, DlnaStreamPump>(
        'dlna_stream_pump',
      );
      streamSeek = _lib.lookupFunction<DlnaStreamSeekNative, DlnaStreamSeek>(
        'dlna_stream_seek',
      );
      streamPosition = _lib
          .lookupFunction<DlnaStreamPositionNative, DlnaStreamPosition>(
            'dlna_stream_position',
          );
      streamClose = _lib.lookupFunction<DlnaStreamCloseNative, DlnaStreamClose>(
        'dlna_stream_close',
      );
      try {
        final hasLibass = _lib
            .lookupFunction<DlnaHasLibassNative, DlnaHasLibass>(
              'dlna_has_libass',
            );
        _libassAvailable = hasLibass() != 0;
      } catch (_) {
        _libassAvailable = false;
      }
      _streamsAvailable = true;
    } catch (e) {
      logger.warning('ffmpeg_merge lacks dlna_stream_* symbols: $e');
    }
  }

  /// Newest ffmpeg_merge build output under the hooks_runner cache that
  /// MATCHES THIS MACHINE'S ARCHITECTURE, or null. The cache accumulates
  /// builds for every target (an android arm64 build from a phone run sits
  /// next to the linux x64 one) — dlopen'ing a foreign-arch .so fails and
  /// silently disables the engine, so verify the ELF machine type.
  static String? _locateHookLib(String name) {
    final root = Directory('.dart_tool/hooks_runner');
    if (!root.existsSync()) return null;
    File? best;
    for (final entity in root.listSync(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith(name)) continue;
      if (!_matchesHostArch(entity)) continue;
      if (best == null ||
          entity.lastModifiedSync().isAfter(best.lastModifiedSync())) {
        best = entity;
      }
    }
    return best?.path;
  }

  /// True when [file] is an ELF shared object for this machine's
  /// architecture (e_machine of the ELF header).
  static bool _matchesHostArch(File file) {
    RandomAccessFile? handle;
    try {
      handle = file.openSync();
      final header = handle.readSync(20);
      if (header.length < 20) return false;
      // \x7fELF magic.
      if (header[0] != 0x7f ||
          header[1] != 0x45 ||
          header[2] != 0x4c ||
          header[3] != 0x46) {
        return false;
      }
      final machine = header[18] | (header[19] << 8); // little-endian e_machine
      return machine == _hostElfMachine;
    } catch (_) {
      return false;
    } finally {
      handle?.closeSync();
    }
  }

  /// e_machine value for the host architecture (dart:ffi Abi).
  static int get _hostElfMachine {
    switch (Abi.current()) {
      case Abi.macosX64 || Abi.linuxX64:
        return 62; // EM_X86_64
      case Abi.macosArm64 || Abi.linuxArm64 || Abi.androidArm64:
        return 183; // EM_AARCH64
      case Abi.linuxIA32 || Abi.androidIA32:
        return 3; // EM_386
      case Abi.linuxArm || Abi.androidArm:
        return 40; // EM_ARM
      default:
        return -1; // unknown — accept nothing
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

/// One DLNA streaming session: ffmpeg remuxes [source] into MPEG-TS in a
/// native FIFO; [pump] hands the bytes out. The context is not thread-shared,
/// so every call must come from the SAME isolate (the pump worker in
/// CastMediaServer owns it and must run [FFMpegUtils.ensureInitialized]
/// first — statics are per-isolate).
class DlnaStreamSession {
  DlnaStreamSession._(
    this._ctx,
    this.videoCodec,
    this.audioCodec,
    this.videoFilter,
  ) : _buffer = malloc<Uint8>(pumpChunk) {
    _view = _buffer.asTypedList(pumpChunk);
  }

  /// Bytes handed to the renderer per pump call. 1 MB keeps the pull round
  /// trips (worker → main → socket → next) amortized at multi-GB/s — the
  /// proxy must never be the transfer bottleneck.
  static const int pumpChunk = 1024 * 1024;

  /// ~1-2 HLS segments buffered before the first byte reaches the renderer
  /// (user requirement: start the TV on a full buffer).
  static const int defaultPrebuffer = 2 * 1024 * 1024;

  static const int _codecNameCap = 32;

  final Pointer<Void> _ctx;
  final Pointer<Uint8> _buffer;
  late final Uint8List _view;

  /// Decoder names of the source's first video/audio streams (from
  /// dlna_stream_open) — the phase-2 transcode rung reads these.
  final String videoCodec;
  final String audioCodec;

  /// The filter graph in effect (null = plain remux). Subtitle re-burns on
  /// seek regenerate this — the worker rebuilds the session.
  final String? videoFilter;

  /// Opens [source]. [videoFilter] (nullable) switches to the transcode
  /// path — a libavfilter graph applied to the video. [assSubtitle]
  /// (nullable) is the raw SRT/ASS text burned by the in-engine libass
  /// (preferred when [FFMpegUtils.libassAvailable]); it takes precedence
  /// over [videoFilter]. Returns null when the native streaming API is
  /// missing or the source cannot be opened; the caller falls back (e.g.
  /// direct URL).
  static DlnaStreamSession? open(
    String source, {
    double startSec = 0,
    int prebufferBytes = defaultPrebuffer,
    String? videoFilter,
    String? assSubtitle,
    String? httpHeaders,
  }) {
    FFMpegUtils.ensureInitialized();
    if (!FFMpegUtils.isAvailable || !FFMpegUtils.streamsAvailable) {
      // Distinguish "engine lib failed to load in this isolate" from a
      // genuine avformat open failure — the latter prints its own reason
      // through the native error logger.
      logger.warning(
        'dlna stream: engine unavailable in this isolate '
        '(libLoaded=${FFMpegUtils.isAvailable}, '
        'streamApi=${FFMpegUtils.streamsAvailable}) — cannot open $source',
      );
      return null;
    }
    final url = source.toNativeUtf8();
    final filter = videoFilter == null ? nullptr : videoFilter.toNativeUtf8();
    final ass = assSubtitle == null ? nullptr : assSubtitle.toNativeUtf8();
    final headers = (httpHeaders == null || httpHeaders.isEmpty)
        ? nullptr
        : httpHeaders.toNativeUtf8();
    final video = calloc<Uint8>(_codecNameCap);
    final audio = calloc<Uint8>(_codecNameCap);
    final out = calloc<Pointer<Void>>();
    try {
      final rc = FFMpegUtils.streamOpen(
        url,
        startSec,
        prebufferBytes,
        filter,
        ass,
        headers,
        video.cast(),
        audio.cast(),
        out,
      );
      if (rc != 0 || out.value == nullptr) return null;
      return DlnaStreamSession._(
        out.value,
        video.cast<Utf8>().toDartString(),
        audio.cast<Utf8>().toDartString(),
        videoFilter,
      );
    } catch (_) {
      return null;
    } finally {
      calloc.free(url);
      if (filter != nullptr) calloc.free(filter);
      if (ass != nullptr) calloc.free(ass);
      if (headers != nullptr) calloc.free(headers);
      calloc.free(video);
      calloc.free(audio);
      calloc.free(out);
    }
  }

  /// The native "try again, no full packet buffered yet" code — pump()
  /// returns it when the ring holds less than one TS packet and the source
  /// is not at EOF yet (never happens while a source keeps flowing).
  static const int eagain = -11;

  /// Next MPEG-TS bytes, valid up to [return value]. 0 = source ended,
  /// [eagain] = no full packet yet (caller waits), other <0 = native error
  /// (the caller closes the renderer connection).
  int pump() {
    final n = FFMpegUtils.streamPump(_ctx, _buffer, pumpChunk);
    if (n < 0 && n != eagain) {
      throw Exception('dlna_stream_pump failed: $n');
    }
    return n;
  }

  /// Zero-copy view of the bytes produced by the last [pump] call — valid
  /// only until the next pump.
  Uint8List take(int bytes) => Uint8List.sublistView(_view, 0, bytes);

  /// Seeks the underlying source; the muxer restarts so the next pump emits
  /// a fresh PAT/PMT timeline from ~0. The renderer is re-pushed by the
  /// provider afterwards.
  void seek(double sec) {
    final rc = FFMpegUtils.streamSeek(_ctx, sec);
    if (rc != 0) {
      throw Exception('dlna_stream_seek failed: $rc');
    }
  }

  /// Playback position in seconds (seek target + media time muxed so far).
  /// Advisory — feeds the sync loop and the UI.
  double position() => FFMpegUtils.streamPosition(_ctx);

  void dispose() {
    FFMpegUtils.streamClose(_ctx);
    malloc.free(_buffer);
  }
}

/// SRT → drawtext filtergraph for the subtitle-burn transcode path.
///
/// The prebuilt ffmpeg builds lack libass (ass/subtitles filter), so SRT is
/// burned through a drawtext chain — one instance per cue, gated with
/// `enable=between(t,a,b)`. Cue times are ORIGINAL media time: the filter
/// runs before the rebase-to-zero shift. On a seek the provider regenerates
/// the graph for the new window (cue times stay absolute, so the graph only
/// needs re-windowing, not re-timing). A build that ships libass can use
/// `ass=<file>` directly — the graph string is caller-chosen.
class DlnaSubtitles {
  DlnaSubtitles._();

  static final RegExp _timing = RegExp(
    r'(\d+):(\d+):(\d+)[,.](\d+)\s*-->\s*(\d+):(\d+):(\d+)[,.](\d+)',
  );
  static final RegExp _tags = RegExp(r'<[^>]*>');

  /// One parsed SRT cue.
  static List<({double start, double end, String text})> parse(String srt) {
    final cues = <({double start, double end, String text})>[];
    for (final block in srt.split(RegExp(r'\r?\n\r?\n'))) {
      final lines = block.split(RegExp(r'\r?\n'))
        ..removeWhere((l) => l.trim().isEmpty);
      if (lines.isEmpty) continue;
      final timing = _timing.firstMatch(lines.first);
      final textLines = timing == null ? lines : lines.skip(1).toList();
      if (timing == null) {
        // timing may be on the second line (index line first)
        for (final l in lines.skip(1)) {
          final m = _timing.firstMatch(l);
          if (m != null) {
            textLines.remove(l);
            break;
          }
        }
      }
      final m = timing ?? _timing.firstMatch(block);
      if (m == null || textLines.isEmpty) continue;
      double t(int i) =>
          int.parse(m.group(i)!) * 3600 +
          int.parse(m.group(i + 1)!) * 60 +
          int.parse(m.group(i + 2)!) +
          int.parse(m.group(i + 3)!) / 1000.0;
      final text = textLines
          .map((l) => l.replaceAll(_tags, '').trim())
          .where((l) => l.isNotEmpty)
          .join('\n');
      if (text.isEmpty) continue;
      cues.add((start: t(1), end: t(5), text: text));
    }
    cues.sort((a, b) => a.start.compareTo(b.start));
    return cues;
  }

  /// Converts subtitle text to the ASS format libass reliably parses.
  /// Many libass builds (including the system library on Arch and fvp's
  /// bundled android libass.so) fail to parse raw SRT via ass_read_memory;
  /// ASS always works. [text] that is already ASS passes through untouched.
  static String toAss(String text) {
    final trimmed = text.trimLeft();
    if (trimmed.startsWith('[Script Info]')) return text;
    final ass = StringBuffer()
      ..writeln('[Script Info]')
      ..writeln('ScriptType: v4.00+')
      ..writeln('PlayResX: 384')
      ..writeln('PlayResY: 288')
      ..writeln('WrapStyle: 0')
      ..writeln('ScaledBorderAndShadow: yes')
      ..writeln()
      ..writeln('[V4+ Styles]')
      ..writeln(
        'Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, '
        'OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, '
        'ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, '
        'Alignment, MarginL, MarginR, MarginV, Encoding',
      )
      ..writeln(
        'Style: Default,Arial,24,&H00FFFFFF,&H000000FF,&H00000000,'
        '&H64000000,0,0,0,0,100,100,0,0,1,2,0,2,15,15,15,1',
      )
      ..writeln()
      ..writeln('[Events]')
      ..writeln(
        'Format: Layer, Start, End, Style, Name, MarginL, MarginR, '
        'MarginV, Effect, Text',
      );
    String stamp(double sec) {
      final h = sec ~/ 3600;
      final m = (sec - h * 3600) ~/ 60;
      final s = (sec - h * 3600 - m * 60).floor();
      final cs = ((sec - sec.floor()) * 100).round().clamp(0, 99);
      return '$h:${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}.${cs.toString().padLeft(2, '0')}';
    }

    for (final cue in parse(text)) {
      final body = cue.text.replaceAll('\n', r'\N');
      ass.writeln(
        'Dialogue: 0,${stamp(cue.start)},${stamp(cue.end)},Default,,0,0,0,,'
        '$body',
      );
    }
    return ass.toString();
  }

  /// Builds a drawtext graph burning cues inside [startSec, startSec +
  /// windowSec] from [srt]. Cue text files land in [dir] (caller cleans up).
  /// Returns null when the SRT has no cues in the window.
  static String? buildGraph(
    String srt, {
    required double startSec,
    required Directory dir,
    double windowSec = 600,
    int maxCues = 80,
  }) {
    final cues = parse(srt)
        .where((c) => c.end > startSec && c.start < startSec + windowSec)
        .take(maxCues)
        .toList();
    if (cues.isEmpty) return null;
    final font = findFont();
    final fontPart = font == null ? '' : "fontfile='$font':";
    final parts = <String>[];
    for (var i = 0; i < cues.length; i++) {
      final file = File('${dir.path}/c$i.txt');
      file.writeAsStringSync(cues[i].text);
      final path = file.path.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
      final a = (cues[i].start - startSec).clamp(0, cues[i].end - startSec);
      final b = cues[i].end - startSec;
      parts.add(
        "drawtext=${fontPart}textfile='$path':fontcolor=white:fontsize=26"
        ':box=1:boxcolor=black@0.55:boxborderw=12'
        ':x=(w-text_w)/2:y=h-th-60'
        ":enable='between(t,${a.toStringAsFixed(2)},${b.toStringAsFixed(2)})'",
      );
    }
    return parts.join(',');
  }

  /// Removes a cue-text directory created by [buildGraph].
  static void cleanup(Directory dir) {
    try {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    } catch (_) {}
  }

  /// First usable TTF on this system (drawtext needs an explicit font —
  /// the prebuilt builds ship fontconfig but drawtext still wants a file).
  static String? findFont() {
    const candidates = [
      '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
      '/usr/share/fonts/dejavu/DejaVuSans.ttf',
      '/usr/share/fonts/TTF/DejaVuSans.ttf',
      '/system/fonts/Roboto-Regular.ttf',
      '/system/fonts/DroidSans.ttf',
      'C:\\Windows\\Fonts\\arial.ttf',
      'C:\\Windows\\Fonts\\segoeui.ttf',
    ];
    for (final path in candidates) {
      if (File(path).existsSync()) return path;
    }
    return null;
  }
}
