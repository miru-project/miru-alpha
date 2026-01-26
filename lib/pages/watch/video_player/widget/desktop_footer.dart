import 'package:flutter/material.dart';

import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/pages/watch/video_player/widget/player_button.dart';
import 'package:miru_app_new/pages/watch/video_player/widget/desktop_player_widget.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';
import 'package:miru_app_new/utils/theme/theme.dart';
import 'package:miru_app_new/widgets/core/inner_card.dart';
import 'package:miru_app_new/widgets/index.dart';

import 'package:miru_app_new/pages/watch/video_player/widget/seek_bar.dart';

class DesktopPlayerFooter extends StatelessWidget {
  const DesktopPlayerFooter({
    super.key,
    required this.vidPr,
    required this.epProvider,
  });
  final VideoPlayerNotifierProvider vidPr;
  final EpisodeNotifierProvider epProvider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: (FCard.raw(
        style: FCardStyle.inherit(
          colors: context.theme.colors.copyWith(
            background: context.theme.colors.background.withAlpha(230),
          ),
          typography: overrideTheme.typography,
          style: context.theme.style.copyWith(
            borderRadius: BorderRadius.circular(10),
          ),
        ).call,
        child: Blur(
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SeekBar(vidPr: vidPr),
                DesktopPlayerFooterMenu(vidPr: vidPr, epProvdier: epProvider),
              ],
            ),
          ),
        ),
      )),
    );
  }
}

class DesktopPlayerFooterMenu extends HookConsumerWidget {
  const DesktopPlayerFooterMenu({
    super.key,
    required this.vidPr,
    required this.epProvdier,
  });
  final VideoPlayerNotifierProvider vidPr;
  final EpisodeNotifierProvider epProvdier;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speedPopOverController = useFPopoverController();

    final speed = ref.watch(vidPr.select((value) => value.speed));
    return Row(
      children: [
        DesktopPlayerWidget(vidPr: vidPr, epProvdier: epProvdier),
        Spacer(),
        Row(
          children: [
            const SizedBox(width: 10),
            FPopover(
              onTapHide: () => speedPopOverController.hide(),
              control: FPopoverControl.managed(
                controller: speedPopOverController,
              ),
              popoverBuilder: (context, ctrller) => InnerCard(
                title: "Adjust playback speed",
                child: SizedBox(
                  width: 200,
                  child: FItemGroup(maxHeight: 150, children: []),
                ),
              ),
              child: FButton.icon(
                onPress: () => speedPopOverController.toggle(),
                child: Text('${speed}x', style: const TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 10),
            PlayerButton(
              onPressed: () => ref.read(vidPr.notifier).toggleSettings(),
              icon: FIcons.captions,
            ),
            // 播放列表
            PlayerButton(
              icon: FIcons.listVideo,
              onPressed: () {
                ref.read(vidPr.notifier).toggleSettings(); // Open sidebar
              },
            ),
          ],
        ),
      ],
    );
  }
}
