import 'driver.dart';
import 'icon_input.dart';
import 'interpolate.dart';
import 'normalize.dart';
import 'parse.dart';
import 'plan.dart';
import 'region.dart';
import 'surface.dart';

/// Binding controller port: the lifecycle contract as framework-neutral
/// code (lazy driver, controlled wins, clean re-entry).

/// Mode-deciding props, shared by every binding surface.
class MorphProps {
  final MorphIconInput? icon;
  final MorphIconInput? from;
  final MorphIconInput? to;
  final double? progress;
  final ReducedMotionMode? reducedMotion;

  /// Stroke width on the 24 grid: what a stroke icon is outlined at when
  /// it morphs with a fill icon.
  final double? strokeWidth;

  /// SpringPreset | SpringOpts | null.
  final Object? spring;

  const MorphProps({
    this.icon,
    this.from,
    this.to,
    this.progress,
    this.reducedMotion,
    this.strokeWidth,
    this.spring,
  });
}

/// The endpoint a frozen controlled pair renders at rest at `t`, or null
/// mid-way for a stroke pair. A pair with a fill endpoint rests on `from`.
MorphIconInput? frozenEnd(MorphIconInput from, MorphIconInput to, double t) {
  if (t >= 1) return to;
  if (t <= 0 || paintOf(from) == 'fill' || paintOf(to) == 'fill') return from;
  return null;
}

/// Frozen d of the from->to pair at t (pure core, no driver). Exact
/// endpoints return the canonical d.
String _frozenD(MorphIconInput from, MorphIconInput to, double t) {
  final end = frozenEnd(from, to, t);
  if (end != null) return canonicalD(end);
  final plan = buildPlan(sampledOf(from), sampledOf(to));
  final out = allocOutputs(plan);
  interpPolar(plan, t, out);
  return serialize(out, [for (final it in plan.items) it.closed]);
}

/// Initial d, constant per mount (server/client produce the same string).
String initialD(MorphProps p) {
  if (p.from != null && p.to != null) {
    return _frozenD(p.from!, p.to!, p.progress ?? 0);
  }
  final first = p.icon ?? p.from ?? p.to;
  return first != null ? canonicalD(first) : '';
}

/// Paint attributes of the initial path, a constant like the initial d.
Map<String, String>? initialPaint(MorphProps p) {
  if (p.from != null && p.to != null) {
    final t = p.progress ?? 0;
    final end = frozenEnd(p.from!, p.to!, t);
    return restAttrs(end ?? (t < 0.5 ? p.from! : p.to!));
  }
  return restAttrs(p.icon ?? p.from ?? p.to);
}

/// Per-instance controller: mount / watch / imperative, all change
/// detection here. Lifecycle contract:
/// - lazy: an iconless mount births the driver on the first icon;
///   morphTo with no driver behaves as set.
/// - controlled wins: a full from+to pair owns the path, icon ignored;
///   dropping the pair hands the path back to icon.
/// - every exit from controlled mode invalidates the frozen pair.
class MorphIconController {
  final MotionProbe? motionProbe;

  MorphSurface? _el;
  bool _dead = false;
  Morph? _morph;
  ReducedMotionMode _rm = ReducedMotionMode.never;
  double _sw = 2;
  bool _based = false;
  (MorphIconInput, MorphIconInput)? _pair;
  MorphIconInput? _prevIcon;
  bool _prevControlled;
  MorphIconInput? _prevFrom;
  MorphIconInput? _prevTo;
  double? _prevProgress;

  MorphIconController(MorphProps props, {this.motionProbe})
    : _prevIcon = props.icon,
      _prevControlled = props.from != null && props.to != null,
      _prevFrom = props.from,
      _prevTo = props.to,
      _prevProgress = props.progress {
    _rm = props.reducedMotion ?? _rm;
    _sw = props.strokeWidth ?? _sw;
  }

