import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
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
void main() {
  Widget wrap(Widget child) => FTheme(
    data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
    child: MaterialApp(home: Scaffold(body: child)),
  );

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
            itemBuilder: (context, index) => SizedBox(
              width: 120,
              child: Text('item $index'),
            ),
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
            itemBuilder: (context, index) => SizedBox(
              height: 60,
              child: Text('item $index'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.drag(find.byType(ListView), const Offset(0, 240));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
  });
}
