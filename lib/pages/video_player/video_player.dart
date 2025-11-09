import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/application_controller_provider.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/widgets/error.dart';
import 'package:miru_app_new/pages/video_player/widget/desktop_footer.dart';
import 'package:miru_app_new/pages/video_player/widget/player_header.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:window_manager/window_manager.dart';

bool _hasOriented = false;

class MiruVideoPlayer extends StatefulHookConsumerWidget {
  const MiruVideoPlayer({
    super.key,
    required this.meta,
    required this.selectedGroupIndex,
    required this.selectedEpisodeIndex,
    required this.name,
    required this.detailImageUrl,
    required this.detailUrl,
    required this.epGroup,
  });
  final ExtensionMeta meta;
  final String detailImageUrl;
  final String detailUrl;
  final List<ExtensionEpisodeGroup>? epGroup;
  final int selectedGroupIndex;
  final int selectedEpisodeIndex;
  final String name;

  @override
  createState() => _MiruVideoPlayerState();
}

class _MiruVideoPlayerState extends ConsumerState<MiruVideoPlayer> {
  late double maxHeight;
  late double maxWidth;
  @override
  void dispose() {
    if (_hasOriented) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final epProvider = episodeProvider(
      widget.selectedGroupIndex,
      widget.selectedEpisodeIndex,
      widget.epGroup ?? [],
      widget.name,
      false,
    );

    maxWidth = DeviceUtil.getWidth(context);
    maxHeight = DeviceUtil.getHeight(context);

    if (maxWidth < maxHeight) {
      _hasOriented = true;
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    }
    final epNotifier = ref.watch(epProvider);
    if (epNotifier.epGroup.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Text('Error: No episodes found'),
            FButton.icon(
              child: const Text('back'),
              onPress: () {
                context.pop();
              },
            ),
          ],
        ),
      );
    }
    final url = epNotifier
        .epGroup[epNotifier.selectedGroupIndex]
        .urls[epNotifier.selectedEpisodeIndex]
        .url;

    return Consumer(
      builder: (context, ref, child) {
        final snapshot = ref.watch(
          videoLoadProvider(url, widget.meta.packageName, widget.meta.type),
        );
        return FTheme(
          data: ref.watch(applicationControllerProvider).themeData,
          child: snapshot.when(
            data: (value) {
              return PlayerResolution(
                epProvider: epProvider,
                screenRatio: MediaQuery.of(context).size,
                name: widget.name,
                value: value as ExtensionBangumiWatch,
                url: url,
                meta: widget.meta,
              );
            },
            error: (error, trace) => FScaffold(
              child: Center(
                child: ErrorDisplay(
                  err: error,
                  stack: trace,
                  prefix: FButton(
                    style: FButtonStyle.ghost(),
                    prefix: Icon(FIcons.undo2),
                    onPress: () {
                      context.pop();
                    },
                    child: Text('Return'),
                  ),
                ),
              ),
            ),
            loading: () => const Center(child: FCircularProgress()),
          ),
        );
      },
    );
  }
}

class PlayerButton extends StatelessWidget {
  const PlayerButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size,
  });
  final VoidCallback onPressed;
  final IconData icon;
  final double? size;
  @override
  Widget build(BuildContext context) {
    return FButton.icon(
      style: FButtonStyle.ghost(),
      onPress: onPressed,
      child: Icon(icon, size: size),
    );
  }
}

class PlayerResolution extends ConsumerWidget {
  const PlayerResolution({
    super.key,
    required this.name,
    required this.value,
    required this.url,
    required this.screenRatio,
    required this.meta,
    required this.epProvider,
  });
  final ExtensionBangumiWatch value;
  final String name;
  final ExtensionMeta meta;
  final String url;
  final Size screenRatio;
  final EpisodeNotifierProvider epProvider;
  @override
  Widget build(context, WidgetRef ref) {
    final vidProvider = videoPlayerProvider(
      value.url,
      subtitlesRaw: value.subtitles,
      headers: value.headers,
    );

    // return VideoPlayer(ref.read(vidProvider.notifier).vidController);
    return Stack(
      children: [
        //video player
        Consumer(
          builder: (context, ref, child) {
            final ratio = ref.watch(vidProvider.select((s) => s.ratio));
            return Center(
              child: AspectRatio(
                aspectRatio: ratio == 0
                    ? screenRatio.width / screenRatio.height
                    : ratio,
                child: VideoPlayer(
                  ref.read(vidProvider.notifier).vidController,
                ),
              ),
            );
          },
        ),
        //subtitle text
        VideoPlayerSubtitle(vidProvider: vidProvider),
        //player controls ui
        _VideoPlayer(vidPr: vidProvider, epProvider: epProvider),
      ],
    );
  }
}

