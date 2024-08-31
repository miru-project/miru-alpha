import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/controllers/main_controller.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/extension/extension_service.dart';
import 'package:miru_app_new/utils/network/request.dart';

import 'package:moon_design/moon_design.dart';
import 'package:screen_brightness/screen_brightness.dart';
// import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:window_manager/window_manager.dart';

bool _hasOriented = false;
late StateNotifierProviderFamily<VideoPlayerNotifier, VideoPlayerState, String>
    _videoPlayerProvider;
final _episodeNotifierProvider =
    StateNotifierProvider<EpisodeNotifier, EpisodeNotifierState>((ref) {
  return EpisodeNotifier();
});
final isMobile = Platform.isAndroid || Platform.isIOS;
late FetchResolutionProvider _resolutionNotifer;
final subtitleProvider =
    StateNotifierProvider<SubtitleNotifier, SubTitleGroupState>((ref) {
  return SubtitleNotifier();
});
String _videoUrl = '';

class MiruVideoPlayer extends StatefulHookConsumerWidget {
  const MiruVideoPlayer(
      {super.key,
      required this.service,
      required this.selectedGroupIndex,
      required this.selectedEpisodeIndex,
      required this.name,
      required this.epGroup});
  final ExtensionApiV1 service;
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
  void initState() {
    super.initState();
    // init episodes
    Future.microtask(() {
      final epcontroller = ref.read(_episodeNotifierProvider.notifier);
      epcontroller.initEpisodes(
          widget.selectedGroupIndex,
          widget.selectedEpisodeIndex,
          widget.epGroup ?? [],
          widget.name,
          false);
    });
  }

  @override
  void dispose() {
    if (_hasOriented) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    maxWidth = DeviceUtil.getWidth(context);
    maxHeight = DeviceUtil.getHeight(context);

    if (maxWidth < maxHeight) {
      _hasOriented = true;
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    }
    final epNotifier = ref.watch(_episodeNotifierProvider);
    if (epNotifier.epGroup.isEmpty) {
      return Center(
          child: Column(children: [
        const Text('Error: No episodes found'),
        MoonButton.icon(
          icon: const Text('back'),
          onTap: () {
            context.pop();
          },
        )
      ]));
    }
    final url = epNotifier.epGroup[epNotifier.selectedGroupIndex]
        .urls[epNotifier.selectedEpisodeIndex].url;
    final snapshot = ref.watch(VideoLoadProvider(url, widget.service));
    return snapshot.when(
        data: (value) {
          _resolutionNotifer =
              FetchResolutionProvider(value.url, value.headers ?? {});
          return PlayerResolution(
              value: value, url: url, service: widget.service);
        },
        error: (error, trace) => Center(
                child: Column(children: [
              Text('Error: $error'),
              Row(children: [
                MoonButton.icon(
                  icon: const Text('reload'),
                  onTap: () =>
                      ref.refresh(VideoLoadProvider(url, widget.service)),
                ),
                MoonButton.icon(
                  icon: const Text('back'),
                  onTap: () => context.pop(),
                )
              ])
            ])),
        loading: () => const Center(child: CircularProgressIndicator()));
  }
}

class PlayerResolution extends StatefulHookConsumerWidget {
  const PlayerResolution(
      {super.key,
      required this.value,
      required this.url,
      required this.service});
  final ExtensionBangumiWatch value;
  final ExtensionApiV1 service;
  final String url;
  @override
  createState() => _PlayerResoltionState();
}

class _PlayerResoltionState extends ConsumerState<PlayerResolution> {
  @override
  void initState() {
    _videoUrl = widget.value.url;
    super.initState();
  }

