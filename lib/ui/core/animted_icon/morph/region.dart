import 'dart:async';

import 'icon_input.dart';
import 'plan.dart';

/// Paint classification + the pluggable fill-region solver seam.

bool painted(String? v) {
  if (v == null) return false;
  final t = v.trim();
  return t.isNotEmpty && t != 'none';
}

/// 'stroke' | 'fill' for an icon: raw path data is stroke; a shape is
/// stroke when some element strokes and none fills (fill attr or default).
String paintOf(MorphIconInput icon) {
  if (icon is SvgD) return 'stroke';
  var stroke = false, fill = false;
  for (final el in (icon as ShapeIcon).elements) {
    final s = painted(el.stroke);
    final f = painted(el.fill) || (el.fill == null && !s);
    if (s) stroke = true;
    if (f) fill = true;
  }
  return stroke && !fill ? 'stroke' : 'fill';
}

/// Exact fill-region solver (lazy chunk in the ts source). When registered,
/// fill icons morph through exact unions; when not, flights fall back to
/// the pop flight (shrink/grow).
abstract class RegionSolver {
  MorphIconInput regionOf(MorphIconInput icon, double strokeWidth);
  MorphPlan regionPlan(
    MorphIconInput from,
    MorphIconInput to,
    double strokeWidth,
  );
  MorphPlan regionPlanFrom(String d, MorphIconInput to, double strokeWidth);
}

typedef RegionLoader = Future<RegionSolver?> Function();

RegionLoader? _loader;
RegionSolver? _module;
Future<RegionSolver?>? _loading;
DateTime _since = DateTime.fromMillisecondsSinceEpoch(0);
bool _failed = false;
int _gen = 0;

RegionSolver? get regionModule => _module;
bool get regionFailed => _failed;
bool get regionLoading => _loading != null;
DateTime get regionSince => _since;
RegionLoader? get regionLoader => _loader;

/// Replaces how the region solver is produced (null = never load; fill
/// morphs take the pop fallback). Next need loads through the new loader.
void setRegionLoader(RegionLoader? loader) {
  _loader = loader;
  _gen++;
  _loading = null;
  _module = null;
  _failed = false;
}

/// Starts (or joins) loading the solver. Failures are not cached: the next
/// need retries. Resolves null when no loader is set.
Future<RegionSolver?> preloadRegion() {
  final m = _module;
  if (m != null) return Future.value(m);
  if (_loader == null) return Future.value(null);
  final loading = _loading;
  if (loading != null) return loading;
  _since = DateTime.now();
  final gen = _gen;
  final f = _loader!().then(
    (m) {
      if (gen == _gen) _module = m;
      return m;
    },
    onError: (Object e) {
      if (gen == _gen) {
        _loading = null;
        _failed = true;
      }
      throw e;
    },
  );
  _loading = f;
  return f;
}
