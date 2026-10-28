import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:miru_alpha/ui/core/animted_icon/morph/controller.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/driver.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/icon_input.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/interpolate.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/normalize.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/parse.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/plan.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/resample.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/spring.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/surface.dart';

const square = 'M2 2H22V22H2Z';
const squareFar = 'M12 12H32V32H12Z';
const twoSub = 'M2 2H10V10H2ZM14 14H22V22H14Z';
const threeSub = 'M2 2H10V10H2ZM14 14H22V22H14ZM14 2H22V10H14Z';
const ring = 'M2 2H22V22H2ZM8 8H16V16H8Z';

void main() {
  group('parse', () {
    test('subpaths, closure, arcs', () {
      final ps = parsePath(
        'M15 2 H21 A1 1 0 0 1 22 3 V9 A1 1 0 0 1 21 10 H15 '
        'A1 1 0 0 1 14 9 V3 A1 1 0 0 1 15 2 Z',
      );
      expect(ps, hasLength(1));
      expect(ps.first.closed, isTrue);
      final last = ps.first.pts.sublist(ps.first.pts.length - 2);
      expect(last[0], closeTo(15, 1e-6));
      expect(last[1], closeTo(2, 1e-6));
    });

    test('relative + arc endpoint', () {
      final ps = parsePath('M10 22V7c0-.6-.4-1-1-1H4c-1.1 0-2 .9-2 2v12');
      expect(ps, hasLength(1));
      expect(ps.first.closed, isFalse);
      final seg = ps.first.pts;
      expect(seg[seg.length - 2], closeTo(2, 1e-6));
      expect(seg[seg.length - 1], closeTo(20, 1e-6));

      final arc = parsePath('M0 0A5 5 0 0 1 10 0').first;
      final end = arc.pts.sublist(arc.pts.length - 2);
      expect(end[0], closeTo(10, 1e-6));
      expect(end[1], closeTo(0, 1e-6));
    });
  });

  group('resample + serialize', () {
    test('roundtrip keeps geometry', () {
      final src = parsePath(square).first;
      final pts = resamplePath(src, kSamples);
      expect(pts.length, 2 * kSamples);
      final back = parsePath(serialize([pts], [true]));
      expect(back, hasLength(1));
      var minX = 1e9, minY = 1e9, maxX = -1e9, maxY = -1e9;
      final flat = back.first;
      for (var i = 0; i < flat.segments; i++) {
        minX = minX < flat.pts[i * 6 + 4] ? minX : flat.pts[i * 6 + 4];
        maxX = maxX > flat.pts[i * 6 + 4] ? maxX : flat.pts[i * 6 + 4];
        minY = minY < flat.pts[i * 6 + 5] ? minY : flat.pts[i * 6 + 5];
        maxY = maxY > flat.pts[i * 6 + 5] ? maxY : flat.pts[i * 6 + 5];
      }
      expect(minX, closeTo(2, 1.0));
      expect(minY, closeTo(2, 1.0));
      expect(maxX, closeTo(22, 1.0));
      expect(maxY, closeTo(22, 1.0));
    });
  });

  group('plan + interp', () {
    test('exact endpoints', () {
      final a = sampledOf(const SvgD(square));
      final b = sampledOf(const SvgD(squareFar));
      final plan = buildPlan(a, b);
      expect(plan.items, hasLength(1));
      final out = allocOutputs(plan);
      interpPolar(plan, 0, out);
      for (var i = 0; i < out[0].length; i++) {
        expect(out[0][i], closeTo(a[0].pts[i], 1e-9));
      }
      interpPolar(plan, 1, out);
      for (var i = 0; i < out[0].length; i++) {
        expect(out[0][i], closeTo(b[0].pts[i], 1e-9));
      }
    });

    test('count mismatch covers every dst subpath', () {
      final plan = buildPlan(
        sampledOf(const SvgD(twoSub)),
        sampledOf(const SvgD(threeSub)),
      );
      expect(plan.items.length, 3);
      final out = allocOutputs(plan);
      interpPolar(plan, 1, out);
      (double, double) r2((double, double) c) => (
        double.parse(c.$1.toStringAsFixed(1)),
        double.parse(c.$2.toStringAsFixed(1)),
      );
      final got = out.map((o) => r2(centroid(o))).toSet();
      final want = sampledOf(
        const SvgD(threeSub),
      ).map((s) => r2(centroid(s.pts))).toSet();
      expect(got, want);
    });

    test('holes pair with holes', () {
      final plan = buildPlan(
        sampledOf(const SvgD(ring)),
        sampledOf(const SvgD(ring)),
      );
      expect(plan.items, hasLength(2));
      expect(plan.items[0].hole, isFalse);
      expect(plan.items[1].hole, isTrue);
    });

    test('pop flight halves compress', () {
      final a = sampledOf(const SvgD(square));
      final b = sampledOf(const SvgD(twoSub));
      final plan = _popPlan(a, b);
      expect(plan.items.length, a.length + b.length);
      final out = allocOutputs(plan);
      // t=0.25: old half shrunk to ~half its radius, new half invisible
      interpPolar(plan, 0.25, out);
      final c0 = centroid(a[0].pts);
      expect(out[0][0], closeTo(c0.$1 + (a[0].pts[0] - c0.$1) * 0.5, 1e-9));
      // t=0.75: new half grown to ~half, old half gone
      interpPolar(plan, 0.75, out);
      final c1 = centroid(b[0].pts);
      final oB = out[a.length];
      expect(oB[0], closeTo(c1.$1 + (b[0].pts[0] - c1.$1) * 0.5, 1e-9));
    });
  });

  group('mid-flight rendering at 0.25 / 0.5 / 0.75', () {
    test('stroke pair: finite, parses, monotonic centroid', () {
      final surface = MorphSurface();
      final m = createMorph(surface, const SvgD(square));
      const srcC = 12.0, dstC = 22.0;
      for (final t in const [0.25, 0.5, 0.75]) {
        m.seek(const SvgD(squareFar), t);
        final back = parsePath(surface.d);
        expect(back, hasLength(1), reason: 't=$t');
        expect(back.first.closed, isTrue, reason: 't=$t');
        for (final v in back.first.pts) {
          expect(v.isFinite, isTrue, reason: 't=$t');
        }
        // control-polygon centroid bias: M double-counted (3n+1 entries)
        final c = centroid(cubicPoints(back.first));
        expect(c.$1, closeTo(srcC + (dstC - srcC) * t, 0.1), reason: 't=$t');
        expect(c.$2, closeTo(srcC + (dstC - srcC) * t, 0.1), reason: 't=$t');
        expect(surface.d, isNot(squareFar), reason: 't=$t');
        expect(m.progress, closeTo(t, 1e-9), reason: 't=$t');
      }
      // backward scrub stays proper
      m.seek(const SvgD(squareFar), 0.25);
      final c = centroid(cubicPoints(parsePath(surface.d).first));
      expect(c.$1, closeTo(14.5, 0.1));
    });

    test('open pair: open spline mid-flight', () {
      final surface = MorphSurface();
      final m = createMorph(surface, const SvgD('M2 12H22'));
      m.seek(const SvgD('M12 2V22'), 0.5);
      final back = parsePath(surface.d);
      expect(back, hasLength(1));
      expect(back.first.closed, isFalse);
      for (final v in back.first.pts) {
        expect(v.isFinite, isTrue);
      }
    });

    test('fill pair pop fallback: proper halves at 0.25 / 0.75', () {
      final surface = MorphSurface();
      const fillA = ShapeIcon([IconEl(square, fill: 'currentColor')]);
      const fillB = ShapeIcon([IconEl(squareFar, fill: 'currentColor')]);
      final m = createMorph(surface, fillA);
      // 0.25: old shape at half size around its own centroid
      m.seek(fillB, 0.25);
      final back1 = parsePath(surface.d);
      expect(back1, hasLength(1));
      final b1 = _bbox(cubicPoints(back1.first));
      expect(b1.$3 - b1.$1, closeTo(10.0, 1.0));
      expect((b1.$1 + b1.$3) / 2, closeTo(12.0, 1.0));
      expect(surface.attrs['fill'], 'currentColor');
      // 0.75: new shape at half size around the target centroid
      m.seek(fillB, 0.75);
      final back2 = parsePath(surface.d);
      expect(back2, hasLength(1));
      final b2 = _bbox(cubicPoints(back2.first));
      expect(b2.$3 - b2.$1, closeTo(10.0, 1.0));
      expect((b2.$1 + b2.$3) / 2, closeTo(22.0, 1.0));
      expect(surface.attrs['fill'], 'currentColor');
      // 0.5: the pop swap point - degenerate but finite and renderable
      m.seek(fillB, 0.5);
      final back3 = parsePath(surface.d);
      expect(back3, hasLength(1));
      for (final v in back3.first.pts) {
        expect(v.isFinite, isTrue);
      }
    });
  });

  group('spring', () {
    test('settles and keeps velocity on re-plan', () {
      final s = Spring();
      s.config(320, 26);
      s.start();
      expect(s.x, 0);
      var settled = false;
      var t = 0.0;
      while (t < 5) {
        if (s.step(1 / 60)) {
          settled = true;
          break;
        }
        t += 1 / 60;
      }
      expect(settled, isTrue);
      expect(s.x, 1);

      s.start();
      s.v = 0;
      while (s.x < 0.5) {
        if (s.step(1 / 60)) break;
      }
      final v = s.v;
      expect(v, greaterThan(0));
      s.start();
      expect(s.x, 0);
      expect(s.v, v);
    });
  });

  group('driver', () {
    test('mount paints canonical d; stroke icon has no attrs', () {
      final surface = MorphSurface();
      final m = createMorph(surface, const SvgD(square));
      expect(surface.d, square);
      expect(surface.attrs, isEmpty);
      m.set(const SvgD(twoSub));
      expect(surface.d, twoSub);
      expect(m.progress, 1);
    });

    test('seek renders frozen frames, incremental reuse', () {
      final surface = MorphSurface();
      final m = createMorph(surface, const SvgD(square));
      m.seek(const SvgD(squareFar), 0.5);
      final mid = surface.d;
      expect(mid, isNot(square));
      m.seek(const SvgD(squareFar), 0.5);
      expect(surface.d, mid);
      m.seek(const SvgD(squareFar), 0.8);
      expect(surface.d, isNot(mid));
      expect(m.progress, closeTo(0.8, 1e-9));
    });

    test('destroy makes later calls no-ops', () {
      final surface = MorphSurface();
      final m = createMorph(surface, const SvgD(square));
      m.seek(const SvgD(squareFar), 0.5);
      m.destroy();
      m.set(const SvgD(square));
      expect(surface.d, isNot(square));
      expect(m.progress, isNot(1));
    });

    test('fill icon mounts filled; shape icon canonical d', () {
      const fill = ShapeIcon([IconEl(square, fill: 'currentColor')]);
      final surface = MorphSurface();
      createMorph(surface, fill);
      expect(surface.d, canonicalD(fill));
      expect(surface.attrs['fill'], 'currentColor');
      expect(surface.attrs['fill-rule'], 'nonzero');
    });
  });

  group('controller lifecycle', () {
    test('lazy: iconless mount, late icon births driver', () {
      final surface = MorphSurface();
      final c = MorphIconController(const MorphProps());
      c.attach(surface, const MorphProps());
      expect(surface.d, '');
      c.morphTo(const SvgD(square));
      expect(surface.d, square);
    });

    test('controlled pair owns path, drop hands back to icon', () {
      final surface = MorphSurface();
      final pair = MorphProps(
        from: const SvgD(square),
        to: const SvgD(twoSub),
        progress: 0.5,
        reducedMotion: ReducedMotionMode.always,
      );
      final c = MorphIconController(pair);
      c.attach(surface, pair);
      final mid = surface.d;
      expect(mid, isNot(square));
      expect(mid, isNot(twoSub));

      c.update(
        MorphProps(
          from: const SvgD(square),
          to: const SvgD(twoSub),
          progress: 0,
          reducedMotion: ReducedMotionMode.always,
        ),
      );
      expect(surface.d, square);

      c.update(
        MorphProps(
          icon: const SvgD(twoSub),
          reducedMotion: ReducedMotionMode.always,
        ),
      );
      expect(surface.d, twoSub);
    });

    test('same props update is a no-op', () {
      final surface = MorphSurface();
      final pair = MorphProps(
        from: const SvgD(square),
        to: const SvgD(twoSub),
        progress: 0.5,
        reducedMotion: ReducedMotionMode.always,
      );
      final c = MorphIconController(pair);
      c.attach(surface, pair);
      final before = surface.d;
      c.update(pair);
      expect(surface.d, before);
    });

    test('icon change flies (reduced motion -> instant set)', () {
      final surface = MorphSurface();
      final c = MorphIconController(
        const MorphProps(
          icon: SvgD(square),
          reducedMotion: ReducedMotionMode.always,
        ),
      );
      c.attach(
        surface,
        const MorphProps(
          icon: SvgD(square),
          reducedMotion: ReducedMotionMode.always,
        ),
      );
      c.update(
        const MorphProps(
          icon: SvgD(twoSub),
          reducedMotion: ReducedMotionMode.always,
        ),
      );
      expect(surface.d, twoSub);
    });
  });

  group('initial d / paint', () {
    test('icon-only: canonical', () {
      expect(initialD(const MorphProps(icon: SvgD(square))), square);
    });

    test('frozen pair: endpoints canonical, mid interpolated', () {
      final atOne = initialD(
        const MorphProps(from: SvgD(square), to: SvgD(twoSub), progress: 1),
      );
      expect(atOne, twoSub);
      final atMid = initialD(
        const MorphProps(from: SvgD(square), to: SvgD(twoSub), progress: 0.5),
      );
      expect(atMid, isNot(square));
      expect(atMid, isNot(twoSub));
    });

    test(
      'paint: stroke icon none, fill icon filled, fill pair rests on from',
      () {
        expect(initialPaint(const MorphProps(icon: SvgD(square))), isNull);
        const fill = ShapeIcon([IconEl(square, fill: 'currentColor')]);
        expect(initialPaint(const MorphProps(icon: fill)), {
          'fill': 'currentColor',
          'stroke': 'none',
          'fill-rule': 'nonzero',
        });
        expect(
          initialPaint(
            const MorphProps(from: SvgD(square), to: fill, progress: 0.5),
          ),
          isNull,
        );
      },
    );
  });
}

