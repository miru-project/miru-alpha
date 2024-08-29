import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/controllers/main_controller.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/video_provider.dart';
import 'package:miru_app_new/utils/extension/extension_service.dart';
import 'package:miru_app_new/utils/network/request.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:moon_design/moon_design.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:window_manager/window_manager.dart';

late StateNotifierProviderFamily<VideoPlayerNotifier, VideoPlayerState, String>
    _videoPlayerProvider;
final _sideBarProvider =
    StateNotifierProvider<SideBarNotifier, SideBarState>((ref) {
  return SideBarNotifier();
});
final _episodeNotifierProvider =
    StateNotifierProvider<EpisodeNotifier, EpisodeNotifierState>((ref) {
  return EpisodeNotifier();
});

class _MobileVideoPlayer extends ConsumerWidget {
  // const _MobileVideoPlayer({});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}

final subtitleProvider =
    StateNotifierProvider<SubtitleNotifier, SubTitleGroupState>((ref) {
  return SubtitleNotifier();
});

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
  @override
  void initState() {
    super.initState();
    // init episodes
    Future.microtask(() {
      final epcontroller = ref.read(_episodeNotifierProvider.notifier);
      epcontroller.initEpisodes(widget.selectedGroupIndex,
          widget.selectedEpisodeIndex, widget.epGroup ?? [], widget.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
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
    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height;
    final sideWidth = MediaQuery.of(context).size.width < 800 ? 300.0 : 400.0;

    return snapshot.when(
        data: (value) {
          final subtitleUrl = value.subtitles?.first.url;
          final currentSubtitle = useState<String>('');
          final videoController = usePlayer(
            url: value.url,
          );
          useEffect(() {
            if (subtitleUrl != null) {
              Future.microtask(() {
                ref.read(subtitleProvider.notifier).init(value.subtitles);
              });
              videoController.addListener(() {
                final position = videoController.value.position;
                final subtitle = ref
                    .read(subtitleProvider.notifier)
                    .getCurrentSubtitle(position);
                currentSubtitle.value = subtitle;
              });
            }

            return () {
              videoController.dispose();
              ref.invalidate(subtitleProvider);
            };
          }, [videoController]);
          _videoPlayerProvider = StateNotifierProvider.family<
              VideoPlayerNotifier, VideoPlayerState, String>(
            (ref, url) {
              return VideoPlayerNotifier(videoController, value.subtitles);
            },
          );
          // final subContoller = ref.read(subtitleProvider.notifier);
          final sideBarState = ref.watch(_sideBarProvider);
          final sideBarNotifier = ref.read(_sideBarProvider.notifier);
          return Row(children: [
            AnimatedContainer(
                onEnd: () {
                  if (sideBarState.isOpenSideBar) {
                    sideBarNotifier.showSideBar();
                    return;
                  }
                  sideBarNotifier.hideSideBar();
                },
                duration: const Duration(milliseconds: 120),
                width: sideBarState.isOpenSideBar
                    ? maxWidth - sideWidth
                    : maxWidth,
                child: Stack(children: [
                  //video player
                  Center(
                      child: AspectRatio(
                          aspectRatio: videoController.value.size.width == 0
                              ? maxWidth / maxHeight
                              : videoController.value.size.width /
                                  videoController.value.size.height,
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
                              decoration:
                                  TextDecoration.none, // Remove underline
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )),
                    ),
                  //player controls ui
                  PlatformWidget(
                      mobileWidget: _MobileVideoPlayer(),
                      desktopWidget: _DesktopVideoPlayer())
                ]).animate().fade()),
            if (sideBarState.isShowSideBar) _SideBar(sideWidth: sideWidth)
          ]);
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

class _SideBar extends HookConsumerWidget {
  const _SideBar({required this.sideWidth});
  final double sideWidth;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 4);
    return Container(
      width: sideWidth,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        MoonTabBar(tabs: const [
          MoonTab(label: Text('Subtitle')),
          MoonTab(label: Text('Episodes')),
          MoonTab(label: Text('Quality')),
          MoonTab(label: Text('Settings')),
        ]),
        Expanded(
            child: TabBarView(
                controller: tabController,
                children: [Container(), Container()]))
      ]),
    );
  }
}

class _DesktopVideoPlayer extends StatefulHookConsumerWidget {
  @override
  _DesktopVideoPlayerState createState() => _DesktopVideoPlayerState();
}

class _DesktopVideoPlayerState extends ConsumerState<_DesktopVideoPlayer> {
  Timer? _timer;
  bool _showControls = false;
  _updateTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _showControls = true;
    });
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(_videoPlayerProvider(''));
    final c = ref.watch(_videoPlayerProvider('').notifier);
    // final epNotifier = ref.watch(_episodeNotifierProvider);
    return MouseRegion(
        onHover: (event) {
          _updateTimer();
        },
        child: _showControls
            ? Column(
                children: [
                  Material(child: _Header(onClose: () {
                    controller.controller.dispose();
                    WindowManager.instance.setAlwaysOnTop(false);
                    ref.invalidate(subtitleProvider);
                    context.pop();
                  })),
                  Expanded(
                      child: (!controller.isPlaying)
                          ? Center(
                              child: MoonButton.icon(
                              icon: const Icon(
                                  size: 60, MoonIcons.media_play_24_regular),
                              buttonSize: MoonButtonSize.lg,
                              onTap: () {
                                c.play();
                              },
                            ))
                          : Container(
                              color: Colors.transparent,
                            )),
                  Material(
                      child: Container(
                          color: Colors.transparent,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
                              child: _DesktopFooter())))
                ],
              )
            : const SizedBox.expand());
  }
}

