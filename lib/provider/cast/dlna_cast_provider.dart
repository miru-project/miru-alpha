import 'dart:async';
import 'dart:io';

import 'package:dlna_dart/dlna.dart';
import 'package:dlna_dart/xmlParser.dart' show PlayType, VideoMime;
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:miru_alpha/provider/cast/cast_media_server.dart';
import 'package:miru_alpha/provider/cast/dlna_cast_bridge.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/download/ffmpeg_util.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dlna_cast_provider.g.dart';

/// Subsystem logger — DLNA discovery and transport land in miru.log.
final _log = Logger('${logger.name}.dlna');

/// A DLNA renderer discovered on the local network.
class DlnaDeviceUi {
  const DlnaDeviceUi({
    required this.id,
    required this.name,
    required this.device,
  });

  /// UPnP unique device key from the searcher.
  final String id;

  /// The renderer's friendly name shown in the picker.
  final String name;

  final DLNADevice device;
}

/// How the media reaches the renderer: the ffmpeg proxy remuxes EVERY
/// source to MPEG-TS; the declared MIME walks a per-renderer ladder
/// (profiled first, wildcards last) while the bytes stay identical.
enum CastMode { none, transmux }

/// DLNA cast session state: the live device scan, the connected renderer and
/// the mirrored renderer transport state (two-way sync).
class DlnaCastState {
  const DlnaCastState({
    this.searching = false,
    this.devices = const [],
    this.connectedId,
    this.connectingId,
    this.castUrl,
    this.castMode = CastMode.none,
    this.remoteState,
    this.remotePosition,
    this.error,
  });

  /// True while the SSDP searcher is running.
  final bool searching;

  /// Renderers discovered so far, sorted by name.
  final List<DlnaDeviceUi> devices;

  /// The currently connected renderer's id, if any.
  final String? connectedId;

  /// The renderer a cast handshake is in flight for (SetAVTransportURI +
  /// Play can take a couple of seconds over the network).
  final String? connectingId;

  /// The media URL last pushed to the renderer.
  final String? castUrl;

  /// How the media reaches the renderer: ffmpeg remuxes everything to
  /// MPEG-TS; only the declared protocolInfo/extension walk a per-renderer
  /// ladder (see [cast]).
  final CastMode castMode;

  /// The renderer's reported transport state (PLAYING/PAUSED_PLAYBACK/...).
  final String? remoteState;

  /// The renderer's reported position (from GetPositionInfo polling).
  final Duration? remotePosition;

  /// The renderer's own rejection reason from the last failed cast
  /// (e.g. "Format Not Supported For Playback"), for user feedback.
  final String? error;

  DlnaCastState copyWith({
    bool? searching,
    List<DlnaDeviceUi>? devices,
    String? connectedId,
    String? connectingId,
    String? castUrl,
    CastMode? castMode,
    String? remoteState,
    Duration? remotePosition,
    String? error,
    bool clearConnected = false,
    bool clearConnecting = false,
    bool clearError = false,
    bool clearRemote = false,
  }) => DlnaCastState(
    searching: searching ?? this.searching,
    devices: devices ?? this.devices,
    connectedId: clearConnected ? null : (connectedId ?? this.connectedId),
    connectingId: clearConnecting ? null : (connectingId ?? this.connectingId),
    castUrl: castUrl ?? this.castUrl,
    castMode: castMode ?? this.castMode,
    remoteState: clearRemote ? null : (remoteState ?? this.remoteState),
    remotePosition: clearRemote
        ? null
        : (remotePosition ?? this.remotePosition),
    error: clearError ? null : (error ?? this.error),
  );

  DlnaDeviceUi? connected() =>
      devices.where((d) => d.id == connectedId).firstOrNull;
}