class VideoPlayerSubtitle extends ConsumerWidget {
  const VideoPlayerSubtitle({super.key, required this.vidProvider});
  final VideoPlayerNotifierProvider vidProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSubtitle = ref.watch(
      vidProvider.select((s) => s.currentSubtitle),
    );
    if (currentSubtitle.isEmpty) {
      return const SizedBox.shrink();
    }
    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: RichText(
            text: TextSpan(
              text: currentSubtitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                decoration: TextDecoration.none, // Remove underline
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _VideoPlayer extends StatefulHookConsumerWidget {
  const _VideoPlayer({required this.vidPr, required this.epProvider});
  final VideoPlayerNotifierProvider vidPr;
  final EpisodeNotifierProvider epProvider;
  @override
  _DesktopVideoPlayerState createState() => _DesktopVideoPlayerState();
}

class _DesktopVideoPlayerState extends ConsumerState<_VideoPlayer> {
  // legacy local timer removed; timer is now managed by VideoPlayerProvider

  double _currentVolume = 0;
  // 是否是调整亮度
  bool _isBrightness = false;
  // 是否正在调节
  bool _isAdjusting = false;
  // 滑动时的进度
  Duration _position = Duration.zero;
  // 是否左右滑动调整进度
  bool _isSeeking = false;
  // 是否长按加速
  bool _isLongPress = false;
  void _updateTimer() {
    // delegate to provider
    ref.read(widget.vidPr.notifier).updateTimer();
  }

  void close() {
    WindowManager.instance.setAlwaysOnTop(false);
    context.pop();
  }

  Widget buildcontent(VideoPlayerNotifier c) {
    return Consumer(
      builder: (context, ref, child) {
        final showControls = ref.watch(
          widget.vidPr.select((s) => s.showControls),
        );

        if (!showControls) return const SizedBox.expand();
        return Column(
          children: [
            DefaultTextStyle(
              // color: Colors.transparent,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              child: _hasOriented
                  ? Header(
                      titleSize: 20,
                      subTitleSize: 12,
                      iconSize: 20,
                      onClose: close,
                      episodeProvider: widget.epProvider,
                    )
                  : Header(onClose: close, episodeProvider: widget.epProvider),
            ),
            Consumer(
              builder: (context, ref, child) {
                final isPlaying = ref.watch(
                  widget.vidPr.select((s) => s.isPlaying),
                );
                return Expanded(
                  child: (!isPlaying)
                      ? Center(
                          child: PlayerButton(
                            onPressed: () {
                              c.play();
                            },
                            icon: FIcons.play,
                          ),
                        )
                      : Container(color: Colors.transparent),
                );
              },
            ),
            DesktopPlayerFooter(
              vidPr: widget.vidPr,
              epProvdier: widget.epProvider,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentBrightness = useState(0.0);

    final c = ref.read(widget.vidPr.notifier);
    return Stack(
      children: [
        DefaultTextStyle(
          style: const TextStyle(fontSize: 30),
          child: Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Consumer(
              builder: (context, ref, child) {
                final duration = ref.watch(
                  widget.vidPr.select((s) => s.duration),
                );
                return Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.black45,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isSeeking)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}',
                                ),
                                const Text('/'),
                                Text(
                                  '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                                ),
                              ],
                            ),
                          ),
                        if (_isLongPress)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Playing at 3x speed'),
                          ),
                        if (_isAdjusting)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isBrightness) ...[
                                  const Icon(Icons.brightness_5),
                                  const SizedBox(width: 5),
                                  Text(
                                    (currentBrightness.value * 100)
                                        .toStringAsFixed(0),
                                  ),
                                ],
                                if (!_isBrightness) ...[
                                  const Icon(Icons.volume_up),
                                  const SizedBox(width: 5),
                                  Text(
                                    (_currentVolume * 100).toStringAsFixed(0),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (DeviceUtil.isMobile)
          Consumer(
            builder: (context, ref, child) {
              final position = ref.watch(
                widget.vidPr.select((s) => s.position),
              );

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (ref.read(widget.vidPr).showControls) {
                    ref.read(widget.vidPr.notifier).setShowControls(false);
                    return;
                  }
                  _updateTimer();
                },
                onDoubleTapDown: (details) {
                  // 如果左边点击快退，中间暂停，右边快进
                  final dx = details.localPosition.dx;
                  final width = MediaQuery.of(context).size.width / 3;
                  if (dx < width) {
                    c.seek(position - const Duration(seconds: 10));
                  } else if (dx > width * 2) {
                    c.seek(position + const Duration(seconds: 10));
                  } else {
                    c.playOrPause();
                  }
                },
                onVerticalDragStart: (details) {
                  _isBrightness =
                      details.localPosition.dx <
                      MediaQuery.of(context).size.width / 2;
                },
                // 左右两边上下滑动
                onVerticalDragUpdate: (details) {
                  final add = details.delta.dy / 500;
                  // 如果是左边调节亮度
                  if (_isBrightness) {
                    currentBrightness.value = (currentBrightness.value - add)
                        .clamp(0, 1);
                    ScreenBrightness().setApplicationScreenBrightness(
                      currentBrightness.value,
                    );
                  }
                  // 如果是右边调节音量
                  else {
                    _currentVolume = (_currentVolume - add).clamp(0, 1);
                    // VolumeController.setVolume(_currentVolume);
                    VolumeController.instance.setVolume(_currentVolume);
                  }
                  _isAdjusting = true;
                  setState(() {});
                },
                onHorizontalDragStart: (details) {
                  _position = position;
                },
                onVerticalDragEnd: (details) {
                  _isAdjusting = false;
                  setState(() {});
                },
                // 左右滑动
                onHorizontalDragUpdate: (details) {
                  // double scale = 200000 / MediaQuery.of(context).size.width;
                  // Duration pos =
                  //     _position +
                  //     Duration(milliseconds: (details.delta.dx * scale).round());
                  // _position = Duration(
                  //   milliseconds: pos.inMilliseconds.clamp(
                  //     0,
                  //     controller.duration.inMilliseconds,
                  //   ),
                  // );
                  // _isSeeking = true;
                  // setState(() {});
                },
                onHorizontalDragEnd: (details) {
                  c.seek(_position);
                  _isSeeking = false;
                  setState(() {});
                },
                onLongPressStart: (details) {
                  _isLongPress = true;
                  c.setSpeed(3);
                  setState(() {});
                },
                onLongPressEnd: (details) {
                  c.setSpeed(ref.read(widget.vidPr).speed);
                  _isLongPress = false;
                  setState(() {});
                },
                child: buildcontent(c),
              );
            },
          )
        else
          MouseRegion(
            onHover: (event) {
              _updateTimer();
            },
            child: buildcontent(c),
          ),
      ],
    );
  }
}
