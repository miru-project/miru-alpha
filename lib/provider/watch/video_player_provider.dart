import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/cast/dlna_cast_bridge.dart';
import 'package:miru_alpha/provider/cast/dlna_cast_provider.dart';
import 'package:miru_alpha/provider/network_provider.dart';
import 'package:miru_alpha/utils/watch/subtitle.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';
// The FVPControllerExtensions: setExternalSubtitle routes the subtitle into
// mdk's native (libass) renderer instead of the Dart software overlay.
import 'package:fvp/fvp.dart';

import 'package:material_ui/material_ui.dart';
part 'video_player_provider.g.dart';

class VideoPlayerTickState {
  Duration duration;
  List<DurationRange> bufferedRange;
  final Duration position;
  final bool isPlaying;
  final double speed;
  final int selectedSubtitleIndex;
  final bool isShowSideBar;
  final List<ExtensionBangumiWatchSubtitle> subtitlesRaw;
  final List<Subtitle> subtitles;
  final bool isShowSubtitle;
  final String currentSubtitle;
  final bool showControls;
  final bool showSettings;

  /// The pane the settings surface opens on — the landscape meta chips
  /// deep-link here (mirror / resolution / subtitle / speed); 0 keeps the
  /// first tab. The docked panel keys its tabs on this value so a change
  /// re-selects the pane while the panel is already mounted.
  final int settingsTab;
  final bool locked;
  final Map<String, String> qualityMap;
  final double ratio;
  final pb_extension.ExtensionWatch? v2watch;

  /// The video engine's request failure (fvp): the stream server answered
  /// non-200 (403 expired link, 404 gone, timeouts) or the demuxer failed.
  ///surfaced verbatim on the viewport's video-request error card; `null`
  /// while playback is healthy. Retry re-requests the same URL, Switch
  /// Mirror re-requests another mirror's URL.
  final String? playerError;

  /// Bumped on every controller swap (quality / mirror switch): the video
  /// surface watches it so the `VideoPlayer` widget rebinds to the fresh
  /// controller even when the new stream's aspect ratio is unchanged.
  final int playbackEpoch;
  VideoPlayerTickState({
    this.position = Duration.zero,
    this.isPlaying = false,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.bufferedRange = const [],
    this.selectedSubtitleIndex = 0,
    this.isShowSideBar = false,
    this.subtitlesRaw = const [],
    this.subtitles = const [],
    this.isShowSubtitle = false,
    this.qualityMap = const {},
    this.ratio = 0.0,
    this.currentSubtitle = '',
    this.showControls = false,
    this.showSettings = false,
    this.settingsTab = 0,
    this.locked = false,
    this.v2watch,
    this.playerError,
    this.playbackEpoch = 0,
  });

  VideoPlayerTickState copyWith({
    VideoPlayerController? controller,
    Duration? position,
    bool? isPlaying,
    Duration? duration,
    double? speed,
    List<DurationRange>? buffered,
    int? selectedSubtitleIndex,
    bool? isOpenSideBar,
    bool? isShowSideBar,
    List<ExtensionBangumiWatchSubtitle>? subtitlesRaw,
    List<Subtitle>? subtitles,
    bool? isShowSubtitle,
    bool? showControls,
    bool? showSettings,
    int? settingsTab,
    bool? locked,
    int? selectedGroupIndex,
    int? selectedEpisodeIndex,
    String? name,
    String? currentSubtitle,
    double? ratio,
    Map<String, String>? qualityMap,
    String? playerError,
    bool clearPlayerError = false,
    int? playbackEpoch,
    pb_extension.ExtensionWatch? v2watch,
  }) {
    return VideoPlayerTickState(
      position: position ?? this.position,
      isPlaying: isPlaying ?? this.isPlaying,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      bufferedRange: buffered ?? bufferedRange,
      selectedSubtitleIndex:
          selectedSubtitleIndex ?? this.selectedSubtitleIndex,
      isShowSideBar: isShowSideBar ?? this.isShowSideBar,
      subtitlesRaw: subtitlesRaw ?? this.subtitlesRaw,
      subtitles: subtitles ?? this.subtitles,
      isShowSubtitle: isShowSubtitle ?? this.isShowSubtitle,
      currentSubtitle: currentSubtitle ?? this.currentSubtitle,
      ratio: ratio ?? this.ratio,
      qualityMap: qualityMap ?? this.qualityMap,
      showControls: showControls ?? this.showControls,
      showSettings: showSettings ?? this.showSettings,
      settingsTab: settingsTab ?? this.settingsTab,
      locked: locked ?? this.locked,
      // The error is CLEARABLE: clearPlayerError resets it (retry/switch
      // re-request the stream and a healthy tick must clear the card).
      playerError: clearPlayerError ? null : (playerError ?? this.playerError),
      playbackEpoch: playbackEpoch ?? this.playbackEpoch,
      v2watch: v2watch ?? this.v2watch,
    );
  }
}

