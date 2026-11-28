import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/features/setting/widget/setting_base_tile.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

Widget _harness(Widget child) => FTheme(
  data: ThemeUtils.getThemeData(MiruThemes.zinc.dark),
  child: MaterialApp(
    navigatorKey: RouterUtil.rootNavigatorKey,
    supportedLocales: FLocalizations.supportedLocales,
    localizationsDelegates: [
      I18nUtils.flutterI18nDelegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    home: Scaffold(body: child),
  ),
);

Widget _control() => const ColoredBox(
  key: ValueKey('control-slot'),
  color: Color(0xFF00E5FF),
);

/// Pumps a tile whose single-line label is wider than the column the old
/// fixed-300px control slot left it.
Future<(Rect, Rect)> _pumpAndMeasure(
  WidgetTester tester,
  double tileWidth,
) async {
  await tester.binding.setSurfaceSize(Size(tileWidth + 40, 700));
  addTearDown(() async => tester.binding.setSurfaceSize(null));
  MiruSettings.seedDefaultsForTest();

  await tester.pumpWidget(
    _harness(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SettingBaseTile(
          // A deliberately long, unbreakable-ish label.
          title: 'settings.player.subtitle_background_opacity',
          child: _control(),
        ),
      ),
    ),
  );
  await tester.pump();

  final label = tester.getRect(
    find.descendant(of: find.byType(SettingBaseTile), matching: find.byType(Text)).first,
  );
  final control = tester.getRect(find.byKey(const ValueKey('control-slot')));
  return (label, control);
}

void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);

  testWidgets('side-by-side row keeps the label clear of the control', (
    tester,
  ) async {
    // 620px is above the stack threshold, so this exercises the Row path —
    // the layout that used to starve the label behind a fixed 300px slot.
    final (label, control) = await _pumpAndMeasure(tester, 620);
    expect(tester.takeException(), isNull);
    expect(
      label.right,
      lessThanOrEqualTo(control.left),
      reason: 'label overlaps the control in the side-by-side row',
    );
    expect(label.width, greaterThan(120), reason: 'label column collapsed');
  });

  testWidgets('narrow tile keeps label and control on one line', (
    tester,
  ) async {
    final (label, control) = await _pumpAndMeasure(tester, 360);
    expect(tester.takeException(), isNull);
    // One line: the control sits BESIDE the label, and the two never overlap.
    expect(label.right, lessThanOrEqualTo(control.left));
    // No description row in the compact layout, so the row stays short.
    expect(label.height, lessThan(30));
  });
}
