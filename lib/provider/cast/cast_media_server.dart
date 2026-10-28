import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:logging/logging.dart';
import 'package:miru_alpha/utils/download/ffmpeg_util.dart';

import 'package:miru_alpha/utils/core/log.dart';

/// Subsystem logger — proxy fetches land in miru.log.
final _log = Logger('${logger.name}.castmedia');

/// The casting host's media server: EVERY cast goes through the in-process
/// ffmpeg proxy — a session-owned worker isolate opens the source (HLS
/// playlist or direct file, already routed through the app's gateway) and
/// remuxes it to MPEG-TS. The cast provider walks a GENERIC protocolInfo
/// ladder over the same bytes: plain `video/mp4`/`video/mpeg` wildcards
/// for lenient renderers, then spec-defined `DLNA.ORG_PN` TS profiles for
/// strict ones whose sink lists are entirely profile-bound. The response
/// Content-Type follows the attempt's URI extension — some renderers
/// additionally gate the cast on the HEAD probe's response Content-Type.
///
/// Sessions are PRE-STARTED at cast time ([streamPrepare]): opening a
/// remote HLS source takes ~10 s (master-playlist probing + prebuffer),
/// and renderers re-GET the URI while their player settles — a re-GET
/// ATTACHES to the live session instead of resetting it, so every fetch
/// gets data instantly and the stream never restarts under the renderer.
class CastMediaServer {
  CastMediaServer._();

  static final CastMediaServer instance = CastMediaServer._();

  HttpServer? _server;
  String? _lanAddress;

  /// Starts the server lazily and returns the LAN base URL renderers use.
  Future<String> base() async {
    final existing = _server;
    if (existing != null && _lanAddress != null) {
      return 'http://$_lanAddress:${existing.port}';
    }
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    _server = server;
    server.listen(
      _serve,
      onError: (Object e) {
        _log.warning('media server error: $e');
      },
    );
    _lanAddress ??= await _lanIp();
    _log.info('media server listening on $_lanAddress:${server.port}');
    return 'http://$_lanAddress:${server.port}';
  }

  // Live ffmpeg-proxy streams: source → worker handle. One worker isolate
  // per connected renderer; a second GET for the same source stops the old
  // worker so exactly one pump feeds the renderer.
  final Map<String, _ActiveStream> _streams = {};

  /// The response Content-Type for a served [ext]. The MIME ladder in the
  /// cast provider varies the URI extension per attempt so strict
  /// renderers (which gate on BOTH the declared protocolInfo and the
  /// response Content-Type) see a coherent pair.
  static String contentTypeForExt(String ext) {
    switch (ext) {
      case 'tts':
        return 'video/vnd.dlna.mpeg-tts';
      case 'mp4':
        return 'video/mp4';
      default:
        return 'video/mpeg'; // ts, mpeg, m2ts …
    }
  }

  /// The URL for [source] served by the ffmpeg-proxy: ffmpeg opens the
  /// source, remuxes to MPEG-TS and the worker isolate pumps the bytes to
  /// whoever GETs this URL. [ext] pins the served extension AND response
  /// Content-Type — several renderers gate on the pair.
  Future<String> streamUrl(String source, {String ext = 'ts'}) async {
    final root = await base();
    final token = base64Url.encode(utf8.encode(source)).replaceAll('=', '');
    return '$root/stream/$token/cast.$ext';
  }

  /// PRE-STARTS the ffmpeg session for [source] (fire and forget): the
  /// worker isolate opens the source and fills its prebuffer before the
  /// renderer even asks. Opening a remote HLS source takes ~10 s — without
  /// this the renderer's player stares at an empty response, times out and
  /// re-GETs, resetting the stream forever. Bursts that arrive before a
  /// renderer attaches are held in the stream's pending queue.
  void streamPrepare(String source, {String? httpHeaders}) {
    if (_streams.containsKey(source) || _pendingSpawns.contains(source)) {
      return;
    }
    _pendingSpawns.add(source);
    if (httpHeaders != null && httpHeaders.isNotEmpty) {
      _pendingHeaders[source] = httpHeaders;
    }
    _spawnWorker(source, null);
  }

