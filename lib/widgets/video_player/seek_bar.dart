import 'package:flutter/material.dart';
import 'package:forui/theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_app_new/provider/watch/video_player_provider.dart';
import 'dart:ui' show lerpDouble;

import 'package:miru_app_new/utils/core/log.dart';

class SeekBar extends HookConsumerWidget {
  const SeekBar({super.key, required this.vidPr});
  final VideoPlayerNotifierProvider vidPr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vidLen = useState(0);
    final sliderValue = useState<double>(0.0);
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
          thumbShape: MaterialExpressiveThumbShape(
            mainColor: context.theme.colors.primary,
          ),
          trackHeight: 6,
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

// Material-expressive thumb: outer white ring and inner black circle.
class MaterialExpressiveThumbShape extends SliderComponentShape {
  final double minRadius;
  final double maxRadius;
  final Color mainColor;
  const MaterialExpressiveThumbShape({
    this.minRadius = 10.0,
    this.maxRadius = 12.0,
    this.mainColor = Colors.white,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    final d = maxRadius * 2.0;
    return Size(d, d);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    TextPainter? labelPainter,
    RenderBox? parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    double? value,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Smooth ease for the activation animation.
    final t = Curves.easeOut.transform(activationAnimation.value);

    // Interpolate radius between min and max.
    final baseRadius = lerpDouble(minRadius, maxRadius, t)!;

    // Convert radius into a rect size. Make the thumb vertical (taller than
    // wide) so it's a vertical pill instead of a horizontal one.
    // Make the thumb narrower (thinner) while keeping it tall.
    final thumbWidth = baseRadius * 0.3;
    final thumbHeight = baseRadius * 2.5;
    final borderRadius = Radius.circular(baseRadius * 0.35);

    // Thinner ring for a more delicate look.
    final ringThickness = (baseRadius * 0.2).clamp(0.5, baseRadius * 0.35);

    final outerRect = Rect.fromCenter(
      center: center,
      width: thumbWidth + ringThickness * 2,
      height: thumbHeight + ringThickness * 2,
    );
    final innerRect = Rect.fromCenter(
      center: center,
      width: thumbWidth,
      height: thumbHeight,
    );

    // Shadow for the thumb (subtle)
    if (t > 0.01) {
      final shadowPaint = Paint()
        ..color = Colors.black.withAlpha((3 * t).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      final shadowOffset = Offset(0, 1.0 * t);
      final shadowOuter = outerRect.shift(shadowOffset);
      canvas.drawRRect(
        RRect.fromRectAndRadius(shadowOuter, borderRadius),
        shadowPaint,
      );
    }

    final outerPaint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final innerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw outer rounded rect (ring) then inner rounded rect (thumb body).
    canvas.drawRRect(
      RRect.fromRectAndRadius(outerRect, borderRadius),
      outerPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, borderRadius),
      innerPaint,
    );
  }
}
