import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:miru_alpha/app_bootstrap.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

/// Inert ApplicationController: build() must not touch MiruSettings (settings
/// storage is uninitialized in widget tests). Everything else — including the
/// real setMobilePreviewWidth theme path — stays genuine.
class _StubController extends ApplicationController {
  @override
  ApplicationState build() => ApplicationState(
    themeText: 'dark',
    baseColor: 'zinc',
    primaryColor: 'none',
    themeData: MiruThemes.neutral.light.desktop,
    themeMode: ThemeMode.dark,
    language: 'en',
  );
}

/// Records the MediaQuery size it renders with and how often it mounted.
class _Probe extends StatefulWidget {
  const _Probe();

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  static int mounts = 0;

  @override
  void initState() {
    super.initState();
    mounts++;
  }

  @override
  Widget build(BuildContext context) {
    probedSize = MediaQuery.sizeOf(context);
    return const SizedBox.shrink();
  }
}

Size probedSize = Size.zero;

void main() {
  setUp(() {
    probedSize = Size.zero;
    _ProbeState.mounts = 0;
  });

  tearDown(() {
    ThemeUtils.mobilePreviewWidth = null;
  });

  // Window sized like the desktop launch (1300x800, dpr 1) so the desktop
  // passthrough frame equals the real window exactly (rule: rule 27 sizing).
  Future<void> pumpShell(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1300, 800);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          applicationControllerProvider.overrideWith(_StubController.new),
        ],
        child: MediaQuery(
          data: const MediaQueryData(size: Size(1300, 800)),
          child: MiruMobilePreviewShell(child: const _Probe()),
        ),
      ),
    );
    await tester.pump(); // initState microtask -> initial provider write
  }

  Future<void> pressCombo(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyDownEvent(key);
    await tester.pump();
  }

  testWidgets(
    'default renders the 412x915 phone frame with touch-theme width',
    (tester) async {
      await pumpShell(tester);

      expect(probedSize, const Size(412, 915));
      expect(ThemeUtils.mobilePreviewWidth, 412.0);
      expect(_ProbeState.mounts, 1);
    },
  );

  testWidgets(
    'Ctrl+Shift+D toggles desktop passthrough and back without remounting',
    (tester) async {
      await pumpShell(tester);

      await pressCombo(tester, LogicalKeyboardKey.keyD);

      // Full-bleed at the real window: the width breakpoints (forui lg 1024)
      // now see the desktop size, theme resolves against the real window.
      expect(probedSize, const Size(1300, 800));
      expect(ThemeUtils.mobilePreviewWidth, isNull);
      expect(_ProbeState.mounts, 1);

      await pressCombo(tester, LogicalKeyboardKey.keyD);

      expect(probedSize, const Size(412, 915));
      expect(ThemeUtils.mobilePreviewWidth, 412.0);
      expect(_ProbeState.mounts, 1);
    },
  );

  testWidgets('Ctrl+Shift+P swaps portrait/landscape (unchanged)', (
    tester,
  ) async {
    await pumpShell(tester);

    await pressCombo(tester, LogicalKeyboardKey.keyP);

    expect(probedSize, const Size(915, 412));
    expect(ThemeUtils.mobilePreviewWidth, 915.0);
    expect(_ProbeState.mounts, 1);
  });
}
