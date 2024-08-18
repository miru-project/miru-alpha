import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/video_provider.dart';
import 'package:miru_app_new/utils/extension/extension_service.dart';
import 'package:moon_design/moon_design.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

late StateNotifierProviderFamily<VideoPlayerNotifier, VideoPlayerState, String>
    _videoPlayerProvider;

class VideoPlayerState {
  final VideoPlayerController controller;
  final Duration position;
  final bool isPlaying;
  final Duration duration;
  final double speed;
  final List<DurationRange> buffered;
  final Size size;
  VideoPlayerState({
    required this.controller,
    this.position = Duration.zero,
    this.isPlaying = false,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.buffered = const [],
    this.size = const Size(0, 0),
  });

  VideoPlayerState copyWith({
    VideoPlayerController? controller,
    Duration? position,
    bool? isPlaying,
    Duration? duration,
    double? speed,
    List<DurationRange>? buffered,
    Size? size,
  }) {
    return VideoPlayerState(
      controller: controller ?? this.controller,
      position: position ?? this.position,
      isPlaying: isPlaying ?? this.isPlaying,
      duration: duration ?? this.duration,
      buffered: buffered ?? this.buffered,
      speed: speed ?? this.speed,
      size: size ?? this.size,
    );
  }
}

class VideoPlayerNotifier extends StateNotifier<VideoPlayerState> {
  VideoPlayerNotifier(VideoPlayerController controller)
      : super(VideoPlayerState(controller: controller)) {
    _initialize();
  }

  get speedList => const [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0];
  void _initialize() {
    state.controller.addListener(_updatePosition);
    state = state.copyWith(
      position: state.controller.value.position,
      isPlaying: state.controller.value.isPlaying,
      duration: state.controller.value.duration,
      buffered: state.controller.value.buffered,
      size: state.controller.value.size,
    );
  }

  void _updatePosition() {
    state = state.copyWith(
      position: state.controller.value.position,
      isPlaying: state.controller.value.isPlaying,
      duration: state.controller.value.duration,
      buffered: state.controller.value.buffered,
    );
  }

  void play() {
    state.controller.play();
    state = state.copyWith(isPlaying: true);
  }

  void pause() {
    state.controller.pause();
    state = state.copyWith(isPlaying: false);
  }

  void seek(Duration position) {
    state.controller.seekTo(position);
    state = state.copyWith(position: position);
  }

  void setSpeed(double speed) {
    state.controller.setPlaybackSpeed(speed);
    state = state.copyWith(speed: speed);
  }

  @override
  void dispose() {
    state.controller.removeListener(_updatePosition);
    state.controller.dispose();
    super.dispose();
  }
}

class MiruVideoPlayer extends HookConsumerWidget {
  const MiruVideoPlayer(
      {super.key,
      required this.service,
      required this.url,
      required this.epGroup});
  final ExtensionApiV1 service;
  final String url;
  final List<ExtensionEpisodeGroup>? epGroup;
  @override
  Widget build(context, WidgetRef ref) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    final snapshot = ref.watch(VideoLoadProvider(url, service));
    return snapshot.when(
        data: (value) {
          final controller = usePlayer(
            url: value.url,
          );
          _videoPlayerProvider = StateNotifierProvider.family<
              VideoPlayerNotifier, VideoPlayerState, String>(
            (ref, url) {
              return VideoPlayerNotifier(controller);
            },
          );
          return Stack(children: [
            VideoPlayer(controller),
            Column(children: [
              Expanded(
                  child: Center(
                child: MoonButton(
                  label: const Text('exit'),
                  onTap: () {
                    controller.dispose();
                    context.pop();
                  },
                ),
              )),
              Material(child: _Footer())
            ])
          ]);
        },
        error: (error, trace) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()));
  }
}

