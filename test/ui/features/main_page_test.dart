import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/backend_connection_provider.dart';
import 'package:miru_alpha/ui/features/main_page.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

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

/// Resolved gate that mimics the real one's appearance reload: the app
/// controller re-reads the settings cache, which on a fresh start flips
/// MaterialApp's language key (seeded 'en' -> saved locale) and remounts the
/// app while this dialog flow is in flight. The reload lands AFTER a await,
/// like the real gate (Riverpod forbids provider writes during the
/// synchronous build phase).
class _FakeBackendConnection extends BackendConnection {
  @override
  Future<void> build() async {
    await Future<void>.value();
    ref.read(applicationControllerProvider.notifier).reloadFromSettings();
  }
}

class _FakePickerPlatform extends FilePickerPlatform {
  int calls = 0;

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    String? initialDirectory,
    AndroidOptions androidOptions = const AndroidOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    calls++;
    return '/tmp/picked-directory';
  }
}

void main() {
  setUp(() {
    MiruSettings.seedDefaultsForTest();
  });

  tearDown(() {
    ThemeUtils.mobilePreviewWidth = null;
  });

  /// Fresh-app-data flow: no download path saved, the gate resolves and the
  /// auto dialog offers the directory picker.
  Future<ProviderContainer> pumpMainPage(WidgetTester tester) async {
    // Desktop-platform runner: `DeviceUtil.isMobile` is false (dart:io
    // Platform), so MainPage renders the desktop window chrome — size the
    // surface where that chrome fits (the real phone skips it entirely).
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1300, 800);
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        backendConnectionProvider.overrideWith(_FakeBackendConnection.new),
        applicationControllerProvider.overrideWith(_StubController.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: FTheme(
          data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
          child: MaterialApp.router(
            routerConfig: GoRouter(
              navigatorKey: GlobalKey<NavigatorState>(),
              routes: [GoRoute(path: '/', builder: (_, _) => const MainPage())],
            ),
          ),
        ),
      ),
    );
    // Effect microtask -> gate -> settled frame -> dialog route entrance.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return container;
  }

  testWidgets(
    'fresh start: picking a directory closes the dialog, not the page',
    (tester) async {
      final picker = _FakePickerPlatform();
      final previousPlatform = FilePickerPlatform.instance;
      FilePickerPlatform.instance = picker;
      addTearDown(() => FilePickerPlatform.instance = previousPlatform);

      final container = await pumpMainPage(tester);

      // The auto dialog is up (fresh data: no download path saved).
      expect(
        find.text('settings.download_directory'),
        findsOneWidget,
        reason: 'fresh app data shows the download-directory dialog once',
      );

      await tester.tap(find.text('settings.select_directory'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(picker.calls, 1);
      expect(
        MiruSettings.getSettingSync<String>('DownloadPath'),
        '/tmp/picked-directory',
        reason: 'the picked path persists',
      );
      expect(
        find.text('settings.download_directory'),
        findsNothing,
        reason: 'the dialog closed',
      );
      // The app survived: the shell page is still mounted and interactive.
      expect(tester.takeException(), isNull);
      expect(container.read(backendConnectionProvider).hasValue, isTrue);
      expect(find.byType(MainPage), findsOneWidget);
    },
  );

  testWidgets(
    'fresh start with a saved locale: the gate remount still lands one dialog and the pick closes it',
    (tester) async {
      // The user's device: a persisted non-default language. The gate's
      // appearance reload flips MaterialApp's language key (full remount)
      // while the dialog flow is starting.
      MiruSettings.setSettingSync(SettingKey.language, 'zh');
      final picker = _FakePickerPlatform();
      final previousPlatform = FilePickerPlatform.instance;
      FilePickerPlatform.instance = picker;
      addTearDown(() => FilePickerPlatform.instance = previousPlatform);

      await pumpMainPage(tester);
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('settings.download_directory'),
        findsOneWidget,
        reason: 'exactly one dialog on the live tree after the remount',
      );

      await tester.tap(find.text('settings.select_directory'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(picker.calls, 1);
      expect(
        MiruSettings.getSettingSync<String>('DownloadPath'),
        '/tmp/picked-directory',
      );
      expect(find.text('settings.download_directory'), findsNothing);
      expect(tester.takeException(), isNull);
      expect(find.byType(MainPage), findsOneWidget);
    },
  );
}
