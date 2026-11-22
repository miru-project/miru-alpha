import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_drawing/path_drawing.dart';

/// Bookmark icon for the Favorites bottom-nav tab.
///
/// Full animate-ui bookmark behavior, ported from the React reference:
///   1. **group (bounce):** a scaleY keyframe sequence [1, 0.82, 1.03, 1]
///      anchored at the TOP (transformOrigin 50% 0%), 0.5s easeInOut — the
///      bookmark squashes then overshoots then settles when it becomes
///      selected.
///   2. **path (fill):** the bookmark interior fills (fillOpacity 0 → 1),
///      delayed ~0.2s so the fill lands AFTER the bounce starts.
///
/// When [isTriggered] (the tab is selected) both play; when it deselects they
/// reverse back to the hollow outline.
class BookmarkIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool isTriggered;

  const BookmarkIcon({
    super.key,
    this.size = 22.0,
    this.color = Colors.black,
    this.isTriggered = false,
  });

  // Lucide bookmark path (matches the animate-ui reference geometry).
  static const String _bookmarkPath =
      'M17 3a2 2 0 0 1 2 2v15a1 1 0 0 1-1.496.868l-4.512-2.578a2 2 0 0 0-1.984 0l-4.512 2.578A1 1 0 0 1 5 20V5a2 2 0 0 1 2-2z';

  // The bounce keyframes: [1, 0.82, 1.03, 1] over 0.5s (animate-ui `group`).
  static const List<double> _bounceKeyframes = [1.0, 0.82, 1.03, 1.0];

  @override
  Widget build(BuildContext context) {
    // One animation drives both: the raw progress (0..1) feeds the bounce
    // (group) and the fill (path). The fill is delayed to ~0.2/0.5 of the
    // timeline so it lands after the bounce starts.
    return Animate(target: isTriggered ? 1.0 : 0.0).custom(
      duration: 500.ms,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        // Bounce only on SELECT (isTriggered true, value 0->1). On deselect
        // (isTriggered false, value 1->0) the bounce must NOT play — the
        // bookmark returns to its hollow outline without a reverse squash.
        final scaleY = isTriggered ? _bounceScale(value) : 1.0;
        // Fill fades in over the last ~60% of the timeline (delay ~0.2s of 0.5s).
        final fillProgress = ((value - 0.4) / 0.6).clamp(0.0, 1.0);
        return Center(
          child: Transform.scale(
            // Anchor at the top (50% 0%) so the squash reads as anchored to
            // the nav bar, matching the animate-ui transformOrigin.
            alignment: Alignment.topCenter,
            scaleY: scaleY,
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _BookmarkPainter(
                  pathData: _bookmarkPath,
                  color: color,
                  fillProgress: fillProgress,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Piecewise-linear interpolation across [_bounceKeyframes] over value 0..1.
  static double _bounceScale(double value) {
    final n = _bounceKeyframes.length;
    final scaled = value.clamp(0.0, 1.0) * (n - 1);
    final i = scaled.floor().clamp(0, n - 2);
    final t = scaled - i;
    return _bounceKeyframes[i] +
        (_bounceKeyframes[i + 1] - _bounceKeyframes[i]) * t;
  }
}

class _BookmarkPainter extends CustomPainter {
  final String pathData;
  final Color color;
  final double fillProgress;

  _BookmarkPainter({
    required this.pathData,
    required this.color,
    required this.fillProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas.save();
    canvas.scale(scale);

    final path = parseSvgPathData(pathData);

    // 1. Fill the bookmark interior when selected (fade in via fillProgress).
    if (fillProgress > 0) {
      final fillPaint = Paint()
        ..color = color.withAlpha((fillProgress * 255).toInt())
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    }

    // 2. Always stroke the outline on top so the shape stays crisp.
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BookmarkPainter oldDelegate) =>
      oldDelegate.fillProgress != fillProgress || oldDelegate.color != color;
}