  @override
  Widget build(context) {
    final aspectWidth = useState(DeviceUtil.getWidth(context));
    final aspectHeight = useState(DeviceUtil.getHeight(context));
    final currentSubtitle = useState<String>('');
    final videoController = usePlayer(
      url: _videoUrl,
    );
    Future.microtask(() {
      ref.read(subtitleProvider.notifier).init(widget.value.subtitles);
    });
    videoController.addListener(() {
      final position = videoController.value.position;
      aspectWidth.value = videoController.value.size.width;
      aspectHeight.value = videoController.value.size.height;
      final subtitle =
          ref.read(subtitleProvider.notifier).getCurrentSubtitle(position);
      currentSubtitle.value = subtitle;
    });
    _videoPlayerProvider = StateNotifierProvider.family<VideoPlayerNotifier,
        VideoPlayerState, String>(
      (ref, url) {
        return VideoPlayerNotifier(videoController);
      },
    );
    return Stack(children: [
      //video player
      Center(
          child: AspectRatio(
              aspectRatio: aspectWidth.value / aspectHeight.value,
              child: VideoPlayer(videoController))),
      //subtitle text
      if (currentSubtitle.value.isNotEmpty)
        Positioned(
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
                text: currentSubtitle.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  decoration: TextDecoration.none, // Remove underline
                ),
              ),
              textAlign: TextAlign.center,
            ),
          )),
        ),
      //player controls ui
      _VideoPlayer()
    ]);
  }
}

class _VideoPlayer extends StatefulHookConsumerWidget {
  @override
  _DesktopVideoPlayerState createState() => _DesktopVideoPlayerState();
}

class _DesktopVideoPlayerState extends ConsumerState<_VideoPlayer> {
  Timer? _timer;
  late ValueNotifier<bool> _showControls;

  double _currentBrightness = 0;
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
  _updateTimer() {
    _timer?.cancel();
    _timer = null;
    _showControls.value = true;
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (mounted) {
          _showControls.value = false;
        }
      },
    );
  }

  Widget buildcontent(VideoPlayerState controller, VideoPlayerNotifier c) {
    void close() {
      controller.controller.dispose();
      WindowManager.instance.setAlwaysOnTop(false);
      ref.invalidate(subtitleProvider);
      context.pop();
    }

    if (_showControls.value) {
      return Column(
        children: [
          Material(
            child: _hasOriented
                ? _Header(
                    titleSize: 15,
                    subTitleSize: 12,
                    iconSize: 20,
                    onClose: close)
                : _Header(onClose: close),
          ),
          Expanded(
              child: (!controller.isPlaying)
                  ? Center(
                      child: MoonButton.icon(
                      icon:
                          const Icon(size: 60, MoonIcons.media_play_24_regular),
                      buttonSize: MoonButtonSize.lg,
                      onTap: () {
                        c.play();
                      },
                    ))
                  : Container(
                      color: Colors.transparent,
                    )),
          Material(child: _DesktopFooter())
        ],
      );
    }

    return const SizedBox.expand();
  }

  @override
  Widget build(BuildContext context) {
    _showControls = useState(false);
    final controller = ref.watch(_videoPlayerProvider(''));
    final c = ref.watch(_videoPlayerProvider('').notifier);
    // final epNotifier = ref.watch(_episodeNotifierProvider);
    return Stack(
      children: [
        DefaultTextStyle(
            style: const TextStyle(fontSize: 30),
            child: Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Center(
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
                                '${controller.duration.inMinutes}:${(controller.duration.inSeconds % 60).toString().padLeft(2, '0')}',
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
                                  (_currentBrightness * 100).toStringAsFixed(0),
                                )
                              ],
                              if (!_isBrightness) ...[
                                const Icon(Icons.volume_up),
                                const SizedBox(width: 5),
                                Text(
                                  (_currentVolume * 100).toStringAsFixed(0),
                                )
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )),
        if (_hasOriented)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_showControls.value) {
                _showControls.value = false;
                return;
              }
              _updateTimer();
            },
            onDoubleTapDown: (details) {
              // 如果左边点击快退，中间暂停，右边快进
              final dx = details.localPosition.dx;
              final width = MediaQuery.of(context).size.width / 3;
              if (dx < width) {
                c.seek(controller.position - const Duration(seconds: 10));
              } else if (dx > width * 2) {
                c.seek(
                  controller.position + const Duration(seconds: 10),
                );
              } else {
                c.playOrPause();
              }
            },
            onVerticalDragStart: (details) {
              _isBrightness = details.localPosition.dx <
                  MediaQuery.of(context).size.width / 2;
            },
            // 左右两边上下滑动
            onVerticalDragUpdate: (details) {
              final add = details.delta.dy / 500;
              // 如果是左边调节亮度
              if (_isBrightness) {
                _currentBrightness = (_currentBrightness - add).clamp(0, 1);
                ScreenBrightness().setScreenBrightness(_currentBrightness);
              }
              // 如果是右边调节音量
              else {
                _currentVolume = (_currentVolume - add).clamp(0, 1);
                VolumeController().setVolume(_currentVolume);
              }
              _isAdjusting = true;
              setState(() {});
            },
            onHorizontalDragStart: (details) {
              _position = controller.position;
            },
            onVerticalDragEnd: (details) {
              _isAdjusting = false;
              setState(() {});
            },
            // 左右滑动
            onHorizontalDragUpdate: (details) {
              double scale = 200000 / MediaQuery.of(context).size.width;
              Duration pos = _position +
                  Duration(
                    milliseconds: (details.delta.dx * scale).round(),
                  );
              _position = Duration(
                milliseconds: pos.inMilliseconds.clamp(
                  0,
                  controller.duration.inMilliseconds,
                ),
              );
              _isSeeking = true;
              setState(() {});
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
              c.setSpeed(controller.speed);
              _isLongPress = false;
              setState(() {});
            },
            child: buildcontent(controller, c),
          )
        else
          MouseRegion(
              onHover: (event) {
                _updateTimer();
              },
              child: buildcontent(controller, c))
      ],
    );
  }
}

