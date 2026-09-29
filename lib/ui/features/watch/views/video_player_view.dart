import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/side_settings_menu.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/subtitle.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;
import 'package:video_player/video_player.dart';

class VideoPlayerView extends HookConsumerWidget {
  const VideoPlayerView.local({
    super.key,
    required this.name,
    required this.localPath,
    required this.meta,
    required this.epProvider,
    required this.hasOriented,
  }) : value = null,
       torrent = null,
       mediaUrl = null,
       v2watch = null;

  const VideoPlayerView({
    super.key,
    required this.name,
    required this.value,
    required this.meta,
    required this.epProvider,
    required this.hasOriented,
    required this.mediaUrl,
    this.torrent,
    this.v2watch,
  }) : localPath = null;

  final ExtensionBangumiWatch? value;
  final String name;
  final ExtensionMeta meta;
  final String? mediaUrl;
  final EpisodeNotifierProvider epProvider;
  final bool hasOriented;
  final ExtensionBangumiWatchTorrent? torrent;
  final String? localPath;
  final pb_extension.ExtensionWatch? v2watch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenRatio = MediaQuery.of(context).size;
    final vidProvider = videoPlayerProvider(
      value?.url ?? mediaUrl,
      subtitlesRaw: value?.subtitles,
      headers: value?.headers,
      localPath: localPath,
    );
    final vidState = ref.watch(vidProvider);

    return Stack(
      children: [
        Consumer(
          builder: (context, ref, child) {
            final ratio = vidState.ratio;
            final showSettings = vidState.showSettings;
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
                    ref.read(vidProvider.notifier).videoPlayerController,
                  ),
                ),
              ),
            );
          },
        ),
        Consumer(
          builder: (context, ref, child) {
            final showSettings = vidState.showSettings;
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
        Consumer(
          builder: (context, ref, child) {
            final showSettings = vidState.showSettings;
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
                vidProvider: vidProvider,
                epProvider: epProvider,
                hasOriented: hasOriented,
                meta: meta,
                name: name,
              ),
            );
          },
        ),
        Consumer(
          builder: (context, ref, child) {
            final showSettings = vidState.showSettings;
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
                meta: meta,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _VideoPlayer extends HookConsumerWidget {
  const _VideoPlayer({
    required this.vidProvider,
    required this.epProvider,
    required this.hasOriented,
    required this.meta,
    required this.name,
  });
  final VideoPlayerNotifierProvider vidProvider;
  final EpisodeNotifierProvider epProvider;
  final bool hasOriented;
  final ExtensionMeta meta;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}
