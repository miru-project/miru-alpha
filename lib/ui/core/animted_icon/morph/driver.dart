import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/scheduler.dart';

import 'icon_input.dart';
import 'interpolate.dart';
import 'normalize.dart';
import 'parse.dart';
import 'plan.dart';
import 'region.dart' as region;
import 'resample.dart';
import 'spring.dart';
import 'surface.dart';

/// DOM driver port: createMorph over a MorphSurface — one rAF (ticker) for
/// all instances, controlled seeks, spring flights, region-chunk budget
/// with a pop fallback.

enum ReducedMotionMode { never, user, always }

/// OS reduce-motion probe (widget wires MediaQuery.disableAnimationsOf).
typedef MotionProbe = bool Function();

/// Imperative surface of a driver instance.
abstract class Morph {
  /// Flies toward `icon` with spring physics; interruptible, velocity kept.
  void morphTo(MorphIconInput icon, [Object? spring]);

  /// Jumps to the icon (canonical d, no frames).
  void set(MorphIconInput icon);

  /// Renders the morph toward `icon` frozen at `t` (no spring).
  void seek(MorphIconInput icon, double t);

  /// Progress of the last frame; 1 at rest. Assigning = seek(target, v).
  double get progress;
  set progress(double v);

  ReducedMotionMode get reducedMotion;
  set reducedMotion(ReducedMotionMode v);

  /// Stroke width (24 grid) outlining stroke icons in stroke<->fill morphs.
  double get strokeWidth;
  set strokeWidth(double v);

  void destroy();
}

/// Creates the driver over `el`, painting the initial icon.
Morph createMorph(
  MorphSurface el,
  MorphIconInput icon, {
  ReducedMotionMode? reducedMotion,
  double? strokeWidth,
  MotionProbe? motionProbe,
}) => _Driver(el, icon, reducedMotion, strokeWidth, motionProbe);

// ---------------------------------------------------------------------------
// Singleton scheduler: a Set of tickers, one live Ticker while any exist.
// dt in seconds clamped to 0.1; first frame after start gets dt = 0.

typedef _TickFn = void Function(double dt);

final Set<_TickFn> _tickers = {};
Ticker? _ticker;
Duration? _prev;

void _onTick(Duration elapsed) {
  final prev = _prev;
  _prev = elapsed;
  final dt = prev == null
      ? 0.0
      : ((elapsed - prev).inMicroseconds / 1e6).clamp(0.0, 0.1);
  for (final t in _tickers.toList(growable: false)) {
    t(dt);
  }
}

void _addTicker(_TickFn fn) {
  _tickers.add(fn);
  _ticker ??= Ticker(_onTick)..start();
}

void _removeTicker(_TickFn fn) {
  _tickers.remove(fn);
  if (_tickers.isEmpty && _ticker != null) {
    _ticker!.stop();
    _ticker = null;
    _prev = null;
  }
}

// ---------------------------------------------------------------------------
// Caches by identity. Strings re-derived; plans cached per (src, dst) pair.
// Plans from intermediate shapes are never cached.

final Expando<Map<MorphIconInput, MorphPlan>> _plans = Expando('morph.plans');

/// Elements a driver painted (a driver born on one writes its own attrs).
final Expando<bool> _paintedEls = Expando('morph.paintedEls');

MorphPlan _planBetween(MorphIconInput src, MorphIconInput dst) {
  if (src is SvgD || dst is SvgD) {
    return buildPlan(sampledOf(src), sampledOf(dst));
  }
  var inner = _plans[src];
  if (inner == null) {
    inner = {};
    _plans[src] = inner;
  }
  var p = inner[dst];
  if (p == null) {
    p = buildPlan(sampledOf(src), sampledOf(dst));
    inner[dst] = p;
  }
  return p;
}

/// How long a morph waits for the region solver before flying the fallback.
const int kRegionWaitMs = 100;

/// Fallback flight: old shape shrinks into its centroid on the first half,
/// the new one grows out of its own on the second.
MorphPlan _popPlan(List<Sampled> from, List<Sampled> to) {
  final n = kSamples;
  PlanItem item(Sampled s, int half) {
    var pts = s.pts;
    if (pts.length > 2 * n) {
      final dec = Float64List(2 * n);
      var w = 0;
      for (var i = 0; i + 1 < pts.length && w + 1 < dec.length; i += 4) {
        dec[w++] = pts[i];
        dec[w++] = pts[i + 1];
      }
      pts = dec;
    }
    final c = centroid(pts);
    final m = pts.length ~/ 2;
    final p = Float64List(2 * n);
    for (var i = 0; i < m && 2 * i + 1 < 2 * n; i++) {
      p[2 * i] = pts[2 * i] - c.$1;
      p[2 * i + 1] = pts[2 * i + 1] - c.$2;
    }
    final aC = Float64List(2 * n), bT = Float64List(2 * n);
    (half == 0 ? aC : bT).setAll(0, p);
    return PlanItem(
      aC: aC,
      bT: bT,
      caX: c.$1,
      caY: c.$2,
      cbX: c.$1,
      cbY: c.$2,
      theta: 0,
      lnSigma: 0,
      closed: s.closed,
      hole: s.hole,
      half: half,
    );
  }

  return MorphPlan([
    ...from.map((s) => item(s, 0)),
    ...to.map((s) => item(s, 1)),
  ], n);
}

