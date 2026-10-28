import 'dart:math' as math;
import 'dart:typed_data';

import 'icon_input.dart';
import 'resample.dart';

/// Pure geometry + endpoint plan (polar matching). No flutter.

/// Shoelace signed area of a flat point list.
double signedArea(Float64List pts) {
  final n = pts.length ~/ 2;
  var s = 0.0;
  for (var i = 0; i < n; i++) {
    final j = (i + 1) % n;
    s += pts[2 * i] * pts[2 * j + 1] - pts[2 * j] * pts[2 * i + 1];
  }
  return s / 2;
}

/// Mean point of a flat point list.
(double, double) centroid(Float64List pts) {
  final n = pts.length ~/ 2;
  if (n == 0) return (0, 0);
  var x = 0.0, y = 0.0;
  for (var i = 0; i < n; i++) {
    x += pts[2 * i];
    y += pts[2 * i + 1];
  }
  return (x / n, y / n);
}

/// Point-in-polygon (ray cast, wrap-closed).
bool inside(double x, double y, Float64List pts) {
  final n = pts.length ~/ 2;
  var c = false;
  for (var i = 0, j = n - 1; i < n; j = i++) {
    final xi = pts[2 * i], yi = pts[2 * i + 1];
    final xj = pts[2 * j], yj = pts[2 * j + 1];
    if ((yi > y) != (yj > y) &&
        x < (xj - xi) * (y - yi) / (yj - yi + 1e-12) + xi) {
      c = !c;
    }
  }
  return c;
}

/// One matched subpath pair of a flight: centered endpoints + alignment.
class PlanItem {
  final Float64List aC;
  final Float64List bT;
  final double caX, caY, cbX, cbY;
  final double theta;
  final double lnSigma;
  final bool closed;
  final bool hole;
  final int? half;

  const PlanItem({
    required this.aC,
    required this.bT,
    required this.caX,
    required this.caY,
    required this.cbX,
    required this.cbY,
    required this.theta,
    required this.lnSigma,
    required this.closed,
    this.hole = false,
    this.half,
  });
}

class MorphPlan {
  final List<PlanItem> items;
  final int n;

  const MorphPlan(this.items, this.n);
}

(double, double) _procrustes(Float64List aC, Float64List bT) {
  final n = aC.length ~/ 2;
  var cross = 0.0, dot = 0.0, sa = 0.0, sb = 0.0;
  for (var i = 0; i < n; i++) {
    final ax = aC[2 * i], ay = aC[2 * i + 1];
    final bx = bT[2 * i], by = bT[2 * i + 1];
    cross += ax * by - ay * bx;
    dot += ax * bx + ay * by;
    sa += ax * ax + ay * ay;
    sb += bx * bx + by * by;
  }
  if (sa < 1e-9 || sb < 1e-9) return (0, 0);
  final theta = math.atan2(cross, dot);
  final c = math.cos(theta), s = math.sin(theta);
  var dotRA = 0.0;
  for (var i = 0; i < n; i++) {
    final ax = aC[2 * i], ay = aC[2 * i + 1];
    final bx = bT[2 * i], by = bT[2 * i + 1];
    dotRA += (c * ax - s * ay) * bx + (s * ax + c * ay) * by;
  }
  final scale = (dotRA / sa).clamp(1e-4, 1e4);
  final lnSigma = math.log(scale).clamp(-8.0, 8.0);
  return (theta, lnSigma);
}

List<bool> _holes(List<Sampled> ss) {
  final areas = [for (final s in ss) signedArea(s.pts)];
  final res = List<bool>.filled(ss.length, false);
  for (var i = 0; i < ss.length; i++) {
    if (!ss[i].closed) continue;
    var depth = 0;
    final px = ss[i].pts[0], py = ss[i].pts[1];
    for (var j = 0; j < ss.length; j++) {
      if (j == i || !ss[j].closed) continue;
      if (areas[j].abs() > areas[i].abs() * 1.05 && inside(px, py, ss[j].pts)) {
        depth++;
      }
    }
    res[i] = depth.isOdd;
  }
  return res;
}

