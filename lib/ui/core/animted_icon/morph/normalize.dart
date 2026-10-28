import 'dart:typed_data';

import 'icon_input.dart';
import 'parse.dart';
import 'plan.dart';
import 'region.dart';
import 'resample.dart';

/// Icon -> cubics / samples / canonical d, with caches by icon identity.

final Expando<List<Sampled>> _samples = Expando('morph.samples');
final Expando<String> _canon = Expando('morph.canon');
final Expando<String> _looks = Expando('morph.looks');

/// Flat point list of a cubic chain: [start, c1, c2, end, ...].
Float64List cubicPoints(CubicPath p) {
  final m = p.segments;
  final out = Float64List(2 * (m * 3 + 1));
  out[0] = p.sx;
  out[1] = p.sy;
  var w = 2;
  for (var i = 0; i < m; i++) {
    final o = i * 6;
    for (var k = 0; k < 3; k++) {
      out[w++] = p.pts[o + 2 * k];
      out[w++] = p.pts[o + 2 * k + 1];
    }
  }
  return out;
}

double _areaOf(CubicPath p) => signedArea(cubicPoints(p));

/// The cubics of an icon. Fill icons are wound for ONE nonzero path: each
/// evenodd element's subpaths by nesting depth, each nonzero element
/// positive as a whole (overlapping elements add up).
List<CubicPath> cubicsOf(MorphIconInput icon) {
  if (icon is SvgD) return parsePath(icon.d);
  final els = (icon as ShapeIcon).elements;
  if (paintOf(icon) == 'stroke') {
    return [for (final el in els) ...parsePath(el.d)];
  }
  return [
    for (final el in els)
      ..._wound(parsePath(el.d), el.fillRule?.trim() == 'evenodd'),
  ];
}

List<CubicPath> _wound(List<CubicPath> ps, bool evenodd) {
  var sum = 0.0;
  final areas = [for (final p in ps) _areaOf(p)];
  for (final a in areas) {
    sum += a;
  }
  for (var k = 0; k < ps.length; k++) {
    var flip = sum < 0;
    if (evenodd) {
      var pos = true;
      final px = ps[k].sx, py = ps[k].sy;
      for (var j = 0; j < ps.length; j++) {
        if (j == k) continue;
        if (inside(px, py, cubicPoints(ps[j]))) pos = !pos;
      }
      flip = (areas[k] > 0) != pos;
    }
    if (flip) ps[k] = reverseCubics(ps[k]);
  }
  return ps;
}

List<Sampled> _sample(List<CubicPath> ps) => [
  for (final p in ps) Sampled(resamplePath(p, kSamples), closed: p.closed),
];

/// 64-point-per-subpath samples of an icon (strings re-derived, shapes
/// cached by identity).
List<Sampled> sampledOf(MorphIconInput icon) {
  if (icon is SvgD) return _sample(parsePath(icon.d));
  var s = _samples[icon];
  if (s == null) {
    s = _sample(cubicsOf(icon));
    _samples[icon] = s;
  }
  return s;
}

/// Canonical `d`: input string verbatim, else real cubics quantized to 4
/// decimals (the at-rest snap; engine-stable bytes).
String canonicalD(MorphIconInput icon) {
  if (icon is SvgD) return icon.d;
  var d = _canon[icon];
  if (d == null) {
    d = cubicsToPathD(cubicsOf(icon));
    _canon[icon] = d;
  }
  return d;
}

/// Paint attributes per look: stroke inherits the parent's stroke; fills
/// are nonzero always (cubicsOf wound them for it).
Map<String, String> paintAttrs(String look) => switch (look) {
  'stroke' => {'fill': 'none', 'stroke': 'inherit'},
  'fill' => {'fill': 'currentColor', 'stroke': 'none', 'fill-rule': 'nonzero'},
  _ => {'fill': 'currentColor', 'stroke': 'inherit', 'fill-rule': 'nonzero'},
};

/// The look a fill icon rests on before an exact region solver exists:
/// filled only -> fill; filled+stroked -> both; stroke-only elements win
/// when they enclose clearly more area than the filled ones.
String restLook(MorphIconInput icon) {
  if (icon is SvgD || paintOf(icon) == 'stroke') return 'stroke';
  final cached = _looks[icon];
  if (cached != null) return cached;
  var look = 'fill';
  var filled = 0.0, enclosed = -1.0;
  for (final el in (icon as ShapeIcon).elements) {
    final s = painted(el.stroke);
    final f = painted(el.fill) || (el.fill == null && !s);
    if (s) look = 'both';
    var a = 0.0;
    for (final p in parsePath(el.d)) {
      a += _areaOf(p).abs();
    }
    if (f) {
      filled += a;
    } else if (s) {
      enclosed = enclosed < 0 ? a : enclosed + a;
    }
  }
  if (enclosed > 1.5 * filled) look = 'stroke';
  _looks[icon] = look;
  return look;
}

/// Paint attrs a binding renders with the first icon (SSR included);
/// null for stroke icons (they inherit as always).
Map<String, String>? restAttrs(MorphIconInput? icon) {
  if (icon == null || paintOf(icon) == 'stroke') return null;
  return paintAttrs(restLook(icon));
}
