import 'dart:math' as math;
import 'dart:typed_data';

import 'plan.dart';

/// Output buffers: one per plan item, 2n values each.
List<Float64List> allocOutputs(MorphPlan plan) =>
    List.generate(plan.items.length, (_) => Float64List(2 * plan.n));

/// Polar interpolation at `t` into `out` (same shape as [allocOutputs]).
/// Per item: centroid lerp + progressive rotation/scale toward each other.
/// `half` items run compressed: 0 over t 0..0.5, 1 over t 0.5..1.
void interpPolar(MorphPlan plan, double t, List<Float64List> out) {
  final n = plan.n;
  for (var k = 0; k < plan.items.length && k < out.length; k++) {
    final it = plan.items[k];
    final o = out[k];
    final half = it.half;
    var tl = half == null ? t : (half == 0 ? 2 * t : 2 * t - 1);
    tl = tl.clamp(0.0, 1.0);
    final rot = it.theta * tl;
    final rotB = -it.theta * (1 - tl);
    final sc = math.exp(it.lnSigma * tl);
    final scB = math.exp(-it.lnSigma * (1 - tl));
    final cr = math.cos(rot), sr = math.sin(rot);
    final crB = math.cos(rotB), srB = math.sin(rotB);
    final cx = it.caX + (it.cbX - it.caX) * tl;
    final cy = it.caY + (it.cbY - it.caY) * tl;
    for (var i = 0; i < n; i++) {
      final ax = it.aC[2 * i], ay = it.aC[2 * i + 1];
      final rax = sc * (cr * ax - sr * ay);
      final ray = sc * (sr * ax + cr * ay);
      final bx = it.bT[2 * i], by = it.bT[2 * i + 1];
      final rbx = scB * (crB * bx - srB * by);
      final rby = scB * (srB * bx + crB * by);
      o[2 * i] = cx + rax + (rbx - rax) * tl;
      o[2 * i + 1] = cy + ray + (rby - ray) * tl;
    }
  }
}
