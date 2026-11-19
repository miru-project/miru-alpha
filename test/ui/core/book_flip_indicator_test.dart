import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/core/widget/book_flip_indicator.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

void main() {
  Widget host() => FTheme(
    data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
    child: const MaterialApp(
      home: Scaffold(body: Center(child: BookFlipIndicator())),
    ),
  );

  BookFlipPainter painterOf(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.descendant(
                  of: find.byType(BookFlipIndicator),
                  matching: find.byType(CustomPaint),
                ),
              )
              .painter
          as BookFlipPainter;

  testWidgets('the leaf flip advances and loops', (tester) async {
    await tester.pumpWidget(host());
    expect(painterOf(tester).progress, closeTo(0.0, 0.01));

    await tester.pump(const Duration(milliseconds: 375));
    final mid = painterOf(tester).progress;
    expect(mid, closeTo(0.5, 0.02));

    // The cycle is 750 ms; one full turn plus a hair wraps the progress back
    // to the start, so the end connects to the beginning.
    await tester.pump(const Duration(milliseconds: 400));
    expect(painterOf(tester).progress, lessThan(0.1));
  });

  testWidgets('the leaf state follows the reference keyframes', (tester) async {
    // scaleX 1 -> 0.02 -> -1, opacity 1 1 1 0 at times 0 / 0.4 / 0.8 / 1.
    expect(BookFlipPainter.leafAt(0.0).$1, closeTo(1.0, 0.001));
    expect(BookFlipPainter.leafAt(0.0).$2, 1.0);
    expect(BookFlipPainter.leafAt(0.4).$1, closeTo(0.02, 0.001));
    expect(BookFlipPainter.leafAt(0.8).$1, closeTo(-1.0, 0.001));
    expect(BookFlipPainter.leafAt(0.8).$2, 1.0);
    expect(BookFlipPainter.leafAt(1.0).$1, closeTo(-1.0, 0.001));
    expect(BookFlipPainter.leafAt(1.0).$2, closeTo(0.0, 0.001));
    // Monotone through the flip: no step.
    double? previous;
    for (var i = 0; i <= 20; i++) {
      final sx = BookFlipPainter.leafAt(i / 20).$1;
      if (previous != null) expect(sx, lessThanOrEqualTo(previous + 0.001));
      previous = sx;
    }
  });

  testWidgets('paints without throwing at the extremes', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);
  });
}
