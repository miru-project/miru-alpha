import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_drawing/path_drawing.dart';

class CompassIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool isTriggered;

  const CompassIcon({
    super.key,
    this.size = 22.0,
    this.color = Colors.black,
    this.isTriggered = false,
  });

  @override
  Widget build(BuildContext context) {
    const String needlePathData =
        "m16.24 7.76-1.804 5.411a2 2 0 0 1-1.265 1.265L7.76 16.24l1.804-5.411a2 2 0 0 1 1.265-1.265z";

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        // Ensure the rotation happens within a square container
        child: Animate(target: isTriggered ? 1.0 : 0.0).custom(
          duration: 1400.ms,
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            // Map 0.0 -> 1.0 to rotation degrees: [0, 95, 75, -20, 0]
            double angleInDegrees = _calculateRotation(value);
            double angleInRadians = angleInDegrees * (math.pi / 180);

            return CustomPaint(
              painter: _CompassPainter(
                needleData: needlePathData,
                color: color,
                rotationRadians: angleInRadians,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Replicates the keyframe logic from React: [0, 95, 75, -20, 0]
  double _calculateRotation(double t) {
    if (t <= 0.25) {
      return lerpDouble(0, 95, t / 0.25);
    } else if (t <= 0.50) {
      return lerpDouble(95, 75, (t - 0.25) / 0.25);
    } else if (t <= 0.75) {
      return lerpDouble(75, -20, (t - 0.50) / 0.25);
    } else {
      return lerpDouble(-20, 0, (t - 0.75) / 0.25);
    }
  }

  double lerpDouble(num a, num b, double t) => a + (b - a) * t;
}

class _CompassPainter extends CustomPainter {
  final String needleData;
  final Color color;
  final double rotationRadians;

  _CompassPainter({
    required this.needleData,
    required this.color,
    required this.rotationRadians,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 1. Prevent squeezing by using uniform scaling based on the smallest side
    final double scale = math.min(size.width / 24, size.height / 24);

    // 2. Move to the center of the widget for rotation
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    // Draw the static Circle (r=10, center 12,12 in SVG units)
    canvas.drawCircle(Offset(centerX, centerY), 10 * scale, paint);

    // 3. Draw the animated Needle
    canvas.save();
    canvas.translate(centerX, centerY); // Move origin to center
    canvas.rotate(rotationRadians); // Rotate around center
    canvas.scale(scale); // Scale the path
    canvas.translate(-12, -12); // Move back to path origin for drawing

    Path needle = parseSvgPathData(needleData);
    canvas.drawPath(needle, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.rotationRadians != rotationRadians ||
      oldDelegate.color != color;
}
