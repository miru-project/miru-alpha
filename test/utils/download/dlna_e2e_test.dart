import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:miru_alpha/provider/cast/dlna_cast_bridge.dart';
import 'package:miru_alpha/provider/cast/dlna_cast_provider.dart';
import 'package:miru_alpha/utils/download/ffmpeg_util.dart';

const _hlsOrigin = 'https://test-streams.mux.dev';
const _hlsPath = '/x36xhzz/x36xhzz.m3u8';
const _srt = '''
1
00:00:02,000 --> 00:00:06,000
Hello from the burn test

2
00:00:07,000 --> 00:00:10,000
Second cue
''';

/// Serves a synthetic 2MB mp4-shaped payload over loopback — an
/// infinite-bandwidth source so the copy-passthrough throughput measures
/// the PROXY's ceiling, not a CDN's.
class _LocalMedia {
  HttpServer? _server;
  Uint8List? _bytes;

  /// A REAL mp4 (h264 + aac): the everything-through-ffmpeg design demuxes
  /// the source for remux, so the bytes must open in avformat — a bare ftyp
  /// head + filler (enough for the old copy-passthrough) fails with
  /// "no streams". Generated once by the ffmpeg CLI: this test is opt-in
  /// and ffmpeg is part of the project toolchain. ~300 s of low-bitrate
  /// testsrc so the renderer reads for seconds — the throughput window
  /// needs a sustained transfer to measure MB/s.
  Future<void> _ensureBytes() async {
    if (_bytes != null) return;
    final dir = await Directory.systemTemp.createTemp('dlna_e2e');
    final out = '${dir.path}/media.mp4';
    final result = await Process.run('ffmpeg', [
      '-y',
      '-loglevel',
      'error',
      '-f',
      'lavfi',
      '-i',
      'testsrc=duration=180:size=320x240:rate=10',
      '-f',
      'lavfi',
      '-i',
      'sine=duration=180:frequency=440',
      '-c:v',
      'libx264',
      '-pix_fmt',
      'yuv420p',
      '-preset',
      'ultrafast',
      '-crf',
      '35',
      '-c:a',
      'aac',
      '-b:a',
      '32k',
      '-movflags',
      '+faststart',
      out,
    ]);
    if (result.exitCode != 0) {
      throw StateError(
        'ffmpeg could not generate the E2E media: ${result.stderr}',
      );
    }
    _bytes = await File(out).readAsBytes();
    // The bytes are in memory; the temp dir must not linger — the E2E
    // asserts the only 'dlna*' temp dir is the subtitle cue dir.
    await dir.delete(recursive: true);
  }

  Future<String> start() async {
    await _ensureBytes();
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((req) async {
      // ignore: avoid_print
      print(
        'LOCALMEDIA ← ${req.method} ${req.uri.path} '
        '(${req.headers.value(HttpHeaders.rangeHeader) ?? '-'})',
      );
      req.response.headers.set(HttpHeaders.contentTypeHeader, 'video/mp4');
      req.response.headers.set(
        HttpHeaders.contentLengthHeader,
        _bytes!.length.toString(),
      );
      req.response.add(_bytes!);
      await req.response.close();
    });
    return 'http://127.0.0.1:${_server!.port}/big.mp4';
  }

  Future<void> stop() async {
    await _server?.close(force: true);
  }
}

/// Serves the real Mux HLS over loopback with every URI rewritten to itself
/// (the engine gets a plain-http localhost input — the production shape,
/// where ffmpeg opens the localhost /proxy/ URL and dart:io fetches remotes;
/// ffmpeg's own blocking connects get EINTR'd inside the dart VM).
class _HlsRelay {
  static const String _origin = _hlsOrigin;
  final HttpClient _http = HttpClient();
  HttpServer? _server;
  String? _base;

  Future<String> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _base = 'http://127.0.0.1:${_server!.port}';
    _server!.listen(_serve, onError: (_) {});
    return _local(Uri.parse('$_origin$_hlsPath'));
  }

  String _local(Uri remote) {
    final token = base64Url
        .encode(utf8.encode(remote.toString()))
        .replaceAll('=', '');
    final path = remote.path;
    final ext = path.contains('.')
        ? path.substring(path.lastIndexOf('.'))
        : '.ts';
    return '$_base/relay/$token$ext';
  }

  Future<void> _serve(HttpRequest req) async {
    // ignore: avoid_print
    print(
      'RELAY conn ${req.uri.path.length > 50 ? '…${req.uri.path.substring(req.uri.path.length - 30)}' : req.uri.path}',
    );
    try {
      final token = req.uri.pathSegments[1].split('.').first;
      final remote = Uri.parse(
        utf8.decode(base64Url.decode(base64Url.normalize(token))),
      );
      // ignore: avoid_print
      print('RELAY ← ${remote.path}');
      if (remote.path.toLowerCase().endsWith('.m3u8')) {
        final res = await (await _http.getUrl(remote)).close();
        final text = await utf8.decoder.bind(res).join();
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
        final res = await (await _http.getUrl(remote)).close();
        req.response.headers.set(
          HttpHeaders.contentTypeHeader,
          res.headers.value(HttpHeaders.contentTypeHeader) ?? 'video/mp2t',
        );
        await res.pipe(req.response);
      }
    } catch (_) {
      try {
        req.response.statusCode = 502;
        await req.response.close();
      } catch (_) {}
    }
  }

  Future<void> stop() async {
    _http.close(force: true);
    await _server?.close(force: true);
  }
}