class _Header extends ConsumerStatefulWidget {
  const _Header({
    required this.onClose,
  });
  final VoidCallback onClose;
  @override
  ConsumerState<_Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<_Header> {
  bool _isAlwaysOnTop = false;

  @override
  void initState() {
    super.initState();
    WindowManager.instance.isAlwaysOnTop().then((value) {
      _isAlwaysOnTop = value;
    });
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
              child: DragToMoveArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      epNotifier.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${epNotifier.epGroup[epNotifier.selectedGroupIndex].title}-${epNotifier.epGroup[epNotifier.selectedGroupIndex].urls[epNotifier.selectedEpisodeIndex].name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 置顶
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
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: widget.onClose,
              icon: const Icon(
                MoonIcons.controls_chevron_down_24_regular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopFooter extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isspeedToggled = useState(false);
    final isSubtitlesToggled = useState(false);

    final controller = ref.watch(_videoPlayerProvider(''));
    final c = ref.watch(_videoPlayerProvider('').notifier);
    // final sideBarState = ref.watch(_sideBarProvider);
    final sideBarNotiier = ref.read(_sideBarProvider.notifier);
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
              MoonPopover(
                  onTapOutside: () {
                    isSubtitlesToggled.value = false;
                  },
                  show: isSubtitlesToggled.value,
                  content: Column(
                    children: List.generate(
                        c.subList.length,
                        (index) => MoonMenuItem(
                              label: Text('${c.subList[index].language}x'),
                              onTap: () {
                                c.changeSubtitle(index);
                              },
                            )),
                  ),
                  child: MoonButton.icon(
                      onTap: () {
                        sideBarNotiier.toggleSideBar();
                      },
                      icon: const Icon(Icons.subtitles))),
              // 播放列表
              IconButton(
                icon: const Icon(Icons.playlist_play),
                onPressed: () {
                  showMoonModal(
                      useRootNavigator: false,
                      context: context,
                      builder: (context) {
                        return const _DesktopSettingDialog(
                          initialIndex: 1,
                        );
                      });
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
    final selectedIndex = useState(initIndex ?? 0);
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
            _navItems.length,
            (index) => MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) {
                    hover.value = index;
                  },
                  onExit: (_) {
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
                        color:
                            selectedIndex.value == index || hover.value == index
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
                            selectedIndex.value == index || hover.value == index
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
  Widget episodes() {
    return Container();
  }

  Widget resolution() {
    return Container();
  }

  Widget subtitle() {
    return Container();
  }

  Widget settings() {
    return Container();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(initialIndex);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final epController = ref.watch(_episodeNotifierProvider);
    final epNotifier = ref.read(_episodeNotifierProvider.notifier);
    final subController = ref.watch(subtitleProvider);
    final subNotifier = ref.read(subtitleProvider.notifier);
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
      Container(),
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
    return Center(
        child: SizedBox(
      height: height / 2,
      width: width / 2,
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
          height: height / 2,
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

class BookmarkTab extends StatelessWidget {
  final String text;
  final Color color;

  const BookmarkTab({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BookmarkClipper(),
      child: Container(
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
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
  final List<ExtensionBangumiWatchSubtitle> subtitles;
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
    this.subtitles = const [],
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
      subtitles: subtitles ?? this.subtitles,
      selectedSubtitleIndex:
          selectedSubtitleIndex ?? this.selectedSubtitleIndex,
      isOpenSideBar: isOpenSideBar ?? this.isOpenSideBar,
      isShowSideBar: isShowSideBar ?? this.isShowSideBar,
    );
  }
}

class VideoPlayerNotifier extends StateNotifier<VideoPlayerState> {
  VideoPlayerNotifier(VideoPlayerController controller,
      [List<ExtensionBangumiWatchSubtitle>? subtitles,
      int selectedSubtitleIndex = 0])
      : super(VideoPlayerState(
            controller: controller,
            subtitles: subtitles ?? const [],
            selectedSubtitleIndex: selectedSubtitleIndex)) {
    _initialize();
  }
  List<ExtensionBangumiWatchSubtitle> get subList => state.subtitles;
  get speedList => const [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0];
  void _initialize() {
    state.controller.addListener(_updatePosition);
    state = state.copyWith(
      position: state.controller.value.position,
      isPlaying: state.controller.value.isPlaying,
      duration: state.controller.value.duration,
      buffered: state.controller.value.buffered,
      size: state.controller.value.size,
      subtitles: state.subtitles,
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

class SideBarNotifier extends StateNotifier<SideBarState> {
  SideBarNotifier() : super(SideBarState());

  void toggleSideBar() {
    if (!state.isOpenSideBar) {
      openSideBar();
    } else {
      hideSideBar();
    }
  }

  void openSideBar() {
    state = state.copyWith(isOpenSideBar: true);
  }

  void showSideBar() {
    state = state.copyWith(isShowSideBar: true, isOpenSideBar: true);
  }

  void hideSideBar() {
    state = state.copyWith(isShowSideBar: false, isOpenSideBar: false);
  }
}

class EpisodeNotifierState {
  final List<ExtensionEpisodeGroup> epGroup;
  final int selectedGroupIndex;
  final int selectedEpisodeIndex;
  final String name;
  EpisodeNotifierState(
      {this.epGroup = const [],
      this.selectedGroupIndex = 0,
      this.name = '',
      this.selectedEpisodeIndex = 0});
  EpisodeNotifierState copyWith(
      {List<ExtensionEpisodeGroup>? epGroup,
      String? name,
      int? selectedGroupIndex,
      int? selectedEpisodeIndex}) {
    return EpisodeNotifierState(
        epGroup: epGroup ?? this.epGroup,
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
      List<ExtensionEpisodeGroup> epGroup, String name) {
    state = state.copyWith(
        epGroup: epGroup,
        name: name,
        selectedGroupIndex: groupIndex,
        selectedEpisodeIndex: episodeIndex);
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
