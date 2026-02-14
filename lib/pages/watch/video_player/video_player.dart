import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/pages/watch/video_player/widget/mobile_gesture.dart';
import 'package:miru_app_new/pages/watch/video_player/widget/player_scaffold.dart';
import 'package:miru_app_new/pages/watch/video_player/widget/side_settings_menu.dart';
import 'package:miru_app_new/pages/watch/video_player/widget/subtitle.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:video_player/video_player.dart';
import 'package:window_manager/window_manager.dart';

class MiruVideoPlayer extends ConsumerWidget {
  const MiruVideoPlayer.local({
    super.key,
    required this.name,
    required this.localPath,
    required this.meta,
    required this.epProvider,
    required this.hasOriented,
  }) : value = null,
       torrent = null,
       mediaUrl = null;

  const MiruVideoPlayer({
    super.key,
    required this.name,
    required this.value,
    required this.meta,
    required this.epProvider,
    required this.hasOriented,
    required this.mediaUrl,
    this.torrent,
  }) : localPath = null;

  final ExtensionBangumiWatch? value;
  final String name;
  final ExtensionMeta meta;
  final String? mediaUrl;
  final EpisodeNotifierProvider epProvider;
  final bool hasOriented;
  final ExtensionBangumiWatchTorrent? torrent;
  final String? localPath;
  @override
  Widget build(context, WidgetRef ref) {
    final screenRatio = MediaQuery.of(context).size;
    final vidProvider = videoPlayerProvider(
      value?.url,
      subtitlesRaw: value?.subtitles,
      headers: value?.headers,
      torrent: torrent,
      localPath: localPath,
    );

    return Stack(
      children: [
        //video player
        Consumer(
          builder: (context, ref, child) {
            final ratio = ref.watch(vidProvider.select((s) => s.ratio));
            final showSettings = ref.watch(
              vidProvider.select((s) => s.showSettings),
            );
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.only(
                right: showSettings
                    ? (DeviceUtil.isMobileLayout(context)
                          ? MediaQuery.of(context).size.width * 0.3
                          : 400.0)
                    : 0,
              ),
              child: Center(
                child: AspectRatio(
                  aspectRatio: ratio == 0
                      ? screenRatio.width / screenRatio.height
                      : ratio,
                  child: VideoPlayer(
                    ref.read(vidProvider.notifier).vidController,
                  ),
                ),
              ),
            );
          },
        ),
        //subtitle text
        Consumer(
          builder: (context, ref, child) {
            final showSettings = ref.watch(
              vidProvider.select((s) => s.showSettings),
            );
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: 0,
              right: showSettings
                  ? (DeviceUtil.isMobileLayout(context)
                        ? MediaQuery.of(context).size.width * 0.3
                        : 400.0)
                  : 0,
              top: 0,
              bottom: 0,
              child: VideoPlayerSubtitle(vidProvider: vidProvider),
            );
          },
        ),
        //player controls ui
        Consumer(
          builder: (context, ref, child) {
            final showSettings = ref.watch(
              vidProvider.select((s) => s.showSettings),
            );
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: 0,
              right: showSettings
                  ? (DeviceUtil.isMobileLayout(context)
                        ? MediaQuery.of(context).size.width * 0.3
                        : 400.0)
                  : 0,
              top: 0,
              bottom: 0,
              child: _VideoPlayer(
                vidPr: vidProvider,
                epProvider: epProvider,
                hasOriented: hasOriented,
                meta: meta,
                name: name,
              ),
            );
          },
        ),
        // Side Settings Menu
        Consumer(
          builder: (context, ref, child) {
            final showSettings = ref.watch(
              vidProvider.select((s) => s.showSettings),
            );
            final width = DeviceUtil.isMobileLayout(context)
                ? MediaQuery.of(context).size.width * 0.3
                : 400.0;
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              right: showSettings ? 0 : -width,
              width: width,
              child: SideSettingsMenu(
                vidPr: vidProvider,
                epProvdier: epProvider,
                width: width,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _VideoPlayer extends StatefulHookConsumerWidget {
  const _VideoPlayer({
    required this.vidPr,
    required this.epProvider,
    required this.hasOriented,
    required this.meta,
    required this.name,
  });
  final VideoPlayerNotifierProvider vidPr;
  final EpisodeNotifierProvider epProvider;
  final bool hasOriented;
  final ExtensionMeta meta;
  final String name;
  @override
  _DesktopVideoPlayerState createState() => _DesktopVideoPlayerState();
}

class _DesktopVideoPlayerState extends ConsumerState<_VideoPlayer> {
  void _updateTimer() {
    // delegate to provider
    ref.read(widget.vidPr.notifier).setShowControls(true);
  }

  @override
  void initState() {
    super.initState();
  }

  void close() {
    if (!DeviceUtil.isMobile) WindowManager.instance.setAlwaysOnTop(false);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (DeviceUtil.isMobile)
          MobileGestureOverlay(
            vidPr: widget.vidPr,
            child: PlayerScaffold(
              vidPr: widget.vidPr,
              epProvider: widget.epProvider,
              hasOriented: widget.hasOriented,
              close: close,
            ),
          )
        else
          MouseRegion(
            onHover: (event) {
              _updateTimer();
            },
            child: PlayerScaffold(
              vidPr: widget.vidPr,
              epProvider: widget.epProvider,
              hasOriented: widget.hasOriented,
              close: close,
            ),
          ),
      ],
    );
  }
}