  /// Binds [response] to the live session for [source] (a renderer GET or
  /// re-GET): flushes held bursts and keeps the pull loop running. The
  /// previous response — typically a connection the renderer dropped or
  /// parked — is closed and the write chain reset: a stalled write on the
  /// old socket must never block the new one.
  void _attachResponse(String source, HttpResponse response) {
    final s = _streams[source];
    if (s == null) return;
    _log.info('ffmpeg-proxy: renderer attached to live session for $source');
    final old = s.response;
    if (old != null && !identical(old, response)) {
      unawaited(old.close().catchError((_) {}));
      s.writing = Future<void>.value();
    }
    s.response = response;
    if (s.pending.isNotEmpty) {
      final stash = List<Uint8List>.from(s.pending);
      s.pending.clear();
      unawaited(
        s.writing = s.writing.then((_) async {
          for (final data in stash) {
            try {
              response.add(data);
              await response.flush();
            } catch (_) {
              return;
            }
          }
          if (!s.paused) s.commands.send({'next': true});
        }),
      );
    } else if (!s.paused) {
      s.commands.send({'next': true});
    }
  }

  /// Spawns the worker isolate for [source]. [response] is null for a
  /// pre-started session (bursts are held until a renderer attaches).
  void _spawnWorker(String source, HttpResponse? response) {
    final subs = _pendingFilters.remove(source);
    final filter = subs?.filter;
    final assText = subs?.assText;
    final httpHeaders = _pendingHeaders.remove(source);
    _log.info('ffmpeg-proxy: worker for $source');
    final rp = ReceivePort();
    final cfg = _StreamWorkerCfg(
      source: source,
      reply: rp.sendPort,
      videoFilter: filter,
      assText: assText,
      httpHeaders: httpHeaders,
      // Master position once the cast provider wires this rung in; 0 = top.
      startSec: 0,
    );
    try {
      unawaited(Isolate.spawn(_dlnaStreamWorker, cfg));
    } catch (e, s) {
      _log.severe('ffmpeg-proxy: worker spawn failed', e, s);
      rp.close();
      if (response != null) {
        unawaited(response.close());
      }
      return;
    }
    var done = false;
    Future<void> chain = Future<void>.value();
    late final StreamSubscription<dynamic> sub;
    sub = rp.listen((msg) {
      if (done) return;
      chain = chain
          .then((_) async {
            done = !(await _onWorkerEvent(source, response, msg));
            if (done) sub.cancel();
          })
          .catchError((Object e) {
            _log.warning('ffmpeg-proxy: event handling failed: $e');
            done = true;
            sub.cancel();
            final s = _streams[source]?.response;
            if (s != null) {
              unawaited(s.close().catchError((_) {}));
            }
            _streams.remove(source);
          });
    });
  }

  Future<void> _serveStream(HttpRequest request, String token) async {
    final parts = token.split('/');
    final encoded = parts.isNotEmpty ? parts.first : token;
    String? source;
    try {
      source = utf8.decode(base64Url.decode(base64Url.normalize(encoded)));
    } catch (_) {}
    source ??= request.uri.queryParameters['u'];
    if (source == null || source.isEmpty) {
      request.response.statusCode = 400;
      await request.response.close();
      return;
    }
    final response = request.response;
    final ext = request.uri.pathSegments.isNotEmpty
        ? request.uri.pathSegments.last.split('.').last
        : '';
    // Every GET branch (spawn / pending-spawn / attach) serves the same
    // Content-Type, derived from the requested extension: dart:io sends
    // headers lazily with the first body write, and the MIME ladder keys
    // the renderer's gate on this header.
    response.headers.set(
      HttpHeaders.contentTypeHeader,
      CastMediaServer.contentTypeForExt(ext),
    );
    if (request.method == 'HEAD') {
      // Some renderers probe the URI with a HEAD before accepting the
      // cast and gate on the probe's Content-Type. Answer from the path
      // alone — no ffmpeg session, no filter consumption.
      response.headers.set(HttpHeaders.acceptRangesHeader, 'none');
      await response.close();
      return;
    }
    final existing = _streams[source];
    if (existing != null) {
      // A re-GET of a live session: re-attach instead of resetting the
      // stream under the renderer.
      _attachResponse(source, response);
      return;
    }
    if (_pendingSpawns.contains(source)) {
      // A pre-started worker is still opening (~10 s on remote sources):
      // bind this response the moment it becomes ready instead of spawning
      // a second session that would clobber the first.
      final previous = _pendingResponses.remove(source);
      if (previous != null) {
        unawaited(previous.close().catchError((_) {}));
      }
      _pendingResponses[source] = response;
      return;
    }
    _spawnWorker(source, response);
  }

  /// Playback position of the live ffmpeg-proxy stream for [source], null
  /// when none is active. Advisory — sync loop and UI.
  double? streamPositionOf(String source) => _streams[source]?.position;

