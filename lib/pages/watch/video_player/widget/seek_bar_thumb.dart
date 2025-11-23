import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;

enum _ThumbShape { rectangle, circular }

class SliderThumb extends SliderComponentShape {
  final double minRadius;
  final double maxRadius;
  final Color mainColor;
  final _ThumbShape _shape;

  const SliderThumb({
    this.minRadius = 10.0,
    this.maxRadius = 12.0,
    this.mainColor = Colors.white,
  }) : _shape = _ThumbShape.rectangle;

  const SliderThumb.rectangle({
    this.minRadius = 10.0,
    this.maxRadius = 12.0,
    this.mainColor = Colors.white,
  }) : _shape = _ThumbShape.rectangle;

  const SliderThumb.circular({
    this.minRadius = 10.0,
    this.maxRadius = 12.0,
    this.mainColor = Colors.white,
  }) : _shape = _ThumbShape.circular;

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
    final t = Curves.easeOut.transform(activationAnimation.value);
    final baseRadius = lerpDouble(minRadius, maxRadius, t)!;

    final outerPaint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final innerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    if (_shape == _ThumbShape.rectangle) {
      final thumbWidth = baseRadius * 0.3;
      final thumbHeight = baseRadius * 2.5;
      final borderRadius = Radius.circular(baseRadius * 0.35);
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

      canvas.drawRRect(
        RRect.fromRectAndRadius(outerRect, borderRadius),
        outerPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(innerRect, borderRadius),
        innerPaint,
      );
    } else {
      // Circular shape
      final radius = baseRadius;
      final ringThickness = (baseRadius * 0.2).clamp(0.5, baseRadius * 0.35);

      if (t > 0.01) {
        final shadowPaint = Paint()
          ..color = Colors.black.withAlpha((3 * t).toInt())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(center + Offset(0, 1.0 * t), radius, shadowPaint);
      }

      canvas.drawCircle(center, radius, outerPaint);
      // Draw inner circle (hollow part) - slightly smaller to create a ring effect
      canvas.drawCircle(center, radius - ringThickness, innerPaint);
    }
  }
}
