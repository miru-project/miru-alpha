import 'dart:async';
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
import 'package:miru_app_new/widgets/error.dart';
import 'package:miru_app_new/widgets/index.dart';

import 'package:moon_design/moon_design.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:window_manager/window_manager.dart';

bool _hasOriented = false;
final _episodeNotifierProvider =
    AutoDisposeStateNotifierProvider<EpisodeNotifier, EpisodeNotifierState>((
      ref,
    ) {
      return EpisodeNotifier();
    });

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
      final epcontroller = ref.read(_episodeNotifierProvider.notifier);
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
    final epcontroller = ref.read(_episodeNotifierProvider.notifier);
    if (epNotifier.epGroup.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Text('Error: No episodes found'),
            MoonButton.icon(
              icon: const Text('back'),
              onTap: () {
                context.pop();
              },
            ),
          ],
        ),
      );
    }
    final url =
        epNotifier
            .epGroup[epNotifier.selectedGroupIndex]
            .urls[epNotifier.selectedEpisodeIndex]
            .url;
    final snapshot = ref.watch(
      VideoLoadProvider(url, widget.meta.packageName, widget.meta.type),
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
        error:
            (error, trace) => Center(
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
        (it) =>
            it
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
            aspectRatio:
                controller.ratio == 0
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
            child:
                _hasOriented
                    ? _Header(
                      titleSize: 20,
                      subTitleSize: 12,
                      iconSize: 20,
                      onClose: close,
                    )
                    : _Header(onClose: close),
          ),
          Expanded(
            child:
                (!controller.isPlaying)
                    ? Center(
                      child: FButton.icon(
                        style: FButtonStyle.ghost(),
                        onPress: () {
                          c.play();
                        },
                        child: const Icon(size: 60, FIcons.play),
                      ),
                    )
                    : Container(color: Colors.transparent),
          ),
          Blur(child: _DesktopFooter()),
        ],
      );
    }

    return const SizedBox.expand();
  }

  @override
  Widget build(BuildContext context) {
    final currentBrightness = useState(0.0);
    final controller = ref.watch(VideoPlayerProvider.provider);
    final c = ref.watch(VideoPlayerProvider.provider.notifier);
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
              double scale = 200000 / MediaQuery.of(context).size.width;
              Duration pos =
                  _position +
                  Duration(milliseconds: (details.delta.dx * scale).round());
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
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(100),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(blurRadius: 25, color: Colors.black.withValues(alpha: 0.2)),
        ],
      ),
      child: Blur(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child:
                    DeviceUtil.isMobile
                        ? buildcontent(epNotifier)
                        : DragToMoveArea(child: buildcontent(epNotifier)),
              ),
              // 置顶
              if (!DeviceUtil.isMobile) ...[
                IconButton(
                  icon: Icon(
                    _isAlwaysOnTop ? Icons.push_pin_outlined : Icons.push_pin,
                  ),
                  onPressed: () async {
                    WindowManager.instance.setAlwaysOnTop(!_isAlwaysOnTop);
                    setState(() {
                      _isAlwaysOnTop = !_isAlwaysOnTop;
                    });
                  },
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(FIcons.minus),
                  onPressed: () {
                    WindowManager.instance.minimize();
                  },
                ),
              ],
              const SizedBox(width: 10),
              IconButton(
                onPressed: widget.onClose,
                iconSize: widget.iconSize,
                icon: const Icon(FIcons.x),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopFooter extends HookConsumerWidget {
  void showDialog(BuildContext context, int index) {
    showMoonModal(
      useRootNavigator: false,
      context: context,
      builder: (context) {
        return _DesktopSettingDialog(initialIndex: index);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isspeedToggled = useState(false);
    // final isSubtitlesToggled = useState(false);

    final controller = ref.watch(VideoPlayerProvider.provider);
    final c = ref.watch(VideoPlayerProvider.provider.notifier);
    // buttonSize removed; not used
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: (FCard.raw(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SeekBar(),
            if (!_hasOriented) const SizedBox(height: 10),
            Row(
              children: [
                IconButton(icon: const Icon(FIcons.skipBack), onPressed: () {}),
                if (controller.isPlaying)
                  FButton.icon(onPress: c.pause, child: Icon(FIcons.pause))
                else
                  IconButton(onPressed: c.play, icon: Icon(FIcons.play)),
                IconButton(
                  icon: const Icon(FIcons.skipForward),
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
                      ),
                    ),
                  ),
                  child: FButton.icon(
                    onPress: () {
                      isspeedToggled.value = !isspeedToggled.value;
                    },
                    child: Text(
                      '${controller.speed}x',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
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
                MoonButton.icon(
                  onTap: () {
                    showDialog(context, 1);
                  },
                  icon: const Icon(Icons.subtitles),
                ),
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
      )),
    );
  }
}

class _DialogButton extends HookWidget {
  const _DialogButton({this.initIndex, required this.onPressed});
  final int? initIndex;
  final void Function(int) onPressed;

  static const _navItems = [
    NavItem(text: 'Episode', icon: Icons.tv_outlined, selectIcon: Icons.tv),
    NavItem(text: 'Resolution', icon: Icons.hd_outlined, selectIcon: Icons.hd),
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
              // decoration: BoxDecoration(
              //   color:
              //       selectedIndex.value == index ||
              //               (hover.value == index && ishover.value)
              //           ? context
              //               .moonTheme
              //               ?.tabBarTheme
              //               .colors
              //               .selectedPillTextColor
              //               .withAlpha(20)
              //           : Colors.transparent,
              //   borderRadius: BorderRadius.circular(10),
              // ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selectedIndex.value == index ||
                            (hover.value == index && ishover.value)
                        ? _navItems[index].selectIcon
                        : _navItems[index].icon,
                    color:
                        selectedIndex.value == index || hover.value == index
                            ? context.moonColors?.bulma
                            : context.moonColors?.bulma.withAlpha(150),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
    // final subController = ref.watch(subtitleProvider);
    // final subNotifier = ref.read(subtitleProvider.notifier);
    final controller = ref.read(VideoPlayerProvider.provider);
    final notifer = ref.read(VideoPlayerProvider.provider.notifier);
    // final resolutionController = ref.watch(FetchResolutionProvider(url, headers));
    final dialogContent = [
      // episodes
      ListView.builder(
        itemBuilder:
            (context, index) => MoonAccordion(
              accordionSize: MoonAccordionSize.md,
              backgroundColor: Theme.of(context).colorScheme.surface,
              childrenPadding: const EdgeInsets.all(10),
              label: Text(epController.epGroup[index].title),
              trailing: Text(
                '${epController.epGroup[index].urls.length} episodes',
              ),
              children: List.generate(
                epController.epGroup[index].urls.length,
                (i) => MoonMenuItem(
                  label: Text(
                    epController.epGroup[index].urls[i].name,
                    style: TextStyle(
                      color:
                          index == epController.selectedGroupIndex &&
                                  i == epController.selectedEpisodeIndex
                              ? context
                                  .moonTheme
                                  ?.segmentedControlTheme
                                  .colors
                                  .textColor
                              : null,
                    ),
                  ),
                  backgroundColor:
                      index == epController.selectedGroupIndex &&
                              i == epController.selectedEpisodeIndex
                          ? context
                              .moonTheme
                              ?.segmentedControlTheme
                              .colors
                              .backgroundColor
                          : null,
                  onTap: () {
                    epNotifier.selectEpisode(index, i);
                    context.pop();
                  },
                ),
              ),
            ),
        itemCount: epController.epGroup.length,
      ),
      ListView.builder(
        itemBuilder: (context, index) {
          final item = controller.qualityMap.keys.toList()[index];
          return MoonMenuItem(
            onTap: () {
              notifer.changeVideoQuality(controller.qualityMap[item]!);
              context.pop();
            },
            label: Text(item),
          );
        },
        itemCount: controller.qualityMap.length,
      ),
      // subtitle
      ListView.builder(
        itemCount: controller.subtitlesRaw.length,
        itemBuilder:
            (context, int index) => MoonMenuItem(
              backgroundColor:
                  (index == controller.selectedSubtitleIndex &&
                          controller.isShowSubtitle)
                      ? context
                          .moonTheme
                          ?.segmentedControlTheme
                          .colors
                          .backgroundColor
                      : null,
              onTap: () {
                notifer.setSelectedIndex(index);
                context.pop();
              },
              trailing: Text('${controller.subtitlesRaw[index].language}'),
              label: Text(controller.subtitlesRaw[index].title),
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
        child: Row(
          children: [
            Container(
              width: _buttonGap,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                ),
              ),
              child: (SizedBox(
                child: _DialogButton(
                  initIndex: selectedIndex.value,
                  onPressed: (index) {
                    selectedIndex.value = index;
                  },
                ),
              )),
            ),
            Expanded(
              child: Container(
                height: height * dialogFactor,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(10),
                  ),
                ),
                child: dialogContent[selectedIndex.value],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeekBar extends HookConsumerWidget {
  Timer? _timer;
  void updateSliderTimer(VoidFunction callback) {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 1), () {
      callback();
    });
  }

  int prevTime = 0;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // need configure the side ot tap mpde
    final fcontroller = useFContinuousSliderController(
      stepPercentage: .00001,
      selection: FSliderSelection(max: 1),
    );
    return FSlider(
      tooltipBuilder: (tip, val) {
        return Text('${(val * 100).toStringAsFixed(1)}%');
      },
      controller: fcontroller,
      onChange: (value) {
        // isSliderDraging = true;
        // value.
        ref.read(VideoPlayerProvider.provider.notifier).updateTimer();
        if (DateTime.now().millisecond - prevTime > 100) {
          logger.info(value.rawOffset, value.rawExtent);
          // ref.read(VideoPlayerProvider.provider.notifier).seek(
          //       Duration(
          //         milliseconds:
          //             (value * ref.read(VideoPlayerProvider.provider).duration.inMilliseconds)
          //                 .toInt(),
          //       ),
          //     );
          prevTime = DateTime.now().millisecond;
        }
      },
      // min: 0,
      // max: duration.toDouble(),
      // value: clampDouble(position.toDouble(), 0, duration.toDouble()),
      // secondaryTrackValue:
      //     controller.buffered.isNotEmpty
      //         ? clampDouble(
      //           controller.buffered.last.end.inMilliseconds.toDouble(),
      //           0,
      //           duration.toDouble(),
      //         )
      //         : 0,
      // onChanged: (value) {
      //   if (isSliderDraging) {}
      // },
      // onChangeStart: (value) {
      //   isSliderDraging = true;
      // },
      // onChangeEnd: (value) {
      //   if (isSliderDraging) {
      //     c.seek(Duration(milliseconds: value.toInt()));

      //     isSliderDraging = false;
      //   }
      // },
    );
  }
}
