import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'package:miru_alpha/ui/core/animted_icon/morph/controller.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/driver.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/font_glyph.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/icon_input.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/morph_icon.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/normalize.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/parse.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/plan.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/region.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/spring.dart';
import 'package:miru_alpha/ui/core/animted_icon/morph/surface.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/player_overlay_atoms.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';

const square = 'M2 2H22V22H2Z';
const twoSub = 'M2 2H10V10H2ZM14 14H22V22H14Z';
const squareFar = 'M12 12H32V32H12Z';

Widget _host(
  ValueListenable<MorphIconInput> icon, {
  void Function(MorphIconController)? onController,
  ReducedMotionMode reducedMotion = ReducedMotionMode.never,
}) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: ValueListenableBuilder<MorphIconInput>(
        valueListenable: icon,
        builder: (_, ic, _) => MorphIcon(
          icon: ic,
          size: 24,
          reducedMotion: reducedMotion,
          onController: onController,
        ),
      ),
    ),
  ),
);

Widget _hostProgress(
  ValueListenable<double> progress, {
  MorphIconInput? to,
  void Function(MorphIconController)? onController,
}) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: ValueListenableBuilder<double>(
        valueListenable: progress,
        builder: (_, t, _) => MorphIcon(
          from: const SvgD(square),
          to: to ?? const SvgD(twoSub),
          progress: t,
          size: 24,
          onController: onController,
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('paints initial icon stroke, flies on icon change, settles', (
    tester,
  ) async {
    MorphSurface? surface;
    final icon = ValueNotifier<MorphIconInput>(const SvgD(square));
    await tester.pumpWidget(
      _host(icon, onController: (c) => surface = c.surface),
    );
    await tester.pump();
    surface!;

    expect(surface!.d, square);
    expect(surface!.attrs, isEmpty);

    icon.value = const SvgD(twoSub);
    await tester.pump();
    expect(surface!.d, isNot(twoSub)); // in flight

    await tester.pumpAndSettle();
    expect(surface!.d, twoSub);
    expect(surface!.attrs, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('driver flight settles on canonical target', (tester) async {
    final surface = MorphSurface();
    final m = createMorph(surface, const SvgD(square));
    m.morphTo(const SvgD(squareFar));
    expect(surface.d, isNot(squareFar));
    await tester.pumpAndSettle();
    expect(surface.d, squareFar);
    expect(m.progress, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('controlled pair scrubs', (tester) async {
    final progress = ValueNotifier(0.5);
    MorphSurface? surface;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ValueListenableBuilder<double>(
              valueListenable: progress,
              builder: (_, t, _) => MorphIcon(
                from: const SvgD(square),
                to: const SvgD(twoSub),
                progress: t,
                size: 24,
                onController: (c) => surface = c.surface,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    surface!;

    final mid = surface!.d;
    expect(mid, isNot(square));
    expect(mid, isNot(twoSub));

    progress.value = 0;
    await tester.pump();
    expect(surface!.d, square);

    progress.value = 1;
    await tester.pump();
    expect(surface!.d, twoSub);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scrub renders proper frames at 0.25 / 0.5 / 0.75', (
    tester,
  ) async {
    final progress = ValueNotifier(0.25);
    MorphSurface? surface;
    await tester.pumpWidget(
      _hostProgress(
        progress,
        to: const SvgD(squareFar),
        onController: (c) => surface = c.surface,
      ),
    );
    await tester.pump();
    surface!;

    for (final t in const [0.25, 0.5, 0.75]) {
      progress.value = t;
      await tester.pump();
      // the painter parsed+rendered this frame without exception
      expect(tester.takeException(), isNull, reason: 't=$t');
      final back = parsePath(surface!.d);
      expect(back, hasLength(1), reason: 't=$t');
      expect(back.first.closed, isTrue, reason: 't=$t');
      for (final v in back.first.pts) {
        expect(v.isFinite, isTrue, reason: 't=$t');
      }
      // control-polygon centroid bias (M double-counted) ~ 0.073
      final c = centroid(cubicPoints(back.first));
      expect(c.$1, closeTo(12 + 10 * t, 0.1), reason: 't=$t');
      expect(c.$2, closeTo(12 + 10 * t, 0.1), reason: 't=$t');
    }
  });

  testWidgets('spring flight passes through 0.25 / 0.5 / 0.75 in order', (
    tester,
  ) async {
    MorphIconController? handle;
    final icon = ValueNotifier<MorphIconInput>(const SvgD(square));
    await tester.pumpWidget(_host(icon, onController: (c) => handle = c));
    await tester.pump();

    icon.value = const SvgD(squareFar);
    await tester.pump(); // effect: plan built + ticker started, no frame yet
    final seen = <double>[];
    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      seen.add(handle!.morph!.progress);
      if (handle!.surface!.d == squareFar) break;
    }
    // crossings in order; rise to 1 monotonic (snappy underdamps: wobble
    // past 1 is spring physics, not a scrub bug)
    final firstAt1 = seen.indexWhere((p) => p >= 1);
    final rise = firstAt1 < 0 ? seen : seen.sublist(0, firstAt1 + 1);
    for (final t in const [0.25, 0.5, 0.75]) {
      expect(rise.any((p) => p >= t), isTrue, reason: 't=$t');
    }
    for (var i = 1; i < rise.length; i++) {
      expect(
        rise[i],
        greaterThanOrEqualTo(rise[i - 1] - 1e-9),
        reason: 'frame $i',
      );
    }
    expect(handle!.surface!.d, squareFar);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fill icon: filled attrs, pop fallback settles on target', (
    tester,
  ) async {
    const fillA = ShapeIcon([IconEl(square, fill: 'currentColor')]);
    const fillB = ShapeIcon([IconEl(twoSub, fill: 'currentColor')]);
    MorphSurface? surface;
    final icon = ValueNotifier<MorphIconInput>(fillA);
    await tester.pumpWidget(
      _host(icon, onController: (c) => surface = c.surface),
    );
    await tester.pump();
    surface!;

    expect(surface!.d, canonicalD(fillA));
    expect(surface!.attrs['fill'], 'currentColor');

    icon.value = fillB;
    await tester.pump();
    await tester.pumpAndSettle();
    expect(surface!.d, canonicalD(fillB));
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion always: change jumps without flight', (
    tester,
  ) async {
    MorphSurface? surface;
    final icon = ValueNotifier<MorphIconInput>(const SvgD(square));
    await tester.pumpWidget(
      _host(
        icon,
        reducedMotion: ReducedMotionMode.always,
        onController: (c) => surface = c.surface,
      ),
    );
    await tester.pump();
    surface!;

    expect(surface!.d, square);
    icon.value = const SvgD(twoSub);
    await tester.pump();
    expect(surface!.d, twoSub); // instant, no frames in between
    expect(tester.takeException(), isNull);
  });

  testWidgets('dispose mid-flight detaches cleanly', (tester) async {
    final icon = ValueNotifier<MorphIconInput>(const SvgD(square));
    await tester.pumpWidget(_host(icon));
    await tester.pump();
    icon.value = const SvgD(twoSub);
    await tester.pump(); // flight starts
    await tester.pumpWidget(const SizedBox()); // unmount mid-flight
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('runtime glyph extraction: lucide geometry from packed font', (
    tester,
  ) async {
    final result = await tester.runAsync(
      () async => (
        await MorphGlyphs.icon(FLucideIcons.play),
        await MorphGlyphs.icon(FLucideIcons.pause),
      ),
    );
    final (play, pause) = result!;
    final ps = parsePath(play.d);
    expect(ps, hasLength(1)); // play: one subpath
    expect(ps.first.closed, isTrue);
    final qs = parsePath(pause.d);
    expect(qs, hasLength(2)); // pause: two bars
    for (final p in [...ps, ...qs]) {
      for (final v in p.pts) {
        expect(v.isFinite, isTrue);
        expect(v, inInclusiveRange(-1, 25));
      }
    }
    // stroke pair -> real path morph, never the fill pop fallback
    expect(paintOf(play), 'stroke');
    expect(paintOf(pause), 'stroke');
  });

  testWidgets('play/pause disc: extracted glyphs, snappy morph, settles', (
    tester,
  ) async {
    await tester.runAsync(
      () => MorphGlyphs.warmup([FLucideIcons.play, FLucideIcons.pause]),
    );
    var playing = false;
    Widget app() => MaterialApp(
      builder: (context, child) =>
          FTheme(data: MiruThemes.neutral.light.desktop, child: child!),
      home: Scaffold(
        body: Center(
          child: PlayerPlayPauseDisc(
            isPlaying: playing,
            onPress: () {},
            box: 48,
            iconSize: 22,
          ),
        ),
      ),
    );
    await tester.pumpWidget(app());
    await tester.pump();

    var morph = tester.widget<MorphIcon>(find.byType(MorphIcon));
    expect(morph.icon, isA<SvgD>()); // play glyph
    expect(morph.spring, SpringPreset.snappy);
    expect(morph.size, 22);

    playing = true;
    await tester.pumpWidget(app());
    await tester.pump(); // toggle -> flight starts
    morph = tester.widget<MorphIcon>(find.byType(MorphIcon));
    expect(morph.icon, isA<SvgD>()); // pause glyph (2 bars)
    expect(parsePath((morph.icon as SvgD).d), hasLength(2));

    await tester.pumpAndSettle(); // every flight frame renders clean
    expect(tester.takeException(), isNull);
  });
}
