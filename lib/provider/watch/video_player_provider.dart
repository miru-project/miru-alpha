import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/utils/subtitle.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter/material.dart';

class VideoPlayerProvider {
  static late AutoDisposeStateNotifierProvider<VideoPlayerNotifier,
      VideoPlayerState> _videoPlayerNotifier;
  static void initProvider(
      String url,
      List<ExtensionBangumiWatchSubtitle> subtitle,
      Map<String, String> headers) {
    _videoPlayerNotifier = StateNotifierProvider.autoDispose<
        VideoPlayerNotifier, VideoPlayerState>((ref) {
      return VideoPlayerNotifier(url, subtitle, headers);
    });
  }

  static AutoDisposeStateNotifierProvider<VideoPlayerNotifier, VideoPlayerState>
      get provider => _videoPlayerNotifier;
}

class VideoPlayerState {
  VideoPlayerController? controller;
  Duration duration;
  List<DurationRange> buffered;
  final Duration position;
  final bool isPlaying;
  final double speed;
  final Size size;
  final int selectedSubtitleIndex;
  final bool isOpenSideBar;
  final bool isShowSideBar;
  final List<ExtensionBangumiWatchSubtitle> subtitlesRaw;
  final List<Subtitle> subtitles;
  final bool isShowSubtitle;
  final List<ExtensionEpisodeGroup> epGroup;
  final int selectedGroupIndex;
  final int selectedEpisodeIndex;
  final String name;
  final String currentSubtitle;
  final Map<String, String> qualityMap;

  VideoPlayerState(
      {this.controller,
      this.position = Duration.zero,
      this.isPlaying = false,
      this.duration = Duration.zero,
      this.speed = 1.0,
      this.buffered = const [],
      this.size = const Size(0, 0),
      this.selectedSubtitleIndex = 0,
      this.isOpenSideBar = false,
      this.isShowSideBar = false,
      this.subtitlesRaw = const [],
      this.subtitles = const [],
      this.isShowSubtitle = false,
      this.epGroup = const [],
      this.selectedGroupIndex = 0,
      this.name = '',
      this.selectedEpisodeIndex = 0,
      this.qualityMap = const {},
      this.currentSubtitle = ''});

  VideoPlayerState copyWith(
      {VideoPlayerController? controller,
      Duration? position,
      bool? isPlaying,
      Duration? duration,
      double? speed,
      List<DurationRange>? buffered,
      Size? size,
      int? selectedSubtitleIndex,
      bool? isOpenSideBar,
      bool? isShowSideBar,
      List<ExtensionBangumiWatchSubtitle>? subtitlesRaw,
      List<Subtitle>? subtitles,
      bool? isShowSubtitle,
      List<ExtensionEpisodeGroup>? epGroup,
      int? selectedGroupIndex,
      int? selectedEpisodeIndex,
      String? name,
      String? currentSubtitle,
      Map<String, String>? qualityMap}) {
    return VideoPlayerState(
        controller: controller ?? this.controller,
        position: position ?? this.position,
        isPlaying: isPlaying ?? this.isPlaying,
        duration: duration ?? this.duration,
        speed: speed ?? this.speed,
        buffered: buffered ?? this.buffered,
        size: size ?? this.size,
        selectedSubtitleIndex:
            selectedSubtitleIndex ?? this.selectedSubtitleIndex,
        isOpenSideBar: isOpenSideBar ?? this.isOpenSideBar,
        isShowSideBar: isShowSideBar ?? this.isShowSideBar,
        subtitlesRaw: subtitlesRaw ?? this.subtitlesRaw,
        subtitles: subtitles ?? this.subtitles,
        isShowSubtitle: isShowSubtitle ?? this.isShowSubtitle,
        epGroup: epGroup ?? this.epGroup,
        selectedGroupIndex: selectedGroupIndex ?? this.selectedGroupIndex,
        selectedEpisodeIndex: selectedEpisodeIndex ?? this.selectedEpisodeIndex,
        name: name ?? this.name,
        currentSubtitle: currentSubtitle ?? this.currentSubtitle,
        qualityMap: qualityMap ?? this.qualityMap);
  }
}