  /// Detected codecs of the active stream, null when none.
  ({String video, String audio})? streamCodecs(String source) {
    final s = _streams[source];
    if (s == null) return null;
    return (video: s.videoCodec, audio: s.audioCodec);
  }

  /// Transport-level pause: stop pulling from the worker (the pump idles)
  /// and stash the burst in flight; the renderer starves and parks itself.
  /// Resume with [false].
  void streamPause(String source, bool paused) {
    final s = _streams[source];
    if (s == null) return;
    s.paused = paused;
    s.commands.send({'pause': paused});
    final resp = s.response;
    if (!paused && resp != null && s.pending.isNotEmpty) {
      final stash = List<Uint8List>.from(s.pending);
      s.pending.clear();
      unawaited(
        s.writing = s.writing.then((_) async {
          for (final data in stash) {
            try {
              resp.add(data);
              await resp.flush();
            } catch (_) {
              return; // renderer gone; the ended event cleans up
            }
          }
          s.commands.send({'next': true});
        }),
      );
    }
  }

  /// Seeks the underlying source; the muxer restarts with a fresh timeline
  /// and the caller re-pushes the same URI to the renderer.
  void streamSeek(String source, double sec) =>
      _streams[source]?.commands.send({'seek': sec});

  /// Stops the worker (disconnect / watch-page teardown).
  void streamStop(String source) {
    _streams[source]?.commands.send({'stop': true});
  }

  // Pre-start bookkeeping: sources whose worker is still opening (between
  // spawn and 'ready'), and renderer responses that arrived meanwhile —
  // bound to the session when it becomes ready.
  final Set<String> _pendingSpawns = {};
  final Map<String, HttpResponse> _pendingResponses = {};
  final Map<String, String> _pendingHeaders = {};

  // Pending subtitle-burn setups: source → filter graph (drawtext window
  // fallback) and/or raw subtitle text (libass-direct). Provider registers
  // before the session spawns; consumed on spawn.
  final Map<String, _StreamSubtitle> _pendingFilters = {};

  /// Registers the transcode subtitle setup for [source]'s session.
  /// [filter] = a libavfilter graph; [assText] = raw SRT/ASS text burned by
  /// the in-engine libass (preferred when available). Both null clears.
  void setStreamFilter(String source, String? filter, {String? assText}) {
    if ((filter == null || filter.isEmpty) &&
        (assText == null || assText.isEmpty)) {
      _pendingFilters.remove(source);
    } else {
      _pendingFilters[source] = _StreamSubtitle(
        filter: filter,
        assText: assText,
      );
    }
  }

  /// Applies one worker event to the registry. Returns false when the
  /// worker is done and its listener should stop. [response] is the
  /// attached renderer response, null for a pre-started session whose
  /// renderer has not attached yet.
  Future<bool> _onWorkerEvent(
    String source,
    HttpResponse? response,
    dynamic msg,
  ) async {
    if (msg is! Map) return true;
    switch (msg['event']) {
      case 'ready':
        final previous = _streams[source];
        if (previous != null) previous.commands.send({'stop': true});
        _pendingSpawns.remove(source);
        // A renderer GET that arrived while the worker was opening binds
        // its response here.
        final pendingResp = _pendingResponses.remove(source);
        _streams[source] = _ActiveStream(
          commands: msg['port'] as SendPort,
          videoCodec: msg['videoCodec'] as String? ?? '',
          audioCodec: msg['audioCodec'] as String? ?? '',
          position: 0,
          response: pendingResp ?? response,
        );
        _log.info(
          'ffmpeg-proxy: streaming $source '
          '(${msg['videoCodec']} + ${msg['audioCodec']})',
        );
        _streams[source]!.commands.send({'next': true});
      case 'bytes':
        final s = _streams[source];
        if (s == null) return false; // replaced or stopped meanwhile
        if (msg['pos'] is num) {
          s.position = (msg['pos'] as num).toDouble();
        }
        final data = msg['data'] as Uint8List;
        final resp = s.response;
        // Pre-started session (or paused): hold the burst until a renderer
        // attaches / playback resumes. The pull model bounds the queue.
        if (resp == null || s.paused) {
          s.pending.add(data);
          return true;
        }
        s.writing = s.writing.then((_) async {
          try {
            resp.add(data);
            await resp.flush();
          } catch (_) {
            if (identical(resp, s.response)) {
              // The CURRENT renderer connection died — stop the worker; the
              // ended event cleans the registry entry up.
              s.commands.send({'stop': true});
              _streams.remove(source);
            }
            // A stale response (a newer GET re-attached): drop the burst and
            // keep feeding the live one.
            return;
          }
          if (!s.paused) s.commands.send({'next': true});
        });
      case 'position':
        final s = _streams[source];
        if (s != null && msg['pos'] is num) {
          s.position = (msg['pos'] as num).toDouble();
        }
      case 'error':
        _log.warning('ffmpeg-proxy: $source → ${msg['message']}');
        final entry = _streams.remove(source);
        // Close the BOUND response — for a pre-started session the worker's
        // captured [response] is null and the renderer's connection would
        // never close (its EOF never fires).
        final resp = entry?.response ?? response;
        if (resp != null) {
          try {
            await resp.close();
          } catch (_) {}
        }
        return false;
      case 'ended':
      case 'stopped':
        _log.info('ffmpeg-proxy: $source ${msg['event']}');
        final entry = _streams.remove(source);
        final resp = entry?.response ?? response;
        if (resp != null) {
          try {
            await resp.close();
          } catch (_) {}
        }
        return false;
    }
    return true;
  }

