import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:vector_math/vector_math_64.dart' as vec;

class HeartButton extends StatefulWidget {
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final Function(bool isLiked)? onChanged;

  const HeartButton({
    super.key,
    this.size = 40.0,
    this.activeColor = Colors.red,
    this.inactiveColor = Colors.grey,
    this.onChanged,
  });

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> {
  bool _isLiked = false;

  void _handleTap() {
    setState(() {
      _isLiked = !_isLiked;
    });

    // Provide a light haptic tap when liked
    if (_isLiked) {
      HapticFeedback.lightImpact();
    }

    if (widget.onChanged != null) {
      widget.onChanged!(_isLiked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      // Using Transparent hitTest behavior ensures the button is clickable
      // even in the empty spaces of the heart path.
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: _HeartIconView(
          isAnimated: _isLiked,
          size: widget.size,
          color: _isLiked ? widget.activeColor : widget.inactiveColor,
        ),
      ),
    );
  }
}

/// Internal View that handles the Drawing and the Animation Logic
class _HeartIconView extends StatelessWidget {
  final double size;
  final Color color;
  final bool isAnimated;

  const _HeartIconView({
    required this.size,
    required this.color,
    required this.isAnimated,
  });

  @override
  Widget build(BuildContext context) {
    const String svgPath =
        "M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z";

    return CustomPaint(
          size: Size(size, size),
          painter: _HeartPainter(
            pathData: svgPath,
            color: color,
            // Animates opacity from 0 to 1 when isAnimated is true
            fillOpacity: isAnimated ? 1.0 : 0.0,
          ),
        )
        .animate(target: isAnimated ? 1 : 0)
        // 1. Shrink slightly
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(0.9, 0.9),
          duration: 150.ms,
          curve: Curves.easeInOut,
        )
        .then()
        // 2. Pop up larger
        .scale(
          end: const Offset(1.33, 1.33),
          duration: 250.ms,
          curve: Curves.easeInOut,
        )
        .then()
        // 3. Settle back to original size
        .scale(
          end: const Offset(0.83, 0.83),
          duration: 200.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _HeartPainter extends CustomPainter {
  final String pathData;
  final Color color;
  final double fillOpacity;

  _HeartPainter({
    required this.pathData,
    required this.color,
    required this.fillOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Path path = parseSvgPathData(pathData);
    final Matrix4 matrix = Matrix4.identity();
    matrix.scaleByVector3(vec.Vector3(size.width / 22, size.height / 22, 0));
    path = path.transform(matrix.storage);

    // Draw Fill Layer
    final fillPaint = Paint()
      ..color = color.withAlpha((fillOpacity * 255).toInt())
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw Stroke/Border Layer
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _HeartPainter oldDelegate) =>
      oldDelegate.fillOpacity != fillOpacity || oldDelegate.color != color;
}