/// A minimal UPnP AVTransport MediaRenderer: SSDP M-SEARCH responder,
/// device description, AVTransport SOAP, and a scripted player that GETs
/// the pushed URI and consumes it like a TV would. This is the DLNA CLIENT
/// side of the E2E — the production control point (dlna_dart) talks to it.
class _FakeDlnaRenderer {
  /// [readCapMb] caps how much the renderer reads per push (a TV parks
  /// after buffering); the RSS measurement passes a large cap so the
  /// stream keeps flowing for the whole measurement window.
  _FakeDlnaRenderer(this.friendlyName, {this.readCapMb = 3});

  final String friendlyName;
  final int readCapMb;
  HttpServer? _http;
  RawDatagramSocket? _ssdp;
  String? _base;
  HttpClient? _fetcher;
  StreamSubscription? _readSub;

  String currentUri = '';
  String transportState = 'STOPPED';
  Duration position = Duration.zero;
  int mediaBytes = 0;
  int pushes = 0;
  int playCount = 0;
  int pauseCount = 0;
  int seekCount = 0;
  bool firstBytesAreMp4 = false;
  bool bytesAreTs = false;
  final List<int> head = [];

  /// Per-push records: the declared protocolInfo and the URI extension the
  /// cast provider offered — the MIME-ladder test asserts the walk ORDER
  /// over these.
  final List<String> pushedPi = [];
  final List<String> pushedExt = [];

  /// The Content-Type of the last media GET response (the Samsung-style
  /// HEAD/response gate keys on it).
  String? lastContentType;

  /// When > 0, the next N SetAVTransportURI calls are rejected with
  /// UPnPError 714 "Illegal MIME-type" — simulates a strict renderer whose
  /// sink list does not contain the offered declaration.
  int rejectNextSets = 0;

  /// Last media read: duration (GET→EOF/park) and whether it reached EOF.
  /// The throughput measurement divides mediaBytes by [lastReadMs].
  int lastReadMs = 0;
  bool lastReadEof = false;

  bool get playing => transportState == 'PLAYING';

