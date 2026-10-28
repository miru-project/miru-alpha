import 'dart:typed_data';

/// Path element of a [ShapeIcon]: path data + optional paint attrs (24 grid).
class IconEl {
  final String d;
  final String? fill;
  final String? stroke;
  final String? fillRule;

  const IconEl(this.d, {this.fill, this.stroke, this.fillRule});
}

/// What a binding feeds the engine: raw path data or a multi-element shape.
sealed class MorphIconInput {
  const MorphIconInput();
}

/// Raw svg path data; paints as a stroke inheriting the widget color.
class SvgD extends MorphIconInput {
  final String d;

  const SvgD(this.d);
}

/// Multi-element icon; per-element fill/stroke decide the look.
class ShapeIcon extends MorphIconInput {
  final List<IconEl> elements;

  const ShapeIcon(this.elements);
}

/// Cubic bezier chain: start point + `[c1x,c1y,c2x,c2y,x,y]` per segment.
class CubicPath {
  final Float64List pts;
  final double sx, sy;
  final bool closed;

  const CubicPath(this.pts, this.sx, this.sy, {required this.closed});

  int get segments => pts.length ~/ 6;
}

/// Resampled shape: `n` points, flat `[x,y,...]`, arc-length spaced.
class Sampled {
  final Float64List pts;
  final bool closed;
  final bool hole;

  const Sampled(this.pts, {required this.closed, this.hole = false});

  int get n => pts.length ~/ 2;
}
