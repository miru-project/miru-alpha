import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_drawing/path_drawing.dart';

class HomeIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool isTriggered; // Changed from isAnimating to isTriggered

  const HomeIcon({
    super.key,
    this.size = 22.0,
    this.color = Colors.black,
    this.isTriggered = false,
  });

  @override
  Widget build(BuildContext context) {
    const String housePath =
        "M3 10a2 2 0 0 1 .709-1.528l7-5.999a2 2 0 0 1 2.582 0l7 5.999A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z";
    const String doorPath = "M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8";

    return Animate(target: isTriggered ? 0.0 : 1.0).custom(
      duration: 400.ms,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _HomePainter(
                houseData: housePath,
                doorData: doorPath,
                color: color,
                animationProgress: value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomePainter extends CustomPainter {
  final String houseData;
  final String doorData;
  final Color color;
  final double animationProgress;

  _HomePainter({
    required this.houseData,
    required this.doorData,
    required this.color,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Use uniform scale to prevent flattening/squeezing
    final double scale = size.width / 24;

    canvas.save();
    canvas.scale(scale);

    // 1. Draw static house shell
    Path house = parseSvgPathData(houseData);
    canvas.drawPath(house, paint);

    // 2. Draw animated door (pathLength logic)
    Path door = parseSvgPathData(doorData);

    // Path-loop: Opacity follows the path length
    paint.color = color.withAlpha(
      (animationProgress.clamp(0.0, 1.0) * 255).toInt(),
    );

    // Extract sub-path based on loop progress
    Path extractPath = Path();
    for (PathMetric metric in door.computeMetrics()) {
      extractPath.addPath(
        metric.extractPath(0, metric.length * animationProgress),
        Offset.zero,
      );
    }
    canvas.drawPath(extractPath, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HomePainter oldDelegate) =>
      oldDelegate.animationProgress != animationProgress ||
      oldDelegate.color != color;
}