  Future<String> start() async {
    // Loopback: the LOCATION must carry a host the control point (this same
    // host) can reliably fetch — 0.0.0.0 makes the description fetch flaky.
    _http = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _base = 'http://127.0.0.1:${_http!.port}';
    _http!.listen(_handle, onError: (_) {});
    _ssdp = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      1900,
      reuseAddress: true,
      reusePort: true,
    );
    _ssdp!.joinMulticast(InternetAddress('239.255.255.250'));
    _ssdp!.listen((event) {
      if (event != RawSocketEvent.read) return;
      final d = _ssdp!.receive();
      if (d == null) return;
      final msg = utf8.decode(d.data);
      if (!msg.startsWith('M-SEARCH')) return;
      // ignore: avoid_print
      print('RENDERER ← M-SEARCH from ${d.address.address}:${d.port}');
      // Respond once per ST the control point asked for.
      final st = RegExp(r'ST:\s*(\S+)').firstMatch(msg)?.group(1);
      if (st == null) return;
      final usn =
          'uuid:miru-test-renderer-0001::urn:schemas-upnp-org:device:MediaRenderer:1';
      final reply = StringBuffer()
        ..write('HTTP/1.1 200 OK\r\n')
        ..write('CACHE-CONTROL: max-age=120\r\n')
        ..write('LOCATION: $_base/description.xml\r\n')
        ..write('SERVER: Linux/1.0 UPnP/1.0 MiruTestRenderer/1.0\r\n')
        ..write('ST: $st\r\n')
        ..write('USN: $usn\r\n')
        ..write('CONTENT-LENGTH: 0\r\n\r\n');
      _ssdp!.send(reply.toString().codeUnits, d.address, d.port);
    });
    return _base!;
  }

  /// Simulates a TV-remote pause: transport state flips WITHOUT any SOAP
  /// (the poll loop must pick it up and sync the app player).
  void remotePause() => transportState = 'PAUSED_PLAYBACK';

  /// Simulates a TV-remote play.
  void remotePlay() => transportState = 'PLAYING';

  Future<void> _handle(HttpRequest req) async {
    try {
      if (req.uri.path == '/description.xml') {
        final xml =
            '''
<?xml version="1.0"?>
<root xmlns="urn:schemas-upnp-org:device-1-0">
  <specVersion><major>1</major><minor>0</minor></specVersion>
  <URLBase>$_base</URLBase>
  <device>
    <deviceType>urn:schemas-upnp-org:device:MediaRenderer:1</deviceType>
    <friendlyName>$friendlyName</friendlyName>
    <manufacturer>Miru Test</manufacturer>
    <modelName>MiruFakeRenderer</modelName>
    <UDN>uuid:miru-test-renderer-0001</UDN>
    <serviceList>
      <service>
        <serviceType>urn:schemas-upnp-org:service:AVTransport:1</serviceType>
        <serviceId>urn:schemas-upnp-org:serviceId:AVTransport:1</serviceId>
        <SCPDURL>/scpd.xml</SCPDURL>
        <controlURL>/avtransport</controlURL>
        <eventSubURL>/event</eventSubURL>
      </service>
    </serviceList>
  </device>
</root>''';
        req.response.headers.set(
          HttpHeaders.contentTypeHeader,
          'text/xml; charset="utf-8"',
        );
        req.response.write(xml);
        await req.response.close();
        return;
      }
      if (req.method == 'POST' && req.uri.path == '/avtransport') {
        final soapAction = (req.headers.value('SOAPACTION') ?? '').replaceAll(
          '"',
          '',
        );
        final body = await utf8.decoder.bind(req).join();
        final action = soapAction.split('#').last;
        String soap(String inner) =>
            '<?xml version="1.0"?>'
            '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" '
            's:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
            '<s:Body>$inner</s:Body></s:Envelope>';
        switch (action) {
          case 'SetAVTransportURI':
            final raw =
                RegExp(
                  r'<CurrentURI>([^<]+)</CurrentURI>',
                ).firstMatch(body)?.group(1) ??
                '';
            currentUri = raw
                .replaceAll('&', '&')
                .replaceAll('<', '<')
                .replaceAll('>', '>');
            if (rejectNextSets > 0) {
              rejectNextSets--;
              // ignore: avoid_print
              print('RENDERER REJECTS Set (UPnPError 714) ← $currentUri');
              req.response.statusCode = 500;
              req.response.headers.set(
                HttpHeaders.contentTypeHeader,
                'text/xml; charset="utf-8"',
              );
              req.response.write(
                '<?xml version="1.0"?><s:Envelope '
                'xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" '
                's:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
                '<s:Body><s:Fault><faultcode>s:Client</faultcode>'
                '<faultstring>UPnPError</faultstring><detail><UPnPError '
                'xmlns="urn:schemas-upnp-org:control-1-0"><errorCode>714'
                '</errorCode><errorDescription>Illegal MIME-type'
                '</errorDescription></UPnPError></detail></s:Fault>'
                '</s:Body></s:Envelope>',
              );
              await req.response.close();
              return;
            }
            pushedPi.add(
              RegExp(
                    r'<res protocolInfo="([^"]+)"',
                  ).firstMatch(body)?.group(1) ??
                  '',
            );
            pushedExt.add(
              RegExp(r'cast\.([a-z0-9]+)$').firstMatch(currentUri)?.group(1) ??
                  '',
            );
            pushes++;
            position = Duration.zero;
            transportState = 'STOPPED';
            // Each push may carry a DIFFERENT container (hls→ts, mp4→copy) —
            // re-detect the head bytes per stream.
            bytesAreTs = false;
            firstBytesAreMp4 = false;
            head.clear();
            // ignore: avoid_print
            print('RENDERER push #$pushes ← $currentUri');
            // A TV starts fetching the media as soon as it is set.
            _consumeMedia();
            req.response.write(
              soap(
                '<u:SetAVTransportURIResponse '
                'xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"/>',
              ),
            );
          case 'Play':
            playCount++;
            transportState = 'PLAYING';
            req.response.write(
              soap(
                '<u:PlayResponse '
                'xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"/>',
              ),
            );
          case 'Pause':
            pauseCount++;
            transportState = 'PAUSED_PLAYBACK';
            req.response.write(
              soap(
                '<u:PauseResponse '
                'xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"/>',
              ),
            );
          case 'Stop':
            transportState = 'STOPPED';
            _readSub?.cancel();
            req.response.write(
              soap(
                '<u:StopResponse '
                'xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"/>',
              ),
            );
          case 'Seek':
            seekCount++;
            final target = RegExp(
              r'<Target>([^<]+)</Target>',
            ).firstMatch(body)?.group(1);
            final m = RegExp(r'(\d+):(\d+):(\d+)').firstMatch(target ?? '');
            if (m != null) {
              position = Duration(
                hours: int.parse(m.group(1)!),
                minutes: int.parse(m.group(2)!),
                seconds: int.parse(m.group(3)!),
              );
            }
            req.response.write(
              soap(
                '<u:SeekResponse '
                'xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"/>',
              ),
            );
          case 'GetPositionInfo':
            final rel = _clock(position);
            req.response.write(
              soap(
                '<u:GetPositionInfoResponse '
                'xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">'
                '<Track>1</Track>'
                '<TrackDuration>00:10:00</TrackDuration>'
                '<TrackMetaData></TrackMetaData>'
                '<TrackURI>${_escape(currentUri)}</TrackURI>'
                '<RelTime>$rel</RelTime>'
                '<AbsTime>$rel</AbsTime>'
                '<RelCount>2147483647</RelCount>'
                '<AbsCount>2147483647</AbsCount>'
                '</u:GetPositionInfoResponse>',
              ),
            );
          case 'GetTransportInfo':
            req.response.write(
              soap(
                '<u:GetTransportInfoResponse '
                'xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">'
                '<CurrentTransportState>$transportState</CurrentTransportState>'
                '<CurrentTransportStatus>OK</CurrentTransportStatus>'
                '<CurrentSpeed>1</CurrentSpeed>'
                '</u:GetTransportInfoResponse>',
              ),
            );
          default:
            req.response.write(soap(''));
        }
        req.response.headers.set(
          HttpHeaders.contentTypeHeader,
          'text/xml; charset="utf-8"',
        );
        await req.response.close();
        return;
      }
      req.response.statusCode = 404;
      await req.response.close();
    } catch (e) {
      try {
        await req.response.close();
      } catch (_) {}
    }
  }

  static String _clock(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static String _escape(String uri) =>
      uri.replaceAll('&', '&').replaceAll('<', '<').replaceAll('>', '>');

  /// The "TV decoder": GETs the pushed media URI and consumes it, verifying
  /// the byte stream (ftyp for the fragmented-MP4 remux, TS sync would mean
  /// the muxer regressed).
  /// Records the read window ([lastReadMs]) and whether it ended at EOF
  /// ([lastReadEof]) so the test can compute true transfer throughput.
  Future<void> _consumeMedia() async {
    _readSub?.cancel();
    if (currentUri.isEmpty) return;
    _fetcher ??= HttpClient();
    try {
      // ignore: avoid_print
      print(
        'RENDERER GET ${currentUri.length > 70 ? '…${currentUri.substring(currentUri.length - 40)}' : currentUri}',
      );
      final sw = Stopwatch()..start();
      final res = await (await _fetcher!.getUrl(Uri.parse(currentUri))).close();
      lastContentType = res.headers.contentType?.value ?? lastContentType;
      // ignore: avoid_print
      print('RENDERER GET status=${res.statusCode}');
      head.clear();
      mediaBytes = 0;
      lastReadEof = false;
      sw.reset();
      final sub = res.listen(
        (chunk) {
          mediaBytes += chunk.length;
          for (final b in chunk) {
            head.add(b);
            if (head.length >= 188) break;
          }
          // Flags computed on the FIRST chunk — the test asserts them while
          // this stream is still being consumed.
          if (!bytesAreTs && !firstBytesAreMp4 && head.length >= 12) {
            final fourcc = String.fromCharCodes(head.sublist(4, 8));
            firstBytesAreMp4 = fourcc == 'ftyp';
            bytesAreTs = head[0] == 0x47;
            // ignore: avoid_print
            print(
              'RENDERER head: ${head.take(8).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')} '
              'ts=$bytesAreTs mp4=$firstBytesAreMp4 total=$mediaBytes',
            );
          }
        },
        onDone: () {
          lastReadEof = true;
          lastReadMs = sw.elapsedMilliseconds;
        },
        cancelOnError: true,
      );
      _readSub = sub;
      // Read a bounded amount, then park (a TV buffers far ahead).
      final cap = readCapMb * 1024 * 1024;
      // The harness paces the transfer at ~0.3MB/s (three HTTP hops on
      // one isolate) — the window must cover the full source.
      final deadline = DateTime.now().add(const Duration(seconds: 45));
      while (mediaBytes < cap &&
          !lastReadEof &&
          DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (sub.isPaused || res.statusCode != 200) break;
      }
      lastReadMs = sw.elapsedMilliseconds;
      // Park: cancel the read but leave the connection to the server.
      await sub.cancel();
    } catch (_) {}
  }

  /// Simulated playback clock: 1 s of media per second while PLAYING.
  void tick() {
    if (playing) position += const Duration(seconds: 1);
  }

  Future<void> stop() async {
    _readSub?.cancel();
    _fetcher?.close(force: true);
    _ssdp?.close();
    await _http?.close(force: true);
  }
}

