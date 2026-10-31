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
    VoidCallback? onTap,
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
            onTap: onTap,
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
        onTap: () => taps++,
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

    await tester.tapAt(tester.getCenter(find.byType(SizedBox).last));
    await tester.pumpAndSettle();

    expect(taps, 1);
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
}
