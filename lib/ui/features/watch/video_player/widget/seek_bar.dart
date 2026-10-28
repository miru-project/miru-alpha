import 'package:material_ui/material_ui.dart';
import 'package:forui/theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/seek_bar_thumb.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/utils/core/device_util.dart';

import 'package:miru_alpha/utils/core/log.dart';

/// The mock's two-state scrubber: at rest it is the slim 3px line (no
/// thumb — "deactivated"), and touching it wakes it up — the track grows
/// and the thumb appears so the position can be dragged. Releasing seeks
/// and collapses back to the line.
class SeekBar extends HookConsumerWidget {
  const SeekBar({super.key, required this.vidPr});
  final VideoPlayerNotifierProvider vidPr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vidLen = ref.watch(vidPr.select((s) => s.duration)).inMilliseconds;
    final sliderValue = useState<double>(
      ref.read(vidPr.select((s) => s.position.inMilliseconds.toDouble())),
    );
    final isSliderDraggingRef = useState<bool>(false);
    final buffered = ref.watch(vidPr.select((s) => s.bufferedRange));
    // The mock's "deactivated line": the thumb and the taller track only
    // exist while the user is on the bar.
    final active = isSliderDraggingRef.value;

    // Update slider position when player reports position, but only when
    // the user isn't actively dragging the thumb.
    ref.listen<Duration>(vidPr.select((s) => s.position), (previous, next) {
      if (isSliderDraggingRef.value) return;
      sliderValue.value = vidLen == 0 ? 0.0 : next.inMilliseconds.toDouble();
    });

    return Material(
      color: Colors.transparent,
      child: SliderTheme(
        data: SliderThemeData(
          padding: .zero,
          thumbShape: active
              ? SliderThumb(mainColor: context.theme.colors.primary)
              // Both radii 0: the thumb shape lerps min→max with the
              // activation animation, so a non-zero min would still paint.
              : const SliderThumb(
                  minRadius: 0,
                  maxRadius: 0,
                  mainColor: Colors.transparent,
                ),
          trackHeight: active ? (DeviceUtil.isMobile ? 5.0 : 7.0) : 3.0,
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
            // mdk's buffer end can overshoot the reported duration by a few
            // ms (HLS segment rounding) — unclamped it trips the slider's
            // secondaryTrackValue assertion right as playback reaches the
            // end of the video.
            secondaryTrackValue: buffered.isNotEmpty
                ? buffered.last.end.inMilliseconds.toDouble().clamp(
                    0.0,
                    vidLen.toDouble(),
                  )
                : 0.0,
            max: vidLen.toDouble(),
            value: sliderValue.value.clamp(0.0, vidLen.toDouble()),
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
