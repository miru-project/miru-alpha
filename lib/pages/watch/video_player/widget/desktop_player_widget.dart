import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/pages/watch/video_player/widget/player_button.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';

class DesktopPlayerWidget extends ConsumerWidget {
  const DesktopPlayerWidget({
    super.key,
    required this.vidPr,
    required this.epProvdier,
  });
  final VideoPlayerNotifierProvider vidPr;
  final EpisodeNotifierProvider epProvdier;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(vidPr.select((value) => value.isPlaying));
    final c = ref.read(vidPr.notifier);
    final epController = ref.read(epProvdier.notifier);
    final epLength = epController.epLength;
    final epIndex = epController.selectedIndex;
    final epGroupIndex = epController.selectedGroupIndex;
    return Row(
      children: [
        PlayerButton(
          onPressed: epIndex > 0
              ? () {
                  epController.selectEpisode(epGroupIndex, epIndex - 1);
                }
              : null,
          icon: FIcons.skipBack,
        ),
        if (isPlaying)
          PlayerButton(onPressed: c.pause, icon: FIcons.pause)
        else
          PlayerButton(onPressed: c.play, icon: FIcons.play),
        PlayerButton(
          onPressed: epIndex < epLength - 1
              ? () {
                  epController.selectEpisode(epGroupIndex, epIndex + 1);
                }
              : null,
          icon: FIcons.skipForward,
        ),
        const SizedBox(width: 10),
        // 播放进度
        DesktopTimeIndicator(vidPr: vidPr),
      ],
    );
  }
}

class DesktopTimeIndicator extends ConsumerWidget {
  const DesktopTimeIndicator({super.key, required this.vidPr});
  final VideoPlayerNotifierProvider vidPr;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(vidPr.select((value) => value.position));
    final duration = ref.watch(vidPr.select((value) => value.duration));
    return Row(
      children: [
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
    );
  }
}
