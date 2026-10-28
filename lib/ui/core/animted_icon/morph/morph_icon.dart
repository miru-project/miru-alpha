import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path_drawing/path_drawing.dart';

import 'controller.dart';
import 'driver.dart';
import 'icon_input.dart';
import 'surface.dart';

/// Declarative morphing icon on the 24 grid.
///
/// - `icon`: current icon; a change flies to it (spring).
/// - `from` + `to` + `progress`: controlled pair, path frozen at `progress`
///   (scrubbing); while the pair is full, `icon` is ignored.
/// - `spring`: SpringPreset or SpringOpts for `icon` flights.
class MorphIcon extends HookWidget {
  final MorphIconInput? icon;
  final MorphIconInput? from;
  final MorphIconInput? to;
  final double? progress;
  final Object? spring;
  final ReducedMotionMode reducedMotion;

  /// Stroke width on the 24 grid for stroke<->fill morphs.
  final double strokeWidth;
  final double size;
  final Color? color;

  /// Once per mount: the instance handle (imperative morphTo/set, surface).
  final void Function(MorphIconController controller)? onController;

  const MorphIcon({
    super.key,
    this.icon,
    this.from,
    this.to,
    this.progress,
    this.spring,
    this.reducedMotion = ReducedMotionMode.never,
    this.strokeWidth = 2,
    this.size = 24,
    this.color,
    this.onController,
  });

  MorphProps _props(bool osReduce) => MorphProps(
    icon: icon,
    from: from,
    to: to,
    progress: progress,
    reducedMotion: reducedMotion == ReducedMotionMode.never && osReduce
        ? ReducedMotionMode.user
        : reducedMotion,
    strokeWidth: strokeWidth,
    spring: spring,
  );

  @override
  Widget build(BuildContext context) {
    final surface = useMemoized(MorphSurface.new);
    final osReduce = MediaQuery.disableAnimationsOf(context);
    final controller = useMemoized(() {
      final c = MorphIconController(
        _props(osReduce),
        motionProbe: () => osReduce,
      );
      c.attach(surface, _props(osReduce));
      onController?.call(c);
      return c;
    }, [surface]);
    useEffect(
      () {
        controller.update(_props(osReduce));
        return null;
      },
      [icon, from, to, progress, spring, reducedMotion, strokeWidth, osReduce],
    );
    useEffect(() => controller.detach, const []);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MorphPainter(
          surface: surface,
          color: color ?? Colors.black,
          size: size,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _MorphPainter extends CustomPainter {
  final MorphSurface surface;
  final Color color;
  final double size;
  final double strokeWidth;

  _MorphPainter({
    required this.surface,
    required this.color,
    required this.size,
    required this.strokeWidth,
  }) : super(repaint: surface);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (surface.d.isEmpty) return;
    var path = parseSvgPathData(surface.d);
    final scale = size / 24;
    if (scale != 1) {
      path = path.transform(Matrix4.diagonal3Values(scale, scale, 1).storage);
    }
    final a = surface.attrs;
    final fill = a['fill'] == 'currentColor';
    // unattributed surface = stroke icon default (svg stroke inherit)
    final stroke = a['stroke'] == 'inherit' || a.isEmpty;
    if (fill) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..isAntiAlias = true,
      );
    }
    if (stroke) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * scale
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true,
      );
    }
  }

  @override
  bool shouldRepaint(_MorphPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.size != size ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.surface != surface;
}
