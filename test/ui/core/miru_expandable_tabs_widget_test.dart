import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/core/miru_expandable_tabs.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

void main() {
  Future<void> pumpWidget(WidgetTester tester, {int selectedIndex = 0}) async {
    await tester.binding.setSurfaceSize(const Size(400, 600));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      FTheme(
        data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: MiruExpandableTabs(
                  selectedIndex: selectedIndex,
                  children: [
                    MiruExpandableTabEntry(
                      icon: const Icon(FLucideIcons.heart),
                      label: const Text('Tab One'),
                    ),
                    MiruExpandableTabEntry(
                      icon: const Icon(FLucideIcons.book),
                      label: const Text('Tab Two'),
                    ),
                    MiruExpandableTabEntry(
                      icon: const Icon(FLucideIcons.gift),
                      label: const Text('Tab Three'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders expandable icon pills full-width', (tester) async {
    await pumpWidget(tester);

    expect(find.byIcon(FLucideIcons.heart), findsOneWidget);
    expect(find.byIcon(FLucideIcons.book), findsOneWidget);
    expect(find.byIcon(FLucideIcons.gift), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('first pill is active by default', (tester) async {
    await pumpWidget(tester);

    // The active pill label is visible; inactive labels are collapsed
    expect(find.text('Tab One'), findsOneWidget);
  });

  testWidgets('active pill can be controlled externally', (tester) async {
    await pumpWidget(tester, selectedIndex: 1);

    expect(find.text('Tab Two'), findsOneWidget);
  });

  testWidgets('onIndexChanged fires when a pill is tapped', (tester) async {
    int? tapped;
    await tester.binding.setSurfaceSize(const Size(400, 600));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      FTheme(
        data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: MiruExpandableTabs(
                  selectedIndex: 0,
                  onIndexChanged: (i) => tapped = i,
                  children: [
                    MiruExpandableTabEntry(
                      icon: const Icon(FLucideIcons.heart),
                      label: const Text('Tab One'),
                    ),
                    MiruExpandableTabEntry(
                      icon: const Icon(FLucideIcons.book),
                      label: const Text('Tab Two'),
                    ),
                    MiruExpandableTabEntry(
                      icon: const Icon(FLucideIcons.gift),
                      label: const Text('Tab Three'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(FLucideIcons.book));
    await tester.pump();

    expect(tapped, 1);
    expect(tester.takeException(), isNull);
  });
}
