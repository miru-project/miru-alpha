import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/scrollable_positioned_list.dart';

/// Harness for the in-repo fork's prepend handling: items inserted before
/// the positioned item must keep the same logical item at the same anchor,
/// i.e. the content on screen does not move a pixel.
class _Harness extends StatefulWidget {
  const _Harness();

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  final itemController = ItemScrollController();
  final itemPositionsListener = ItemPositionsListener.create();
  int itemCount = 6;

  void insertBefore(int count) {
    setState(() => itemCount += count);
    itemController.notifyItemsInsertedBefore(count);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 200,
          child: ScrollablePositionedList.builder(
            itemScrollController: itemController,
            itemPositionsListener: itemPositionsListener,
            itemCount: itemCount,
            itemBuilder: (context, index) => SizedBox(
              key: ValueKey('item-$index'),
              height: 100,
              child: ColoredBox(
                color: index.isEven ? Colors.orange : Colors.teal,
                child: Text('item $index'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Iterable<ItemPosition> _positions(_HarnessState state) =>
    state.itemPositionsListener.itemPositions.value;

ItemPosition? _at(Iterable<ItemPosition> positions, int index) {
  for (final p in positions) {
    if (p.index == index) return p;
  }
  return null;
}

void main() {
  testWidgets('prepend keeps the same logical item at the same anchor', (
    tester,
  ) async {
    await tester.pumpWidget(const _Harness());
    await tester.pumpAndSettle();

    final harness = tester.state<_HarnessState>(find.byType(_Harness));

    // Land on item 2; it anchors to the top of the viewport.
    harness.itemController.jumpTo(index: 2);
    await tester.pumpAndSettle();

    final before = _positions(harness).toList();
    final targetBefore = _at(before, 2);
    expect(targetBefore, isNotNull);
    expect(targetBefore!.itemLeadingEdge, closeTo(0, 0.01));

    // Three items are prepended above it.
    harness.insertBefore(3);
    await tester.pumpAndSettle();

    final after = _positions(harness).toList();
    final targetAfter = _at(after, 5);
    expect(targetAfter, isNotNull);
    // Same logical item, same anchor: insertion moved nothing on screen.
    expect(targetAfter!.itemLeadingEdge, closeTo(0, 0.01));

    // The fork's own jump API still works afterwards.
    harness.itemController.jumpTo(index: 0);
    await tester.pumpAndSettle();
    final reset = _positions(harness).toList();
    expect(_at(reset, 0)!.itemLeadingEdge, closeTo(0, 0.01));
  });
}
