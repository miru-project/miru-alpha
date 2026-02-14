import 'dart:async';
import 'dart:io';
import 'package:miru_app_new/miru_core/network.dart';
import 'package:miru_app_new/miru_core/grpc_client.dart';
import 'package:miru_app_new/miru_core/proto/proto.dart' as proto;
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/utils/watch/subtitle.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter/material.dart';
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
  final Map<String, String> qualityMap;
  final double ratio;
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
class VideoPlayerNotifier extends _$VideoPlayerNotifier {
  late VideoPlayerController vidController;
  late final Size defaultSize;
  VideoPlayerController get videoPlayerController => vidController;
  @override
  VideoPlayerTickState build(
    String? mediaUrl, {
    List<ExtensionBangumiWatchSubtitle>? subtitlesRaw,
    Map<String, String>? headers,
    Size? initialRatio,
    ExtensionBangumiWatchTorrent? torrent,
    String? localPath,
  }) {
    defaultSize = initialRatio ?? const Size(0, 0);
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
      // if showing, schedule auto-hide
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
      if (torrent != null) {
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
    vidController = VideoPlayerController.networkUrl(Uri.parse(url));

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

  void _updatePosition() {
    state = state.copyWith(
      position: vidController.value.position,
      isPlaying: vidController.value.isPlaying,
      duration: vidController.value.duration,
      buffered: vidController.value.buffered,
      currentSubtitle: getCurrentSubtitle(),
      ratio: vidController.value.aspectRatio,
    );

    EpisodeNotifier.progress = state.position.inSeconds;
    EpisodeNotifier.totalProgress = state.duration.inSeconds;
  }

  void changeSubtitle(int index) {
    state = state.copyWith(selectedSubtitleIndex: index);
  }

  void play() {
    vidController.play();
    state = state.copyWith(isPlaying: true);
  }

  void playOrPause() {
    if (state.isPlaying) {
      pause();
      return;
    }
    play();
  }

  void pause() {
    vidController.pause();
    state = state.copyWith(isPlaying: false);
  }

  void seek(Duration position) {
    state = state.copyWith(position: position);
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
}