class _Header extends ConsumerStatefulWidget {
  const _Header({
    required this.onClose,
    this.titleSize = 20,
    this.subTitleSize = 18,
    this.iconSize = 24,
  });
  final VoidCallback onClose;
  final double titleSize;
  final double subTitleSize;
  final double iconSize;
  @override
  ConsumerState<_Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<_Header> {
  bool _isAlwaysOnTop = false;

  @override
  void initState() {
    super.initState();
    if (!DeviceUtil.isMobile) {
      WindowManager.instance.isAlwaysOnTop().then((value) {
        _isAlwaysOnTop = value;
      });
    }
  }

  Widget buildcontent(EpisodeNotifierState epNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          epNotifier.name,
          style: TextStyle(
            fontSize: widget.titleSize,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '${epNotifier.epGroup[epNotifier.selectedGroupIndex].title}-${epNotifier.epGroup[epNotifier.selectedGroupIndex].urls[epNotifier.selectedEpisodeIndex].name}',
          style: TextStyle(
            fontSize: widget.subTitleSize,
            fontWeight: FontWeight.w300,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final epNotifier = ref.watch(_episodeNotifierProvider);
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: DeviceUtil.isMobile
                    ? buildcontent(epNotifier)
                    : DragToMoveArea(
                        child: buildcontent(epNotifier),
                      ),
              ),
              // 置顶
              if (!DeviceUtil.isMobile) ...[
                IconButton(
                  icon: Icon(
                    _isAlwaysOnTop ? Icons.push_pin_outlined : Icons.push_pin,
                  ),
                  onPressed: () async {
                    WindowManager.instance.setAlwaysOnTop(
                      !_isAlwaysOnTop,
                    );
                    setState(() {
                      _isAlwaysOnTop = !_isAlwaysOnTop;
                    });
                  },
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(
                    MoonIcons.controls_minus_24_regular,
                  ),
                  onPressed: () {
                    WindowManager.instance.minimize();
                  },
                )
              ],
              const SizedBox(width: 10),
              IconButton(
                onPressed: widget.onClose,
                iconSize: widget.iconSize,
                icon: const Icon(
                  MoonIcons.controls_chevron_down_24_regular,
                ),
              ),
            ],
          )),
    );
  }
}

class _DesktopFooter extends HookConsumerWidget {
  void showDialog(context, int index) {
    showMoonModal(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          return _DesktopSettingDialog(
            initialIndex: index,
          );
        });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isspeedToggled = useState(false);
    // final isSubtitlesToggled = useState(false);