  Future<void> _serve(HttpRequest request) async {
    final path = request.uri.path;
    if (path.startsWith('/stream/')) {
      await _serveStream(request, path.substring('/stream/'.length));
      return;
    }
    request.response.statusCode = 404;
    await request.response.close();
  }

  /// Picks the LAN address the RENDERER can actually reach. The first
  /// interface is often a VPN/hotspot tunnel (this device offered
  /// 10.224.9.x while the TV lives at 192.168.1.227) — prefer the
  /// interface sharing a subnet with any discovered device, then real
  /// network adapters, and never a tunnel.
  Future<String> _lanIp() async {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddress.anyIPv4.type,
    );
    final candidates = <(NetworkInterface, String)>[
      for (final interface in interfaces)
        for (final address in interface.addresses)
          if (address.type == InternetAddressType.IPv4)
            (interface, address.address),
    ];
    if (candidates.isEmpty) return '127.0.0.1';
    // Same /24 as a discovered renderer (the device map is on hand from
    // the scan).
    for (final (interface, address) in candidates) {
      final subnet = address.split('.').take(3).join('.');
      final sameSubnet = _knownDeviceHosts.any(
        (host) => host.startsWith('$subnet.'),
      );
      if (sameSubnet) {
        _log.info(
          'media server: using ${interface.name} $address '
          '(renderer subnet)',
        );
        return address;
      }
    }
    // Real adapters next; tunnels (tun/tap/rmnet) last.
    final ranked = candidates.toList()
      ..sort((a, b) => _ifaceRank(a.$1.name).compareTo(_ifaceRank(b.$1.name)));
    _log.info(
      'media server: no renderer-subnet match — using '
      '${ranked.first.$1.name} ${ranked.first.$2}',
    );
    return ranked.first.$2;
  }

  final Set<String> _knownDeviceHosts = {};

  /// Remembers where the discovered renderers live AND invalidates the
  /// cached LAN address — the first interface is often a tunnel, and the
  /// renderer subnet is only knowable after a scan.
  void noteDeviceHosts(Iterable<String> urlBases) {
    for (final base in urlBases) {
      final host = Uri.tryParse(base)?.host;
      if (host != null && host.isNotEmpty && _knownDeviceHosts.add(host)) {
        _lanAddress = null; // re-resolve with the new subnet knowledge
        _log.info('media server: renderer subnet hint $host');
      }
    }
  }

  int _ifaceRank(String name) {
    if (name.startsWith('tun') || name.startsWith('tap')) return 5;
    if (name.startsWith('rmnet') || name.startsWith('ccmni')) return 4;
    if (name.startsWith('wlan') || name.startsWith('eth')) return 0;
    return 2;
  }
}

/// Registry entry for one live ffmpeg-proxy stream. The renderer RESPONSE
/// lives HERE (main isolate): the worker only computes bursts and this
/// isolate does the IO — pull-based via the `next` token for backpressure.
/// [response] is null while the session is pre-started but no renderer has
/// attached yet (bursts are held in [pending]).
class _ActiveStream {
  _ActiveStream({
    required this.commands,
    required this.videoCodec,
    required this.audioCodec,
    required this.position,
    required this.response,
  });

  final SendPort commands;
  final String videoCodec;
  final String audioCodec;
  HttpResponse? response;
  double position;
  bool paused = false;

