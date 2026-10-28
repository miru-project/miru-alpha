import 'dart:math' as math;
import 'dart:typed_data';

import 'icon_input.dart';

/// Samples per subpath (flight buffers carry `n` points each).
const int kSamples = 64;

/// Cubic chain -> `n` arc-length equidistant on-curve points (flat pairs).
Float64List resamplePath(CubicPath p, int n) {
  final m = p.segments;
  if (m == 0) return _degenerate(p.sx, p.sy, n);
  // dense flatten: 16 steps per segment
  const steps = 16;
  final dense = Float64List(2 * (m * steps + 1));
  dense[0] = p.sx;
  dense[1] = p.sy;
  var x = p.sx, y = p.sy;
  for (var i = 0; i < m; i++) {
    final o = i * 6;
    final ax = x, ay = y; // segment start
    final c1x = p.pts[o], c1y = p.pts[o + 1];
    final c2x = p.pts[o + 2], c2y = p.pts[o + 3];
    final ex = p.pts[o + 4], ey = p.pts[o + 5];
    for (var k = 1; k <= steps; k++) {
      final t = k / steps;
      final mt = 1 - t;
      final a = mt * mt * mt, b = 3 * mt * mt * t;
      final c = 3 * mt * t * t, d = t * t * t;
      x = a * ax + b * c1x + c * c2x + d * ex;
      y = a * ay + b * c1y + c * c2y + d * ey;
      final w = 2 * (i * steps + k);
      dense[w] = x;
      dense[w + 1] = y;
    }
  }
  final total = m * steps;
  final cum = Float64List(total + 1);
  for (var i = 1; i <= total; i++) {
    final ddx = dense[2 * i] - dense[2 * i - 2];
    final ddy = dense[2 * i + 1] - dense[2 * i - 1];
    cum[i] = cum[i - 1] + math.sqrt(ddx * ddx + ddy * ddy);
  }
  final len = cum[total];
  final out = Float64List(2 * n);
  if (len <= 1e-12) return _degenerate(p.sx, p.sy, n);
  for (var i = 0; i < n; i++) {
    final target = p.closed ? len * i / n : len * i / (n - 1);
    var lo = 1, hi = total;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (cum[mid] < target) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    final t = (target - cum[lo - 1]) / (cum[lo] - cum[lo - 1] + 1e-12);
    out[2 * i] = dense[2 * lo - 2] + t * (dense[2 * lo] - dense[2 * lo - 2]);
    out[2 * i + 1] =
        dense[2 * lo - 1] + t * (dense[2 * lo + 1] - dense[2 * lo - 1]);
  }
  return out;
}

Float64List _degenerate(double x, double y, int n) {
  final out = Float64List(2 * n);
  for (var i = 0; i < n; i++) {
    out[2 * i] = x;
    out[2 * i + 1] = y;
  }
  return out;
}