/// Drives the DLNA device search, the connected renderer's transport, and
/// the TWO-WAY sync between the app player (via [DlnaPlayerSurface]) and the
/// renderer.
///
/// One scan at a time: [startScan] opens the SSDP socket, [stopScan] closes
/// it. The devices stream re-emits the whole map on every discovery, so the
/// state rebuilds the sorted list each tick.
///
/// Keep-alive: the discovered devices and the connected renderer survive the
/// cast sheet closing — reopening the sheet shows the previous list and
/// session instead of rescanning from zero.
@Riverpod(keepAlive: true)
class DlnaCast extends _$DlnaCast {
  DLNAManager? _manager;
  StreamSubscription<Map<String, DLNADevice>>? _sub;

  /// The app player surface (registered via [attachPlayer]).
  DlnaPlayerSurface? _player;

  /// Reverse-sync poll timer and echo suppression.
  Timer? _poll;
  int _pollFails = 0;
  int _positionFails = 0;
  bool _positionUnsupported = false;
  DateTime _lastCommand = DateTime.fromMillisecondsSinceEpoch(0);

  /// Subtitle burn state: the SRT the player attached (null = none) and its
  /// windowed cue-file directory.
  String? _srt;
  Directory? _subtitleDir;
  String _title = '';

  /// The MIME rung the connected renderer accepted (protocolInfo + URI
  /// extension) — seek re-pushes reuse it instead of re-walking the ladder.
  PlayType _activeType = VideoMime.mpeg;
  String _activeExt = 'ts';
  Map<String, String> _activeHeaders = const {};

  @override
  DlnaCastState build() {
    ref.onDispose(_teardown);
    return const DlnaCastState();
  }

  /// Registers the app player surface. App actions flow to the renderer;
  /// renderer transport state flows back via
  /// [DlnaPlayerSurface.syncTransport].
  void attachPlayer(DlnaPlayerSurface surface) {
    _player = surface;
  }

  /// Attaches an SRT for subtitle burning into the cast video (null clears).
  /// A windowed drawtext graph is (re)generated on cast and on every seek.
  void setSubtitles(String? srt) {
    _srt = srt;
    _subtitleDir?.deleteSync(recursive: true);
    _subtitleDir = null;
    final url = state.castUrl;
    if (srt == null && url != null) {
      CastMediaServer.instance.setStreamFilter(url, null);
    }
  }

  void startScan() {
    if (state.searching) return;
    _teardown();
    // Keep the previously discovered list: a rescan refreshes it in place
    // (the stream re-emits the full map), and a sheet reopen shows the old
    // devices immediately instead of an empty state.
    state = state.copyWith(searching: true);
    _scan();
  }

  Future<void> _scan() async {
    try {
      _manager ??= DLNAManager();
      final dm = await _manager!.start();
      _sub = dm.devices.stream.listen((map) {
        final devices = <DlnaDeviceUi>[];
        for (final entry in map.entries) {
          final device = entry.value;
          // Only renderers that actually expose an AVTransport control are
          // castable: `controlURL('AVTransport')` throws on devices like the
          // Google TV Streamer whose description carries no such service —
          // listing them just produced a silent cast failure. Skip them.
          try {
            device.controlURL('AVTransport');
          } catch (_) {
            _log.info(
              'scan: ${device.info.friendlyName} has no AVTransport '
              'service — not a castable renderer',
            );
            continue;
          }
          devices.add(
            DlnaDeviceUi(
              id: entry.key,
              name: device.info.friendlyName,
              device: device,
            ),
          );
          // Remember where renderers live so the media server binds the
          // interface they can actually reach.
          CastMediaServer.instance.noteDeviceHosts([
            entry.key,
            entry.value.info.URLBase,
          ]);
        }
        devices.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        state = state.copyWith(devices: devices);
      });
    } catch (e, s) {
      _log.severe('scan: SSDP search failed to start', e, s);
      state = state.copyWith(searching: false);
    }
  }

  void stopScan() {
    _sub?.cancel();
    _sub = null;
    try {
      _manager?.stop();
    } catch (_) {}
    _manager = null;
    state = state.copyWith(searching: false);
  }

  /// The renderer's own rejection reason, if it sent one (UPnPError
  /// errorDescription inside the thrown exception text).
  String? _reasonFrom(Object error) {
    final match = RegExp(
      r'<errorDescription>([^<]+)</errorDescription>',
    ).firstMatch(error.toString());
    return match?.group(1);
  }