class _Driver implements Morph {
  final MorphSurface el;
  final MotionProbe? motionProbe;

  final Spring spring = Spring();
  late ReducedMotionMode _reducedMotion;
  late double _strokeWidth;
  late MorphIconInput _target;
  bool _rest = true;
  MorphPlan? _plan;
  List<Float64List>? _out;
  List<bool>? _closed;
  double _t = 1;
  bool _flying = false;
  bool _dead = false;
  bool _regionFlight = false;
  bool _drawn = false;
  Object? _pending;
  String _paint = 'stroke';
  bool _known = false;
  int _split = 0;
  String _popFrom = 'stroke';
  MorphIconInput? _popBase;
  late final void Function(double) _tickFn;

  _Driver(
    this.el,
    MorphIconInput icon,
    ReducedMotionMode? reducedMotion,
    double? strokeWidth,
    this.motionProbe,
  ) {
    _reducedMotion = reducedMotion ?? ReducedMotionMode.never;
    _strokeWidth = strokeWidth ?? 2;
    _target = icon;
    _known = _paintedEls[el] != true;
    _tickFn = _tick;
    _paintRest(icon);
    if (region.paintOf(icon) == 'fill' &&
        region.regionModule == null &&
        region.regionLoader != null) {
      _upgrade(region.preloadRegion());
    }
  }

  void _paintAs(String p) {
    if (p == _paint && _known) return;
    el.attrs.addAll(paintAttrs(p));
    _paint = p;
    _known = true;
    _paintedEls[el] = true;
  }

  void _paintRest(MorphIconInput ic) {
    final mod = region.regionModule;
    final r = mod != null && region.paintOf(ic) == 'fill'
        ? mod.regionOf(ic, _strokeWidth)
        : ic;
    el.setAttribute('d', canonicalD(r));
    _paintAs(restLook(r));
  }

  void _upgrade(Future<region.RegionSolver?> load) {
    final icon = _target;
    load.then((_) {
      if (!_dead && _rest && _target == icon && _pending == null) {
        _paintRest(icon);
      }
    }, onError: (Object e) {});
  }

  (int, int) _shown(double tt) => _split == 0
      ? (0, _plan?.items.length ?? 0)
      : tt < 0.5
      ? (0, _split)
      : (_split, _plan?.items.length ?? 0);

  void _render(double tt) {
    final p = _plan, o = _out, cl = _closed;
    if (p == null || o == null || cl == null) return;
    _t = tt;
    interpPolar(p, tt, o);
    _drawn = true;
    final (lo, hi) = _shown(tt);
    if (_split != 0) {
      _paintAs(tt < 0.5 ? _popFrom : restLook(_target));
    }
    el.setAttribute('d', serialize(o.sublist(lo, hi), cl.sublist(lo, hi)));
  }

  void _stop() {
    if (!_flying) return;
    _flying = false;
    _removeTicker(_tickFn);
  }

  void _tick(double dt) {
    final settled = spring.step(dt);
    _render(spring.x);
    if (settled) {
      _stop();
      _settle();
    }
  }

  void _settle() {
    _rest = true;
    _plan = null;
    _out = null;
    _closed = null;
    _t = 1;
    spring.x = 1;
    spring.v = 0;
    _regionFlight = false;
    _split = 0;
    _paintRest(_target);
    if (region.paintOf(_target) == 'fill' &&
        region.regionModule == null &&
        (region.regionLoading || !region.regionFailed) &&
        region.regionLoader != null) {
      _upgrade(region.preloadRegion());
    }
  }

  List<Sampled> _snapshot() {
    final p = _plan, o = _out;
    if (_rest || p == null || o == null) return sampledOf(_target);
    final (lo, hi) = _shown(_t);
    return [
      for (var k = lo; k < hi; k++)
        Sampled(
          Float64List.fromList(o[k]),
          closed: p.items[k].closed,
          hole: p.items[k].hole,
        ),
    ];
  }

  bool _needsRegion(MorphIconInput icon) =>
      (!_rest && _regionFlight) ||
      region.paintOf(icon) == 'fill' ||
      region.paintOf(_target) == 'fill';