(double, double, double, double) _bbox(Float64List pts) {
  var minX = 1e9, minY = 1e9, maxX = -1e9, maxY = -1e9;
  final n = pts.length ~/ 2;
  for (var i = 0; i < n; i++) {
    minX = minX < pts[2 * i] ? minX : pts[2 * i];
    maxX = maxX > pts[2 * i] ? maxX : pts[2 * i];
    minY = minY < pts[2 * i + 1] ? minY : pts[2 * i + 1];
    maxY = maxY > pts[2 * i + 1] ? maxY : pts[2 * i + 1];
  }
  return (minX, minY, maxX, maxY);
}

// popPlan is private to the driver; rebuild the fallback here for the
// half-compression check.
MorphPlan _popPlan(List<Sampled> from, List<Sampled> to) {
  PlanItem item(Sampled s, int half) {
    final n = kSamples;
    final c = centroid(s.pts);
    final m = s.pts.length ~/ 2;
    final p = Float64List(2 * n);
    for (var i = 0; i < m; i++) {
      p[2 * i] = s.pts[2 * i] - c.$1;
      p[2 * i + 1] = s.pts[2 * i + 1] - c.$2;
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
      half: half,
    );
  }

  return MorphPlan([
    ...from.map((s) => item(s, 0)),
    ...to.map((s) => item(s, 1)),
  ], kSamples);
}
