import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/pages/video_player/video_player.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';
import 'package:miru_app_new/utils/theme/theme.dart';
import 'package:miru_app_new/widgets/core/inner_card.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:miru_app_new/pages/video_player/widget/desktop_setting_dialog.dart';
import 'package:miru_app_new/pages/video_player/widget/seek_bar.dart';

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
          style: context.theme.style,
        ).call,
        child: Blur(
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
  void showDialog(BuildContext context, int index) {
    showFDialog(
      useRootNavigator: false,
      routeStyle: context.theme.dialogRouteStyle
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
        return DesktopSettingDialog(
          initialIndex: index,
          vidPr: vidPr,
          epProvdier: epProvdier,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speedPopOverController = useFPopoverController();
    // final isSubtitlesToggled = useState(false);

    final isPlaying = ref.watch(vidPr.select((value) => value.isPlaying));
    final position = ref.watch(vidPr.select((value) => value.position));
    final duration = ref.watch(vidPr.select((value) => value.duration));
    final speed = ref.watch(vidPr.select((value) => value.speed));
    final c = ref.read(vidPr.notifier);
    return Row(
      children: [
        Row(
          children: [
            PlayerButton(onPressed: () {}, icon: FIcons.skipBack),
            if (isPlaying)
              PlayerButton(onPressed: c.pause, icon: FIcons.pause)
            else
              PlayerButton(onPressed: c.play, icon: FIcons.play),
            PlayerButton(onPressed: () {}, icon: FIcons.skipForward),
            const SizedBox(width: 10),
            // 播放进度
            Text(
              '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            const Text('/'),
            const SizedBox(width: 10),
            Text(
              '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Spacer(),
        Row(
          children: [
            const SizedBox(width: 10),
            FPopover(
              onTapHide: () => speedPopOverController.hide(),
              controller: speedPopOverController,
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
    );
  }
}