  void _retarget(MorphIconInput icon, bool pop) {
    if (!_rest && _plan != null && _out != null && !_drawn) {
      _t = 0;
      interpPolar(_plan!, 0, _out!);
    }
    if (pop || (!_rest && _split != 0)) {
      final from = _snapshot();
      _popBase = _rest ? _target : null;
      _popFrom = _paint;
      _plan = _popPlan(from, sampledOf(icon));
      _split = from.length;
      _regionFlight = false;
    } else if (_needsRegion(icon)) {
      final mod = region.regionModule!;
      _plan = (_rest || _out == null)
          ? mod.regionPlan(_target, icon, _strokeWidth)
          : mod.regionPlanFrom(serialize(_out!, _closed), icon, _strokeWidth);
      _regionFlight = true;
      _split = 0;
      _paintAs('fill');
    } else {
      _plan = _rest
          ? _planBetween(_target, icon)
          : buildPlan(_snapshot(), sampledOf(icon));
      _regionFlight = false;
    }
    _out = allocOutputs(_plan!);
    _drawn = false;
    _closed = [for (final it in _plan!.items) it.closed];
    _target = icon;
    _rest = false;
  }

  bool _whenRegion(
    MorphIconInput icon,
    void Function() run,
    void Function() fallback,
  ) {
    if (region.regionModule != null ||
        (!_rest && _split != 0) ||
        !_needsRegion(icon)) {
      return false;
    }
    final req = Object();
    _pending = req;
    void give() {
      if (_dead || _pending != req) return;
      _pending = null;
      fallback();
    }

    if (region.regionLoader == null) {
      give();
      return true;
    }
    final load = region.preloadRegion();
    final waited = DateTime.now().difference(region.regionSince).inMilliseconds;
    if (waited > kRegionWaitMs) {
      give();
      return true;
    }
    final timer = Timer(Duration(milliseconds: kRegionWaitMs - waited), give);
    load.then(
      (m) {
        timer.cancel();
        if (_dead || _pending != req) return;
        _pending = null;
        if (m == null) {
          give();
        } else {
          run();
        }
      },
      onError: (Object e) {
        timer.cancel();
        give();
      },
    );
    return true;
  }

  void _setNow(MorphIconInput icon) {
    _stop();
    _pending = null;
    _target = icon;
    _settle();
  }

  bool _motionOff() {
    if (_reducedMotion == ReducedMotionMode.always) return true;
    if (_reducedMotion != ReducedMotionMode.user) return false;
    return motionProbe?.call() ?? false;
  }

  @override
  void seek(MorphIconInput icon, double t) => _seek(icon, t);

  void _seek(MorphIconInput icon, double tt, [bool pop = false]) {
    if (_dead) return;
    if (!pop &&
        _whenRegion(icon, () => _seek(icon, tt), () => _seek(icon, tt, true))) {
      return;
    }
    _pending = null;
    var reuse = !_rest && _plan != null && icon == _target;
    if (reuse &&
        _split != 0 &&
        region.regionModule != null &&
        _popBase != null) {
      _target = _popBase!;
      _rest = true;
      reuse = false;
    }
    _stop();
    spring.v = 0;
    if (!reuse) _retarget(icon, pop);
    _render(tt);
  }

  void _fly(MorphIconInput icon, Object? sp, bool pop) {
    if (_dead) return;
    if (icon == _target && (_rest || _flying)) {
      _pending = null;
      return;
    }
    if (_motionOff()) {
      _setNow(icon);
      return;
    }
    if (!pop &&
        _whenRegion(
          icon,
          () => _fly(icon, sp, false),
          () => _fly(icon, sp, true),
        )) {
      return;
    }
    _pending = null;
    final (k, c) = resolveSpring(sp);
    spring.config(k, c);
    _retarget(icon, pop);
    spring.start();
    if (!_flying) {
      _flying = true;
      _addTicker(_tickFn);
    }
  }

  @override
  void morphTo(MorphIconInput icon, [Object? spring]) =>
      _fly(icon, spring, false);

  @override
  void set(MorphIconInput icon) {
    if (_dead) return;
    _setNow(icon);
  }

  @override
  double get progress => _rest ? 1 : _t;

  @override
  set progress(double v) {
    if (!_dead) _seek(_target, v);
  }

  @override
  ReducedMotionMode get reducedMotion => _reducedMotion;

  @override
  set reducedMotion(ReducedMotionMode v) => _reducedMotion = v;

  @override
  double get strokeWidth => _strokeWidth;

  @override
  set strokeWidth(double v) => _strokeWidth = v;

  @override
  void destroy() {
    _stop();
    _dead = true;
    _pending = null;
    _plan = null;
    _out = null;
    _closed = null;
  }
}