class _Footer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(_videoPlayerProvider(''));
    final c = ref.watch(_videoPlayerProvider('').notifier);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black54,
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SeekBar(),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () {},
              ),
              if (controller.isPlaying)
                IconButton(
                  onPressed: c.pause,
                  icon: const Icon(
                    Icons.pause,
                    size: 30,
                  ),
                )
              else
                IconButton(
                  onPressed: c.play,
                  icon: const Icon(
                    Icons.play_arrow,
                    size: 30,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () {},
              ),
              const SizedBox(width: 10),
              // 播放进度
              Text(
                '${controller.position.inMinutes}:${(controller.position.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const Text('/'),
              Text(
                '${controller.duration.inMinutes}:${(controller.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const Spacer(),
              // Obx(() {
              //   if (controller.currentQuality.value.isEmpty) {
              //     return const SizedBox.shrink();
              //   }
              //   return FilledButton.tonal(
              //     onPressed: () {
              //       if (controller.qualityMap.isEmpty) {
              //         controller.sendMessage(
              //           Message(
              //             Text(
              //               'video.no-qualities'.i18n,
              //             ),
              //           ),
              //         );
              //         return;
              //       }
              //       controller.toggleSideBar(SidebarTab.qualitys);
              //     },
              //     style: ButtonStyle(
              //       padding: MaterialStateProperty.all(
              //         const EdgeInsets.symmetric(
              //           horizontal: 10,
              //           vertical: 5,
              //         ),
              //       ),
              //     ),
              //     child: Text(
              //       controller.currentQuality.value,
              //       style: const TextStyle(
              //         fontSize: 14,
              //         fontWeight: FontWeight.w300,
              //       ),
              //     ),
              //   );
              // }),
              const SizedBox(width: 10),
              // 倍速
              PopupMenuButton<double>(
                initialValue: controller.speed,
                onSelected: (value) {
                  c.setSpeed(value);
                },
                itemBuilder: (context) {
                  return [
                    for (final speed in c.speedList)
                      PopupMenuItem(
                        value: speed,
                        child: Text('${speed}x'),
                      ),
                  ];
                },
                child: Text(
                  '${controller.speed}x',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              // torrent files
              const SizedBox(width: 10),
              // Obx(() {
              //   if (controller.torrentMediaFileList.isEmpty) {
              //     return const SizedBox.shrink();
              //   }
              //   return IconButton(
              //     onPressed: () {
              //       // controller.toggleSideBar(SidebarTab.torrentFiles);
              //     },
              //     icon: const Icon(Icons.video_file),
              //   );
              // }),
              IconButton(
                onPressed: () {
                  // controller.toggleSideBar(SidebarTab.tracks);
                },
                icon: const Icon(
                  Icons.subtitles,
                ),
              ),
              // 播放列表
              IconButton(
                icon: const Icon(Icons.playlist_play),
                onPressed: () {
                  // controller.toggleSideBar(SidebarTab.episodes);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeekBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isSliderDraging = false;
    const Duration buffer = Duration.zero;
    final controller = ref.watch(_videoPlayerProvider(''));
    final c = ref.watch(_videoPlayerProvider('').notifier);
    final duration = controller.duration.inMilliseconds;
    final position = controller.position.inMilliseconds;
    return Material(
        child: SizedBox(
      height: 13,
      child: SliderTheme(
        data: const SliderThemeData(
          trackHeight: 2,
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: 6,
          ),
          overlayShape: RoundSliderOverlayShape(
            overlayRadius: 12,
          ),
        ),
        child: Slider(
          min: 0,
          max: duration.toDouble(),
          value: clampDouble(
            position.toDouble(),
            0,
            duration.toDouble(),
          ),
          secondaryTrackValue: clampDouble(
            buffer.inMilliseconds.toDouble(),
            0,
            duration.toDouble(),
          ),
          onChanged: (value) {
            if (isSliderDraging) {}
          },
          onChangeStart: (value) {
            isSliderDraging = true;
          },
          onChangeEnd: (value) {
            if (isSliderDraging) {
              c.seek(Duration(milliseconds: value.toInt()));

              isSliderDraging = false;
            }
          },
        ),
      ),
    ));
  }
}

VideoPlayerController usePlayer({
  List<Object?>? keys,
  required String url,
  VideoPlayerOptions? videoPlayerOptions,
  VoidCallback? listener,
}) {
  return use(
    _PlayerHook(
      listener: listener,
      url: url,
      keys: keys,
      videoPlayerOptions: videoPlayerOptions,
    ),
  );
}

class _PlayerHook extends Hook<VideoPlayerController> {
  const _PlayerHook(
      {required this.url, this.videoPlayerOptions, this.listener, super.keys});
  final String url;
  final VideoPlayerOptions? videoPlayerOptions;
  final VoidCallback? listener;
  @override
  HookState<VideoPlayerController, Hook<VideoPlayerController>> createState() =>
      _PlayerControllerHookState();
}

class _PlayerControllerHookState
    extends HookState<VideoPlayerController, _PlayerHook> {
  late final VideoPlayerController player;
  @override
  void initHook() {
    player = VideoPlayerController.networkUrl(Uri.parse(hook.url),
        videoPlayerOptions: hook.videoPlayerOptions)
      ..initialize().then((_) {
        player.play();
      });
    // ..addListener(hook.listener ?? () {});

    super.initHook();
  }

  @override
  VideoPlayerController build(BuildContext context) => player;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  String get debugLabel => 'usePlayer';
}
