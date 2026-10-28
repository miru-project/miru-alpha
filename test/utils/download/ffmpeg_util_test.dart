@Tags(['ffi'])
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:miru_alpha/provider/cast/cast_media_server.dart';
import 'package:miru_alpha/utils/download/ffmpeg_util.dart';

/// White bottom-center cue used by the libass burn test (libass's default
/// style: white, bottom-center, large enough to move the crop mean).
const _burnSrt = '1\n00:00:01,000 --> 00:00:05,000\nBURN TEST\n';

/// Serves the real Mux Big Buck Bunny HLS over loopback with every URI
/// rewritten to itself. The ENGINE gets a plain-http localhost input — the
/// production shape (ffmpeg opens the localhost miru-core /proxy/ URL while
/// the Go backend does the remote fetches). ffmpeg cannot fetch remotes
/// directly from inside the dart VM under test: its blocking connects get
/// EINTR'd by the VM's signals (production never does this — the /proxy/
/// URL is loopback and dart:io's fetcher is signal-safe).
class _HlsRelay {
  _HlsRelay(this._origin);

  final String _origin;
  final HttpClient _http = HttpClient();
  HttpServer? _server;
  String? _base;

  Future<String> start(String remotePath) async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _base = 'http://127.0.0.1:${_server!.port}';
    _server!.listen(_serve, onError: (_) {});
    return _local(Uri.parse('$_origin$remotePath'));
  }

  String _local(Uri remote) {
    final token = base64Url
        .encode(utf8.encode(remote.toString()))
        .replaceAll('=', '');
    // Keep the remote's extension: ffmpeg's hls demuxer gates segment URLs
    // on an extension whitelist (plus mime sniffing needs a hint).
    final path = remote.path;
    final ext = path.contains('.')
        ? path.substring(path.lastIndexOf('.'))
        : '.ts';
    return '$_base/relay/$token$ext';
  }

  Future<void> _serve(HttpRequest req) async {
    try {
      final token = req.uri.pathSegments[1].split('.').first;
      final remote = Uri.parse(
        utf8.decode(base64Url.decode(base64Url.normalize(token))),
      );
      if (remote.path.toLowerCase().endsWith('.m3u8')) {
        final text = await _fetchText(remote);
        final out = text
            .split('\n')
            .map((line) {
              final t = line.trim();
              if (t.isEmpty || t.startsWith('#')) return line;
              return _local(remote.resolve(t));
            })
            .join('\n');
        req.response.headers.set(
          HttpHeaders.contentTypeHeader,
          'application/vnd.apple.mpegurl',
        );
        req.response.write(out);
        await req.response.close();
      } else {
        final upstream = await (await _http.getUrl(remote)).close();
        if (upstream.statusCode != 200) {
          throw HttpException('${upstream.statusCode} $remote');
        }
        req.response.headers.set(
          HttpHeaders.contentTypeHeader,
          upstream.headers.value(HttpHeaders.contentTypeHeader) ?? 'video/mp2t',
        );
        await upstream.pipe(req.response);
      }
    } catch (_) {
      try {
        req.response.statusCode = 502;
        await req.response.close();
      } catch (_) {}
    }
  }

  Future<String> _fetchText(Uri remote) async {
    final res = await (await _http.getUrl(remote)).close();
    if (res.statusCode != 200) {
      throw HttpException('${res.statusCode} $remote');
    }
    return await utf8.decoder.bind(res).join();
  }

  Future<void> stop() async {
    _http.close(force: true);
    await _server?.close(force: true);
  }
}