  /// Pushes [url] to [deviceId] and starts playback there. ALL traffic is
  /// hot-proxied through the local media server: ffmpeg remuxes the source
  /// (HLS or direct file) to MPEG-TS, and the SAME bytes are offered under
  /// a ladder of protocolInfo/extension pairs.
  ///
  /// Why a ladder: renderers disagree on what they accept. Some AVTransport
  /// implementations gate the cast on the RESPONSE Content-Type of a HEAD
  /// probe (an upstream `application/octet-stream` passthrough is rejected
  /// with UPnPError 714), while stricter stacks publish sink lists with
  /// ONLY profile-bound entries — wildcards match nothing and the TV
  /// reports PLAYING while decoding nothing. The ladder covers both
  /// extremes and falls back to `any`.
  Future<bool> cast({
    required String deviceId,
    required String url,
    String title = '',
    Map<String, String> headers = const {},
  }) async {
    final device = state.devices
        .where((d) => d.id == deviceId)
        .map((d) => d.device)
        .firstOrNull;
    if (device == null) {
      _log.warning('cast: device $deviceId not in the scanned list');
      return false;
    }
    _title = title;
    _set((s) => s.copyWith(connectingId: deviceId, clearError: true));
    if (_srt != null) {
      _refreshSubtitleFilter(url, 0);
    }
    // Extension HTTP headers (Referer/User-Agent/…) travel with the
    // session: the engine applies them to every manifest/segment fetch so
    // header-gated sources pass the same checks the local player passes.
    _activeHeaders = headers;
    // Pre-start the ffmpeg session: a remote HLS source takes ~10s to open
    // and prebuffer — doing it at Set time means the renderer's GET (and
    // every re-GET while its player settles) finds a live, primed stream
    // instead of dead air that makes it time out and reset.
    CastMediaServer.instance.streamPrepare(
      url,
      httpHeaders: headers.isEmpty
          ? null
          : headers.entries.map((e) => '${e.key}: ${e.value}').join('\r\n'),
    );
    // The MIME ladder over ONE stream of TS bytes. The URI extension varies
    // per rung so the response Content-Type matches the declared
    // protocolInfo (some renderers gate on the HEAD response's
    // Content-Type).
    //
    // GENERIC declarations only — no vendor/model profiles. Most DLNA
    // renderers accept H264-in-TS under plain `video/mp4`/`video/mpeg`
    // wildcards; strict ones (profile-bound sink lists) fall through to the
    // standard DLNA.ORG_PN TS profiles, which are spec-defined and present
    // in every probed sink list.
    const ladder = <(PlayType, String)>[
      (VideoMime.mp4, 'mp4'), // generic mp4
      (VideoMime.mpeg, 'mpeg'), // generic mpeg (TS bytes)
      (_RawMime('http-get:*:video/mpeg:DLNA.ORG_PN=MPEG_TS_HD_NA_ISO'), 'mpeg'),
      (_RawMime('http-get:*:video/mpeg:DLNA.ORG_PN=MPEG_TS_SD_NA_ISO'), 'mpeg'),
      (VideoMime.any, 'mpeg'), // last resort
    ];
    Object? lastError;
    StackTrace? lastStack;
    for (final (attempt, ext) in ladder) {
      final target = await CastMediaServer.instance.streamUrl(url, ext: ext);
      try {
        await device.setUrl(target, title: title, type: attempt);
      } catch (e, s) {
        lastError = e;
        lastStack = s;
        _log.info(
          'cast: ${device.info.friendlyName} rejected '
          '${attempt.protocolInfo} — trying the next MIME',
        );
        continue;
      }
      _log.info(
        'cast: SetAVTransportURI → ${device.info.friendlyName} ← '
        'ffmpeg ts $target (${attempt.protocolInfo})',
      );
      // The Set was ACCEPTED. Play can still race the renderer's own load —
      // it fails seconds later with a SOAP fault while the renderer is
      // still pulling the fresh stream. Retry it
      // on the SAME rung before giving the MIME up.
      Object? playError;
      StackTrace? playStack;
      for (var playAttempt = 1; playAttempt <= 3; playAttempt++) {
        try {
          await device.play();
          playError = null;
          break;
        } catch (e, s) {
          playError = e;
          playStack = s;
          if (playAttempt < 3) {
            await Future<void>.delayed(
              Duration(milliseconds: 800 * playAttempt),
            );
          }
        }
      }
      if (playError != null) {
        lastError = playError;
        lastStack = playStack;
        _log.warning(
          'cast: play failed on ${device.info.friendlyName} after Set '
          '${attempt.protocolInfo} — '
          '${_reasonFrom(playError) ?? playError}',
        );
        continue;
      }
      _log.info('cast: playing on ${device.info.friendlyName}');
      _activeType = attempt;
      _activeExt = ext;
      _stamp();
      _attachBridge();
      _startPoll();
      _set(
        (s) => s.copyWith(
          connectedId: deviceId,
          castUrl: url,
          castMode: CastMode.transmux,
          clearConnecting: true,
        ),
      );
      return true;
    }
    final reason = _reasonFrom(lastError!);
    _log.severe(
      'cast: failed on ${device.info.friendlyName}',
      lastError,
      lastStack,
    );
    // The pre-started session has no renderer attached — stop it so an
    // abandoned cast does not leave a worker pulling the source.
    CastMediaServer.instance.streamStop(url);
    _set((s) => s.copyWith(clearConnecting: true, error: reason));
    return false;
  }