const videoExtensions = [
  "mp4",
  "webm",
  "ogg",
  "flv",
  "mov",
  "ts",
  "3gp",
  "avi",
  "wmv",
  "mkv",
  "mpg",
  "mpeg",
  "m4v",
  "mvp",
  "flac",
  "mp3",
  "wav",
  "m4a",
];

@riverpod
class VideoPlayerNotifier extends _$VideoPlayerNotifier
    implements DlnaPlayerSurface {
  late VideoPlayerController vidController;
  late final Size defaultSize;
  VideoPlayerController get videoPlayerController => vidController;

  /// The watch result's HTTP headers (Referer/User-Agent/…): the DLNA cast
  /// hands them to the ffmpeg engine so the source fetch passes the same
  /// gates the local player passes.
  Map<String, String> _streamHeaders = const {};

  /// The family's torrent / local-file source: quality switches are
  /// meaningless for them (no HLS manifest to resolve).
  ExtensionBangumiWatchTorrent? _familyTorrent;
  String? _familyLocalPath;

  /// Headers for the currently loaded stream, empty when none.
  Map<String, String> get streamHeaders => _streamHeaders;

  @override
  VideoPlayerTickState build(
    String? mediaUrl, {
    Map<String, String>? headers,
    Size? initialRatio,
    ExtensionBangumiWatchTorrent? torrent,
    String? localPath,
    Map<String, String> qualityMap = const {},
  }) {
    defaultSize = initialRatio ?? const Size(0, 0);
    _streamHeaders = headers ?? const {};
    _familyTorrent = torrent;
    _familyLocalPath = localPath;
    // Register the simplified player surface: the cast session forwards app
    // actions and echoes renderer transport state back onto this notifier.
    ref.read(dlnaCastProvider.notifier).attachPlayer(this);
    String streamUrl = mediaUrl ?? '';
    vidController = _getController(
      streamUrl,
      headers ?? const {},
      torrent,
      localPath,
    );
    final initialState = VideoPlayerTickState(
      showControls: false,
      ratio: vidController.value.aspectRatio,
      qualityMap: qualityMap,
    );

    Future.microtask(() => _init(mediaUrl, headers ?? const {}, qualityMap));
    return initialState;
  }

  /// Injects the session data the shell resolved — the watch protobuf and the
  /// subtitle list — after the element exists. Family arguments are hashed
  /// into provider identity, so protobufs must never ride the family key;
  /// they belong to the open page, not to a keyed element.
  void setSession({
    List<ExtensionBangumiWatchSubtitle>? subtitlesRaw,
    pb_extension.ExtensionWatch? v2watch,
  }) {
    if (!ref.mounted) return;
    final nextSubtitles =
        subtitlesRaw ?? const <ExtensionBangumiWatchSubtitle>[];
    if (listEquals(state.subtitlesRaw, nextSubtitles) &&
        state.v2watch == v2watch) {
      return;
    }
    state = state.copyWith(subtitlesRaw: nextSubtitles, v2watch: v2watch);
  }

  VideoPlayerController _getController(
    String url,
    Map<String, String> headers,
    ExtensionBangumiWatchTorrent? torrent,
    String? localPath,
  ) {
    if (localPath != null) {
      return VideoPlayerController.file(File(localPath));
    }
    if (torrent != null) {
      for (var file in torrent.files) {
        final ext = file.split('.').last;
        if (videoExtensions.contains(ext)) {
          url =
              '${CoreNetwork.baseUrl}/torrent/data/${torrent.infoHash}/${Uri.encodeComponent(file)}';
          break;
        }
      }
    }
    return VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: headers,
    );
  }

  Timer? _hideTimer;
  int prevTime = 0;

  /// A scrub (seekbar drag / swipe seek) is in flight: the chrome auto-hide
  /// holds off so the bar cannot fade out mid-drag.
  bool _scrubbing = false;

  /// Seek target awaiting engine arrival (see [_updatePosition]): mdp/mdk
  /// keeps reporting the pre-seek position through the whole HLS rebuffer,
  /// so echoing it back snapped the thumb and time label backwards after
  /// release. Display holds the target until the engine lands.
  Duration? _seekTarget;
  DateTime _seekAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Engine position within this band of [_seekTarget] counts as landed.
  static const _seekArrivalBand = Duration(milliseconds: 900);

  /// Watchdog: never hold the displayed target longer than this.
  static const _seekHoldCap = Duration(seconds: 6);

  /// Manually set showControls state and cancel existing timer if hiding.
  void setShowControls(bool v) {
    _hideTimer?.cancel();
    state = state.copyWith(showControls: v);
    if (v) {
      // Auto-hide only while playing: a paused surface keeps its controls —
      // the play/pause affordance stays visible (the reference mock does the
      // same). Pausing cancels this via the tap path re-showing controls.
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (state.isPlaying && !_scrubbing) {
          state = state.copyWith(showControls: false);
        }
      });
    }
  }

  /// Scrub session marker (seekbar drag start/end). While active the
  /// auto-hide is suspended; on end the 3s timer re-arms like a fresh
  /// control reveal.
  void setScrubbing(bool v) {
    if (_scrubbing == v) return;
    _scrubbing = v;
    _hideTimer?.cancel();
    if (!v && state.showControls && state.isPlaying) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (state.isPlaying && !_scrubbing) {
          state = state.copyWith(showControls: false);
        }
      });
    }
  }

  /// Screen lock (landscape mobile): a locked surface hides all chrome and
  /// swallows playback gestures until the unlock pill is tapped.
  void setLocked(bool v) {
    _hideTimer?.cancel();
    state = state.copyWith(locked: v, showControls: !v);
    if (!v) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (!_scrubbing) state = state.copyWith(showControls: false);
      });
    }
  }

  void _init(
    String? url,
    Map<String, String> headers,
    Map<String, String> familyQualityMap,
  ) {
    ref.onDispose(() {
      _hideTimer?.cancel();
      vidController.removeListener(_updatePosition);
      vidController.dispose();
      if (torrent?.infoHash.isNotEmpty ?? false) {
        MiruGrpcClient.downloadClient.deleteTorrent(
          proto.DeleteTorrentRequest()..infoHash = torrent!.infoHash,
        );
      }
    });
    vidController.initialize().then((_) {
      vidController.addListener(_updatePosition);
      vidController.play();

      state = state.copyWith(
        isPlaying: true,
        duration: vidController.value.duration,
        buffered: vidController.value.buffered,
      );
    });
    // Don't  get quality when using torrent or local file
    if (torrent != null || url == null || localPath != null) {
      return;
    }
    if (familyQualityMap.isNotEmpty) {
      // The manifest was already fetched + parsed before the player was
      // created (the master collapsed to its first variant there) — reuse
      // it instead of re-fetching the same URL.
      state = state.copyWith(qualityMap: familyQualityMap);
      return;
    }
    getQuality(url, headers).then((val) {
      state = state.copyWith(qualityMap: val);
    });
  }

  // player management
  List<double> get speedList => const [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    2.0,
    3.0,
  ];

  /// Clears the video-request error card (a fresh re-request is starting).
  void clearPlayerError() {
    state = state.copyWith(clearPlayerError: true);
  }

  /// Quality / mirror / retry switch. The target URL is resolved first (a
  /// mirror can hand back a multi-variant master — collapse it to one
  /// variant like the initial load; a known variant url skips the fetch),
  /// the fresh controller is built BESIDE the running one and swapped in
  /// only after it is ready; the old controller is disposed post-frame so
  /// the surface never renders a dead controller.
  Future<void> changeVideoQuality(String url) async {
    _seekTarget = null;
    if (_familyTorrent != null || _familyLocalPath != null) return;
    final knownVariant = state.qualityMap.containsValue(url);
    final src = knownVariant
        ? (qualityMap: state.qualityMap, playbackUrl: url)
        : await resolvePlayback(url, _streamHeaders);
    vidController.pause();
    final old = vidController;
    final fresh = VideoPlayerController.networkUrl(
      Uri.parse(src.playbackUrl),
      // Keep the stream headers: a fresh controller without them drops the
      // Referer/User-Agent the source gates on, and the cast engine (fed
      // the same headers) would then send requests the local player never
      // does.
      httpHeaders: _streamHeaders,
    );
    await fresh.initialize();
    old.removeListener(_updatePosition);
    vidController = fresh;
    fresh.addListener(_updatePosition);
    fresh.play();
    state = state.copyWith(
      playbackEpoch: state.playbackEpoch + 1,
      isPlaying: true,
      duration: fresh.value.duration,
      buffered: fresh.value.buffered,
      ratio: fresh.value.aspectRatio,
      qualityMap: src.qualityMap,
      clearPlayerError: true,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      old.dispose();
    });
  }

  /// Controller listener: pushes the player's value into Riverpod state.
  ///
  /// mdk fires many notifications per second (one per frame tick), and every
  /// push here rebuilds every watcher of this provider — pushing all of them
  /// is the transport's lag. Only meaningful deltas are pushed instead:
  /// 250ms position granularity (the scrubber still drags locally at full
  /// rate via its own useState), plus any discrete flag change.
  void _updatePosition() {
    final v = vidController.value;
    // Seek in flight: hold the displayed target (the user's release point)
    // until the engine actually lands — echoing the engine's stale
    // pre-seek position snapped the thumb backwards mid-rebuffer. Only
    // non-position fields move during the hold; errors still surface.
    if (_seekTarget != null) {
      final arrived = (v.position - _seekTarget!).abs() <= _seekArrivalBand;
      if (!arrived && DateTime.now().difference(_seekAt) < _seekHoldCap) {
        final errorNow = v.hasError ? v.errorDescription : null;
        if (v.isPlaying == state.isPlaying &&
            v.duration == state.duration &&
            v.aspectRatio == state.ratio &&
            errorNow == state.playerError &&
            _sameBuffered(v.buffered, state.bufferedRange)) {
          return;
        }
        state = state.copyWith(
          isPlaying: v.isPlaying,
          duration: v.duration,
          buffered: v.buffered,
          ratio: v.aspectRatio,
          playerError: errorNow,
          clearPlayerError: !v.hasError,
        );
        return;
      }
      _seekTarget = null;
    }
    final positionMoved =
        (v.position - state.position).abs() >=
        const Duration(milliseconds: 250);
    final playStateChanged = v.isPlaying != state.isPlaying;
    final errorNow = v.hasError ? v.errorDescription : null;
    final errorChanged = errorNow != state.playerError;
    if (!positionMoved &&
        !playStateChanged &&
        !errorChanged &&
        v.duration == state.duration &&
        v.aspectRatio == state.ratio &&
        _sameBuffered(v.buffered, state.bufferedRange)) {
      return;
    }
    state = state.copyWith(
      position: v.position,
      isPlaying: v.isPlaying,
      duration: v.duration,
      buffered: v.buffered,
      currentSubtitle: getCurrentSubtitle(),
      ratio: v.aspectRatio,
      // The video engine's request failure (the stream server answering
      // 403/404/5xx, expired signed links, demuxer failures) — video_player
      // reports it on the controller value; surface it verbatim for the
      // video-request error card. A healthy value clears it.
      playerError: errorNow,
      clearPlayerError: !v.hasError,
    );
  }

  /// Whether the two buffered ranges carry identical start/end points.
  bool _sameBuffered(List<DurationRange> a, List<DurationRange> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].start != b[i].start || a[i].end != b[i].end) return false;
    }
    return true;
  }

  void changeSubtitle(int index) {
    state = state.copyWith(selectedSubtitleIndex: index);
  }

  @override
  void play() {
    vidController.play();
    state = state.copyWith(isPlaying: true);
    // Cast session live: the local play is the master action — mirror it.
    DlnaCastBridge.instance.pipePlay();
  }

  void playOrPause() {
    if (state.isPlaying) {
      pause();
      return;
    }
    play();
  }

  @override
  void pause() {
    vidController.pause();
    state = state.copyWith(isPlaying: false);
    DlnaCastBridge.instance.pipePause();
  }

  void seek(Duration position) {
    state = state.copyWith(position: position);
    _seekTarget = position;
    _seekAt = DateTime.now();
    vidController.seekTo(position);
    DlnaCastBridge.instance.pipeSeek(position);
  }

  void seekBy(int seconds) {
    seek(state.position + Duration(seconds: seconds));
  }

  // --- DlnaPlayerSurface (the simplified player the cast session drives) ---

  @override
  Duration get position => state.position;

  @override
  Duration? get duration => state.duration;

  @override
  bool get playing => state.isPlaying;

  @override
  void seekTo(Duration position) => seek(position);

  @override
  Future<void> load(String source) async {
    // Episode/source switch — same machinery as a quality switch: a fresh
    // controller on the new source; the cast session re-pushes it.
    changeVideoQuality(source);
  }

  @override
  void syncTransport({required bool playing, required Duration position}) {
    // RENDERER→app echo: apply without re-forwarding (no pipe* calls here).
    state = state.copyWith(isPlaying: playing, position: position);
    if (playing) {
      vidController.play();
    } else {
      vidController.pause();
    }
    vidController.seekTo(position);
  }

  void setSpeed(double speed) {
    vidController.setPlaybackSpeed(speed);
    state = state.copyWith(speed: speed);
  }

  //subtitle management
  void setSubtitles(List<Subtitle> subtitles, int index) {
    state = state.copyWith(subtitles: subtitles, selectedSubtitleIndex: index);
  }

  String getCurrentSubtitle() {
    final subtitle = state.subtitles.firstWhere(
      (subtitle) =>
          state.position >= subtitle.start && state.position <= subtitle.end,
      orElse: () =>
          Subtitle(start: Duration.zero, end: Duration.zero, text: ''),
    );
    return subtitle.text;
  }

  void setSubSelectedIndex(int index) {
    // Native (libass) render path first: mdk loads the subtitle as an
    // external media track and draws it into the frame — no Dart-side VTT
    // parsing, no software text overlay. The URL rides the app's standard
    // image/media proxy, exactly like covers and screenshots do; a source
    // that needs special fetching (TLS fingerprinting, tokens) is the
    // EXTENSION'S job to hand back as a working proxyable URL. Falls back
    // to the Dart VTT overlay when the fvp platform is not the engine.
    final subUrl = state.subtitlesRaw[index].url;
    try {
      vidController.setExternalSubtitle(
        MiruRequest.proxyUrl(subUrl).toString(),
      );
      state = state.copyWith(
        selectedSubtitleIndex: index,
        isShowSubtitle: false,
        subtitles: const [],
      );
      return;
    } catch (_) {
      // Not the fvp platform — software overlay fallback below.
    }
    // Fetch with the stream's headers: the subtitle CDN gates on the same
    // Referer/User-Agent the video source does — a bare URL request 403s.
    SubtitleUtil.parseVttSubtitles(subUrl, headers: _streamHeaders).then((
      value,
    ) {
      setSubtitles(value, index);
    });
  }

  void closeSubtitle() {
    // Stop the native (libass) render too: mdk keeps drawing the active
    // external subtitle track until it is disabled. No-op when the fvp
    // platform is not the engine (the Dart overlay needs no teardown).
    try {
      vidController.setSubtitleTracks(const []);
    } catch (_) {}
    state = state.copyWith(isShowSubtitle: false);
  }

  void initSubtitle(List<ExtensionBangumiWatchSubtitle>? subtitles) {
    state = state.copyWith(
      subtitlesRaw: subtitles,
      isShowSubtitle: false,
      selectedSubtitleIndex: 0,
      subtitles: const [],
    );
  }

  void putVideoDefaultRatio(Size size) {
    defaultSize = size;
  }

  int get length => state.subtitles.length;
  List<Subtitle> get subtitles => state.subtitles;
  int get selectedIndex => state.selectedSubtitleIndex;

  void toggleSettings() {
    state = state.copyWith(showSettings: !state.showSettings);
  }

  /// Opens the settings surface on a specific pane — the landscape meta
  /// chips deep-link (mirror / resolution / subtitle / speed) instead of
  /// dumping the user on the first tab.
  void openSettings(int tab) {
    state = state.copyWith(settingsTab: tab, showSettings: true);
  }

  Future<void> switchMirror(
    String packageName,
    pb_extension.ExtensionMirror mirror,
  ) async {
    final currentPosition = vidController.value.position;
    final isPlaying = vidController.value.isPlaying;

    // Optional: show loading or some UI feedback
    vidController.pause();

    try {
      final watchResult = await MiruCoreEndpoint.mirror(
        packageName,
        mirror.url,
      );

      if (watchResult is pb_extension.ExtensionBangumiWatch) {
        _seekTarget = null;
        // The cast engine is fed streamHeaders — keep it in step with the
        // headers the new controller actually uses, so both engines send the
        // same requests after a mirror switch.
        _streamHeaders = watchResult.headers;
        // A mirror's url may be a multi-variant master — collapse it to one
        // variant like the initial load. The same fetch also carries the
        // variant map (no second manifest GET).
        final src = await resolvePlayback(watchResult.url, watchResult.headers);
        final old = vidController;
        final fresh = _getController(
          src.playbackUrl,
          watchResult.headers,
          watchResult.torrent,
          null,
        );
        await fresh.initialize();
        old.removeListener(_updatePosition);
        vidController = fresh;
        fresh.addListener(_updatePosition);

        if (isPlaying) {
          fresh.play();
        }

        await fresh.seekTo(currentPosition);

        state = state.copyWith(
          playbackEpoch: state.playbackEpoch + 1,
          subtitlesRaw: watchResult.subtitles,
          duration: fresh.value.duration,
          isPlaying: isPlaying,
          position: currentPosition,
          ratio: fresh.value.aspectRatio,
          qualityMap: src.qualityMap,
        );

        // Subtitles re-init if needed
        initSubtitle(watchResult.subtitles);

        // The old controller stays the bound surface until this state write
        // rebuilds the video consumer; dispose it after that frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          old.dispose();
        });
      }
    } catch (e) {
      // Handle error
    }
  }
}
