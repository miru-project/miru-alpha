import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/scrollable_positioned_list.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/webtoon_zoom_surface.dart';

/// The hybrid surface has to satisfy two opposing requirements: a two-finger
/// pinch must zoom, and a one-finger drag must still scroll. The obvious way to
/// get zoom back — wrapping the list in an `InteractiveViewer` — breaks the
/// second one, so these tests pin the behaviour down.
void main() {
  late ScrollOffsetController offsetController;
  late ScrollOffsetListener offsetListener;
  late ItemScrollController itemController;
  late ItemPositionsListener itemPositions;
  late List<double> scales;

  // The listener interfaces expose no dispose, and each setUp builds fresh
  // ones, so nothing is shared between tests.
  setUp(() {
    offsetController = ScrollOffsetController();
    offsetListener = ScrollOffsetListener.create();
    itemController = ItemScrollController();
    itemPositions = ItemPositionsListener.create();
    scales = [];
  });

  /// [longStrip] makes the chapter long enough that a coast is never clipped by
  /// the end of the list, so a test measures inertia and not the boundary.
  Widget subject({bool longStrip = false}) {
    final items = longStrip ? 60 : 10;
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 600,
          child: WebtoonZoomSurface(
            itemCount: items,
            itemPositionsListener: itemPositions,
            scrollOffsetController: offsetController,
            scrollOffsetListener: offsetListener,
            itemScrollController: itemController,
            maxScale: 4,
            onScaleChanged: scales.add,
            itemBuilder: (context, index) =>
                SizedBox(height: 400, child: Text('page $index')),
          ),
        ),
      ),
    );
  }

  /// Largest scale among every [Transform] in the tree. The zoom transform is
  /// the only one that changes, and it is not the first in tree order —
  /// Scaffold and Material insert their own.
  double currentScale(WidgetTester tester) {
    return tester
        .widgetList<Transform>(find.byType(Transform))
        .map((transform) => transform.transform.getMaxScaleOnAxis())
        .reduce(math.max);
  }

  group('scrolling', () {
    testWidgets('a one-finger drag scrolls the list', (tester) async {
      await tester.pumpWidget(subject());
      await tester.pump();

      expect(offsetController.offset, 0);

      await tester.drag(find.byType(WebtoonZoomSurface), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(offsetController.offset, greaterThan(100));
      // No pinch happened, so the surface must not be transformed.
      expect(scales, isEmpty);
    });

    testWidgets('position is reported through ItemPositionsListener', (
      tester,
    ) async {
      await tester.pumpWidget(subject());
      await tester.pump();

      await tester.drag(find.byType(WebtoonZoomSurface), const Offset(0, -900));
      await tester.pumpAndSettle();

      // The first partially-visible item index moved past the top page.
      final visible = itemPositions.itemPositions.value;
      expect(visible, isNotEmpty);
      expect(
        visible
            .map((position) => position.index)
            .reduce((a, b) => a > b ? a : b),
        greaterThan(0),
      );
    });
  });
  group('pinch zoom', () {
    // Two fingers 100px apart at y=200. Moving one *further* from the other
    // raises the scale; moving it *towards* the other lowers it.
    testWidgets('spreading two fingers zooms in', (tester) async {
      await tester.pumpWidget(subject());
      await tester.pump();

      expect(currentScale(tester), 1);

      final left = await tester.startGesture(
        const Offset(150, 200),
        pointer: 1,
      );
      await tester.startGesture(const Offset(250, 200), pointer: 2);
      await tester.pump();

      // 100px apart -> 200px apart is 2x.
      await left.moveTo(const Offset(50, 200));
      await tester.pump();

      expect(currentScale(tester), closeTo(2, 0.01));
      expect(scales.last, closeTo(2, 0.01));
    });

    testWidgets('a diagonal pinch keeps the focal page under the fingers', (
      tester,
    ) async {
      const marker = ValueKey('focal-marker');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: WebtoonZoomSurface(
                itemCount: 10,
                itemPositionsListener: itemPositions,
                scrollOffsetController: offsetController,
                scrollOffsetListener: offsetListener,
                itemScrollController: itemController,
                onScaleChanged: scales.add,
                itemBuilder: (context, index) => SizedBox(
                  height: 400,
                  // A feature small enough that "the same pixel is still under
                  // the fingers" is a meaningful assertion, parked so the pinch
                  // focal at (150, 250) starts inside it.
                  child: index == 0
                      ? const Padding(
                          padding: EdgeInsets.only(top: 240, left: 140),
                          child: SizedBox(key: marker, width: 20, height: 20),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final markerStart = tester.getTopLeft(find.byKey(marker));
      expect(markerStart, const Offset(140, 240));

      // A diagonal pinch whose midpoint also travels: the content has to follow
      // both the scale change and the pan, in both axes.
      final top = await tester.startGesture(const Offset(100, 200), pointer: 1);
      final bottom = await tester.startGesture(
        const Offset(200, 300),
        pointer: 2,
      );
      await tester.pump();
      await top.moveTo(const Offset(50, 150));
      await bottom.moveTo(const Offset(250, 450));
      await tester.pump();

      final startSpread =
          (const Offset(200, 300) - const Offset(100, 200)).distance;
      final endSpread =
          (const Offset(250, 450) - const Offset(50, 150)).distance;
      final scale = endSpread / startSpread;
      expect(currentScale(tester), closeTo(scale, 0.01));

      // The pixel that was under the start focal at (150, 250) must be under
      // the moved focal at (150, 300), i.e. scaled and panned from there.
      final markerEnd = tester.getTopLeft(find.byKey(marker));
      final behind = const Offset(150, 250) - markerStart;
      final expected = const Offset(150, 300) - behind * scale;
      expect(markerEnd.dx, closeTo(expected.dx, 0.5));
      expect(markerEnd.dy, closeTo(expected.dy, 0.5));
      expect(offsetController.offset, 0);

      // Lifting the fingers must not move the view it just produced.
      await top.up();
      await bottom.up();
      await tester.pumpAndSettle();

      final afterLift = tester.getTopLeft(find.byKey(marker));
      expect(afterLift.dx, closeTo(expected.dx, 0.5));
      expect(afterLift.dy, closeTo(expected.dy, 0.5));
      expect(currentScale(tester), closeTo(scale, 0.01));
    });

    testWidgets('pinching leaves the recorded scroll offset alone', (
      tester,
    ) async {
      await tester.pumpWidget(subject());
      await tester.pump();

      var reported = 0;
      offsetListener.changes.listen((_) => reported++);

      await tester.drag(find.byType(WebtoonZoomSurface), const Offset(0, -900));
      await tester.pumpAndSettle();

      final before = offsetController.offset;
      final itemBefore = itemPositions.itemPositions.value
          .map((position) => position.index)
          .reduce(math.max);
      expect(before, greaterThan(0));
      expect(itemBefore, greaterThan(0));
      expect(reported, greaterThan(0));

      final top = await tester.startGesture(const Offset(100, 200), pointer: 1);
      final bottom = await tester.startGesture(
        const Offset(200, 300),
        pointer: 2,
      );
      await tester.pump();
      final reportedBeforePinch = reported;
      await top.moveTo(const Offset(50, 150));
      await bottom.moveTo(const Offset(250, 450));
      await tester.pump();

      // Zooming is paint-only: the list is neither jumped nor remounted, so the
      // position that gets recorded is the position the reader was left at.
      expect(currentScale(tester), greaterThan(1));
      expect(offsetController.offset, closeTo(before, 0.5));
      expect(
        itemPositions.itemPositions.value
            .map((position) => position.index)
            .reduce(math.max),
        itemBefore,
      );
      expect(reported, reportedBeforePinch);
    });

    testWidgets('a two-finger pan tracks the fingers at 1x, not double', (
      tester,
    ) async {
      const marker = ValueKey('focal-marker');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: WebtoonZoomSurface(
                itemCount: 10,
                itemPositionsListener: itemPositions,
                scrollOffsetController: offsetController,
                scrollOffsetListener: offsetListener,
                itemScrollController: itemController,
                onScaleChanged: scales.add,
                itemBuilder: (context, index) => SizedBox(
                  height: 400,
                  child: index == 0
                      ? const Padding(
                          padding: EdgeInsets.only(top: 290, left: 140),
                          child: SizedBox(key: marker, width: 20, height: 20),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final markerStart = tester.getTopLeft(find.byKey(marker));
      final left = await tester.startGesture(
        const Offset(100, 300),
        pointer: 1,
      );
      final right = await tester.startGesture(
        const Offset(200, 300),
        pointer: 2,
      );
      await tester.pump();
      await left.moveTo(const Offset(50, 300));
      await right.moveTo(const Offset(250, 300));
      await tester.pump();
      expect(currentScale(tester), closeTo(2, 0.01));

      // Both fingers travel 100px up. If the list also scrolled, the content
      // would move 2x the fingers; the pinch owns the gesture, so it must move
      // exactly as far as they did.
      await left.moveTo(const Offset(50, 200));
      await right.moveTo(const Offset(250, 200));
      await tester.pump();

      final expected =
          const Offset(150, 200) - (const Offset(150, 300) - markerStart) * 2;
      final markerEnd = tester.getTopLeft(find.byKey(marker));
      expect(markerEnd.dx, closeTo(expected.dx, 0.5));
      expect(markerEnd.dy, closeTo(expected.dy, 0.5));
      expect(offsetController.offset, 0);
    });

    testWidgets('a magnified strip has no black below its last page', (
      tester,
    ) async {
      const last = ValueKey('page-2');
      const first = ValueKey('page-0');

      /// Three pages of a known height, so every painted edge is computable.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: WebtoonZoomSurface(
                itemCount: 3,
                itemPositionsListener: itemPositions,
                scrollOffsetController: offsetController,
                scrollOffsetListener: offsetListener,
                itemScrollController: itemController,
                onScaleChanged: scales.add,
                itemBuilder: (context, index) => SizedBox(
                  key: switch (index) {
                    2 => last,
                    _ => first,
                  },
                  height: 1000,
                  child: const ColoredBox(color: Color(0xFFFFFFFF)),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Magnify, then haul the strip to its end.
      final a = await tester.startGesture(const Offset(150, 300), pointer: 1);
      final b = await tester.startGesture(const Offset(250, 300), pointer: 2);
      await tester.pump();
      await a.moveTo(const Offset(50, 300));
      await tester.pump();
      await a.up();
      await b.up();
      await tester.pumpAndSettle();
      final scale = currentScale(tester);
      expect(scale, closeTo(2, 0.01));

      for (var i = 0; i < 12; i++) {
        await tester.drag(
          find.byType(WebtoonZoomSurface),
          const Offset(0, -400),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Magnified, the strip has to keep painting: the last page must reach past
      // the bottom of the viewport, and the first page past the top. Short of
      // that — a pan that only moved the transform, or a content height that
      // stopped it early — the gap is black canvas.
      final lastPage = tester.getRect(find.byKey(last));
      expect(lastPage.bottom, greaterThanOrEqualTo(600 - 1));
      expect(lastPage.top, lessThanOrEqualTo(0 + 1));

      for (var i = 0; i < 12; i++) {
        await tester.drag(
          find.byType(WebtoonZoomSurface),
          const Offset(0, 400),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();

      final firstPage = tester.getRect(find.byKey(first));
      expect(firstPage.top, lessThanOrEqualTo(0 + 1));
      expect(firstPage.bottom, greaterThanOrEqualTo(600 - 1));
    });

    testWidgets(
      'a flick while magnified coasts to a stop, it does not stop dead',
      (tester) async {
        await tester.pumpWidget(subject());
        await tester.pump();

        // Magnify first.
        final zoomA = await tester.startGesture(
          const Offset(150, 200),
          pointer: 1,
        );
        final zoomB = await tester.startGesture(
          const Offset(250, 200),
          pointer: 2,
        );
        await tester.pump();
        await zoomA.moveTo(const Offset(50, 200));
        await tester.pump();
        await zoomA.up();
        await zoomB.up();
        await tester.pumpAndSettle();
        expect(currentScale(tester), greaterThan(1));

        // Fling upwards and let go mid-gesture. The moves carry real timestamps
        // and come in threes, because the flick's speed comes from how fast they
        // arrived — and the framework's velocity estimator needs a few samples,
        // exactly as it does for an ordinary drag.
        final gesture = await tester.startGesture(const Offset(200, 500));
        await gesture.moveBy(
          const Offset(0, -40),
          timeStamp: const Duration(milliseconds: 8),
        );
        await gesture.moveBy(
          const Offset(0, -40),
          timeStamp: const Duration(milliseconds: 16),
        );
        await gesture.moveBy(
          const Offset(0, -110),
          timeStamp: const Duration(milliseconds: 24),
        );
        await tester.pump(const Duration(milliseconds: 16));
        final atRelease = offsetController.offset;
        await gesture.up();
        await tester.pump();
        await tester.pumpAndSettle(const Duration(milliseconds: 16));

        // The list kept going after the finger did, and came to rest on its own
        // rather than dead where it was released.
        final settled = offsetController.offset;
        expect(settled, greaterThan(atRelease));
        // ...and it is at rest: nothing is still moving.
        await tester.pump(const Duration(milliseconds: 100));
        expect(offsetController.offset, closeTo(settled, 0.5));
      },
    );

    testWidgets('every flick coasts as far as the first one did', (
      tester,
    ) async {
      await tester.pumpWidget(subject(longStrip: true));
      await tester.pump();

      // Magnify once; the flicks below all happen at the same zoom.
      final zoomA = await tester.startGesture(
        const Offset(150, 200),
        pointer: 1,
      );
      final zoomB = await tester.startGesture(
        const Offset(250, 200),
        pointer: 2,
      );
      await tester.pump();
      await zoomA.moveTo(const Offset(50, 200));
      await tester.pump();
      await zoomA.up();
      await zoomB.up();
      await tester.pumpAndSettle();
      expect(currentScale(tester), greaterThan(1));

      // One flick. Returns the offset at the moment the finger lifted; the
      // caller decides whether to let the coast finish before the next gesture.
      Future<double> flick(Offset offset) async {
        final gesture = await tester.startGesture(const Offset(200, 500));
        await gesture.moveBy(
          offset,
          timeStamp: const Duration(milliseconds: 8),
        );
        await gesture.moveBy(
          offset,
          timeStamp: const Duration(milliseconds: 16),
        );
        await gesture.moveBy(
          offset,
          timeStamp: const Duration(milliseconds: 24),
        );
        await tester.pump(const Duration(milliseconds: 16));
        final released = offsetController.offset;
        await gesture.up();
        await tester.pump();
        return released;
      }

      Future<void> settle() =>
          tester.pumpAndSettle(const Duration(milliseconds: 16));

      /// Pan + coast of one flick, measured from before the finger landed.
      Future<double> flickAndSettle(Offset offset) async {
        final start = offsetController.offset;
        await flick(offset);
        await settle();
        return offsetController.offset - start;
      }

      // Baseline: one flick, left to coast on its own.
      final alone = await flickAndSettle(const Offset(0, -60));
      expect(alone, greaterThan(0), reason: 'a flick must coast');

      // The common gesture: the reader flicks again *while the first coast is
      // still running*. The pan takes over on touch-down, so the second flick
      // has to carry its own inertia — it used to find the fling still
      // animating, start nothing, and coast only as far as the interrupted one
      // happened to have left.
      await flick(const Offset(0, -60));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        offsetController.offset,
        greaterThan(0),
        reason: 'the first coast should still be running',
      );
      final overlapping = await flickAndSettle(const Offset(0, -60));
      expect(
        overlapping,
        greaterThan(alone * 0.8),
        reason:
            'a flick interrupted another coasted $overlapping, '
            'a lone one $alone',
      );

      // ...and the other direction, again with a coast already running.
      await flick(const Offset(0, 60));
      await tester.pump(const Duration(milliseconds: 300));
      final back = await flickAndSettle(const Offset(0, 60));
      // Downward, so the offset counts down; the distance is what matters.
      expect(
        back,
        lessThan(0),
        reason: 'a downward flick should coast downward',
      );
      expect(
        back.abs(),
        greaterThan(alone.abs() * 0.8),
        reason:
            'the reverse flick travelled ${back.abs()}, '
            'a lone one ${alone.abs()}',
      );
    });

    testWidgets('pinching back together returns to 1x', (tester) async {
      await tester.pumpWidget(subject());
      await tester.pump();

      final markerBefore = tester.getTopLeft(find.text('page 0'));
      final left = await tester.startGesture(
        const Offset(150, 200),
        pointer: 1,
      );
      final right = await tester.startGesture(
        const Offset(250, 200),
        pointer: 2,
      );
      await tester.pump();

      await left.moveTo(const Offset(50, 200));
      await tester.pump();
      expect(scales.last, greaterThan(1));

      // Close them back to the original 100px separation.
      await left.moveTo(const Offset(150, 200));
      await tester.pump();
      expect(scales.last, closeTo(1, 0.01));

      await right.up();
      await left.up();
      await tester.pumpAndSettle();

      // Back at 1x the page sits exactly where it started, unshifted.
      expect(tester.getTopLeft(find.text('page 0')), markerBefore);
      expect(currentScale(tester), 1);
    });

    testWidgets('scale is clamped to maxScale', (tester) async {
      await tester.pumpWidget(subject());
      await tester.pump();

      final left = await tester.startGesture(
        const Offset(195, 200),
        pointer: 1,
      );
      await tester.startGesture(const Offset(205, 200), pointer: 2);
      await tester.pump();

      // 10px apart -> 200px apart is 20x, far past the 4x ceiling.
      await left.moveTo(const Offset(5, 200));
      await tester.pump();

      expect(scales.last, 4);
      expect(currentScale(tester), 4);
    });

    testWidgets('a zoomed page pans with one finger, carrying the list', (
      tester,
    ) async {
      await tester.pumpWidget(subject());
      await tester.pump();

      // Zoom in first.
      final left = await tester.startGesture(
        const Offset(150, 200),
        pointer: 1,
      );
      final right = await tester.startGesture(
        const Offset(250, 200),
        pointer: 2,
      );
      await tester.pump();
      await left.moveTo(const Offset(50, 200));
      await tester.pump();
      await right.up();
      await left.up();
      await tester.pumpAndSettle();

      final scale = currentScale(tester);
      expect(scale, greaterThan(1));
      final markerBefore = tester.getTopLeft(find.text('page 0'));

      // Magnified, the gesture belongs to the view instead of the list: the page
      // tracks the finger on both axes, and the list is carried along
      // vertically so the content it has built follows the view (a transform
      // alone would paint pages the list never built — a black band).
      final gesture = await tester.startGesture(const Offset(200, 400));
      await gesture.moveBy(const Offset(0, -20));
      await gesture.moveBy(const Offset(40, -100));
      await tester.pump();

      // 1:1 with the finger: the two moves added up to (40, -120), whatever the
      // scale, and not multiplied by it.
      final markerAfter = tester.getTopLeft(find.text('page 0'));
      expect(markerAfter.dx - markerBefore.dx, closeTo(40, 0.5));
      expect(markerAfter.dy - markerBefore.dy, closeTo(-120, 0.5));
      // ...and the recorded position follows, because the view really did move
      // through the chapter.
      expect(offsetController.offset, greaterThan(0));

      // Pinching back out hands the list back its drag.
      await gesture.up();
      final out = await tester.startGesture(const Offset(50, 200), pointer: 3);
      final back = await tester.startGesture(
        const Offset(250, 200),
        pointer: 4,
      );
      await tester.pump();
      await out.moveTo(const Offset(150, 200));
      await tester.pump();
      await back.up();
      await out.up();
      await tester.pumpAndSettle();
      expect(currentScale(tester), closeTo(1, 0.01));

      await tester.drag(find.byType(WebtoonZoomSurface), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(offsetController.offset, greaterThan(0));
    });

    testWidgets('a tap fires the callback without scrolling or zooming', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: WebtoonZoomSurface(
                itemCount: 10,
                itemPositionsListener: itemPositions,
                scrollOffsetController: offsetController,
                scrollOffsetListener: offsetListener,
                itemScrollController: itemController,
                onTap: () => taps++,
                itemBuilder: (context, index) => const SizedBox(height: 400),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tapAt(const Offset(200, 200));
      await tester.pumpAndSettle();

      expect(taps, 1);
      expect(offsetController.offset, 0);
      expect(scales, isEmpty);
    });
  });
}
