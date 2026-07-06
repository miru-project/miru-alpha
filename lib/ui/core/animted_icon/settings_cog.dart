import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_drawing/path_drawing.dart';

class SettingsIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool isTriggered;

  const SettingsIcon({
    super.key,
    this.size = 22.0,
    this.color = Colors.black,
    this.isTriggered = false,
  });

  @override
  Widget build(BuildContext context) {
    const String gearPath =
        "M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z";

    return Animate(target: isTriggered ? 1.0 : 0.0).custom(
      duration: 1250.ms,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        // value 0 -> 1 maps to 0 -> 180 degrees (pi radians)
        final double rotationAngle = value * math.pi;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Transform.rotate(
              angle: rotationAngle,
              alignment:
                  Alignment.center, // Center of rotation: (size/2, size/2)
              child: CustomPaint(
                painter: _SettingsPainter(pathData: gearPath, color: color),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsPainter extends CustomPainter {
  final String pathData;
  final Color color;

  _SettingsPainter({required this.pathData, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Calculate UNIFORM scale to prevent flattening
    // Original SVG viewbox is 24x24.
    // We pick the smallest dimension to ensure the icon stays square.
    final double uniformScale = math.min(size.width / 24, size.height / 24);

    // Center the drawing if the canvas isn't perfectly square
    final double dx = (size.width - (24 * uniformScale)) / 2;
    final double dy = (size.height - (24 * uniformScale)) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(uniformScale);

    // 1. Draw Gear Path
    Path path = parseSvgPathData(pathData);
    canvas.drawPath(path, paint);

    // 2. Draw Center Circle (Original cx:12, cy:12, r:3)
    canvas.drawCircle(const Offset(12, 12), 3, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SettingsPainter oldDelegate) =>
      oldDelegate.color != color;
}