    final controller = ref.watch(_videoPlayerProvider(''));
    final c = ref.watch(_videoPlayerProvider('').notifier);
    final buttonSize = _hasOriented ? null : 30.0;
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
          if (!_hasOriented) const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () {},
              ),
              if (controller.isPlaying)
                IconButton(
                  onPressed: c.pause,
                  icon: Icon(
                    Icons.pause,
                    size: buttonSize,
                  ),
                )
              else
                IconButton(
                  onPressed: c.play,
                  icon: Icon(
                    Icons.play_arrow,
                    size: buttonSize,
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
              // 倍速
              MoonPopover(
                  onTapOutside: () {
                    isspeedToggled.value = false;
                  },
                  show: isspeedToggled.value,
                  content: Column(
                    children: List.generate(
                        c.speedList.length,
                        (index) => MoonMenuItem(
                              label: Text('${c.speedList[index]}x'),
                              onTap: () {
                                c.setSpeed(c.speedList[index]);
                              },
                            )),
                  ),
                  child: MoonButton.icon(
                      onTap: () {
                        isspeedToggled.value = !isspeedToggled.value;
                      },
                      icon: Text(
                        '${controller.speed}x',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ))),
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
              MoonButton.icon(
                  onTap: () {
                    showDialog(context, 1);
                  },
                  icon: const Icon(Icons.subtitles)),
              // 播放列表
              IconButton(
                icon: const Icon(Icons.playlist_play),
                onPressed: () {
                  showDialog(context, 0);

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

class _DialogButton extends HookWidget {
  const _DialogButton({
    this.initIndex,
    required this.onPressed,
  });
  final int? initIndex;
  final void Function(int) onPressed;

  static const _navItems = [
    NavItem(
      text: 'Episode',
      icon: Icons.tv_outlined,
      selectIcon: Icons.tv,
    ),
    NavItem(
      text: 'Resolution',
      icon: Icons.hd_outlined,
      selectIcon: Icons.hd,
    ),
    NavItem(
      text: 'Subtitle',
      icon: Icons.subtitles_outlined,
      selectIcon: Icons.subtitles_rounded,
    ),
    NavItem(
      text: 'Settings',
      icon: Icons.settings_outlined,
      selectIcon: Icons.settings,
    ),
  ];

  @override
  Widget build(context) {
    final hover = useState(0);
    final ishover = useState(false);
    final selectedIndex = useState(initIndex ?? 0);
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
            _navItems.length,
            (index) => MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) {
                    ishover.value = true;
                    hover.value = index;
                  },
                  onExit: (_) {
                    ishover.value = false;
                    hover.value = index;
                  },
                  child: GestureDetector(
                    onTap: () {
                      onPressed(index);
                      selectedIndex.value = index;
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: selectedIndex.value == index ||
                                (hover.value == index && ishover.value)
                            ? context.moonTheme?.tabBarTheme.colors
                                .selectedPillTextColor
                                .withAlpha(20)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            selectedIndex.value == index ||
                                    (hover.value == index && ishover.value)
                                ? _navItems[index].selectIcon
                                : _navItems[index].icon,
                            color: selectedIndex.value == index ||
                                    hover.value == index
                                ? context.moonColors?.bulma
                                : context.moonColors?.bulma.withAlpha(150),
                          ),
                        ],
                      ),
                    ),
                  ),
                )));
  }
}