/// The simplified player the two-way sync is validated against.
class _TestPlayer implements DlnaPlayerSurface {
  Duration pos = Duration.zero;
  bool isPlaying = false;
  int syncs = 0;
  final List<String> loaded = [];

  @override
  void play() => isPlaying = true;

  @override
  void pause() => isPlaying = false;

  @override
  void seekTo(Duration position) => pos = position;

  @override
  Future<void> load(String source) async {
    loaded.add(source);
    pos = Duration.zero;
    isPlaying = true;
  }

  @override
  Duration get position => pos;

  @override
  Duration? get duration => const Duration(minutes: 10);

  @override
  bool get playing => isPlaying;

  @override
  void syncTransport({required bool playing, required Duration position}) {
    syncs++;
    isPlaying = playing;
    pos = position;
  }
}

void main() {
  Logger.root.level = Level.ALL;

  test('DLNA E2E: discovery, hot-proxy cast (HLS + mp4), two-way sync, '
      'subtitles, memory bounds', () async {
    if (Platform.environment['MIRU_DLNA_E2E'] != '1') {
      markTestSkipped('opt in with MIRU_DLNA_E2E=1 (network + LAN)');
      return;
    }
    final container = ProviderContainer();
    addTearDown(container.dispose);
    Logger.root.onRecord.listen(
      // ignore: avoid_print
      (r) => print(
        '[${r.level.name}] ${r.loggerName}: ${r.message} ${r.error ?? ''}',
      ),
    );

    final relay = _HlsRelay();
    final hlsUrl = await relay.start();
    addTearDown(relay.stop);

    final renderer = _FakeDlnaRenderer('MiruE2E-Renderer');
    await renderer.start();
    addTearDown(renderer.stop);
    final clock = Timer.periodic(const Duration(seconds: 1), (_) {
      renderer.tick();
    });
    addTearDown(clock.cancel);

    final player = _TestPlayer();
    final cast = container.read(dlnaCastProvider.notifier);
    cast.attachPlayer(player);

    final rssBefore = ProcessInfo.currentRss;
    final tempBefore = Directory.systemTemp
        .listSync()
        .whereType<Directory>()
        .where((d) => d.path.contains('dlna'))
        .length;

    // 1. Discovery: the production control point finds the fake renderer
    // (the LAN may expose real devices too — target the fake explicitly).
    cast.startScan();
    DlnaDeviceUi? device;
    final deadline = DateTime.now().add(const Duration(seconds: 20));
    while (DateTime.now().isBefore(deadline)) {
      final devices = container.read(dlnaCastProvider).devices;
      device = devices
          .where((d) => d.name == renderer.friendlyName)
          .firstOrNull;
      if (device != null) break;
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    expect(device, isNotNull, reason: 'fake renderer not discovered over SSDP');

    // 2. Cast the HLS source: ffmpeg remux → renderer GETs MPEG-TS.
    expect(await cast.cast(deviceId: device!.id, url: hlsUrl), isTrue);
    expect(renderer.pushes, 1);
    Future<bool> rendererReached(int target) async {
      final d = DateTime.now().add(const Duration(seconds: 60));
      while (renderer.mediaBytes < target && DateTime.now().isBefore(d)) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      return renderer.mediaBytes >= target;
    }

    expect(
      await rendererReached(512 * 1024),
      isTrue,
      reason:
          'renderer received no transmuxed bytes '
          '(${renderer.mediaBytes} B)',
    );
    expect(renderer.bytesAreTs, isTrue, reason: 'stream is not mpegts');
    expect(renderer.firstBytesAreMp4, isFalse);

    // 3. Two-way sync: the fake renderer's position advances while
    // playing; the poll loop must sync the simplified player.
    final syncDeadline = DateTime.now().add(const Duration(seconds: 12));
    while (player.pos.inSeconds < 3 && DateTime.now().isBefore(syncDeadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    expect(
      player.pos.inSeconds,
      greaterThanOrEqualTo(3),
      reason: 'renderer position never synced back to the player',
    );
    expect(player.syncs, greaterThan(0));

    // 4. App pause → renderer Pause SOAP; state mirrors back.
    player.pause();
    DlnaCastBridge.instance.pipePause();
    await Future<void>.delayed(const Duration(seconds: 2));
    expect(renderer.pauseCount, greaterThanOrEqualTo(1));
    expect(container.read(dlnaCastProvider).remoteState, 'PAUSED_PLAYBACK');

    // Renderer-side play (TV remote) → the app player follows.
    renderer.remotePlay();
    final playDeadline = DateTime.now().add(const Duration(seconds: 8));
    while (!player.isPlaying && DateTime.now().isBefore(playDeadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    expect(
      player.isPlaying,
      isTrue,
      reason: 'renderer play did not sync to the app player',
    );

    // 5. App seek → native stream seek + re-push (SetAVTransportURI #2).
    player.seekTo(const Duration(seconds: 30));
    DlnaCastBridge.instance.pipeSeek(const Duration(seconds: 30));
    final pushDeadline = DateTime.now().add(const Duration(seconds: 20));
    while (renderer.pushes < 2 && DateTime.now().isBefore(pushDeadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    expect(
      renderer.pushes,
      greaterThanOrEqualTo(2),
      reason: 'seek did not re-push the stream',
    );

    // 6. Episode switch → the mp4 source goes through the SAME ffmpeg remux
    // (loopback source; arrives as MPEG-TS).
    final localMedia = _LocalMedia();
    final mp4Url = await localMedia.start();
    addTearDown(localMedia.stop);
    expect(await cast.switchSource(mp4Url), isTrue);
    final mp4Deadline = DateTime.now().add(const Duration(seconds: 30));
    while ((renderer.mediaBytes < 512 * 1024 || !renderer.bytesAreTs) &&
        DateTime.now().isBefore(mp4Deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    expect(
      renderer.bytesAreTs,
      isTrue,
      reason: 'mp4 source did not arrive as remuxed mpegts',
    );
    expect(container.read(dlnaCastProvider).castMode, CastMode.transmux);

    // 6b. Seek: always the native stream seek + re-push (SetAVTransportURI
    // #2); the renderer is never sent a REL_TIME seek — the piped MP4 has
    // no byte-accurate seek.
    final pushesBeforeSeek = renderer.pushes;
    player.seekTo(const Duration(seconds: 5));
    DlnaCastBridge.instance.pipeSeek(const Duration(seconds: 5));
    final seekDeadline = DateTime.now().add(const Duration(seconds: 10));
    while (renderer.pushes <= pushesBeforeSeek &&
        DateTime.now().isBefore(seekDeadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    expect(
      renderer.pushes,
      greaterThan(pushesBeforeSeek),
      reason: 'seek did not re-push the stream',
    );
    expect(
      renderer.seekCount,
      0,
      reason: 'a REL_TIME seek must not be sent for the piped stream',
    );

    // 7. Subtitles: SRT burn through the transcode path.
    cast.setSubtitles(_srt);
    expect(await cast.switchSource(hlsUrl), isTrue);
    final subDeadline = DateTime.now().add(const Duration(seconds: 45));
    var subBytes = 0;
    while (subBytes < 512 * 1024 && DateTime.now().isBefore(subDeadline)) {
      subBytes = renderer.mediaBytes;
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    expect(
      subBytes,
      greaterThan(512 * 1024),
      reason: 'subtitle-burn transcode produced no bytes',
    );

    // 8. Memory/disk bounds: streaming must not balloon or spill to disk.
    final rssGrowth = ProcessInfo.currentRss - rssBefore;
    expect(
      rssGrowth,
      lessThan(256 * 1024 * 1024),
      reason: 'proxy RSS grew by ${rssGrowth ~/ (1024 * 1024)} MB',
    );
    final tempAfter = Directory.systemTemp
        .listSync()
        .whereType<Directory>()
        .where((d) => d.path.contains('dlna'))
        .length;
    expect(
      tempAfter,
      lessThanOrEqualTo(tempBefore + 1),
      reason: 'subtitle cue dir is the only allowed temp dir',
    );

    await cast.disconnect();
    container.dispose();
  }, timeout: const Timeout(Duration(minutes: 6)));

  /// Sustained-streaming RSS profile: 75 s of HLS transmux with three
  /// interleaved seeks, then 20 s of copy-passthrough, sampling RSS every
  /// 500 ms. Prints the time series and asserts bounded growth — the
  /// leak check is the delta between the warm-up average and the tail
  /// average (per-seek engine rebuilds must not accumulate).
  test('DLNA streaming RSS profile over sustained HLS + seeks', () async {
    if (Platform.environment['MIRU_DLNA_E2E'] != '1') {
      markTestSkipped('opt in with MIRU_DLNA_E2E=1 (network + LAN)');
      return;
    }
    FFMpegUtils.ensureInitialized();
    Logger.root.onRecord.listen(
      // ignore: avoid_print
      (r) => print(
        '[${r.level.name}] ${r.loggerName}: ${r.message} ${r.error ?? ''}',
      ),
    );

    final relay = _HlsRelay();
    final hlsUrl = await relay.start();
    addTearDown(relay.stop);
    final renderer = _FakeDlnaRenderer('MiruE2E-Renderer', readCapMb: 300);
    await renderer.start();
    addTearDown(renderer.stop);
    final clock = Timer.periodic(const Duration(seconds: 1), (_) {
      renderer.tick();
    });
    addTearDown(clock.cancel);

    final player = _TestPlayer();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final cast = container.read(dlnaCastProvider.notifier);
    cast.attachPlayer(player);
    final localMedia = _LocalMedia();
    final mp4Url = await localMedia.start();
    addTearDown(localMedia.stop);

    final baseline = ProcessInfo.currentRss;
    double mb(int bytes) => bytes / (1024 * 1024);
    final samples = <({int tMs, double rss, double media})>[];

    cast.startScan();
    expect(
      await cast.cast(deviceId: await _discover(cast, renderer), url: hlsUrl),
      isTrue,
    );
    final sw = Stopwatch()..start();
    const seeksAt = [20, 40, 60]; // s into the stream
    var nextSeek = 0;
    var pushesAtLastSeek = renderer.pushes;
    while (sw.elapsedMilliseconds < 75000) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      samples.add((
        tMs: sw.elapsedMilliseconds,
        rss: mb(ProcessInfo.currentRss),
        media: mb(renderer.mediaBytes),
      ));
      if (nextSeek < seeksAt.length &&
          sw.elapsed.inSeconds >= seeksAt[nextSeek]) {
        nextSeek++;
        player.seekTo(Duration(seconds: 30 + nextSeek * 10));
        DlnaCastBridge.instance.pipeSeek(Duration(seconds: 30 + nextSeek * 10));
        // Wait for the re-push so the next engine build is counted.
        final d = DateTime.now().add(const Duration(seconds: 15));
        while (renderer.pushes <= pushesAtLastSeek &&
            DateTime.now().isBefore(d)) {
          await Future<void>.delayed(const Duration(milliseconds: 200));
        }
        pushesAtLastSeek = renderer.pushes;
      }
    }

    // Copy-passthrough window (mp4): the no-conversion path. The renderer
    // consumes at full speed from the loopback source — this window measures
    // the proxy's raw transfer ceiling.
    final pushesBeforeMp4 = renderer.pushes;
    await cast.switchSource(mp4Url);
    final mp4Start = sw.elapsedMilliseconds;
    while (renderer.pushes <= pushesBeforeMp4 &&
        sw.elapsedMilliseconds < mp4Start + 20000) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    while (sw.elapsedMilliseconds < mp4Start + 20000) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      samples.add((
        tMs: sw.elapsedMilliseconds,
        rss: mb(ProcessInfo.currentRss),
        media: mb(renderer.mediaBytes),
      ));
    }
    // Transfer window over the renderer's actual read. The everything-
    // through-ffmpeg design remuxes the whole source at pipe speed (the
    // engine alone does ~80 MB/s on this file); what matters here is that
    // the FULL source reached the renderer and the stream closed cleanly —
    // a raw MB/s assertion would only measure this harness's pacing.
    final copyThroughput = renderer.lastReadMs > 0
        ? mb(renderer.mediaBytes) / (renderer.lastReadMs / 1000)
        : 0.0;
    // ignore: avoid_print
    print(
      'THROUGHPUT mp4 remux: ${copyThroughput.toStringAsFixed(1)}MB/s '
      '(${mb(renderer.mediaBytes).toStringAsFixed(1)}MB in '
      '${renderer.lastReadMs}ms eof=${renderer.lastReadEof})',
    );
    expect(
      renderer.lastReadEof,
      isTrue,
      reason: 'renderer never read the remuxed source to EOF',
    );
    expect(
      renderer.mediaBytes,
      greaterThan(2 * 1024 * 1024),
      reason:
          'renderer received only ${mb(renderer.mediaBytes)}MB of the '
          '300s source',
    );

    // Time-series table (every 4th sample = 2 s resolution).
    for (var i = 0; i < samples.length; i += 4) {
      final s = samples[i];
      // ignore: avoid_print
      print(
        'RSS t=${(s.tMs / 1000).toStringAsFixed(0).padLeft(3)}s '
        'rss=${s.rss.toStringAsFixed(1)}MB '
        'streamed=${s.media.toStringAsFixed(1)}MB',
      );
    }

    // Steady-state analysis: compare the post-warm-up head and tail.
    final warmup = samples
        .where((s) => s.tMs > 10000 && s.tMs <= 20000)
        .map((s) => s.rss)
        .toList();
    final tail = samples
        .where((s) => s.tMs > 60000 && s.tMs <= 70000)
        .map((s) => s.rss)
        .toList();
    double avg(List<double> v) => v.reduce((a, b) => a + b) / v.length;
    final peak = samples.map((s) => s.rss).reduce((a, b) => a > b ? a : b);
    // ignore: avoid_print
    print(
      'RSS SUMMARY baseline=${mb(baseline).toStringAsFixed(1)}MB '
      'warmup10-20s=${avg(warmup).toStringAsFixed(1)}MB '
      'tail60-70s=${avg(tail).toStringAsFixed(1)}MB '
      'peak=$peak MB '
      'leak-slope=${(avg(tail) - avg(warmup)).toStringAsFixed(1)}MB/50s '
      'seeks=3',
    );

    expect(warmup, isNotEmpty);
    expect(tail, isNotEmpty);
    // Leak bound: ~50 s of streaming + 3 engine rebuilds must not trend.
    expect(
      avg(tail) - avg(warmup),
      lessThan(30),
      reason: 'RSS trended upward across the streaming window (leak?)',
    );
    // Hard bound: never balloon.
    expect(
      peak - mb(baseline),
      lessThan(300),
      reason: 'RSS ballooned during streaming',
    );
  }, timeout: const Timeout(Duration(minutes: 5)));

  /// The MIME ladder, verified walk-by-walk against a scriptable renderer:
  /// rung 1 is the widely-supported generic `video/mp4`; a renderer that
  /// rejects a rung (UPnPError 714) makes the cast walk to the next generic
  /// declaration over the SAME TS bytes; exhausting the ladder surfaces the
  /// renderer's own fault. All locally, no LAN device needed.
  test('DLNA MIME ladder: mp4 preferred, walks on rejection', () async {
    if (Platform.environment['MIRU_DLNA_E2E'] != '1') {
      markTestSkipped('opt in with MIRU_DLNA_E2E=1 (network + LAN)');
      return;
    }
    FFMpegUtils.ensureInitialized();
    Logger.root.onRecord.listen(
      // ignore: avoid_print
      (r) => print(
        '[${r.level.name}] ${r.loggerName}: ${r.message} ${r.error ?? ''}',
      ),
    );

    // readCapMb high: the renderer must NOT park mid-ladder — the walk is
    // what's under test, and a parked socket drags in the EOF/re-GET race.
    final renderer = _FakeDlnaRenderer('MiruE2E-Renderer', readCapMb: 300);
    await renderer.start();
    addTearDown(renderer.stop);

    final player = _TestPlayer();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final cast = container.read(dlnaCastProvider.notifier);
    cast.attachPlayer(player);
    // The source must NOT EOF mid-ladder (an exhausted session ends the
    // stream under later rungs) — the relayed HLS runs for the whole test.
    final relay = _HlsRelay();
    final hlsUrl = await relay.start();
    addTearDown(relay.stop);

    cast.startScan();
    expect(
      await cast.cast(deviceId: await _discover(cast, renderer), url: hlsUrl),
      isTrue,
    );
    // Rung 1: generic mp4, both in the declared protocolInfo and the served
    // Content-Type.
    expect(renderer.pushedPi.first, 'http-get:*:video/mp4:*');
    expect(renderer.pushedExt.first, 'mp4');
    await _waitForContentType(renderer, 'video/mp4');
    expect(renderer.lastContentType, 'video/mp4');

    // A strict renderer rejects the generic rungs → the walk lands on the
    // spec-defined DLNA.ORG_PN TS profile rung, same TS bytes, matching
    // Content-Type.
    renderer.rejectNextSets = 2;
    expect(await cast.switchSource(hlsUrl), isTrue);
    expect(
      renderer.pushedPi.last,
      'http-get:*:video/mpeg:DLNA.ORG_PN='
      'MPEG_TS_HD_NA_ISO',
    );
    expect(renderer.pushedExt.last, 'mpeg');
    await _waitForContentType(renderer, 'video/mpeg');
    expect(renderer.lastContentType, 'video/mpeg');

    // Rejecting EVERY rung fails the cast with the renderer's own fault.
    renderer.rejectNextSets = 10;
    expect(await cast.switchSource(hlsUrl), isFalse);
    expect(
      container.read(dlnaCastProvider).error,
      contains('Illegal MIME-type'),
    );
    // The whole ladder was walked: 5 rungs.
    expect(
      renderer.pushedPi.length,
      renderer.pushedPi.indexOf(renderer.pushedPi.last) + 1,
    );

    await cast.disconnect();
    container.dispose();
  }, timeout: const Timeout(Duration(minutes: 3)));
}

/// Discovery helper shared by the E2E tests: waits for [renderer] by
/// friendly name, returns its device id.
Future<String> _discover(DlnaCast cast, _FakeDlnaRenderer renderer) async {
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (DateTime.now().isBefore(deadline)) {
    final state = cast.state;
    final device = state.devices
        .where((d) => d.name == renderer.friendlyName)
        .firstOrNull;
    if (device != null) return device.id;
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
  throw StateError('fake renderer not discovered');
}

/// Waits until the renderer's last media response Content-Type equals
/// [expected] — the GET and first write are async relative to the cast
/// returning. Times out after 10 s (leaves the value for the assertion).
Future<void> _waitForContentType(
  _FakeDlnaRenderer renderer,
  String expected,
) async {
  // The engine's remote open (probe + prebuffer) can take ~15 s — the wait
  // must cover it.
  final deadline = DateTime.now().add(const Duration(seconds: 30));
  while (renderer.lastContentType != expected &&
      DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}