  Morph? get morph => _morph;
  MorphSurface? get surface => _el;
  double get progress => _morph?.progress ?? 1;

  /// Mount: births the driver (lazy when no icon), seeds the controlled
  /// pair. Does not fire the watch baselines (seeded at construction).
  void attach(MorphSurface el, MorphProps props) {
    _el = el;
    if (props.reducedMotion != null) _rm = props.reducedMotion!;
    _sw = props.strokeWidth ?? _sw;
    final controlled = props.from != null && props.to != null;
    final initial = props.icon ?? props.from ?? props.to;
    if (initial == null) return;
    final m = createMorph(
      el,
      controlled ? props.from! : initial,
      reducedMotion: _rm,
      strokeWidth: _sw,
      motionProbe: motionProbe,
    );
    _morph = m;
    if (controlled) {
      _pair = (props.from!, props.to!);
      final t = props.progress ?? 0;
      if (t <= 0) {
        m.set(props.from!);
      } else if (t >= 1) {
        m.set(props.to!);
      } else {
        m.seek(props.to!, t);
        _based = true;
      }
    }
  }

  void detach() {
    _dead = true;
    _el = null;
    _morph?.destroy();
    _morph = null;
    _based = false;
    _pair = null;
  }

  /// Prop watcher: one owner decides per run — the controlled pair while
  /// fully present, icon otherwise. Same-prop runs are no-ops.
  void update(MorphProps p) {
    _rm = p.reducedMotion ?? ReducedMotionMode.never;
    _sw = p.strokeWidth ?? 2;
    final m = _morph;
    if (m != null) {
      m.reducedMotion = _rm;
      m.strokeWidth = _sw;
    }
    final controlled = p.from != null && p.to != null;
    final left = _prevControlled && !controlled;
    final iconChanged = p.icon != _prevIcon;
    final pairChanged =
        p.from != _prevFrom || p.to != _prevTo || p.progress != _prevProgress;
    _prevControlled = controlled;
    _prevIcon = p.icon;
    _prevFrom = p.from;
    _prevTo = p.to;
    _prevProgress = p.progress;
    if (controlled) {
      if (!pairChanged) return;
      final morph = _morph ?? _ensure(p.from!);
      if (morph == null) return;
      _applyPair(p.from!, p.to!, p.progress);
      return;
    }
    if (p.icon == null || (!iconChanged && !left)) return;
    _pair = null;
    _based = false;
    if (_morph != null) {
      _morph!.morphTo(p.icon!, p.spring);
    } else {
      _ensure(p.icon!);
    }
  }

  void _applyPair(MorphIconInput from, MorphIconInput to, double? progress) {
    final m = _morph;
    if (m == null) return;
    final t = progress ?? 0;
    final changed = _pair == null || _pair!.$1 != from || _pair!.$2 != to;
    if (changed) {
      _pair = (from, to);
      _based = false;
    }
    if (t <= 0) {
      m.set(from);
      _based = false;
    } else if (t >= 1) {
      m.set(to);
      _based = false;
    } else {
      if (!_based) {
        m.set(from);
        _based = true;
      }
      m.seek(to, t);
    }
  }

  Morph? _ensure(MorphIconInput birth) {
    if (_morph != null) return _morph;
    if (_dead || _el == null) return null;
    _morph = createMorph(
      _el!,
      birth,
      reducedMotion: _rm,
      strokeWidth: _sw,
      motionProbe: motionProbe,
    );
    return _morph;
  }

  /// Imperative flight; no driver yet = set (nothing to fly from).
  void morphTo(MorphIconInput icon, [Object? spring]) {
    _pair = null;
    _based = false;
    if (_morph != null) {
      _morph!.morphTo(icon, spring);
    } else {
      _ensure(icon);
    }
  }

  void set(MorphIconInput icon) {
    _pair = null;
    _based = false;
    if (_morph != null) {
      _morph!.set(icon);
    } else {
      _ensure(icon);
    }
  }
}