class _DesktopSettingDialog extends HookConsumerWidget {
  static const _buttonGap = 60.0;
  const _DesktopSettingDialog({this.initialIndex = 0});
  final int initialIndex;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(initialIndex);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final epController = ref.watch(_episodeNotifierProvider);
    final epNotifier = ref.read(_episodeNotifierProvider.notifier);
    final subController = ref.watch(subtitleProvider);
    final subNotifier = ref.read(subtitleProvider.notifier);
    final resolutionController = ref.watch(_resolutionNotifer);
    // final videoController = ref.watch(_videoPlayerProvider(''));
    final videoNotifer = ref.watch(_videoPlayerProvider('').notifier);
    final dialogContent = [
      // episodes
      ListView.builder(
        itemBuilder: (context, index) => MoonAccordion(
          accordionSize: MoonAccordionSize.md,
          backgroundColor: Theme.of(context).colorScheme.surface,
          childrenPadding: const EdgeInsets.all(10),
          label: Text(epController.epGroup[index].title),
          trailing: Text('${epController.epGroup[index].urls.length} episodes'),
          children: List.generate(
              epController.epGroup[index].urls.length,
              (i) => MoonMenuItem(
                    label: Text(
                      epController.epGroup[index].urls[i].name,
                      style: TextStyle(
                          color: index == epController.selectedGroupIndex &&
                                  i == epController.selectedEpisodeIndex
                              ? context.moonTheme?.segmentedControlTheme.colors
                                  .textColor
                              : null),
                    ),
                    backgroundColor: index == epController.selectedGroupIndex &&
                            i == epController.selectedEpisodeIndex
                        ? context.moonTheme?.segmentedControlTheme.colors
                            .backgroundColor
                        : null,
                    onTap: () {
                      epNotifier.selectEpisode(index, i);
                      context.pop();
                    },
                  )),
        ),
        itemCount: epController.epGroup.length,
      ),
      // resolution
      resolutionController.when(
          data: (Map<String, String> value) {
            final keys = value.keys.toList();
            return ListView.builder(
              itemBuilder: (context, index) => MoonMenuItem(
                onTap: () {
                  if (value[keys[index]] != null) {
                    _videoUrl = value[keys[index]]!;
                    epNotifier.rebuild();
                  }
                  context.pop();
                },
                label: Text(keys[index]),
              ),
              itemCount: value.length,
            );
          },
          error: (e, stack) =>
              Column(children: [Text(e.toString()), Text(stack.toString())]),
          loading: () => const CircularProgressIndicator()),
      // subtitle
      ListView.builder(
          itemCount: subController.subtitlesRaw.length,
          itemBuilder: (context, int index) => MoonMenuItem(
              backgroundColor: (index == subController.selectedSubtitleIndex &&
                      subController.isShowSubtitle)
                  ? context
                      .moonTheme?.segmentedControlTheme.colors.backgroundColor
                  : null,
              onTap: () {
                subNotifier.setSelectedIndex(index);
                context.pop();
              },
              trailing: Text('${subController.subtitlesRaw[index].language}'),
              label: Text(subController.subtitlesRaw[index].title))),
      // settings
      Container(),
    ];
    final dialogFactor = _hasOriented ? 0.8 : .5;
    return Center(
        child: SizedBox(
      height: height * dialogFactor,
      width: width * dialogFactor,
      child: Row(children: [
        Container(
          width: _buttonGap,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(10)),
          ),
          child: (SizedBox(
              child: _DialogButton(
            initIndex: selectedIndex.value,
            onPressed: (index) {
              selectedIndex.value = index;
            },
          ))),
        ),
        Expanded(
            child: Container(
          height: height * dialogFactor,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(10)),
          ),
          child: dialogContent[selectedIndex.value],
        ))
      ]),
    ));
  }
}