void main() {
  group('FFMpegUtils.combineToMp4Async', () {
    // The merge must fail for a nonexistent input — what this pins down is
    // that failures propagate across the isolate boundary and never wedge
    // the serialization queue.
    test('propagates worker-isolate errors to the caller', () async {
      await expectLater(
        FFMpegUtils.combineToMp4Async(['fake.ts'], 'out.mp4'),
        throwsA(anything),
      );
    });

    test('concurrent merges are queued, not deadlocked', () async {
      // If the gate leaked a completer on failure, the second call would
      // await forever and this test would time out.
      final results = await Future.wait([
        FFMpegUtils.combineToMp4Async(['a.ts'], 'out1.mp4').catchError((_) {}),
        FFMpegUtils.combineToMp4Async(['b.ts'], 'out2.mp4').catchError((_) {}),
      ]);
      expect(results.length, 2);
    });
  });

  group('DLNA ffmpeg-proxy stream', () {
    test('native lib exposes the dlna_stream API', () {
      FFMpegUtils.ensureInitialized();
      // Offline-safe: pins the FFI surface (open/pump/seek/position/close)
      // against whatever libffmpeg_merge the build hook produced.
      expect(FFMpegUtils.isAvailable, isTrue);
      expect(FFMpegUtils.streamsAvailable, isTrue);
    });

    /// Locates a WORKING ffmpeg CLI to use as the test oracle (source
    /// generation + output inspection; the engine itself is independent).
    /// Prefers the hook-extracted archives (probed with -version — broken
    /// lib symlinks fail fast), then whatever is on PATH.
    Future<File?> workingFfmpeg() async {
      final dotDart = Directory('.dart_tool');
      if (dotDart.existsSync()) {
        for (final dir in dotDart.listSync().whereType<Directory>()) {
          final exe = File('${dir.path}/bin/ffmpeg');
          if (!exe.existsSync()) continue;
          // The hook extracts archives without preserving the exec bit.
          await Process.run('chmod', ['+x', exe.path]);
          final probe = await Process.run(
            exe.path,
            const ['-version'],
            environment: {'LD_LIBRARY_PATH': '${dir.path}/lib'},
          );
          if (probe.exitCode == 0) return exe;
        }
      }
      final which = await Process.run('which', const ['ffmpeg']);
      if (which.exitCode == 0) {
        final path = (which.stdout as String).trim();
        if (path.isNotEmpty) return File(path);
      }
      return null;
    }

    // Proves the libass-direct burn end to end at the pixel level: a black
    // clip with a white SRT cue (1 s-5 s) is transcoded with the in-engine
    // libass (the same path android uses with fvp's bundled libass.so);
    // the bottom-third luma of the burned output must jump while the cue
    // is active. Uses the bundled ffmpeg CLI for source generation and
    // frame inspection.
    test('libass-direct burn composites subtitles onto frames', () async {
      FFMpegUtils.ensureInitialized();
      if (!FFMpegUtils.libassAvailable) {
        markTestSkipped('no loadable libass on this platform');
        return;
      }
      final ffmpeg = await workingFfmpeg();
      if (ffmpeg == null) {
        markTestSkipped('no working ffmpeg CLI for the test oracle');
        return;
      }
      final tmp = await Directory.systemTemp.createTemp('libass_burn');
      addTearDown(() {
        // MIRU_KEEP_BURN=1 keeps the artifacts for manual inspection.
        if (Platform.environment['MIRU_KEEP_BURN'] == '1') {
          // ignore: avoid_print
          print('KEEP_BURN: ${tmp.path}');
        } else {
          tmp.deleteSync(recursive: true);
        }
      });
      final src = File('${tmp.path}/black.mp4');
      final out = File('${tmp.path}/burned.ts');

      // 6 s of black YUV420P piped into the bundled x264 encoder.
      final gen = await Process.start(ffmpeg.path, [
        '-y',
        '-f',
        'rawvideo',
        '-pix_fmt',
        'yuv420p',
        '-s',
        '320x180',
        '-r',
        '25',
        '-i',
        'pipe:0',
        '-c:v',
        'libx264',
        '-preset',
        'ultrafast',
        src.path,
      ]);
      const w = 320, h = 180;
      final black = Uint8List(w * h * 3 ~/ 2);
      final yPlane = black;
      for (var i = 0; i < w * h; i++) {
        yPlane[i] = 16; // limited-range black
      }
      for (var f = 0; f < 6 * 25; f++) {
        gen.stdin.add(black);
      }
      await gen.stdin.flush();
      await gen.stdin.close();
      if (await gen.exitCode != 0) {
        fail('source generation failed');
      }

      // Burn a white bottom-center cue (SRT converted to ASS — libass
      // parses ASS reliably across builds, raw SRT not).
      final session = DlnaStreamSession.open(
        src.path,
        assSubtitle: DlnaSubtitles.toAss(_burnSrt),
      );
      expect(session, isNotNull, reason: 'libass burn session failed to open');
      final sink = out.openSync(mode: FileMode.write);
      try {
        final deadline = DateTime.now().add(const Duration(seconds: 30));
        while (DateTime.now().isBefore(deadline)) {
          final n = session!.pump();
          if (n == DlnaStreamSession.eagain) {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            continue;
          }
          if (n == 0) break;
          sink.writeFromSync(session.take(n), 0, n);
        }
      } finally {
        sink.closeSync();
        session!.dispose();
      }
      expect(out.lengthSync(), greaterThan(0), reason: 'no burned output');

      // Decode every frame's bottom third in ONE pass, keeping the raw
      // limited-range Y plane (gray conversion would rescale 16→0 and hide
      // the signal). Per frame: 320×60 Y + 160×30 U + 160×30 V.
      const cropW = 320, cropH = 60;
      const frameBytes = cropW * cropH * 3 ~/ 2;
      final probe = await Process.run(ffmpeg.path, [
        '-i',
        out.path,
        '-vf',
        'crop=iw:ih/3:0:2*ih/3',
        '-f',
        'rawvideo',
        '-pix_fmt',
        'yuv420p',
        'pipe:1',
      ], stdoutEncoding: null);
      final raw = probe.stdout as List<int>;
      final frameCount = raw.length ~/ frameBytes;
      expect(frameCount, greaterThan(40), reason: 'too few decoded frames');

      double yMean(int frame) {
        final base = frame * frameBytes;
        var sum = 0;
        for (var i = 0; i < cropW * cropH; i++) {
          sum += raw[base + i];
        }
        return sum / (cropW * cropH);
      }

      // Cue spans 1 s-5 s = frames 25-125; compare against the lead-in.
      var noCue = 0.0, cue = 0.0;
      for (var f = 0; f < 10; f++) {
        noCue += yMean(f);
      }
      noCue /= 10;
      var cueFrames = 0;
      for (var f = 30; f < frameCount && f < 120; f++) {
        cue += yMean(f);
        cueFrames++;
      }
      cue /= cueFrames;
      // ignore: avoid_print
      print(
        'libass burn: bottom-third Y mean cue=$cue noCue=$noCue '
        '($frameCount frames)',
      );
      expect(
        cue,
        greaterThan(noCue + 1.5),
        reason: 'subtitle text did not appear in the burned frames',
      );
    });

    // E2E: streams Mux's Big Buck Bunny HLS (CC-BY, Blender Foundation —
    // the repo's allowed live-resource class) through the in-process ffmpeg
    // proxy to a local HTTP client standing in for the DLNA renderer, and
    // exercises seek + play/pause. Opt-in: MIRU_DLNA_E2E=1 (network).
    test('streams HLS to a local client with audio, seek and pause', () async {
      if (Platform.environment['MIRU_DLNA_E2E'] != '1') {
        markTestSkipped('opt in with MIRU_DLNA_E2E=1 (network)');
        return;
      }
      FFMpegUtils.ensureInitialized();
      expect(FFMpegUtils.streamsAvailable, isTrue);
      // Worker/registry logs are invisible without a root listener in tests.
      Logger.root.onRecord.listen(
        // ignore: avoid_print
        (r) => print(
          '[${r.level.name}] ${r.loggerName}: ${r.message} ${r.error ?? ''}',
        ),
      );

      final relay = _HlsRelay('https://test-streams.mux.dev');
      const remotePath = '/x36xhzz/x36xhzz.m3u8';
      final hls = await relay.start(remotePath);
      addTearDown(relay.stop);

      final server = CastMediaServer.instance;
      final streamUrl = await server.streamUrl(hls);

      final client = HttpClient();
      final response = await (await client.getUrl(
        Uri.parse(streamUrl),
      )).close();
      expect(response.statusCode, 200);

      // The renderer stand-in: count bytes, verify 188-byte TS packet
      // sync (pump output is packet-aligned, so byte i%188==0 must be
      // 0x47 across the whole session — seek restarts included), and
      // keep a snapshot for the audio probe.
      var bytes = 0;
      var scanned = 0;
      var syncOk = true;
      final snapshot = <int>[];
      final subscription = response.listen((chunk) {
        for (final b in chunk) {
          if (scanned % 188 == 0 && b != 0x47) syncOk = false;
          scanned++;
        }
        bytes += chunk.length;
        if (snapshot.length < 2 * 1024 * 1024) snapshot.addAll(chunk);
      });

      // Prebuffer (~2 MB ≈ 1-2 segments) delays the first byte.
      Future<bool> reached(int target) async {
        final deadline = DateTime.now().add(const Duration(seconds: 90));
        var ticks = 0;
        while (bytes < target && DateTime.now().isBefore(deadline)) {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          if (++ticks % 10 == 0) {
            // ignore: avoid_print
            print(
              '… client bytes=$bytes pos='
              '${server.streamPositionOf(hls)?.toStringAsFixed(1)}',
            );
          }
        }
        return bytes >= target;
      }

      expect(
        await reached(1024 * 1024),
        isTrue,
        reason: 'no stream data ($bytes bytes received)',
      );
      expect(syncOk, isTrue, reason: 'TS packet sync broken');
      expect(server.streamCodecs(hls), isNotNull);
      expect(server.streamCodecs(hls)!.video, 'h264');
      expect(server.streamCodecs(hls)!.audio, 'aac');

      // PAUSE: worker stops pumping; the byte counter must flatten.
      CastMediaServer.instance.streamPause(hls, true);
      var flat = 0;
      var last = bytes;
      final pauseDeadline = DateTime.now().add(const Duration(seconds: 6));
      while (DateTime.now().isBefore(pauseDeadline) && flat < 4) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        if (bytes == last) {
          flat++;
        } else {
          flat = 0;
        }
        last = bytes;
      }
      expect(flat, 4, reason: 'bytes kept flowing while paused');

      // PLAY: resume the pump; bytes flow again.
      CastMediaServer.instance.streamPause(hls, false);
      final resumed = bytes;
      expect(
        await reached(resumed + 512 * 1024),
        isTrue,
        reason: 'no bytes after play',
      );

      // SEEK: fresh muxer timeline; position jumps to the target and
      // TS packets keep streaming (alignment held across the restart).
      CastMediaServer.instance.streamSeek(hls, 30);
      final seekDeadline = DateTime.now().add(const Duration(seconds: 20));
      var pos = server.streamPositionOf(hls) ?? 0;
      while ((pos < 28 || pos > 45) && DateTime.now().isBefore(seekDeadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        pos = server.streamPositionOf(hls) ?? 0;
      }
      expect(
        pos,
        inInclusiveRange(28, 45),
        reason: 'position did not jump to the seek target',
      );
      expect(syncOk, isTrue, reason: 'TS sync broken after seek');

      // AUDIO: the received TS carries an AAC audio stream — probed by
      // the engine itself (no ffprobe dependency).
      final tmp = File(
        '${Directory.systemTemp.path}/dlna_e2e_${DateTime.now().millisecondsSinceEpoch}.ts',
      );
      await tmp.writeAsBytes(snapshot);
      final probe = DlnaStreamSession.open(tmp.path, prebufferBytes: 65536);
      addTearDown(() {
        if (tmp.existsSync()) tmp.deleteSync();
      });
      expect(probe, isNotNull, reason: 'snapshot not probeable');
      expect(probe!.audioCodec, 'aac');
      expect(probe.videoCodec, 'h264');
      probe.dispose();

      subscription.cancel();
      client.close(force: true);
      CastMediaServer.instance.streamStop(hls);
    }, timeout: const Timeout(Duration(minutes: 6)));
  });
}
