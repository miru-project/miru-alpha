import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/pages/watch/video_player/widget/player_button.dart';
import 'package:miru_app_new/provider/watch/epidsode_provider.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';
import 'package:miru_app_new/utils/theme/theme.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:miru_app_new/pages/watch/video_player/widget/seek_bar.dart';

class MobilePlayerFooter extends ConsumerWidget {
  const MobilePlayerFooter({
    super.key,
    required this.vidPr,
    required this.epProvider,
  });
  final VideoPlayerNotifierProvider vidPr;
  final EpisodeNotifierProvider epProvider;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final epController = ref.read(epProvider.notifier);
    final epLength = epController.epLength;
    final epIndex = epController.selectedIndex;
    final epGroupIndex = epController.selectedGroupIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: (FCard.raw(
        style: FCardStyle.inherit(
          colors: context.theme.colors.copyWith(
            background: context.theme.colors.background.withAlpha(100),
          ),
          typography: overrideTheme.typography,
          style: context.theme.style,
        ).call,
        child: Blur(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
            child: Consumer(
              builder: (context, ref, _) {
                final position = ref.watch(
                  vidPr.select((value) => value.position),
                );
                final isPlaying = ref.watch(
                  vidPr.select((value) => value.isPlaying),
                );
                final duration = ref.watch(
                  vidPr.select((value) => value.duration),
                );
                final c = ref.read(vidPr.notifier);
                return Row(
                  // mainAxisAlignment: .spaceBetween,
                  children: [
                    PlayerButton(
                      onPressed: epIndex > 0
                          ? () {
                              epController.selectEpisode(
                                epGroupIndex,
                                epIndex - 1,
                              );
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
                              epController.selectEpisode(
                                epGroupIndex,
                                epIndex + 1,
                              );
                            }
                          : null,
                      icon: FIcons.skipForward,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(child: SeekBar(vidPr: vidPr)),
                    Text(
                      '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      )),
    );
  }
}