class BookmarkClipper extends CustomClipper<Path> {
  static const _radius = 20.0;
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width - _radius, 0);
    path.arcToPoint(
      Offset(size.width, 20),
      radius: const Radius.circular(20),
      clockwise: true,
    );
    path.lineTo(size.width, size.height + 20);
    path.arcToPoint(
      Offset(size.width - 20, size.height),
      radius: const Radius.circular(20),
      clockwise: true,
    );
    path.lineTo(0, size.height + 20);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _SeekBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isSliderDraging = false;
    final controller = ref.watch(_videoPlayerProvider(''));
    final c = ref.watch(_videoPlayerProvider('').notifier);
    final duration = controller.duration.inMilliseconds;
    final position = controller.position.inMilliseconds;
    return Material(
        child: SizedBox(
      height: 13,
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 2,
          activeTrackColor: context
              .moonTheme?.segmentedControlTheme.colors.backgroundColor
              .withAlpha(200),
          thumbColor:
              context.moonTheme?.segmentedControlTheme.colors.backgroundColor,
          secondaryActiveTrackColor: context
              .moonTheme?.segmentedControlTheme.colors.backgroundColor
              .withAlpha(100),
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: 6,
          ),
          overlayShape: const RoundSliderOverlayShape(
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
          secondaryTrackValue: controller.buffered.isNotEmpty
              ? clampDouble(
                  controller.buffered.last.end.inMilliseconds.toDouble(),
                  0,
                  duration.toDouble(),
                )
              : 0,
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

class Subtitle {
  final Duration start;
  final Duration end;
  final String text;

  Subtitle({
    required this.start,
    required this.end,
    required this.text,
  });
}

class SubtitleUtil {
  static Future<List<Subtitle>> parseVttSubtitles(String url) async {
    // #todo
    final String data = (await dio.get<String>(url)).data!;
    final List<Subtitle> subtitles = [];
    RegExp regExp = RegExp(
      r'(\d{2}:\d{2}:\d{2}\.\d{3}) --> (\d{2}:\d{2}:\d{2}\.\d{3})\n(.+)',
      multiLine: true,
    );

    for (final RegExpMatch match in regExp.allMatches(data)) {
      final start = _parseHours(match.group(1)!);
      final end = _parseHours(match.group(2)!);
      final text = match.group(3)!;
      subtitles.add(Subtitle(start: start, end: end, text: text));
    }
    if (subtitles.isNotEmpty) {
      return subtitles;
    }
    regExp = RegExp(
      r'(\d{2}:\d{2}\.\d{3}) --> (\d{2}:\d{2}\.\d{3})\n(.+)',
      multiLine: true,
    );
    for (final RegExpMatch match in regExp.allMatches(data)) {
      final start = _parseMinutes(match.group(1)!);
      final end = _parseMinutes(match.group(2)!);
      final text = match.group(3)!;
      subtitles.add(Subtitle(start: start, end: end, text: text));
    }
    return subtitles;
  }

  static Duration _parseHours(String time) {
    final parts = time.split(':');
    final secondsParts = parts[2].split('.');
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(secondsParts[0]),
      milliseconds: int.parse(secondsParts[1]),
    );
  }

  static Duration _parseMinutes(String time) {
    final parts = time.split(':');
    final secondsParts = parts[1].split('.');
    return Duration(
      minutes: int.parse(parts[0]),
      seconds: int.parse(secondsParts[0]),
      milliseconds: int.parse(secondsParts[1]),
    );
  }
}

class VideoPlayerState {
  final VideoPlayerController controller;
  final Duration position;
  final bool isPlaying;
  final Duration duration;
  final double speed;
  final List<DurationRange> buffered;
  final Size size;
  final int selectedSubtitleIndex;
  final bool isOpenSideBar;
  final bool isShowSideBar;
  VideoPlayerState({
    required this.controller,
    this.position = Duration.zero,
    this.isPlaying = false,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.buffered = const [],
    this.size = const Size(0, 0),
    this.selectedSubtitleIndex = 0,
    this.isOpenSideBar = false,
    this.isShowSideBar = false,
  });

  VideoPlayerState copyWith({
    VideoPlayerController? controller,
    Duration? position,
    bool? isPlaying,
    Duration? duration,
    double? speed,
    List<DurationRange>? buffered,
    Size? size,
    List<ExtensionBangumiWatchSubtitle>? subtitles,
    int? selectedSubtitleIndex,
    bool? isOpenSideBar,
    bool? isShowSideBar,
  }) {
    return VideoPlayerState(
      controller: controller ?? this.controller,
      position: position ?? this.position,
      isPlaying: isPlaying ?? this.isPlaying,
      duration: duration ?? this.duration,
      buffered: buffered ?? this.buffered,
      speed: speed ?? this.speed,
      size: size ?? this.size,
      selectedSubtitleIndex:
          selectedSubtitleIndex ?? this.selectedSubtitleIndex,
      isOpenSideBar: isOpenSideBar ?? this.isOpenSideBar,
      isShowSideBar: isShowSideBar ?? this.isShowSideBar,
    );
  }
}

class VideoPlayerNotifier extends StateNotifier<VideoPlayerState> {
  VideoPlayerNotifier(VideoPlayerController controller,
      [int selectedSubtitleIndex = 0])
      : super(VideoPlayerState(
            controller: controller,
            selectedSubtitleIndex: selectedSubtitleIndex)) {
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
      selectedSubtitleIndex: state.selectedSubtitleIndex,
      isOpenSideBar: state.isOpenSideBar,
      isShowSideBar: state.isShowSideBar,
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

  void changeSubtitle(int index) {
    state = state.copyWith(selectedSubtitleIndex: index);
  }

  void play() {
    state.controller.play();
    state = state.copyWith(isPlaying: true);
  }

  void changeVideoUrl(String url) {
    state = state.copyWith(
        controller: VideoPlayerController.networkUrl(Uri.parse(url)));
    _initialize();
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

enum SidebarTab { subtitles, episodes, qualitys, settings }

class SideBarState {
  final bool isOpenSideBar;
  final bool isShowSideBar;
  SideBarState({this.isOpenSideBar = false, this.isShowSideBar = false});

  SideBarState copyWith({bool? isOpenSideBar, bool? isShowSideBar}) {
    return SideBarState(
      isOpenSideBar: isOpenSideBar ?? this.isOpenSideBar,
      isShowSideBar: isShowSideBar ?? this.isShowSideBar,
    );
  }
}

class EpisodeNotifierState {
  final List<ExtensionEpisodeGroup> epGroup;
  final int selectedGroupIndex;
  final int selectedEpisodeIndex;
  final String name;
  final bool flag;
  EpisodeNotifierState(
      {this.epGroup = const [],
      this.selectedGroupIndex = 0,
      this.name = '',
      this.flag = false,
      this.selectedEpisodeIndex = 0});
  EpisodeNotifierState copyWith(
      {List<ExtensionEpisodeGroup>? epGroup,
      String? name,
      bool? flag,
      int? selectedGroupIndex,
      int? selectedEpisodeIndex}) {
    return EpisodeNotifierState(
        epGroup: epGroup ?? this.epGroup,
        flag: flag ?? this.flag,
        name: name ?? this.name,
        selectedGroupIndex: selectedGroupIndex ?? this.selectedGroupIndex,
        selectedEpisodeIndex:
            selectedEpisodeIndex ?? this.selectedEpisodeIndex);
  }
}

class EpisodeNotifier extends StateNotifier<EpisodeNotifierState> {
  EpisodeNotifier() : super(EpisodeNotifierState());
  void selectEpisode(int groupIndex, int episodeIndex) {
    state = state.copyWith(
      selectedGroupIndex: groupIndex,
      selectedEpisodeIndex: episodeIndex,
    );
  }

  void initEpisodes(int groupIndex, int episodeIndex,
      List<ExtensionEpisodeGroup> epGroup, String name, bool flag) {
    state = state.copyWith(
        epGroup: epGroup,
        flag: flag,
        name: name,
        selectedGroupIndex: groupIndex,
        selectedEpisodeIndex: episodeIndex);
  }

  void rebuild() {
    state = state.copyWith(
      flag: !state.flag,
    );
  }
}

class SubTitleGroupState {
  final List<ExtensionBangumiWatchSubtitle> subtitlesRaw;
  final int selectedSubtitleIndex;
  final List<Subtitle> subtitles;
  final bool isShowSubtitle;
  SubTitleGroupState(
      {this.subtitlesRaw = const [],
      this.selectedSubtitleIndex = 0,
      this.isShowSubtitle = false,
      this.subtitles = const []});
  SubTitleGroupState copyWith(
      {List<ExtensionBangumiWatchSubtitle>? subtitlesRaw,
      bool? isShowSubtitle,
      int? selectedSubtitleIndex,
      List<Subtitle>? subtitles}) {
    return SubTitleGroupState(
      subtitlesRaw: subtitlesRaw ?? this.subtitlesRaw,
      isShowSubtitle: isShowSubtitle ?? this.isShowSubtitle,
      subtitles: subtitles ?? this.subtitles,
      selectedSubtitleIndex:
          selectedSubtitleIndex ?? this.selectedSubtitleIndex,
    );
  }
}

class SubtitleNotifier extends StateNotifier<SubTitleGroupState> {
  SubtitleNotifier() : super(SubTitleGroupState());

  void setSubtitles(List<Subtitle> subtitles, int index) {
    state = state.copyWith(subtitles: subtitles, selectedSubtitleIndex: index);
  }

  String getCurrentSubtitle(Duration position) {
    final subtitle = state.subtitles.firstWhere(
      (subtitle) => position >= subtitle.start && position <= subtitle.end,
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

  void init(List<ExtensionBangumiWatchSubtitle>? subtitles) {
    state = state.copyWith(
        subtitlesRaw: subtitles,
        isShowSubtitle: false,
        selectedSubtitleIndex: 0,
        subtitles: const []);
  }

  int get length => state.subtitles.length;
  List<Subtitle> get subtitles => state.subtitles;
  int get selectedIndex => state.selectedSubtitleIndex;
}
