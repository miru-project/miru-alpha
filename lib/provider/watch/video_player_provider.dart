import 'dart:async';
import 'dart:io';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/cast/dlna_cast_bridge.dart';
import 'package:miru_alpha/provider/cast/dlna_cast_provider.dart';
import 'package:miru_alpha/provider/network_provider.dart';
import 'package:miru_alpha/utils/watch/subtitle.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';

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
      v2watch: v2watch ?? v2watch,
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

  /// Headers for the currently loaded stream, empty when none.
  Map<String, String> get streamHeaders => _streamHeaders;

  @override
  VideoPlayerTickState build(
    String? mediaUrl, {
    List<ExtensionBangumiWatchSubtitle>? subtitlesRaw,
    Map<String, String>? headers,
    Size? initialRatio,
    ExtensionBangumiWatchTorrent? torrent,
    String? localPath,
    pb_extension.ExtensionWatch? v2watch,
  }) {
    defaultSize = initialRatio ?? const Size(0, 0);
    _streamHeaders = headers ?? const {};
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
      subtitlesRaw: subtitlesRaw ?? const [],
      showControls: false,
      ratio: vidController.value.aspectRatio,
      v2watch: v2watch,
    );

    Future.microtask(() => _init(mediaUrl, headers ?? const {}));
    return initialState;
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

  /// Manually set showControls state and cancel existing timer if hiding.
  void setShowControls(bool v) {
    _hideTimer?.cancel();
    state = state.copyWith(showControls: v);
    if (v) {
      // Auto-hide only while playing: a paused surface keeps its controls —
      // the play/pause affordance stays visible (the reference mock does the
      // same). Pausing cancels this via the tap path re-showing controls.
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (state.isPlaying) state = state.copyWith(showControls: false);
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
        state = state.copyWith(showControls: false);
      });
    }
  }

  void _init(String? url, Map<String, String> headers) {
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

  void changeVideoQuality(String url) {
    vidController.pause();
    vidController.removeListener(_updatePosition);
    vidController.dispose();
    // Keep the stream headers: a fresh controller without them drops the
    // Referer/User-Agent the source gates on, and the cast engine (fed the
    // same headers) would then send requests the local player never does.
    vidController = VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: _streamHeaders,
    );

    vidController.initialize().then((_) {
      vidController.addListener(_updatePosition);
      vidController.play();

      state = state.copyWith(
        isPlaying: true,
        duration: vidController.value.duration,
        buffered: vidController.value.buffered,
      );
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
    final positionMoved =
        (v.position - state.position).abs() >=
        const Duration(milliseconds: 250);
    final playStateChanged = v.isPlaying != state.isPlaying;
    if (!positionMoved &&
        !playStateChanged &&
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
    state = state.copyWith(selectedSubtitleIndex: index, isShowSubtitle: true);
    SubtitleUtil.parseVttSubtitles(state.subtitlesRaw[index].url).then((value) {
      setSubtitles(value, index);
    });
  }

  void closeSubtitle() {
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
        vidController.removeListener(_updatePosition);
        await vidController.dispose();

        // The cast engine is fed streamHeaders — keep it in step with the
        // headers the new controller actually uses, so both engines send the
        // same requests after a mirror switch.
        _streamHeaders = watchResult.headers;
        vidController = _getController(
          watchResult.url,
          watchResult.headers,
          watchResult.torrent,
          null,
        );

        await vidController.initialize();
        vidController.addListener(_updatePosition);

        if (isPlaying) {
          vidController.play();
        }

        await vidController.seekTo(currentPosition);

        state = state.copyWith(
          subtitlesRaw: watchResult.subtitles,
          duration: vidController.value.duration,
          isPlaying: isPlaying,
          position: currentPosition,
          ratio: vidController.value.aspectRatio,
        );

        // Subtitles re-init if needed
        initSubtitle(watchResult.subtitles);

        // Quality re-init
        getQuality(watchResult.url, watchResult.headers).then((val) {
          state = state.copyWith(qualityMap: val);
        });
      }
    } catch (e) {
      // Handle error
    }
  }
}
