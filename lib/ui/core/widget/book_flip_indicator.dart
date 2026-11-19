import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

/// Replayable "book opening" indicator for the row the reader is on.
///
/// The right leaf flips across the spine and fades out
/// (`scaleX 1 -> 0.02 -> -1`, opacity `1 1 1 0`, 750 ms, keyframes at
/// 0 / 0.4 / 0.8 / 1, `Curves.easeInOut`) and the cycle restarts from the
/// closed book, so the end connects back to the start and it loops forever.
///
/// Port of animate-ui's `BookOpen` default variant with the four text-line
/// paths dropped — only the page flip remains.
class BookFlipIndicator extends StatefulWidget {
  const BookFlipIndicator({super.key, this.size = 20.0, this.color});

  final double size;

  /// Defaults to the theme's primary colour.
  final Color? color;

  @override
  State<BookFlipIndicator> createState() => _BookFlipIndicatorState();
}

class _BookFlipIndicatorState extends State<BookFlipIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.theme.colors.primary;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: BookFlipPainter(color: color, progress: _controller.value),
        ),
      ),
    );
  }
}

class BookFlipPainter extends CustomPainter {
  BookFlipPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  /// Lucide `book-open` geometry, 24 x 24, stroke only.
  static final Path _spine = _path(
    (p) => p
      ..moveTo(12, 5)
      ..lineTo(12, 21),
  );

  static final Path _leftCover = _path(
    (p) => p
      ..moveTo(12, 5)
      ..arcToPoint(
        const Offset(8, 3),
        radius: const Radius.circular(5),
        largeArc: false,
        clockwise: false,
      )
      ..lineTo(4, 3)
      ..arcToPoint(
        const Offset(2, 5),
        radius: const Radius.circular(2),
        largeArc: false,
        clockwise: false,
      )
      ..lineTo(2, 17)
      ..arcToPoint(
        const Offset(3.999, 19),
        radius: const Radius.circular(2),
        largeArc: false,
        clockwise: false,
      )
      ..lineTo(8, 19)
      ..arcToPoint(
        const Offset(12, 21),
        radius: const Radius.circular(5),
        largeArc: false,
        clockwise: true,
      ),
  );

  static final Path _rightCover = _path(
    (p) => p
      ..moveTo(12, 5)
      ..arcToPoint(
        const Offset(16, 3.002),
        radius: const Radius.circular(5),
        largeArc: false,
        clockwise: true,
      )
      ..lineTo(20.001, 3)
      ..arcToPoint(
        const Offset(22, 5),
        radius: const Radius.circular(2),
        largeArc: false,
        clockwise: true,
      )
      ..lineTo(22, 17)
      ..arcToPoint(
        const Offset(20.001, 19),
        radius: const Radius.circular(2),
        largeArc: false,
        clockwise: true,
      )
      ..lineTo(16, 19)
      ..arcToPoint(
        const Offset(12, 21),
        radius: const Radius.circular(5),
        largeArc: false,
        clockwise: false,
      ),
  );

  /// The flipping leaf: the right cover, closed back along the spine.
  static final Path _leaf = _path(
    (p) => p
      ..moveTo(12, 5)
      ..arcToPoint(
        const Offset(16, 3.002),
        radius: const Radius.circular(5),
        largeArc: false,
        clockwise: true,
      )
      ..lineTo(20.001, 3)
      ..arcToPoint(
        const Offset(22, 5),
        radius: const Radius.circular(2),
        largeArc: false,
        clockwise: true,
      )
      ..lineTo(22, 17)
      ..arcToPoint(
        const Offset(20.001, 19),
        radius: const Radius.circular(2),
        largeArc: false,
        clockwise: true,
      )
      ..lineTo(16, 19)
      ..arcToPoint(
        const Offset(12, 21),
        radius: const Radius.circular(5),
        largeArc: false,
        clockwise: false,
      )
      ..close(),
  );

  static Path _path(void Function(Path) build) {
    final path = Path();
    build(path);
    return path;
  }

  /// Keyframes: scaleX `1, 0.02, -1, -1` and opacity `1, 1, 1, 0` at
  /// times `0, 0.4, 0.8, 1` — the leaf turns edge-on, keeps going through the
  /// spine and fades before the cycle restarts.
  @visibleForTesting
  static (double scaleX, double opacity) leafAt(double t) => _leafAt(t);

  static (double scaleX, double opacity) _leafAt(double t) {
    final p = t.clamp(0.0, 1.0);
    final double scaleX;
    if (p < 0.4) {
      scaleX = _lerp(1.0, 0.02, _ease(p / 0.4));
    } else if (p < 0.8) {
      scaleX = _lerp(0.02, -1.0, _ease((p - 0.4) / 0.4));
    } else {
      scaleX = -1.0;
    }
    final opacity = p < 0.8 ? 1.0 : _lerp(1.0, 0.0, _ease((p - 0.8) / 0.2));
    return (scaleX, opacity);
  }

  static double _ease(double x) =>
      Curves.easeInOut.transform(x.clamp(0.0, 1.0));

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 24;
    canvas.save();
    canvas.scale(unit);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    canvas.drawPath(_spine, stroke);
    canvas.drawPath(_leftCover, stroke);
    canvas.drawPath(_rightCover, stroke);

    final (scaleX, opacity) = _leafAt(progress);
    if (opacity > 0.01) {
      canvas.save();
      // transformOrigin '0% 50%' — the spine, mid-height.
      canvas.translate(12, 12);
      canvas.scale(scaleX == 0 ? 0.0001 : scaleX, 1);
      canvas.translate(-12, -12);
      canvas.drawPath(
        _leaf,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color.withValues(alpha: opacity),
      );
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(BookFlipPainter old) =>
      old.progress != progress || old.color != color;
}
