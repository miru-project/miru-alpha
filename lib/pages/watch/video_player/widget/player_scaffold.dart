import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:miru_app_new/pages/watch/video_player/widget/player_button.dart';
import 'package:miru_app_new/pages/watch/video_player/widget/mobile_footer.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/pages/watch/video_player/widget/desktop_footer.dart';
import 'package:miru_app_new/pages/watch/video_player/widget/player_header.dart';

class PlayerScaffold extends ConsumerWidget {
  const PlayerScaffold({
    super.key,
    required this.vidPr,
    required this.epProvider,
    required this.hasOriented,
    required this.close,
  });
  final VideoPlayerNotifierProvider vidPr;
  final EpisodeNotifierProvider epProvider;
  final bool hasOriented;
  final VoidCallback close;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControls = ref.watch(vidPr.select((s) => s.showControls));

    if (!showControls) return const SizedBox.expand();
    return Column(
      children: [
        DefaultTextStyle(
          // color: Colors.transparent,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          child: hasOriented
              ? PlayerHeader(
                  titleSize: 20,
                  subTitleSize: 12,
                  iconSize: 20,
                  onClose: close,
                  episodeProvider: epProvider,
                  vidPr: vidPr,
                )
              : PlayerHeader(
                  titleSize: 20,
                  subTitleSize: 12,
                  onClose: close,
                  episodeProvider: epProvider,
                  vidPr: vidPr,
                ),
        ),
        MainPlayerButton(vidPr: vidPr, size: 30),
        DeviceUtil.platformWidget(
          desktop: DesktopPlayerFooter(vidPr: vidPr, epProvider: epProvider),
          mobile: MobilePlayerFooter(vidPr: vidPr, epProvider: epProvider),
        ),
      ],
    );
  }
}