  Future<void> play() async {
    _stamp();
    await _connected?.play();
  }

  Future<void> pause() async {
    _stamp();
    await _connected?.pause();
  }

  Future<void> stop() async {
    _stamp();
    await _connected?.stop();
  }

  Future<void> setVolume(int volume) async => _connected?.volume(volume);

  /// Seeks the renderer: seek the ffmpeg stream and re-push the same URI
  /// (the piped MP4 has no byte-accurate seek — the renderer re-GETs a
  /// stream whose 0:00 is the target).
  Future<void> seekTo(Duration position) async {
    _stamp();
    final url = state.castUrl;
    if (url == null) return;
    final seconds = position.inMilliseconds / 1000.0;
    if (_srt != null) _refreshSubtitleFilter(url, seconds);
    CastMediaServer.instance.streamSeek(url, seconds);
    // Re-push with retry: the renderer is busy tearing the old stream down
    // when the re-push lands — a single SOAP round trip routinely times out
    // there.
    final device = _connected;
    if (device == null) return;
    final target = await CastMediaServer.instance.streamUrl(
      url,
      ext: _activeExt,
    );
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        await device.setUrl(target, title: _title, type: _activeType);
        await device.play();
        return;
      } catch (e) {
        if (attempt == 3) {
          _log.severe('cast: seek re-push failed', e, StackTrace.current);
        } else {
          await Future<void>.delayed(Duration(milliseconds: 600 * attempt));
        }
      }
    }
  }

  /// Episode/source switch: a fresh push of the new media (same renderer).
  Future<bool> switchSource(String url) async {
    final id = state.connectedId;
    if (id == null) return false;
    // Episode/source switches within a cast keep the SAME extension — its
    // headers still apply to the new stream.
    return cast(deviceId: id, url: url, title: _title, headers: _activeHeaders);
  }

  /// Stops playback and drops the connection (keeps the device list).
  Future<void> disconnect() async {
    DlnaCastBridge.instance.detach();
    _stopPoll();
    _subtitleDir?.deleteSync(recursive: true);
    _subtitleDir = null;
    final url = state.castUrl;
    if (url != null) CastMediaServer.instance.streamStop(url);
    await stop();
    state = state.copyWith(clearConnected: true, clearRemote: true);
  }

  /// Watch-page teardown: drops the renderer session, the scan, AND the
  /// discovered list. The cast experience is scoped to a watch session —
  /// source switches inside the page (episode, quality, mirror) never touch
  /// this state, but leaving the watch page starts the next one fresh.
  void reset() {
    DlnaCastBridge.instance.detach();
    _stopPoll();
    _subtitleDir?.deleteSync(recursive: true);
    _subtitleDir = null;
    final url = state.castUrl;
    if (url != null) CastMediaServer.instance.streamStop(url);
    // Best-effort renderer stop; the state clear below must not wait on a
    // SOAP round trip.
    unawaited(stop());
    _teardown();
    state = const DlnaCastState();
  }

  /// State writes after the autoDispose provider dies (sheet closed while
  /// a handshake was in flight) throw — they are simply dropped then.
  void _set(DlnaCastState Function(DlnaCastState) update) {
    try {
      state = update(state);
    } catch (_) {}
  }

  void _stamp() {
    _lastCommand = DateTime.now();
  }

  /// While connected, the app player is the master surface: its actions
  /// forward to the renderer (via the bridge), and renderer-side transport
  /// events echo back onto the player.
  void _attachBridge() {
    final surface = _player;
    if (surface == null) return;
    DlnaCastBridge.instance.attach(
      surface: surface,
      onRemotePlay: () => unawaited(play()),
      onRemotePause: () => unawaited(pause()),
      onRemotePosition: (position) => unawaited(seekTo(position)),
      onRemoteEnded: () {
        _set((s) => s.copyWith(remoteState: 'STOPPED'));
      },
    );
  }

  /// Regenerates the subtitle burn graph for [url] at [startSec].
  ///
  /// Linux (BtbN engine): the libass-based `subtitles` filter renders the
  /// whole timeline with full styling — one static graph, no windowing.
  /// Other platforms (avbuild engine, no libass): the windowed drawtext
  /// chain (SRT text only).
  void _refreshSubtitleFilter(String url, double startSec) {
    final srt = _srt;
    if (srt == null) {
      CastMediaServer.instance.setStreamFilter(url, null);
      return;
    }
    // libass-direct first: the in-engine libass (system library on linux,
    // fvp's bundled libass.so on android) renders the full timeline with
    // real styling — no temp files, no windowing. The drawtext window
    // chain stays as the fallback when no libass loads (e.g. windows).
    if (FFMpegUtils.libassAvailable) {
      CastMediaServer.instance.setStreamFilter(
        url,
        null,
        assText: DlnaSubtitles.toAss(srt),
      );
      return;
    }
    _subtitleDir ??= Directory.systemTemp.createTempSync('dlna_sub');
    String? graph;
    if (Platform.isLinux) {
      final ext = srt.trimLeft().startsWith('[Script Info]') ? 'ass' : 'srt';
      final file = File('${_subtitleDir!.path}/subs.$ext');
      if (!file.existsSync()) file.writeAsStringSync(srt);
      final escaped = file.path
          .replaceAll(r'\', r'\\')
          .replaceAll("'", r"\'")
          .replaceAll(':', r'\:');
      graph = "subtitles='$escaped'";
    } else {
      graph = DlnaSubtitles.buildGraph(
        srt,
        startSec: startSec,
        dir: _subtitleDir!,
      );
    }
    CastMediaServer.instance.setStreamFilter(url, graph);
  }

  /// Starts the reverse-sync poll: renderer position + transport state,
  /// echoed onto the player surface. Echo suppression: commands issued in
  /// the last 5 s are observed, not corrected against. A renderer that
  /// rejects the poll calls (some renderers answer GetPositionInfo with
  /// UPnPError 402 "Illegal value") backs the interval off exponentially
  /// instead of being hammered every second.
  void _startPoll() {
    _stopPoll();
    _pollFails = 0;
    _positionFails = 0;
    _positionUnsupported = false;
    _schedulePoll(const Duration(seconds: 1));
  }

  void _schedulePoll(Duration delay) {
    _poll = Timer(delay, () {
      unawaited(_pollOnce());
    });
  }

  void _stopPoll() {
    _poll?.cancel();
    _poll = null;
  }

  Future<void> _pollOnce() async {
    final device = _connected;
    if (device == null) return;
    try {
      await _pollBody(device);
      _pollFails = 0;
    } catch (e) {
      _pollFails = (_pollFails + 1).clamp(1, 4);
      _log.fine('poll: $e');
    }
    _schedulePoll(
      _pollFails == 0
          ? const Duration(seconds: 1)
          : Duration(seconds: 1 << _pollFails),
    );
  }

  /// One poll round: renderer position + transport state, echoed onto the
  /// player surface. Throws on SOAP faults (the caller backs off).
  ///
  /// Position and transport state fail INDEPENDENTLY: some renderers
  /// renderers) answer GetPositionInfo with UPnPError 402
  /// "Illegal value" during state transitions while GetTransportInfo keeps
  /// working — a position failure must not blind the transport read. After
  /// three consecutive position failures the poll stops asking for it for
  /// the rest of the session (the renderer is master for state anyway).
  Future<void> _pollBody(DLNADevice device) async {
    final suppress =
        DateTime.now().difference(_lastCommand) < const Duration(seconds: 5);
    Duration? pos;
    if (!_positionUnsupported) {
      try {
        final infoXml = await device.position();
        final rel = RegExp(
          r'<RelTime>([^<]+)</RelTime>',
        ).firstMatch(infoXml)?.group(1);
        pos = _parseClock(rel);
        _positionFails = 0;
      } catch (e) {
        _positionFails++;
        if (_positionFails >= 3) {
          _positionUnsupported = true;
          _log.info(
            'poll: renderer rejects GetPositionInfo '
            '($_positionFails failures) — position sync disabled',
          );
        }
      }
    }
    String? transportState;
    try {
      final transportXml = await device.getTransportInfo();
      transportState = RegExp(
        r'<CurrentTransportState>([^<]+)</CurrentTransportState>',
      ).firstMatch(transportXml)?.group(1);
    } catch (_) {}
    if (pos != null) _set((s) => s.copyWith(remotePosition: pos));
    if (transportState != null) {
      _set((s) => s.copyWith(remoteState: transportState));
    }
    if (suppress) return;
    final surface = _player;
    if (surface == null) return;
    if (transportState == 'STOPPED') {
      DlnaCastBridge.instance.pipeRemoteEnded();
      return;
    }
    if (pos == null) return;
    // NOTE: the renderer position does NOT go through pipe* — those are
    // USER-action forwards. The reverse half of the sync is syncTransport
    // only; forwarding it here would seek + re-push every poll tick.
    if (transportState == 'TRANSITIONING') return;
    final rendererPlaying = transportState == 'PLAYING';
    final drift = (pos - surface.position).abs();
    if (surface.playing != rendererPlaying ||
        (rendererPlaying && drift > const Duration(seconds: 2))) {
      // Renderer-side pause/play (TV remote) or persistent drift with no
      // local command in flight: the renderer is the screen the user
      // watches — the app player follows.
      surface.syncTransport(playing: rendererPlaying, position: pos);
    }
  }

  Duration? _parseClock(String? clock) {
    if (clock == null) return null;
    final m = RegExp(r'(\d+):(\d+):(\d+)').firstMatch(clock);
    if (m == null) return null;
    return Duration(
      hours: int.parse(m.group(1)!),
      minutes: int.parse(m.group(2)!),
      seconds: int.parse(m.group(3)!),
    );
  }

  DLNADevice? get _connected => state.devices
      .where((d) => d.id == state.connectedId)
      .map((d) => d.device)
      .firstOrNull;

  void _teardown() {
    DlnaCastBridge.instance.detach();
    _stopPoll();
    _sub?.cancel();
    _sub = null;
    try {
      _manager?.stop();
    } catch (_) {}
    _manager = null;
  }
}

/// A raw protocolInfo string — dlna_dart's enum lacks DLNA.ORG_PN profiles,
/// which profile-bound renderers gate on.
class _RawMime implements PlayType {
  const _RawMime(this.protocolInfo);

  @override
  final String protocolInfo;
}