class VideoPlayerNotifier extends StateNotifier<VideoPlayerState> {
  VideoPlayerNotifier(String url, List<ExtensionBangumiWatchSubtitle> subtitle,
      Map<String, String> headers)
      : super(VideoPlayerState(
            subtitlesRaw: subtitle,
            controller: VideoPlayerController.networkUrl(Uri.parse(url)))) {
    _init(url, headers);
  }

  void _init(url, headers) {
    state.controller?.initialize().then((_) {
      state.controller?.addListener(_updatePosition);
      state.controller?.play();

      state = state.copyWith(
        isPlaying: true,
        duration: state.controller?.value.duration,
        buffered: state.controller?.value.buffered,
      );
    });
    getQuality(url, headers).then((val) {
      state = state.copyWith(qualityMap: val);
    });
  }

  // player management
  get speedList => const [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0];
  // void initVideoPlayer(String url, Map<String, String> headers) {
  //   final controller = VideoPlayerController.networkUrl(Uri.parse(url));

  //   state.controller = controller;
  //   state.duration = controller.value.duration;
  //   state.buffered = controller.value.buffered;
  //   state.controller?.initialize().then((_) {
  //     state.controller?.addListener(_updatePosition);
  //     state.controller?.play();

  //     state = state.copyWith(
  //         isPlaying: true,
  //         duration: state.controller?.value.duration,
  //         buffered: state.controller?.value.buffered,
  //         isShowSubtitle: false,
  //         selectedSubtitleIndex: 0,
  //         subtitles: const []);
  //     getQuality(url, headers);
  //   });
  // }

  void changeVideoQuality(String url) {
    state.controller?.pause();
    state.controller?.dispose();
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    state = state.copyWith(
      controller: controller,
      duration: controller.value.duration,
      buffered: controller.value.buffered,
    );
    state.controller?.initialize().then((_) {
      state.controller?.addListener(_updatePosition);
      state.controller?.play();

      state = state.copyWith(
        isPlaying: true,
        duration: state.controller?.value.duration,
        buffered: state.controller?.value.buffered,
      );
    });
  }

  void _updatePosition() {
    state = state.copyWith(
      position: state.controller?.value.position,
      isPlaying: state.controller?.value.isPlaying,
      duration: state.controller?.value.duration,
      buffered: state.controller?.value.buffered,
      currentSubtitle: getCurrentSubtitle(),
    );
  }

  void changeSubtitle(int index) {
    state = state.copyWith(selectedSubtitleIndex: index);
  }

  void play() {
    state.controller?.play();
    state = state.copyWith(isPlaying: true);
  }

  void playOrPause() {
    if (state.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void toggleSideBar() {
    state = state.copyWith(isOpenSideBar: !state.isOpenSideBar);
  }

  void pause() {
    state.controller?.pause();
    state = state.copyWith(isPlaying: false);
  }

  void seek(Duration position) {
    state.controller?.seekTo(position);
    state = state.copyWith(position: position);
  }

  void setSpeed(double speed) {
    state.controller?.setPlaybackSpeed(speed);
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

  void setSelectedIndex(int index) {
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
        subtitles: const []);
  }

  int get length => state.subtitles.length;
  List<Subtitle> get subtitles => state.subtitles;
  int get selectedIndex => state.selectedSubtitleIndex;

  //episode management
  // void selectEpisode(int groupIndex, int episodeIndex) {
  //   state = state.copyWith(
  //     selectedGroupIndex: groupIndex,
  //     selectedEpisodeIndex: episodeIndex,
  //   );
  // }

  // void initEpisodes(int groupIndex, int episodeIndex,
  //     List<ExtensionEpisodeGroup> epGroup, String name, bool flag) {
  //   state = state.copyWith(
  //       epGroup: epGroup,
  //       name: name,
  //       selectedGroupIndex: groupIndex,
  //       selectedEpisodeIndex: episodeIndex);
  // }

  @override
  void dispose() {
    state.controller?.removeListener(_updatePosition);
    state.controller?.dispose();
    // DatabaseService.putHistory(History()
    //   ..title = name
    //   ..package = package

    //   ..type = type
    //   ..url = url
    //   ..date = DateTime.now());
    super.dispose();
  }
}
