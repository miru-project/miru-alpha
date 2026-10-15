import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:logging/logging.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';

void main() {
  // Both apps share the router's root navigator key — the exact context the
  // toast helpers read — so each test pumps its own MaterialApp around it.
  Widget app({required bool toaster}) => MaterialApp(
    navigatorKey: RouterUtil.rootNavigatorKey,
    builder: (context, child) => FTheme(
      data: MiruThemes.neutral.light.desktop,
      child: toaster ? FToaster(child: child!) : child!,
    ),
    home: const Scaffold(body: SizedBox.shrink()),
  );

  testWidgets('a toast renders when the FToaster is mounted', (tester) async {
    await tester.pumpWidget(app(toaster: true));

    showSimpleToast('Saved');

    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('a toast without an FToaster is dropped, not thrown', (
    tester,
  ) async {
    final warnings = <LogRecord>[];
    final sub = Logger.root.onRecord.listen(warnings.add);
    await tester.pumpWidget(app(toaster: false));

    showSimpleToast('Saved');

    await tester.pump();
    sub.cancel();
    expect(tester.takeException(), isNull);
    expect(find.text('Saved'), findsNothing);
    expect(warnings.map((r) => r.message), contains(contains('FToaster')));
  });

  testWidgets('iconsMessageToast also survives a missing FToaster', (
    tester,
  ) async {
    await tester.pumpWidget(app(toaster: false));

    iconsMessageToast(title: 'Downloading', icon: Icons.download);

    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Downloading'), findsNothing);
  });
}
