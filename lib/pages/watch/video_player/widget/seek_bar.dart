import 'package:flutter/material.dart';
import 'package:forui/theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_app_new/pages/watch/video_player/widget/seek_bar_thumb.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';

import 'package:miru_app_new/utils/core/log.dart';

class SeekBar extends HookConsumerWidget {
  const SeekBar({super.key, required this.vidPr});
  final VideoPlayerNotifierProvider vidPr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vidLen = useState(
      ref.read(vidPr.select((s) => s.duration)).inMilliseconds,
    );
    final sliderValue = useState<double>(
      ref.read(vidPr.select((s) => s.position.inMilliseconds.toDouble())),
    );
    final isSliderDraggingRef = useState<bool>(false);
    final buffered = ref.watch(vidPr.select((s) => s.bufferedRange));

    // Update slider position when player reports position, but only when
    // the user isn't actively dragging the thumb.
    ref.listen<Duration>(vidPr.select((s) => s.position), (previous, next) {
      if (isSliderDraggingRef.value) return;
      final dur = ref.read(vidPr.select((s) => s.duration));
      vidLen.value = dur.inMilliseconds;
      sliderValue.value = vidLen.value == 0
          ? 0.0
          : next.inMilliseconds.toDouble();
    });

    return Material(
      color: Colors.transparent,
      child: SliderTheme(
        data: SliderThemeData(
          thumbShape: SliderThumb(mainColor: context.theme.colors.primary),
          trackHeight: DeviceUtil.isMobile ? 5 : 7,
          activeTrackColor: context.theme.colors.primary,
          inactiveTrackColor: context.theme.colors.muted,
          overlayColor: Colors.transparent,
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Slider(
            secondaryActiveColor: context.theme.colors.primary.withAlpha(80),
            secondaryTrackValue: buffered.isNotEmpty
                ? buffered.last.end.inMilliseconds.toDouble()
                : 0.0,
            max: vidLen.value.toDouble(),
            value: sliderValue.value.clamp(0.0, vidLen.value.toDouble()),
            onChangeStart: (value) {
              isSliderDraggingRef.value = true;
            },
            onChanged: (value) {
              sliderValue.value = value;
            },
            onChangeEnd: (value) {
              ref
                  .read(vidPr.notifier)
                  .seek(Duration(milliseconds: value.toInt()));
              logger.info(value, 'seek_end');
              isSliderDraggingRef.value = false;
            },
          ),
        ),
      ),
    );
  }
}
