import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;

class CustomSeekBarThumb extends SliderComponentShape {
  final double minRadius;
  final double maxRadius;
  final Color mainColor;
  const CustomSeekBarThumb({
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
