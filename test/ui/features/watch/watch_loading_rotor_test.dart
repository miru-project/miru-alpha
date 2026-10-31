import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_loading_viewport.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

void main() {
  // The resolver rotor: a 52px custom-painted ring whose bright arc rotates
  // over a 3s cycle, with the glass play glyph centered. Text-based checks
  // can never see a painter, so the rotor gets its own assertions: it must
  // EXIST at 52x52, actually ROTATE (its `turns` advances per frame and
  // wraps), and keep a repaint-driving painter wired to the animation.
  testWidgets('resolver rotor renders at 48x48 and rotates', (tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      FTheme(
        data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
        child: const MaterialApp(
          home: Scaffold(
            body: WatchLoadingViewport(title: 'Daemons', onBack: _noop),
          ),
        ),
      ),
    );
    // One bare frame: the ticker's first tick renders the plan source.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final paints = tester.widgetList<CustomPaint>(
      find.byWidgetPredicate(
        (w) =>
            w is CustomPaint &&
            w.painter.runtimeType.toString().contains('_RingPainter'),
      ),
    );
    debugPrint('ring painters: ${paints.length}');

    // The rotor's box: 48x48 (the glass disc's CustomPaint), 2026-10-30
    // overlay's smaller resolver disc.
    final ring = find.byWidgetPredicate(
      (w) =>
          w is CustomPaint &&
          w.painter.runtimeType.toString().contains('_RingPainter'),
    );
    expect(ring, findsOneWidget);
    final box = tester.getSize(ring);
    expect(box.width, 48);
    expect(box.height, 48);

    double turnsOf() =>
        (tester.widget<CustomPaint>(ring).painter as dynamic).turns as double;

    final t0 = turnsOf();
    // Advance well into the cycle — the arc's angle must follow.
    await tester.pump(const Duration(milliseconds: 750));
    final t1 = turnsOf();
    await tester.pump(const Duration(milliseconds: 750));
    final t2 = turnsOf();

    debugPrint('turns: t0=$t0 t1=$t1 t2=$t2');
    // Rotates: each sampled turn value differs from the last.
    expect(t1, isNot(t0));
    expect(t2, isNot(t1));
    // And stays on the unit circle.
    for (final t in [t0, t1, t2]) {
      expect(t, greaterThanOrEqualTo(0.0));
      expect(t, lessThan(1.0));
    }

    // The centered play glyph sits inside the ring.
    expect(find.byIcon(FLucideIcons.play), findsOneWidget);
  });

  // The rotor unmounts with the viewport: no live ticker leaks past dispose
  // (a repeated controller without dispose would keep the frame pumping).
  testWidgets('rotor ticker stops when the viewport unmounts', (tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      FTheme(
        data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
        child: const MaterialApp(
          home: Scaffold(
            body: WatchLoadingViewport(title: 'Daemons', onBack: _noop),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    // Reaching here is the assertion: a live ticker/pending timer would
    // fail teardown with "A Timer is still pending".
  });
}

void _noop() {}
