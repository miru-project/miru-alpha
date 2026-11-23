import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_zoom_surface.dart';

/// A pointer release that arrives after the surface was torn down must not
/// throw.
///
/// The canvas unmounts mid-gesture on a chapter flip, while the ticker teardown
//  is still in flight. `_onPointerUp` called `setState` unconditionally, which
// threw "Null check operator used on a null value" from `State.setState` —
// the SEVERE in the field logs.
void main() {
  testWidgets('pointer up after unmount does not call setState', (
    tester,
  ) async {
    late ReaderZoomController controller;

    Widget build() => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 400,
          child: ReaderZoomSurface(
            controller: controller,
            builder: (context, zoom) => zoom.wrap(
              SizedBox(
                height: 1200,
                child: ListView.builder(
                  itemCount: 12,
                  itemBuilder: (context, index) => Container(
                    key: ValueKey('item-$index'),
                    height: 100,
                    color: index.isEven ? Colors.red : Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    controller = ReaderZoomController();
    await tester.pumpWidget(build());
    await tester.pumpAndSettle();

    // Start a drag so a pointer is down.
    final gesture = await tester.startGesture(const Offset(200, 300));
    await gesture.moveBy(const Offset(0, -120));
    await tester.pump();

    // Tear the surface down mid-gesture, then let the pointer up land.
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump();

    // The original implementation threw here: State.setState on a defunct
    // element. Reaching this line at all is the assertion.
    await gesture.up();
    await tester.pump();
    // Drain the double-tap disambiguation timer so the binding has no
    // pending work at teardown.
    await tester.pump(const Duration(milliseconds: 350));

    expect(tester.takeException(), isNull);
  });

  testWidgets('two-finger pointer down after unmount is also safe', (
    tester,
  ) async {
    late ReaderZoomController controller;

    Widget build() => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 400,
          child: ReaderZoomSurface(
            controller: controller,
            builder: (context, zoom) => zoom.wrap(
              SizedBox(
                height: 1200,
                child: ListView.builder(
                  itemCount: 12,
                  itemBuilder: (context, index) =>
                      Container(key: ValueKey('two-$index'), height: 100),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    controller = ReaderZoomController();
    await tester.pumpWidget(build());
    await tester.pumpAndSettle();

    final first = await tester.startGesture(const Offset(150, 300));
    await tester.pump();
    final second = await tester.startGesture(const Offset(250, 300));
    await tester.pump();

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump();

    await first.up();
    await second.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(tester.takeException(), isNull);
  });
}
