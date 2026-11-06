import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_zoom_surface.dart';

/// The reader's hybrid zoom, tested on its own so the paged and webtoon wirings
/// only have to supply a scrollable.
void main() {
  late double scale;
  late Offset translate;
  late bool scrollingEnabled;

  /// Live zoom, mirrored out of the surface by the builder.
  Widget subject({
    required Widget scrollable,
    ValueChanged<Offset>? onTapUp,
    bool? doubleTapEnabled,
    double? doubleTapScale,
    ReaderZoomController? controller,
    Size? Function(Size viewport)? contentSize,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 600,
          child: ReaderZoomSurface(
            controller: controller,
            onTapUp: onTapUp,
            doubleTapEnabled: doubleTapEnabled ?? true,
            doubleTapScale: doubleTapScale ?? 2.5,
            contentSize: contentSize,
            builder: (context, zoom) {
              scale = zoom.scale;
              translate = zoom.translate;
              scrollingEnabled = zoom.scrollingEnabled;
              return zoom.wrap(scrollable);
            },
          ),
        ),
      ),
    );
  }

  /// Closes the double-tap recognizer's disambiguation window (300 ms) and the
  /// per-pointer minimum-spacing timer (40 ms) it arms on every pointer down.
  /// A gesture test that ends while either is pending fails the binding's
  /// pending-timer audit, and a tap landing inside the window reads as the
  /// second tap of a double tap.
  Future<void> closeTapWindow(WidgetTester tester) =>
      tester.pump(const Duration(milliseconds: 350));

  setUp(() {
    scale = 1;
    translate = Offset.zero;
    scrollingEnabled = true;
  });

  testWidgets('a one-finger drag is left to the scrollable at 1x', (
    tester,
  ) async {
    var dragged = 0;
    await tester.pumpWidget(
      subject(
        scrollable: NotificationListener<ScrollStartNotification>(
          onNotification: (notification) {
            if (notification.dragDetails != null) dragged++;
            return false;
          },
          child: ListView(children: const [SizedBox(height: 3000)]),
        ),
      ),
    );
    await tester.pump();

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(dragged, greaterThan(0));
    // The transform stays out of the way, so the strip moves and nothing else.
    expect(scale, 1);
    expect(translate, Offset.zero);
    expect(scrollingEnabled, isTrue);
  });

  testWidgets('pinching magnifies and pins the scrollable', (tester) async {
    await tester.pumpWidget(
      subject(scrollable: ListView(children: const [SizedBox(height: 3000)])),
    );
    await tester.pump();

    final a = await tester.startGesture(const Offset(150, 300), pointer: 1);
    final b = await tester.startGesture(const Offset(250, 300), pointer: 2);
    await tester.pump();
    expect(scrollingEnabled, isFalse, reason: 'two fingers own the gesture');

    await a.moveTo(const Offset(50, 300));
    await tester.pump();
    expect(scale, closeTo(2, 0.01));

    await a.up();
    await b.up();
    await tester.pumpAndSettle();

    // Magnified, the same scrollable is pinned so a one-finger drag pans
    // instead of turning the page.
    expect(scrollingEnabled, isFalse);
  });

  testWidgets('a magnified page pans in both axes, 1:1 with the finger', (
    tester,
  ) async {
    const markerKey = ValueKey('page');
    await tester.pumpWidget(
      subject(
        // A page fills the viewport, so that is what the pan is bounded by.
        contentSize: (viewport) => viewport,
        scrollable: const Center(
          child: SizedBox(key: markerKey, width: 400, height: 600),
        ),
      ),
    );
    await tester.pump();

    // Zoom in with a horizontal-only pinch: no vertical drag for the scrollable.
    final a = await tester.startGesture(const Offset(150, 300), pointer: 1);
    final b = await tester.startGesture(const Offset(250, 300), pointer: 2);
    await tester.pump();
    await a.moveTo(const Offset(50, 300));
    await tester.pump();
    await a.up();
    await b.up();
    await tester.pumpAndSettle();
    expect(scale, closeTo(2, 0.01));

    final before = tester.getTopLeft(find.byKey(markerKey));
    final gesture = await tester.startGesture(const Offset(200, 300));
    await gesture.moveBy(const Offset(30, 0));
    await gesture.moveBy(const Offset(30, -60));
    await tester.pump();
    await closeTapWindow(tester);
    final after = tester.getTopLeft(find.byKey(markerKey));

    // Both axes follow the finger exactly, at any scale.
    expect(after.dx - before.dx, closeTo(60, 0.5));
    expect(after.dy - before.dy, closeTo(-60, 0.5));
    await gesture.up();
  });

  testWidgets('a pan cannot pull a magnified page off its content', (
    tester,
  ) async {
    const markerKey = ValueKey('page');
    await tester.pumpWidget(
      subject(
        contentSize: (viewport) => viewport,
        scrollable: const Center(
          child: SizedBox(key: markerKey, width: 400, height: 600),
        ),
      ),
    );
    await tester.pump();

    final a = await tester.startGesture(const Offset(150, 300), pointer: 1);
    final b = await tester.startGesture(const Offset(250, 300), pointer: 2);
    await tester.pump();
    await a.moveTo(const Offset(50, 300));
    await tester.pump();
    await a.up();
    await b.up();
    await tester.pumpAndSettle();

    // Haul the page far past its own edges, both ways.
    final down = await tester.startGesture(const Offset(200, 300));
    await down.moveBy(const Offset(100, 100));
    await down.moveBy(const Offset(3000, 3000));
    await tester.pump();
    await down.up();
    await tester.pumpAndSettle();
    // Past the bottom-right corner the page simply stops: the top-left of the
    // page is showing and there is nothing further to give.
    expect(translate, Offset.zero);

    final up = await tester.startGesture(const Offset(200, 300));
    await up.moveBy(const Offset(-100, -100));
    await up.moveBy(const Offset(-3000, -3000));
    await tester.pump();
    await up.up();
    await tester.pumpAndSettle();
    // The other extreme: at 2x on a 400x600 page there is 200px of horizontal
    // and 300px of vertical slack, which is 400 and 600 painted pixels.
    expect(translate.dx, closeTo(-400, 1));
    expect(translate.dy, closeTo(-600, 1));
  });

  testWidgets("a magnified pan's horizontal velocity coasts like a scroll", (
    tester,
  ) async {
    const markerKey = ValueKey('page');
    await tester.pumpWidget(
      subject(
        contentSize: (viewport) => viewport,
        scrollable: const Center(
          child: SizedBox(key: markerKey, width: 400, height: 600),
        ),
      ),
    );
    await tester.pump();

    // Zoom to 2x with a horizontal-only pinch.
    final a = await tester.startGesture(const Offset(150, 300), pointer: 1);
    final b = await tester.startGesture(const Offset(250, 300), pointer: 2);
    await tester.pump();
    await a.moveTo(const Offset(50, 300));
    await tester.pump();
    await a.up();
    await b.up();
    await tester.pumpAndSettle();
    expect(scale, closeTo(2, 0.01));

    // Drag left and let go mid-flick. The moves carry real timestamps and come
    // in threes, because the framework's velocity estimator needs a few
    // samples, exactly as it does for an ordinary drag. The pinch itself pans
    // the view (its focal moved), leaving ~75 content px of slack on this
    // side; the drag stays inside it so the flick has room to coast.
    final gesture = await tester.startGesture(const Offset(200, 300));
    await gesture.moveBy(
      const Offset(-20, 0),
      timeStamp: const Duration(milliseconds: 8),
    );
    await gesture.moveBy(
      const Offset(-20, 0),
      timeStamp: const Duration(milliseconds: 16),
    );
    await gesture.moveBy(
      const Offset(-50, 0),
      timeStamp: const Duration(milliseconds: 24),
    );
    await tester.pump(const Duration(milliseconds: 16));
    final atRelease = translate;
    await gesture.up();
    // The ticker's first tick lands with no elapsed time; the coast moves
    // from the second frame on.
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));

    // The release velocity carries: the page keeps travelling the way the
    // drag was heading instead of stopping dead under the finger.
    expect(translate.dx, lessThan(atRelease.dx));

    await tester.pumpAndSettle(const Duration(milliseconds: 16));
    // At rest, against the content's far edge: 2x on a 400px page leaves 200
    // content px of slack, which is 400 painted pixels.
    final settled = translate;
    expect(settled.dx, closeTo(-400, 1));
    await tester.pump(const Duration(milliseconds: 100));
    expect(translate.dx, closeTo(settled.dx, 0.5));
  });

  testWidgets('the horizontal coast hard-clips at the content edges', (
    tester,
  ) async {
    const markerKey = ValueKey('page');
    await tester.pumpWidget(
      subject(
        contentSize: (viewport) => viewport,
        scrollable: const Center(
          child: SizedBox(key: markerKey, width: 400, height: 600),
        ),
      ),
    );
    await tester.pump();

    // Zoom to 2x with a horizontal-only pinch.
    final a = await tester.startGesture(const Offset(150, 300), pointer: 1);
    final b = await tester.startGesture(const Offset(250, 300), pointer: 2);
    await tester.pump();
    await a.moveTo(const Offset(50, 300));
    await tester.pump();
    await a.up();
    await b.up();
    await tester.pumpAndSettle();

    // A hot flick released while the view already sits against the far edge:
    // the drag was clamped there, so the coast starts with nothing but the
    // finger's velocity pointing out of the content.
    final gesture = await tester.startGesture(const Offset(200, 300));
    await gesture.moveBy(
      const Offset(-20, 0),
      timeStamp: const Duration(milliseconds: 8),
    );
    await gesture.moveBy(
      const Offset(-20, 0),
      timeStamp: const Duration(milliseconds: 16),
    );
    await gesture.moveBy(
      const Offset(-3000, 0),
      timeStamp: const Duration(milliseconds: 24),
    );
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.up();

    // Sample every coast frame: the view must never paint past the content's
    // edge — no black strip beyond it — and must not spring back; the coast
    // loses its velocity at the bound.
    var worst = 0.0;
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      worst = math.min(worst, translate.dx);
    }
    expect(worst, greaterThan(-400.5));

    await tester.pumpAndSettle(const Duration(milliseconds: 16));
    // At rest exactly against the content's far edge: 400 painted px at 2x.
    expect(translate.dx, closeTo(-400, 1));
    await tester.pump(const Duration(milliseconds: 100));
    expect(translate.dx, closeTo(-400, 0.5));

    // The leading edge, symmetric: a hot rightward flick released against it
    // cannot paint past it either.
    final back = await tester.startGesture(const Offset(200, 300));
    await back.moveBy(
      const Offset(20, 0),
      timeStamp: const Duration(milliseconds: 8),
    );
    await back.moveBy(
      const Offset(20, 0),
      timeStamp: const Duration(milliseconds: 16),
    );
    await back.moveBy(
      const Offset(3000, 0),
      timeStamp: const Duration(milliseconds: 24),
    );
    await tester.pump(const Duration(milliseconds: 16));
    await back.up();
    var best = 0.0;
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      best = math.max(best, translate.dx);
    }
    expect(best, lessThan(0.5));
    await tester.pumpAndSettle(const Duration(milliseconds: 16));
    expect(translate.dx, closeTo(0, 1));
  });

  testWidgets('a touch stops the horizontal coast and pans from there', (
    tester,
  ) async {
    const markerKey = ValueKey('page');
    await tester.pumpWidget(
      subject(
        contentSize: (viewport) => viewport,
        scrollable: const Center(
          child: SizedBox(key: markerKey, width: 400, height: 600),
        ),
      ),
    );
    await tester.pump();

    final a = await tester.startGesture(const Offset(150, 300), pointer: 1);
    final b = await tester.startGesture(const Offset(250, 300), pointer: 2);
    await tester.pump();
    await a.moveTo(const Offset(50, 300));
    await tester.pump();
    await a.up();
    await b.up();
    await tester.pumpAndSettle();

    // Flick right and let the coast start. A gentle flick keeps the coast
    // short and in-range, so the follow-up pan cannot clamp.
    final gesture = await tester.startGesture(const Offset(200, 300));
    await gesture.moveBy(
      const Offset(8, 0),
      timeStamp: const Duration(milliseconds: 8),
    );
    await gesture.moveBy(
      const Offset(8, 0),
      timeStamp: const Duration(milliseconds: 16),
    );
    await gesture.moveBy(
      const Offset(20, 0),
      timeStamp: const Duration(milliseconds: 24),
    );
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.up();
    // The ticker's first tick lands with no elapsed time; the coast moves
    // from the second frame on.
    await tester.pump(const Duration(milliseconds: 16));
    final coasting = translate;
    await tester.pump(const Duration(milliseconds: 32));
    // The coast runs on: the view keeps travelling after the finger lifted.
    final coasted = translate;
    expect(coasted.dx, greaterThan(coasting.dx));

    // A touch takes the view over: the coast stops...
    final hand = await tester.startGesture(const Offset(200, 300));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));
    final stopped = translate;
    await tester.pump(const Duration(milliseconds: 16));
    expect(translate.dx, closeTo(stopped.dx, 0.5));

    // ...and the pan continues 1:1 from wherever the coast had reached.
    await hand.moveBy(const Offset(20, 0));
    await tester.pump(const Duration(milliseconds: 16));
    expect(translate.dx, closeTo(stopped.dx + 20, 0.5));
    await hand.up();
    await tester.pumpAndSettle(const Duration(milliseconds: 16));
  });

  testWidgets('a slow magnified pan stops where the finger lifted', (
    tester,
  ) async {
    const markerKey = ValueKey('page');
    await tester.pumpWidget(
      subject(
        contentSize: (viewport) => viewport,
        scrollable: const Center(
          child: SizedBox(key: markerKey, width: 400, height: 600),
        ),
      ),
    );
    await tester.pump();

    final a = await tester.startGesture(const Offset(150, 300), pointer: 1);
    final b = await tester.startGesture(const Offset(250, 300), pointer: 2);
    await tester.pump();
    await a.moveTo(const Offset(50, 300));
    await tester.pump();
    await a.up();
    await b.up();
    await tester.pumpAndSettle();

    // A drag without timestamps carries no velocity the tracker can see —
    // below the flick threshold the pan keeps the old contract and freezes.
    final gesture = await tester.startGesture(const Offset(200, 300));
    await gesture.moveBy(const Offset(-30, 0));
    await gesture.moveBy(const Offset(-30, 0));
    await tester.pump();
    await closeTapWindow(tester);
    final atRelease = translate;
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 350));

    expect(translate, atRelease);
  });

  testWidgets('the controller gives a magnified view back to the reader', (
    tester,
  ) async {
    final controller = ReaderZoomController();
    await tester.pumpWidget(
      subject(
        controller: controller,
        scrollable: ListView(children: const [SizedBox(height: 3000)]),
      ),
    );
    await tester.pump();

    final a = await tester.startGesture(const Offset(150, 300), pointer: 1);
    final b = await tester.startGesture(const Offset(250, 300), pointer: 2);
    await tester.pump();
    await a.moveTo(const Offset(50, 300));
    await tester.pump();
    await a.up();
    await b.up();
    await tester.pumpAndSettle();

    expect(controller.isZoomed, isTrue);
    expect(scale, greaterThan(1));

    controller.reset();
    await tester.pumpAndSettle();

    expect(controller.isZoomed, isFalse);
    expect(scale, closeTo(1, 0.01));
    expect(translate, Offset.zero);
    expect(scrollingEnabled, isTrue, reason: 'the list gets its drag back');
  });

  testWidgets('a tap still fires once the view is magnified', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      subject(
        onTapUp: (_) => taps++,
        scrollable: const Center(child: SizedBox(width: 400, height: 600)),
      ),
    );
    await tester.pump();

    final a = await tester.startGesture(const Offset(150, 300), pointer: 1);
    final b = await tester.startGesture(const Offset(250, 300), pointer: 2);
    await tester.pump();
    await a.moveTo(const Offset(50, 300));
    await tester.pump();
    await a.up();
    await b.up();
    await tester.pumpAndSettle();

    // The pinch's stationary finger armed the double-tap window; let it
    // close before tapping, or the tap reads as its second tap.
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tapAt(tester.getCenter(find.byType(SizedBox).last));
    // A single tap resolves only once the double-tap window has closed.
    await tester.pump(const Duration(milliseconds: 350));

    expect(taps, 1);
  });

  testWidgets('a double tap zooms without leaking the single-tap action', (
    tester,
  ) async {
    // Guards the framework disambiguation the HUD relies on: the reader hands
    // the HUD toggle in as `onTapUp`, so a double tap that leaked it would
    // dismiss the overlay mid-zoom.
    var taps = 0;
    await tester.pumpWidget(
      subject(
        onTapUp: (_) => taps++,
        scrollable: const Center(child: SizedBox(width: 400, height: 600)),
      ),
    );
    await tester.pump();

    await tester.tapAt(const Offset(200, 300));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tapAt(const Offset(200, 300));
    await tester.pumpAndSettle();

    expect(taps, 0, reason: 'a double tap never leaks the single-tap action');
    expect(scale, closeTo(2.5, 0.01), reason: 'the double tap zoomed instead');
  });

  testWidgets('with the double tap disabled, taps resolve immediately', (
    tester,
  ) async {
    // The reader disables the double tap while its overlay is up: the toggle
    // then lands the moment the finger lifts, and a second quick tap cannot
    // zoom by accident — it is just another tap.
    var taps = 0;
    await tester.pumpWidget(
      subject(
        onTapUp: (_) => taps++,
        doubleTapEnabled: false,
        scrollable: const Center(child: SizedBox(width: 400, height: 600)),
      ),
    );
    await tester.pump();

    await tester.tapAt(const Offset(200, 300));
    await tester.pump(const Duration(milliseconds: 50));
    expect(taps, 1, reason: 'no double-tap window to wait out');

    await tester.tapAt(const Offset(200, 300));
    await tester.pump(const Duration(milliseconds: 50));
    expect(taps, 2);
    expect(scale, 1, reason: 'a double tap no longer zooms');
  });

  testWidgets('the scale is clamped at both ends', (tester) async {
    await tester.pumpWidget(
      subject(scrollable: ListView(children: const [SizedBox(height: 3000)])),
    );
    await tester.pump();

    Future<double> pinch(double from, double to) async {
      final a = await tester.startGesture(
        Offset(from, 300),
        pointer: math.max(from, to).toInt(),
      );
      final b = await tester.startGesture(
        Offset(from + 100, 300),
        pointer: math.max(from, to).toInt() + 1,
      );
      await tester.pump();
      await a.moveTo(Offset(to, 300));
      await tester.pump();
      await a.up();
      await b.up();
      await tester.pumpAndSettle();
      return scale;
    }

    expect(await pinch(150, -450), lessThanOrEqualTo(4));
    expect(await pinch(50, 250), greaterThanOrEqualTo(1));
  });

  group('double-tap zoom', () {
    /// Two taps close enough together to read as a double tap. The first tap's
    /// up starts the disambiguation window; the second lands inside it, past
    /// the minimum spacing between the two. Returns the second tap's position
    /// — the focal the zoom keeps under the finger.
    Future<Offset> doubleTap(WidgetTester tester, Offset at) async {
      final focal = at + const Offset(5, 5);
      await tester.tapAt(at);
      await tester.pump(const Duration(milliseconds: 60));
      await tester.tapAt(focal);
      return focal;
    }

    testWidgets('a double tap magnifies around the tapped point and spares '
        'the single tap', (tester) async {
      final taps = <Offset>[];
      await tester.pumpWidget(
        subject(
          onTapUp: taps.add,
          doubleTapScale: 3,
          contentSize: (viewport) => viewport,
          scrollable: const Center(child: SizedBox(width: 400, height: 600)),
        ),
      );
      await tester.pump();

      final focal = await doubleTap(tester, const Offset(300, 450));
      await tester.pumpAndSettle();

      expect(taps, isEmpty, reason: 'a double tap is not two taps');
      expect(scale, closeTo(3, 0.01));
      // The content under the second tap stays under it: at 1x that content
      // was the focal itself, and 3x pulls the view origin back to 2/3 of it.
      expect(translate.dx, closeTo(-focal.dx * 2, 1));
      expect(translate.dy, closeTo(-focal.dy * 2, 1));
      expect(scrollingEnabled, isFalse, reason: 'the magnified view pans');
    });

    testWidgets('a second double tap recovers the fitted view', (tester) async {
      final taps = <Offset>[];
      await tester.pumpWidget(
        subject(
          onTapUp: taps.add,
          doubleTapScale: 3,
          contentSize: (viewport) => viewport,
          scrollable: const Center(child: SizedBox(width: 400, height: 600)),
        ),
      );
      await tester.pump();

      await doubleTap(tester, const Offset(300, 450));
      await tester.pumpAndSettle();
      expect(scale, closeTo(3, 0.01));

      // The next tap pair starts a fresh disambiguation cycle.
      await tester.pump(const Duration(milliseconds: 300));
      await doubleTap(tester, const Offset(200, 300));
      await tester.pumpAndSettle();

      expect(taps, isEmpty);
      expect(scale, closeTo(1, 0.01));
      expect(translate, Offset.zero);
      expect(scrollingEnabled, isTrue, reason: 'the list gets its drag back');
    });

    testWidgets('single taps still arrive, one per window', (tester) async {
      final taps = <Offset>[];
      await tester.pumpWidget(
        subject(
          onTapUp: taps.add,
          scrollable: const Center(child: SizedBox(width: 400, height: 600)),
        ),
      );
      await tester.pump();

      await tester.tapAt(const Offset(100, 200));
      await tester.pump(const Duration(milliseconds: 350));
      expect(taps, const [Offset(100, 200)]);

      // A second tap only after the first window closed: two single taps,
      // never a zoom.
      await tester.tapAt(const Offset(250, 350));
      await tester.pump(const Duration(milliseconds: 350));
      expect(taps, const [Offset(100, 200), Offset(250, 350)]);
      expect(scale, 1);
    });

    testWidgets('a page-turn reset cuts a running zoom animation short', (
      tester,
    ) async {
      final controller = ReaderZoomController();
      await tester.pumpWidget(
        subject(
          controller: controller,
          scrollable: const Center(child: SizedBox(width: 400, height: 600)),
        ),
      );
      await tester.pump();

      await doubleTap(tester, const Offset(300, 450));
      // Two frames: the ticker records its start on the first, so only the
      // second one carries animation progress.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(controller.isZoomed, isTrue, reason: 'mid-animation');

      controller.reset();
      await tester.pump();

      expect(controller.isZoomed, isFalse);
      expect(scale, closeTo(1, 0.01));
      expect(translate, Offset.zero);
    });
  });
}