  /// Bursts received while paused or before a renderer attached — flushed
  /// on resume / attach.
  final List<Uint8List> pending = [];

  /// Serialized response-write chain (one burst in flight at a time).
  Future<void> writing = Future<void>.value();
}

/// Sendable worker startup message (no socket — see [_ActiveStream]).
/// Subtitle setup registered by the provider for a pending renderer GET:
/// a libavfilter graph (drawtext fallback) and/or raw SRT/ASS text for the
/// in-engine libass-direct burn.
class _StreamSubtitle {
  _StreamSubtitle({this.filter, this.assText});

  final String? filter;
  final String? assText;
}

class _StreamWorkerCfg {
  _StreamWorkerCfg({
    required this.source,
    required this.reply,
    this.videoFilter,
    this.assText,
    this.httpHeaders,
    this.startSec = 0,
  });

  final String source;
  final SendPort reply;
  final String? videoFilter;
  final String? httpHeaders;

  /// Raw SRT/ASS text for the libass-direct burn (takes precedence over
  /// [videoFilter] inside the engine).
  final String? assText;
  final double startSec;
}

/// Worker isolate: owns the native ffmpeg-proxy session (one isolate per
/// stream — the native context is not thread-shared). Fully pull-driven:
/// it pumps ONE burst per `next` token from the main isolate, which writes
/// the burst to the renderer socket and pulls again once flushed. Commands
/// (seek/pause/stop) land on the same port between bursts.
void _dlnaStreamWorker(_StreamWorkerCfg cfg) {
  DlnaStreamSession? session;
  try {
    session = DlnaStreamSession.open(
      cfg.source,
      startSec: cfg.startSec,
      videoFilter: cfg.videoFilter,
      assSubtitle: cfg.assText,
      httpHeaders: cfg.httpHeaders,
    );
  } catch (e) {
    _log.severe('ffmpeg-proxy: open failed for ${cfg.source}', e);
    session = null;
  }
  if (session == null) {
    cfg.reply.send({
      'event': 'error',
      'message': 'ffmpeg open failed: ${cfg.source}',
    });
    return;
  }
  final commands = ReceivePort();
  cfg.reply.send({
    'event': 'ready',
    'port': commands.sendPort,
    'videoCodec': session.videoCodec,
    'audioCodec': session.audioCodec,
  });
  var stop = false;
  var pull = false;
  var paused = false;
  commands.listen((msg) {
    if (msg is! Map) return;
    final seek = msg['seek'];
    if (seek is num) {
      try {
        session!.seek(seek.toDouble());
        cfg.reply.send({'event': 'position', 'pos': session.position()});
      } catch (e) {
        cfg.reply.send({'event': 'error', 'message': '$e'});
        stop = true;
      }
    }
    if (msg['pause'] is bool) paused = msg['pause'] as bool;
    if (msg['next'] == true) pull = true;
    if (msg['stop'] == true) stop = true;
  });
  unawaited(
    _dlnaPullLoop(
      cfg,
      session,
      () => pull,
      () {
        pull = false;
      },
      () => paused,
      () => stop,
      commands,
    ),
  );
}

/// One burst per `next` token. `session.pump()` blocks natively while it
/// reads the source; native rw_timeout (15 s) bounds a stalled source, and
/// EAGAIN (no full packet yet) retries inside the worker.
Future<void> _dlnaPullLoop(
  _StreamWorkerCfg cfg,
  DlnaStreamSession session,
  bool Function() pull,
  void Function() resetPull,
  bool Function() paused,
  bool Function() stop,
  ReceivePort commands,
) async {
  var ended = false;
  try {
    while (!stop()) {
      if (!pull() || paused()) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        continue;
      }
      resetPull();
      var n = session.pump();
      while (n == DlnaStreamSession.eagain) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        n = session.pump();
      }
      if (n == 0) {
        ended = true;
        break;
      }
      if (n < 0) {
        cfg.reply.send({'event': 'error', 'message': 'pump failed: $n'});
        break;
      }
      // take() views the worker's static buffer — fromList snapshots it
      // before the buffer is reused by the next pump.
      cfg.reply.send({
        'event': 'bytes',
        'data': Uint8List.fromList(session.take(n)),
        'pos': session.position(),
      });
    }
  } catch (e) {
    _log.info('ffmpeg-proxy: pull loop ended (${cfg.source}): $e');
    ended = true;
  } finally {
    try {
      session.dispose();
    } catch (_) {}
    commands.close();
    cfg.reply.send({'event': ended ? 'ended' : 'stopped'});
  }
}
