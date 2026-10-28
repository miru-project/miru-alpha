import 'dart:math' as math;

/// Named spring presets for [Morph.morphTo]-style flights.
enum SpringPreset { snappy, gentle, bouncy }

/// Custom spring: stiffness + damping (25-grid units, snappy default).
class SpringOpts {
  final double stiffness;
  final double damping;

  const SpringOpts({required this.stiffness, required this.damping});
}

const Map<SpringPreset, SpringOpts> springPresets = {
  SpringPreset.snappy: SpringOpts(stiffness: 320, damping: 26),
  SpringPreset.gentle: SpringOpts(stiffness: 140, damping: 16),
  SpringPreset.bouncy: SpringOpts(stiffness: 380, damping: 12),
};

/// `SpringPreset | SpringOpts | null` -> (k, c); null = snappy.
(double, double) resolveSpring(Object? s) {
  if (s is SpringPreset) {
    final o = springPresets[s]!;
    return (o.stiffness, o.damping);
  }
  if (s is SpringOpts) return (s.stiffness, s.damping);
  const d = SpringOpts(stiffness: 320, damping: 26);
  return (d.stiffness, d.damping);
}

/// Progress spring: x runs 0 (plan source) -> 1 (target), v preserved on
/// re-plan (interruptible flights keep velocity).
class Spring {
  double x = 1;
  double v = 0;
  double _k = 320;
  double _c = 26;

  static const double _h = 1 / 120;

  void config(double k, double c) {
    _k = k;
    _c = c;
  }

  /// (Re)start from the plan source; velocity carried over.
  void start() {
    x = 0;
  }

  /// One frame; true when settled (x snapped to 1, v zeroed).
  bool step(double dt) {
    if (dt <= 0) return false;
    final steps = (dt / _h).ceil().clamp(1, 24);
    final h = dt / steps;
    for (var i = 0; i < steps; i++) {
      final a = -_k * (x - 1) - _c * v;
      v += a * h;
      x += v * h;
      if ((1 - x).abs() < 0.001 && v.abs() < 0.02) {
        x = 1;
        v = 0;
        return true;
      }
      if (x.isNaN || x.isInfinite) {
        x = 1;
        v = 0;
        return true;
      }
    }
    return false;
  }

  /// Oscillation period estimate (tests: rough settle time bound).
  double get settleSeconds {
    final w0 = math.sqrt(_k);
    final z = _c / (2 * w0);
    if (z >= 1) return 4 / (_c / 2);
    return 4 / (w0 * math.sqrt(1 - z * z));
  }
}
