import 'dart:async';
import 'dart:ui';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/application_controller_provider.dart';
import 'package:miru_app_new/provider/main_controller_provider.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/log.dart';
import 'package:miru_app_new/utils/theme/theme.dart';
import 'package:miru_app_new/widgets/core/inner_card.dart';
import 'package:miru_app_new/widgets/error.dart';
import 'package:miru_app_new/widgets/index.dart';

// import 'package:moon_design/moon_design.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:window_manager/window_manager.dart';

bool _hasOriented = false;
final _episodeNotifierProvider = Provider<EpisodeNotifierState>(
  isAutoDispose: true,
  (ref) {
    return EpisodeNotifierState();
  },
);

//Changing epsisode will make this reload
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
  void initState() {
    super.initState();
    // init episodes
    Future.microtask(() {
      final epcontroller = ref.read(episodeProvider.notifier);
      epcontroller.initEpisodes(
        widget.selectedGroupIndex,
        widget.selectedEpisodeIndex,
        widget.epGroup ?? [],
        widget.name,
        false,
      );
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
    final epcontroller = ref.read(episodeProvider.notifier);
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
    final snapshot = ref.watch(
      videoLoadProvider(url, widget.meta.packageName, widget.meta.type),
    );
    epcontroller.putinformation(
      widget.meta.type,
      widget.meta.packageName,
      widget.detailImageUrl,
      widget.detailUrl,
    );
    return FTheme(
      data: ref.watch(applicationControllerProvider).themeData,
      child: snapshot.when(
        data: (value) {
          // _resolutionNotifer =
          //     FetchResolutionProvider(value.url, value.headers ?? {});
          return PlayerResolution(
            ratio: MediaQuery.of(context).size,
            name: widget.name,
            value: value as ExtensionBangumiWatch,
            url: url,
            meta: widget.meta,
          );
        },
        error: (error, trace) => Center(
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
        loading: () => const Center(child: FProgress.circularIcon()),
      ),
    );
  }
}

//changing video quality will make this reload
class PlayerResolution extends StatefulHookConsumerWidget {
  const PlayerResolution({
    super.key,
    required this.name,
    required this.value,
    required this.url,
    required this.ratio,
    required this.meta,
  });
  final ExtensionBangumiWatch value;
  final String name;
  final ExtensionMeta meta;
  final String url;
  final Size ratio;
  @override
  createState() => _PlayerResoltionState();
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

class _PlayerResoltionState extends ConsumerState<PlayerResolution> {
  @override
  void initState() {
    VideoPlayerProvider.initProvider(
      widget.value.url,
      widget.value.subtitles ?? [],
      widget.value.headers ?? {},
      widget.ratio,
    );

    super.initState();
  }

  @override
  Widget build(context) {
    final controller = ref.watch(
      VideoPlayerProvider.provider.select(
        (it) => it
          ..currentSubtitle
          ..ratio
          ..controller,
      ),
    );

    return Stack(
      children: [
        //video player
        Center(
          child: AspectRatio(
            aspectRatio: controller.ratio == 0
                ? widget.ratio.width / widget.ratio.height
                : controller.ratio,
            child: VideoPlayer(controller.controller!),
          ),
        ),
        //subtitle text
        if (controller.currentSubtitle.isNotEmpty)
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
                    text: controller.currentSubtitle,
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
          ),
        //player controls ui
        _VideoPlayer(),
      ],
    );
  }
}

class _VideoPlayer extends StatefulHookConsumerWidget {
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
    ref.read(VideoPlayerProvider.provider.notifier).updateTimer();
  }

  Widget buildcontent(VideoPlayerState controller, VideoPlayerNotifier c) {
    void close() {
      WindowManager.instance.setAlwaysOnTop(false);
      // ref.invalidate(subtitleProvider);

      context.pop();
    }

    final showControls = ref.watch(
      VideoPlayerProvider.provider.select((s) => s.showControls),
    );
    if (showControls) {
      return Column(
        children: [
          DefaultTextStyle(
            // color: Colors.transparent,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            child: _hasOriented
                ? _Header(
                    titleSize: 20,
                    subTitleSize: 12,
                    iconSize: 20,
                    onClose: close,
                  )
                : _Header(onClose: close),
          ),
          Expanded(
            child: (!controller.isPlaying)
                ? Center(
                    child: PlayerButton(
                      onPressed: () {
                        c.play();
                      },
                      icon: FIcons.play,
                    ),
                  )
                : Container(color: Colors.transparent),
          ),
          _DesktopFooter(),
        ],
      );
    }

    return const SizedBox.expand();
  }

  @override
  Widget build(BuildContext context) {
    final currentBrightness = useState(0.0);
    final controller = ref.watch(VideoPlayerProvider.provider);
    final c = ref.read(VideoPlayerProvider.provider.notifier);
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
                                (currentBrightness.value * 100).toStringAsFixed(
                                  0,
                                ),
                              ),
                            ],
                            if (!_isBrightness) ...[
                              const Icon(Icons.volume_up),
                              const SizedBox(width: 5),
                              Text((_currentVolume * 100).toStringAsFixed(0)),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (DeviceUtil.isMobile)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (ref.read(VideoPlayerProvider.provider).showControls) {
                ref
                    .read(VideoPlayerProvider.provider.notifier)
                    .setShowControls(false);
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
                c.seek(controller.position + const Duration(seconds: 10));
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
                currentBrightness.value = (currentBrightness.value - add).clamp(
                  0,
                  1,
                );
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
              _position = controller.position;
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
            child: buildcontent(controller, c),
          ),
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
    return FLabel(
      axis: Axis.vertical,
      description: Text(
        '${epNotifier.epGroup[epNotifier.selectedGroupIndex].title}-${epNotifier.epGroup[epNotifier.selectedGroupIndex].urls[epNotifier.selectedEpisodeIndex].name}',
        style: TextStyle(
          fontSize: widget.subTitleSize,
          fontWeight: FontWeight.w300,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      child: Text(
        epNotifier.name,
        style: TextStyle(
          fontSize: widget.titleSize,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final epNotifier = ref.watch(_episodeNotifierProvider);
    return FCard.raw(
      // decoration:s BoxDecoration(
      //   color: Theme.of(context).scaffoldBackgroundColor.withAlpha(100),
      //   borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      //   boxShadow: [
      //     BoxShadow(blurRadius: 25, color: Colors.black.withValues(alpha: 0.2)),
      //   ],
      // ),
      child: Blur(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: DeviceUtil.isMobile
                    ? buildcontent(epNotifier)
                    : DragToMoveArea(child: buildcontent(epNotifier)),
              ),
              // 置顶
              if (!DeviceUtil.isMobile) ...[
                PlayerButton(
                  onPressed: () async {
                    WindowManager.instance.setAlwaysOnTop(!_isAlwaysOnTop);
                    setState(() {
                      _isAlwaysOnTop = !_isAlwaysOnTop;
                    });
                  },
                  icon: _isAlwaysOnTop
                      ? Icons.push_pin_outlined
                      : Icons.push_pin,
                ),
                const SizedBox(width: 10),
                PlayerButton(
                  onPressed: () {
                    WindowManager.instance.minimize();
                  },
                  icon: FIcons.minus,
                ),
              ],
              const SizedBox(width: 10),
              PlayerButton(onPressed: widget.onClose, icon: FIcons.x),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopFooter extends HookConsumerWidget {
  void showDialog(BuildContext context, int index) {
    showFDialog(
      useRootNavigator: false,
      style: context.theme.dialogStyle
          .copyWith(
            barrierFilter: (animation) => ImageFilter.compose(
              outer: ImageFilter.blur(
                sigmaX: animation * 5,
                sigmaY: animation * 5,
              ),
              inner: ColorFilter.mode(
                context.theme.colors.barrier,
                BlendMode.srcOver,
              ),
            ),
          )
          .call,
      context: context,
      builder: (context, style, animation) {
        return _DesktopSettingDialog(initialIndex: index);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speedPopOverController = useFPopoverController();
    // final isSubtitlesToggled = useState(false);

    final controller = ref.watch(VideoPlayerProvider.provider);
    final c = ref.read(VideoPlayerProvider.provider.notifier);
    // buttonSize removed; not used
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: (FCard.raw(
        style: FCardStyle.inherit(
          colors: context.theme.colors.copyWith(
            background: context.theme.colors.background.withAlpha(230),
          ),
          typography: overrideTheme.typography,
          style: context.theme.style,
        ).call,
        child: Blur(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SeekBar(),
                // if (!_hasOriented) const SizedBox(height: 10),
                Row(
                  children: [
                    Row(
                      children: [
                        PlayerButton(onPressed: () {}, icon: FIcons.skipBack),
                        if (controller.isPlaying)
                          PlayerButton(onPressed: c.pause, icon: FIcons.pause)
                        else
                          PlayerButton(onPressed: c.play, icon: FIcons.play),
                        PlayerButton(
                          onPressed: () {},
                          icon: FIcons.skipForward,
                        ),
                        const SizedBox(width: 10),
                        // 播放进度
                        Text(
                          '${controller.position.inMinutes}:${(controller.position.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('/'),
                        const SizedBox(width: 10),
                        Text(
                          '${controller.duration.inMinutes}:${(controller.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
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
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        FPopover(
                          onTapHide: () => speedPopOverController.hide(),
                          controller: speedPopOverController,
                          // onTapOutside: () {
                          //   isspeedToggled.value = false;
                          // },
                          // show: isspeedToggled.value,
                          popoverBuilder: (context, ctrller) => InnerCard(
                            title: "Adjust playback speed",
                            child: SizedBox(
                              width: 200,
                              child: FItemGroup(
                                maxHeight: 150,
                                children: [
                                  FItem(
                                    prefix: Icon(FIcons.user),
                                    title: const Text('Personalization'),
                                    suffix: Icon(FIcons.chevronRight),
                                    onPress: () {},
                                  ),
                                  FItem(
                                    prefix: Icon(FIcons.mail),
                                    title: const Text('Mail'),
                                    suffix: Icon(FIcons.chevronRight),
                                    onPress: () {},
                                  ),
                                  FItem(
                                    prefix: Icon(FIcons.wifi),
                                    title: const Text('WiFi'),
                                    details: const Text('Forus Labs (5G)'),
                                    suffix: Icon(FIcons.chevronRight),
                                    onPress: () {},
                                  ),
                                  FItem(
                                    prefix: Icon(FIcons.alarmClock),
                                    title: const Text('Alarm Clock'),
                                    suffix: Icon(FIcons.chevronRight),
                                    onPress: () {},
                                  ),
                                  FItem(
                                    prefix: Icon(FIcons.qrCode),
                                    title: const Text('QR code'),
                                    suffix: Icon(FIcons.chevronRight),
                                    onPress: () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                          child: FButton.icon(
                            onPress: () => speedPopOverController.toggle(),
                            child: Text(
                              '${controller.speed}x',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
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
                        PlayerButton(
                          onPressed: () => showDialog(context, 1),
                          icon: FIcons.captions,
                        ),
                        // 播放列表
                        PlayerButton(
                          icon: FIcons.listVideo,
                          onPressed: () {
                            showDialog(context, 0);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}

// class _DialogButton extends HookWidget {
//   const _DialogButton({this.initIndex, required this.onPressed});
//   final int? initIndex;
//   final void Function(int) onPressed;

//   static const _navItems = [
//     NavItem(text: 'Episode', icon: Icons.tv_outlined, selectIcon: Icons.tv),
//     NavItem(text: 'Resolution', icon: Icons.hd_outlined, selectIcon: Icons.hd),
//     NavItem(
//       text: 'Subtitle',
//       icon: Icons.subtitles_outlined,
//       selectIcon: Icons.subtitles_rounded,
//     ),
//     NavItem(
//       text: 'Settings',
//       icon: Icons.settings_outlined,
//       selectIcon: Icons.settings,
//     ),
//   ];

//   @override
//   Widget build(context) {
//     final hover = useState(0);
//     final ishover = useState(false);
//     final selectedIndex = useState(initIndex ?? 0);
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(
//         _navItems.length,
//         (index) => MouseRegion(
//           cursor: SystemMouseCursors.click,
//           onEnter: (_) {
//             ishover.value = true;
//             hover.value = index;
//           },
//           onExit: (_) {
//             ishover.value = false;
//             hover.value = index;
//           },
//           child: GestureDetector(
//             onTap: () {
//               onPressed(index);
//               selectedIndex.value = index;
//             },
//             child: Container(
//               width: 40,
//               height: 40,
//               padding: const EdgeInsets.all(5),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     selectedIndex.value == index ||
//                             (hover.value == index && ishover.value)
//                         ? _navItems[index].selectIcon
//                         : _navItems[index].icon,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class _DesktopSettingDialog extends HookConsumerWidget {
  const _DesktopSettingDialog({this.initialIndex = 0});
  static const _navItems = [
    NavItem(text: 'Episode', icon: FIcons.tv),
    NavItem(text: 'Resolution', icon: FIcons.ratio),
    NavItem(text: 'Subtitle', icon: FIcons.captions),
    NavItem(text: 'Settings', icon: FIcons.bolt),
  ];
  final int initialIndex;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(initialIndex);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final epController = ref.watch(_episodeNotifierProvider);
    final epNotifier = ref.read(episodeProvider.notifier);
    // final subController = ref.watch(subtitleProvider);
    // final subNotifier = ref.read(subtitleProvider.notifier);
    final controller = ref.read(VideoPlayerProvider.provider);
    final notifer = ref.read(VideoPlayerProvider.provider.notifier);
    final dialogContent = [
      // episodes
      ListView.builder(
        itemBuilder: (context, index) => Column(
          children: [
            FAccordion(
              children: List.generate(
                epController.epGroup[index].urls.length,
                (i) => FButton(
                  mainAxisAlignment: MainAxisAlignment.start,
                  style: FButtonStyle.ghost(),
                  child: Text(
                    epController.epGroup[index].urls[i].name,
                    style: TextStyle(),
                  ),
                  onPress: () {
                    epNotifier.selectEpisode(index, i);
                    context.pop();
                  },
                ),
              ),
            ),
          ],
        ),
        itemCount: epController.epGroup.length,
      ),
      ListView.builder(
        itemBuilder: (context, index) {
          final item = controller.qualityMap.keys.toList()[index];
          return FButton(
            style: FButtonStyle.ghost(),
            mainAxisAlignment: MainAxisAlignment.start,
            onPress: () {
              notifer.changeVideoQuality(controller.qualityMap[item]!);
              context.pop();
            },
            child: Text(item),
          );
        },
        itemCount: controller.qualityMap.length,
      ),
      // subtitle
      ListView.builder(
        itemCount: controller.subtitlesRaw.length,
        itemBuilder: (context, int index) => FButton(
          onPress: () {
            notifer.setSelectedIndex(index);
            context.pop();
          },
          suffix: Text('${controller.subtitlesRaw[index].language}'),
          child: Text(controller.subtitlesRaw[index].title),
        ),
      ),
      // settings
      Container(),
    ];
    final dialogFactor = _hasOriented ? 0.8 : .5;
    return Center(
      child: SizedBox(
        height: height * dialogFactor,
        width: width * dialogFactor,
        child: FCard.raw(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 5, vertical: 15),
            child: FScaffold(
              sidebar: SizedBox(
                width: 160,
                child: FSidebarGroup(
                  children: List.generate(_navItems.length, (index) {
                    return FSidebarItem(
                      onPress: () {
                        selectedIndex.value = index;
                      },
                      icon: Icon(_navItems[index].icon),
                      label: Text(_navItems[index].text),
                    );
                  }),
                ),
              ),
              child: Container(
                height: height * dialogFactor,
                decoration: BoxDecoration(
                  // color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(10),
                  ),
                ),
                child: dialogContent[selectedIndex.value],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeekBar extends StatefulHookConsumerWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SeekBarState();
}

class _SeekBarState extends ConsumerState<_SeekBar> {
  Timer? _timer;
  void updateSliderTimer(VoidFunction callback) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 300), () {
      callback();
    });
  }

  int prevTime = 0;
  bool isSliderDraging = false;
  double rawextent = 0;
  final sliderPos = 0;
  @override
  Widget build(BuildContext context) {
    final duration = ref.watch(
      VideoPlayerProvider.provider.select((s) => s.duration),
    );
    final pos = ref.watch(
      VideoPlayerProvider.provider.select((s) => s.position),
    );
    final vidLen = duration.inMilliseconds;
    final double playerPos = vidLen == 0 ? 0 : pos.inMilliseconds / vidLen;
    final sliderSelection = FSliderSelection(max: 1);
    final fcontroller = useFContinuousSliderController(
      stepPercentage: .00001,
      selection: sliderSelection,
    );

    // fcontroller.slide(pos / vidLen, min: fa);
    {
      if (!isSliderDraging) {
        fcontroller.slide(playerPos * rawextent, min: false);
      }
      return SizedBox(
        height: 50,
        child: FSlider(
          enabled: duration.inMilliseconds > 0,
          layout: FLayout.ltr,
          tooltipBuilder: (tip, val) {
            return Text(
              Duration(
                milliseconds: (vidLen * val).toInt(),
              ).toString().split('.').first.substring(2),
            );
          },
          controller: fcontroller,
          semanticFormatterCallback: (val) {
            rawextent = val.rawExtent.max;
            isSliderDraging = false;
            // logger.info("playerpos", playerPos);
            return "";
          },
          onChange: (value) {
            isSliderDraging = true;

            ref.read(VideoPlayerProvider.provider.notifier).updateTimer();
            final time = DateTime.now().millisecondsSinceEpoch;
            logger.info("playerpos on change ");
            if (time - prevTime > 300) {
              logger.info(sliderSelection.rawExtent);
              prevTime = time;
              updateSliderTimer(() {
                final seekVal = value.offset.max * vidLen;
                // logger.info('seek to $seekVal');
                ref
                    .read(VideoPlayerProvider.provider.notifier)
                    .seek(Duration(milliseconds: seekVal.toInt()));
                isSliderDraging = false;
              });
            }
          },
        ),
      );
    }
  }
}