PlanItem _item(Sampled a, Sampled b, bool holeB, {int? half}) {
  final n = a.pts.length ~/ 2;
  final ca = centroid(a.pts), cb = centroid(b.pts);
  final aC = Float64List(2 * n), bT = Float64List(2 * n);
  for (var i = 0; i < n; i++) {
    aC[2 * i] = a.pts[2 * i] - ca.$1;
    aC[2 * i + 1] = a.pts[2 * i + 1] - ca.$2;
    bT[2 * i] = b.pts[2 * i] - cb.$1;
    bT[2 * i + 1] = b.pts[2 * i + 1] - cb.$2;
  }
  final (theta, lnSigma) = _procrustes(aC, bT);
  return PlanItem(
    aC: aC,
    bT: bT,
    caX: ca.$1,
    caY: ca.$2,
    cbX: cb.$1,
    cbY: cb.$2,
    theta: theta,
    lnSigma: lnSigma,
    closed: a.closed,
    hole: holeB,
    half: half,
  );
}

/// Matches subpaths of two sampled icons into one flight plan.
/// Counts mismatch via overlays: extra src collapse onto the nearest dst,
/// extra dst fly out of the nearest src. Empty side -> pop in/out.
MorphPlan buildPlan(List<Sampled> src, List<Sampled> dst) {
  if (src.isEmpty && dst.isEmpty) return const MorphPlan([], kSamples);
  if (src.isEmpty) {
    return MorphPlan([for (final b in dst) _growItem(b)], kSamples);
  }
  if (dst.isEmpty) {
    return MorphPlan([for (final a in src) _shrinkItem(a)], kSamples);
  }
  final holesA = _holes(src), holesB = _holes(dst);
  final ca = [for (final s in src) centroid(s.pts)];
  final cb = [for (final s in dst) centroid(s.pts)];
  final usedA = List<bool>.filled(src.length, false);
  final usedB = List<bool>.filled(dst.length, false);
  final pairs = <(double, int, int)>[];
  for (var i = 0; i < src.length; i++) {
    for (var j = 0; j < dst.length; j++) {
      var cost = _dist(ca[i], cb[j]);
      if (holesA[i] != holesB[j]) cost += 1e6;
      if (src[i].closed != dst[j].closed) cost += 1e3;
      pairs.add((cost, i, j));
    }
  }
  pairs.sort((x, y) => x.$1.compareTo(y.$1));
  final dstOf = List<List<int>>.generate(src.length, (_) => []);
  for (final (_, i, j) in pairs) {
    if (!usedA[i] && !usedB[j]) {
      dstOf[i].add(j);
      usedA[i] = true;
      usedB[j] = true;
    }
  }
  for (var j = 0; j < dst.length; j++) {
    if (usedB[j]) continue;
    var best = 0;
    var bd = double.infinity;
    for (var i = 0; i < src.length; i++) {
      final d = _dist(ca[i], cb[j]);
      if (d < bd) {
        bd = d;
        best = i;
      }
    }
    dstOf[best].add(j);
    usedB[j] = true;
  }
  for (var i = 0; i < src.length; i++) {
    if (usedA[i] || dstOf[i].isNotEmpty) continue;
    var best = -1;
    var bd = double.infinity;
    for (var j = 0; j < dst.length; j++) {
      if (!usedB[j]) continue;
      final d = _dist(ca[i], cb[j]);
      if (d < bd) {
        bd = d;
        best = j;
      }
    }
    if (best < 0) best = 0;
    dstOf[i].add(best);
    usedA[i] = true;
  }
  final items = <PlanItem>[];
  for (var i = 0; i < src.length; i++) {
    for (final j in dstOf[i]) {
      items.add(_item(src[i], dst[j], holesB[j]));
    }
  }
  return MorphPlan(items, kSamples);
}

/// One subpath shrinking into its own centroid (empty dst side).
PlanItem _shrinkItem(Sampled a) {
  final it = _item(a, a, false);
  return PlanItem(
    aC: it.aC,
    bT: Float64List(it.bT.length),
    caX: it.caX,
    caY: it.caY,
    cbX: it.caX,
    cbY: it.caY,
    theta: 0,
    lnSigma: 0,
    closed: it.closed,
    hole: it.hole,
  );
}

/// One subpath growing out of its own centroid (empty src side).
PlanItem _growItem(Sampled b) {
  final it = _item(b, b, false);
  return PlanItem(
    aC: Float64List(it.aC.length),
    bT: it.bT,
    caX: it.cbX,
    caY: it.cbY,
    cbX: it.cbX,
    cbY: it.cbY,
    theta: 0,
    lnSigma: 0,
    closed: it.closed,
    hole: it.hole,
  );
}

double _dist((double, double) a, (double, double) b) {
  final dx = a.$1 - b.$1, dy = a.$2 - b.$2;
  return math.sqrt(dx * dx + dy * dy);
}
