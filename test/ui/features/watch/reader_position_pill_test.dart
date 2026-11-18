import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_position_pill.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_status_pill.dart';

/// Unit-style tests for [ReaderPositionPill] — the snapping/persisting behavior
/// of the draggable progress pill. Exercise the two bottom corners + the vertical
/// center line (y bounded to the safe-area segment), the radius morph, the
/// screen-edge clamp, and the legacy bottomCenter -> line migration.
void main() {
  setUp(MiruSettings.seedDefaultsForTest);

  test('cornerHitHeight floors at 48 and adds 44 to the bottom inset', () {
    expect(ReaderPositionPill.cornerHitHeight(0), 48.0);
    expect(ReaderPositionPill.cornerHitHeight(2), 48.0);
    expect(ReaderPositionPill.cornerHitHeight(24), 68.0);
    expect(ReaderPositionPill.cornerHitHeight(48), 92.0);
  });

  Widget pilled(int page, double progress) => FTheme(
    data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
    child: MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            ReaderPositionPill(
              isolated: false,
              childBuilder: (borderRadius, compact, showGrip) =>
                  ReaderStatusPill(
                    chapterLabel: 'Chapter 84',
                    page: page,
                    totalPage: 14,
                    progress: progress,
                    borderRadius: borderRadius,
                    compact: compact,
                    showGrip: showGrip,
                  ),
            ),
          ],
        ),
      ),
    ),
  );

  testWidgets('tapping the pill shows the grip, then it fades away', (
    tester,
  ) async {
    await tester.pumpWidget(pilled(3, 0.3));
    await tester.pumpAndSettle();
    expect(find.byKey(kReaderPillGripKey), findsNothing);

    // Tap at the card's centre: the card is hit-transparent by design, so the
    // press lands on the gesture layer underneath it.
    await tester.tapAt(
      tester.getCenter(find.byType(ReaderStatusPill), warnIfMissed: false),
    );
    await tester.pump();
    expect(find.byKey(kReaderPillGripKey), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2400));
    expect(find.byKey(kReaderPillGripKey), findsNothing);
  });

  testWidgets('the animated radius lands on the content card shape', (
    tester,
  ) async {
    await tester.pumpWidget(
      FTheme(
        data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: ReaderStatusPill(
                chapterLabel: 'Chapter 84',
                page: 3,
                totalPage: 14,
                progress: 0.3,
                borderRadius: 0,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // An outline FBadge keeps its own pill radius unless its ShapeBorder is
    // overridden, so assert the badge's resolved decoration itself.
    final decoration = tester
        .widget<DecoratedBox>(
          find
              .descendant(
                of: find.byType(FBadge),
                matching: find.byType(DecoratedBox),
              )
              .first,
        )
        .decoration;
    expect(decoration, isA<ShapeDecoration>());
    final shape = (decoration as ShapeDecoration).shape;
    expect(shape, isA<RoundedRectangleBorder>());
    expect((shape as RoundedRectangleBorder).borderRadius, BorderRadius.zero);
  });

  testWidgets('at a corner the card drops the title and percentage', (
    tester,
  ) async {
    await tester.pumpWidget(pilled(3, 0.3));
    await tester.pumpAndSettle();

    final base = tester.getRect(find.byType(ReaderStatusPill));
    expect(find.text('Chapter 84'), findsOneWidget);
    expect(find.text('30%'), findsOneWidget);
    expect(find.text('3 / 14'), findsOneWidget);

    final gesture = await tester.startGesture(base.center);
    await gesture.moveBy(const Offset(-400, 0));
    await gesture.moveBy(const Offset(-400, 200));
    await gesture.up();
    await tester.pumpAndSettle();

    // Docked at the side: page/total only, no chapter title, no percentage.
    expect(find.text('3 / 14'), findsOneWidget);
    expect(find.text('Chapter 84'), findsNothing);
    expect(find.text('30%'), findsNothing);
    // ...and the card is no taller than the line rest (no bottom padding
    // animation): only the content changed.
    final corner = tester.getRect(find.byType(ReaderStatusPill));
    expect(corner.height, lessThan(40));
  });

  testWidgets('at a corner: press expands, tap does not, drag stays open', (
    tester,
  ) async {
    await tester.pumpWidget(pilled(3, 0.3));
    await tester.pumpAndSettle();

    final base = tester.getRect(find.byType(ReaderStatusPill));
    final cornerGesture = await tester.startGesture(base.center);
    await cornerGesture.moveBy(const Offset(-400, 0));
    await cornerGesture.moveBy(const Offset(-400, 200));
    await cornerGesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Chapter 84'), findsNothing); // compact at rest

    // A quick tap keeps the compact size (only the notch flashes).
    await tester.tapAt(
      tester.getCenter(find.byType(ReaderStatusPill), warnIfMissed: false),
    );
    await tester.pump();
    expect(find.text('Chapter 84'), findsNothing);

    // Press and hold expands to the full readout ...
    final held = await tester.startGesture(
      tester.getCenter(find.byType(ReaderStatusPill), warnIfMissed: false),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await held.up();
    await tester.pumpAndSettle();
    expect(find.text('Chapter 84'), findsNothing); // ... and shrinks back

    // A real long press expands and stays open until release.
    final longPress = await tester.startGesture(
      tester.getCenter(find.byType(ReaderStatusPill), warnIfMissed: false),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Chapter 84'), findsOneWidget);
    await longPress.up();
    await tester.pumpAndSettle();
    expect(find.text('Chapter 84'), findsNothing);

    // Pulling out of the corner keeps the full readout open while dragging ...
    final pulled = await tester.startGesture(
      tester.getCenter(find.byType(ReaderStatusPill), warnIfMissed: false),
    );
    await pulled.moveBy(const Offset(0, -200));
    await tester.pump();
    expect(find.text('Chapter 84'), findsOneWidget);
    // ... and it shrinks only once it has arrived back at the corner.
    await pulled.moveBy(const Offset(0, 200));
    await pulled.up();
    await tester.pumpAndSettle();
    expect(find.text('Chapter 84'), findsNothing);
  });

  testWidgets('expand and shrink animate through intermediate widths', (
    tester,
  ) async {
    await tester.pumpWidget(pilled(3, 0.3));
    await tester.pumpAndSettle();

    // Dock at the corner -> compact.
    final base = tester.getRect(find.byType(ReaderStatusPill));
    final toCorner = await tester.startGesture(base.center);
    await toCorner.moveBy(const Offset(-400, 0));
    await toCorner.moveBy(const Offset(-400, 200));
    await toCorner.up();
    await tester.pumpAndSettle();
    final compact = tester.getRect(find.byType(ReaderStatusPill)).width;

    // Long press: the width must pass THROUGH intermediate values on its way
    // to the full readout — a swap would jump straight there.
    final held = await tester.startGesture(
      tester.getCenter(find.byType(ReaderStatusPill), warnIfMissed: false),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 90));
    final mid = tester.getRect(find.byType(ReaderStatusPill)).width;
    expect(mid, greaterThan(compact));
    expect(mid, lessThan(400));
    await tester.pumpAndSettle();
    final full = tester.getRect(find.byType(ReaderStatusPill)).width;
    expect(full, greaterThan(mid));

    // Release: same in reverse, but the shrink is the quick one (100 ms), so
    // sample inside that window — the pointer-up is dispatched on the first
    // frame, then the animation has ~100 ms to run.
    await held.up();
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump(const Duration(milliseconds: 30));
    final back = tester.getRect(find.byType(ReaderStatusPill)).width;
    expect(back, lessThan(full));
    expect(back, greaterThan(compact));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byType(ReaderStatusPill)).width,
      closeTo(compact, 0.5),
    );
  });

  testWidgets('corner radius eases continuously, with no step', (tester) async {
    await tester.pumpWidget(pilled(3, 0.3));
    await tester.pumpAndSettle();

    final pillRect = tester.getRect(find.byType(ReaderStatusPill));
    final gesture = await tester.startGesture(pillRect.center);

    // Walk from the line's bottom end to the bottom-left corner in small
    // increments, sampling the radius the card is asked to draw.
    final radii = <double>[
      tester
          .widget<ReaderStatusPill>(find.byType(ReaderStatusPill))
          .borderRadius,
    ];
    const steps = 40;
    for (var i = 0; i < steps; i++) {
      await gesture.moveBy(const Offset(-8, 0));
      await tester.pump();
      radii.add(
        tester
            .widget<ReaderStatusPill>(find.byType(ReaderStatusPill))
            .borderRadius,
      );
    }
    await gesture.up();
    await tester.pumpAndSettle();

    // Starts as a pill, ends as a rectangle.
    expect(radii.first, closeTo(16.0, 0.001));
    expect(radii.last, lessThan(1.0));
    // Monotone falloff, and no single step is a jump: a step function would
    // show up here as one delta far larger than its neighbours.
    for (var i = 1; i < radii.length; i++) {
      expect(radii[i], lessThanOrEqualTo(radii[i - 1] + 0.001));
      expect(radii[i - 1] - radii[i], lessThan(4.0));
    }
    // The whole morph is spread over the drag, not concentrated in one frame.
    expect(radii.reduce((a, b) => a + b) / radii.length, greaterThan(2.0));
    // ...and it is gradual rather than two-valued: a step function would only
    // ever produce 16 and 0.
    expect(radii.where((r) => r > 1.0 && r < 15.0).length, greaterThan(10));
  });

  testWidgets('default rest is the line bottom end and radius is 16', (
    tester,
  ) async {
    await tester.pumpWidget(pilled(3, 0.3));
    await tester.pumpAndSettle();

    expect(find.text('3 / 14'), findsOneWidget);
    final rect = tester.getRect(find.byType(ReaderStatusPill));
    // Vertical center line: pill horizontally centered on an 800 dp viewport.
    expect(rect.center.dx, closeTo(400, 1.0));
    expect(
      MiruSettings.getSettingSync<String>(SettingKey.readerPillAnchor),
      'line',
    );
  });

  testWidgets('legacy bottomCenter setting migrates onto the line bottom', (
    tester,
  ) async {
    MiruSettings.setSettingSync(SettingKey.readerPillAnchor, 'bottomCenter');
    await tester.pumpWidget(pilled(3, 0.3));
    await tester.pumpAndSettle();

    final pill = tester.widget<ReaderStatusPill>(find.byType(ReaderStatusPill));
    expect(pill.borderRadius, 16.0);
    final rect = tester.getRect(find.byType(ReaderStatusPill));
    expect(rect.center.dx, closeTo(400, 1.0));
  });

  testWidgets('dragging to the far left snaps to the bottom-left corner', (
    tester,
  ) async {
    await tester.pumpWidget(pilled(3, 0.3));
    await tester.pumpAndSettle();

    final pillRect = tester.getRect(find.byType(ReaderStatusPill));

    final gesture = await tester.startGesture(
      pillRect.center + const Offset(0, 2),
    );
    await gesture.moveBy(const Offset(-120, 0));
    await gesture.moveBy(const Offset(-120, 0));
    await gesture.moveBy(const Offset(-120, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      MiruSettings.getSettingSync<String>(SettingKey.readerPillAnchor),
      'bottomLeft',
    );
    final pill = tester.widget<ReaderStatusPill>(find.byType(ReaderStatusPill));
    expect(pill.borderRadius, 0.0);
  });

  testWidgets('vertical drag on the center line rests on the line', (
    tester,
  ) async {
    await tester.pumpWidget(pilled(3, 0.3));
    await tester.pumpAndSettle();

    final pillRect = tester.getRect(find.byType(ReaderStatusPill));

    final gesture = await tester.startGesture(pillRect.center);
    await gesture.moveBy(const Offset(0, -80));
    await gesture.moveBy(const Offset(0, -80));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      MiruSettings.getSettingSync<String>(SettingKey.readerPillAnchor),
      'line',
    );
    final frac = double.parse(
      MiruSettings.getSettingSync<String>(SettingKey.readerPillLineY),
    );
    expect(frac, lessThan(1.0));
    final pill = tester.widget<ReaderStatusPill>(find.byType(ReaderStatusPill));
    expect(pill.borderRadius, 16.0);
  });

  testWidgets('drag beyond the top edge settles at the line segment top', (
    tester,
  ) async {
    await tester.pumpWidget(pilled(3, 0.3));
    await tester.pumpAndSettle();

    final pillRect = tester.getRect(find.byType(ReaderStatusPill));

    final gesture = await tester.startGesture(pillRect.center);
    await gesture.moveBy(const Offset(0, -400));
    await gesture.moveBy(const Offset(0, -400));
    await gesture.up();
    await tester.pumpAndSettle();

    final rect = tester.getRect(find.byType(ReaderStatusPill));
    // The line rest is bounded by the safe-area segment (8 dp extra above the
    // zero test inset); only the corner anchors reach the physical edge.
    expect(rect.top, 8.0);
    expect(rect.left, greaterThanOrEqualTo(0.0));
    expect(rect.right, lessThanOrEqualTo(800.0));
  });

  testWidgets('corner rest is flush with the physical corner', (tester) async {
    await tester.pumpWidget(pilled(3, 0.3));
    await tester.pumpAndSettle();

    final pillRect = tester.getRect(find.byType(ReaderStatusPill));

    final gesture = await tester.startGesture(pillRect.center);
    await gesture.moveBy(const Offset(-400, 0));
    await gesture.moveBy(const Offset(-400, 10000));
    await gesture.up();
    await tester.pumpAndSettle();

    final rect = tester.getRect(find.byType(ReaderStatusPill));
    expect(rect.left, 0.0);
    expect(rect.bottom, 600.0);
  });
}
