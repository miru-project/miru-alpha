import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';

part 'video_player_view_model.g.dart';

class VideoPlayerViewState {
  final double ratio;
  final bool showSettings;
  final bool showControls;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double speed;
  final String currentSubtitle;
  final Map<String, String> qualityMap;

  const VideoPlayerViewState({
    this.ratio = 0.0,
    this.showSettings = false,
    this.showControls = false,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.currentSubtitle = '',
    this.qualityMap = const {},
  });

  VideoPlayerViewState copyWith({
    double? ratio,
    bool? showSettings,
    bool? showControls,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? speed,
    String? currentSubtitle,
    Map<String, String>? qualityMap,
  }) {
    return VideoPlayerViewState(
      ratio: ratio ?? this.ratio,
      showSettings: showSettings ?? this.showSettings,
      showControls: showControls ?? this.showControls,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      currentSubtitle: currentSubtitle ?? this.currentSubtitle,
      qualityMap: qualityMap ?? this.qualityMap,
    );
  }
}

@riverpod
class VideoPlayerViewModel extends _$VideoPlayerViewModel {
  @override
  VideoPlayerViewState build({
    required String? mediaUrl,
    List<ExtensionBangumiWatchSubtitle>? subtitlesRaw,
    Map<String, String>? headers,
    String? localPath,
  }) {
    final vidProvider = videoPlayerProvider(
      mediaUrl,
      subtitlesRaw: subtitlesRaw,
      headers: headers,
      localPath: localPath,
    );
    final state = ref.watch(vidProvider);
    return VideoPlayerViewState(
      ratio: state.ratio,
      showSettings: state.showSettings,
      showControls: state.showControls,
      isPlaying: state.isPlaying,
      position: state.position,
      duration: state.duration,
      speed: state.speed,
      currentSubtitle: state.currentSubtitle,
      qualityMap: state.qualityMap,
    );
  }

  // Expose state values as getters
  double get ratio => state.ratio;
  bool get showSettings => state.showSettings;
  bool get showControls => state.showControls;
  bool get isPlaying => state.isPlaying;
  Duration get position => state.position;
  Duration get duration => state.duration;
  double get speed => state.speed;
  String get currentSubtitle => state.currentSubtitle;
  Map<String, String> get qualityMap => state.qualityMap;

  // Expose video controller from legacy provider
  VideoPlayerController get videoController {
    final vidProvider = videoPlayerProvider(
      mediaUrl,
      subtitlesRaw: subtitlesRaw,
      headers: headers,
      localPath: localPath,
    );
    return ref.read(vidProvider.notifier).videoPlayerController;
  }

  void toggleSettings() {
    final vidProvider = videoPlayerProvider(
      mediaUrl,
      subtitlesRaw: subtitlesRaw,
      headers: headers,
      localPath: localPath,
    );
    ref.read(vidProvider.notifier).setShowControls(!state.showSettings);
  }

  void setShowControls(bool v) {
    final vidProvider = videoPlayerProvider(
      mediaUrl,
      subtitlesRaw: subtitlesRaw,
      headers: headers,
      localPath: localPath,
    );
    ref.read(vidProvider.notifier).setShowControls(v);
  }

  void changeQuality(String url) {
    final vidProvider = videoPlayerProvider(url);
    ref.read(vidProvider.notifier).changeVideoQuality(url);
  }
}
