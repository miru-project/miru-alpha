import 'dart:async';
import 'dart:math' as math;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/refresh/forui_header.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

/// EasyRefresh learns the scroll axis from the position it is handed, so any
/// horizontal list under it — including a nested horizontal rail that
/// inherits EasyRefresh's physics — flips the indicator's `Positioned` into
/// horizontal geometry, which leaves the width unconstrained. The Forui
/// indicator used to size itself to infinite width there, tripping the
/// framework's "was given an infinite size during layout" assertion and
/// leaking the layout debug flag that surfaced as the `!_debugDoingThisLayout`
/// failure in the console. Dragging a horizontal list reproduces that axis,
/// so this test pins the layout to staying healthy through it.
///
/// The morph tests pin the three-state icon behavior: the loading glyph is a
/// Lucide icon spun by a continuous angle θ(t); state transitions carry θ
/// into the result glyph (it starts at the spinner's angle and eases onto the
/// next full-turn boundary); fail renders an X with the error message. They
/// hold `processed` open with a long `processedDuration` so the settle
/// assertions don't race the header's retract back to inactive.
void main() {
  /// Keeps the result glyph on screen while the morph is asserted.
  const holdProcessed = Duration(seconds: 5);

  Widget wrap(Widget child) => FTheme(
    data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
    child: MaterialApp(home: Scaffold(body: child)),
  );

  /// Rotation angle (radians, wrapped to (-π, π]) of the Transform directly
  /// wrapping [icon].
  double angleOf(WidgetTester tester, Finder icon) {
    final transform = tester.widget<Transform>(
      find.ancestor(of: icon, matching: find.byType(Transform)).first,
    );
    final m = transform.transform;
    return math.atan2(m.entry(1, 0), m.entry(0, 0));
  }

  /// Distance from the angle to the nearest full-turn boundary — 0 means the
  /// glyph sits upright.
  double turnDistance(double angle) {
    final d = angle.abs() % (2 * math.pi);
    return d > math.pi ? 2 * math.pi - d : d;
  }

  /// Drains the processed hold + the retract spring so no ticker or timer
  /// outlives the test.
  Future<void> pumpToRest(WidgetTester tester) async {
    await tester.pump(holdProcessed);
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(seconds: 2));
  }

  /// Drags past the trigger and lets the release spring settle — the
  /// clamping header only flips ready → processing (and starts the task)
  /// once the spring pins the offset back at the trigger.
  Future<void> pullToRefresh(WidgetTester tester) async {
    await tester.drag(find.byType(ListView), const Offset(0, 240));
    await tester.pump();
    // The release spring takes ~1s of fake time to settle below the trigger.
    await tester.pump(const Duration(milliseconds: 1200));
  }

  testWidgets('horizontal list under EasyRefresh lays out without exceptions', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        EasyRefresh(
          header: const ForuiHeader(),
          onRefresh: () async {},
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 20,
            itemBuilder: (context, index) =>
                SizedBox(width: 120, child: Text('item $index')),
          ),
        ),
      ),
    );
    await tester.pump();

    // Releasing a horizontal drag is what hands EasyRefresh a ballistic
    // simulation, and that is where the axis flips.
    await tester.drag(find.byType(ListView), const Offset(-240, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
  });

  testWidgets('vertical list under EasyRefresh still lays out cleanly', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        EasyRefresh(
          header: const ForuiHeader(),
          onRefresh: () async {},
          child: ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) =>
                SizedBox(height: 60, child: Text('item $index')),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.drag(find.byType(ListView), const Offset(0, 240));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await pumpToRest(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'loading spins θ(t); the check carries θ onto the turn boundary',
    (tester) async {
      final task = Completer<IndicatorResult>();
      await tester.pumpWidget(
        wrap(
          EasyRefresh(
            header: const ForuiHeader(processedDuration: holdProcessed),
            onRefresh: () => task.future,
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) =>
                  SizedBox(height: 60, child: Text('item $index')),
            ),
          ),
        ),
      );
      await tester.pump();

      await pullToRefresh(tester);
      expect(find.byIcon(FLucideIcons.loaderCircle), findsOneWidget);

      // θ(t) advances while loading.
      final spin1 = angleOf(tester, find.byIcon(FLucideIcons.loaderCircle));
      await tester.pump(const Duration(milliseconds: 100));
      final spin2 = angleOf(tester, find.byIcon(FLucideIcons.loaderCircle));
      expect(spin2, greaterThan(spin1));

      // The success glyph starts at the spinner's angle — the transition
      // carries θ into the new state instead of snapping to zero.
      task.complete(IndicatorResult.success);
      // `idle` flushes the task continuation into `processed`, the pump
      // renders it.
      await tester.idle();
      await tester.pump();
      expect(find.byIcon(FLucideIcons.check), findsOneWidget);
      final settleStart = angleOf(tester, find.byIcon(FLucideIcons.check));
      expect(settleStart, closeTo(spin2, 0.5));

      // The settle lands on a full-turn boundary (visually upright).
      await tester.pump(const Duration(milliseconds: 600));
      final settled = angleOf(tester, find.byIcon(FLucideIcons.check));
      expect(turnDistance(settled), closeTo(0, 0.01));

      await pumpToRest(tester);
    },
  );

  testWidgets('fail shows the X with the error message, θ still carried', (
    tester,
  ) async {
    final task = Completer<IndicatorResult>();
    await tester.pumpWidget(
      wrap(
        EasyRefresh(
          header: ForuiHeader(
            processedDuration: holdProcessed,
            errorText: () => 'boom: extension down',
          ),
          onRefresh: () => task.future,
          child: ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) =>
                SizedBox(height: 60, child: Text('item $index')),
          ),
        ),
      ),
    );
    await tester.pump();

    await pullToRefresh(tester);
    final spin = angleOf(tester, find.byIcon(FLucideIcons.loaderCircle));

    task.complete(IndicatorResult.fail);
    await tester.idle();
    await tester.pump();
    expect(find.byIcon(FLucideIcons.x), findsOneWidget);
    expect(find.text('boom: extension down'), findsOneWidget);

    // The X enters at the spinner's angle and settles upright.
    final settleStart = angleOf(tester, find.byIcon(FLucideIcons.x));
    expect(settleStart, closeTo(spin, 0.5));
    await tester.pump(const Duration(milliseconds: 600));
    final settled = angleOf(tester, find.byIcon(FLucideIcons.x));
    expect(turnDistance(settled), closeTo(0, 0.01));

    await pumpToRest(tester);
  });

  testWidgets('fail without an errorText falls back to common.error', (
    tester,
  ) async {
    final task = Completer<IndicatorResult>();
    await tester.pumpWidget(
      wrap(
        EasyRefresh(
          header: const ForuiHeader(processedDuration: holdProcessed),
          onRefresh: () => task.future,
          child: ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) =>
                SizedBox(height: 60, child: Text('item $index')),
          ),
        ),
      ),
    );
    await tester.pump();

    await pullToRefresh(tester);
    task.complete(IndicatorResult.fail);
    await tester.idle();
    await tester.pump();

    expect(find.byIcon(FLucideIcons.x), findsOneWidget);
    // Without the app's root navigator key, `.i18n` falls back to the raw
    // key — the fallback path is what this pins.
    expect(find.text('common.error'), findsOneWidget);

    await pumpToRest(tester);
  });
}
