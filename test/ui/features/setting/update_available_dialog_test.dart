import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/provider/app_update_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/features/setting/widget/update_available_dialog.dart';
import 'package:miru_alpha/ui/features/setting/widget/update_prompt_listener.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:miru_alpha/utils/update/miru_release.dart';

MiruRelease _release({String version = '2.1.0', String body = ''}) =>
    MiruRelease(
      tagName: 'v$version',
      name: 'Miru Alpha $version',
      htmlUrl: 'https://example.test/releases/v$version',
      body: body,
      publishedAt: DateTime.utc(2026, 11, 19),
      assets: [
        MiruReleaseAsset(
          name: 'Miru-Alpha-linux.tar.gz',
          size: 1024,
          downloadUrl: 'https://example.test/linux.tar.gz',
        ),
      ],
    );

/// A notifier whose state the test owns. `refresh` re-runs [build], so a test
/// can move the flow on (e.g. drop the release under an open dialog) the way a
/// background re-check would.
class _SeededAppUpdate extends AppUpdate {
  _SeededAppUpdate(this.seed);

  AppUpdateState seed;

  @override
  AppUpdateState build() => seed;
}

class _OpenPromptButton extends ConsumerWidget {
  const _OpenPromptButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: FButton(
          onPress: () => showUpdateAvailableDialog(context, ref),
          child: const Text('open'),
        ),
      ),
    );
  }
}

/// The app's own i18n delegate, so `.i18n` resolves to the shipped English
/// strings. Without it a widget that forgets to translate a key renders the key
/// verbatim and the test cannot tell the difference.
Iterable<LocalizationsDelegate<dynamic>> get _delegates => [
  I18nUtils.flutterI18nDelegate,
  ...GlobalMaterialLocalizations.delegates,
];

Future<({ProviderContainer container, _SeededAppUpdate notifier})> _pumpApp(
  WidgetTester tester, {
  AppUpdateState? seed,
  // The default test window is 800x600 — a desktop width. Passing 412x915 puts
  // the dialog through forui's mobile branch (`sm` is 640), which is the only
  // way to test the phone action set.
  Size size = const Size(800, 600),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final notifier = _SeededAppUpdate(
    seed ??
        AppUpdateState(
          status: UpdateStatus.available,
          currentVersion: '2.0.3-alpha',
          release: _release(),
        ),
  );
  final container = ProviderContainer(
    overrides: [appUpdateProvider.overrideWith(() => notifier)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        // `.i18n` resolves through RouterUtil.rootNavigatorKey rather than the
        // build context, so the app's own key has to be the one here or every
        // string renders as a raw key.
        navigatorKey: RouterUtil.rootNavigatorKey,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: _delegates,
        supportedLocales: FLocalizations.supportedLocales,
        builder: (context, child) => FTheme(
          data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
          child: child!,
        ),
        home: const _OpenPromptButton(),
      ),
    ),
  );
  return (container: container, notifier: notifier);
}

Future<void> _open(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(MiruSettings.seedDefaultsForTest);

  testWidgets('shows the versions, the changelog hint and three actions', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      seed: AppUpdateState(
        status: UpdateStatus.available,
        currentVersion: '2.0.3-alpha',
        release: _release(body: '## What changed\n\n- a thing'),
      ),
    );
    await _open(tester);

    expect(find.text('Update available'), findsOneWidget);
    expect(find.textContaining('ready to install'), findsOneWidget);
    // The promise the ignore button makes, spelled out where it is read — and
    // distinct from the button's own label, which the sentence quotes.
    expect(find.textContaining('hides only this version'), findsOneWidget);
    expect(find.text('Ignore this version'), findsOneWidget);
    // The release body, parsed — a heading and a list item, no markdown source.
    expect(find.textContaining("What changed"), findsOneWidget);
    expect(find.textContaining('a thing'), findsOneWidget);
    expect(find.textContaining('## '), findsNothing);
    // The actions, primary first, and compact — FButton defaults to
    // mainAxisSize.max, so a `Flexible` label silently turned every action
    // into a full-width row.
    final buttons = tester
        .widgetList<FButton>(
          find.descendant(
            of: find.byType(FDialog),
            matching: find.byType(FButton),
          ),
        )
        .toList();
    expect(buttons, hasLength(3));
    for (final button in buttons) {
      expect(tester.getSize(find.byWidget(button)).width, lessThan(260));
    }
  });

  testWidgets('a phone is offered two actions, not three', (tester) async {
    // 412 logical px is below forui's `sm` (640), so this is the layout a
    // phone actually gets — the same branch `FDialog.adaptive` takes.
    await _pumpApp(
      tester,
      size: const Size(412, 915),
      seed: AppUpdateState(
        status: UpdateStatus.available,
        currentVersion: '2.0.3-alpha',
        release: _release(body: '## What changed\n\n- a thing'),
      ),
    );
    await _open(tester);

    expect(find.text('Update now'), findsOneWidget);
    expect(find.text('Ignore this version'), findsOneWidget);
    // No third way to say "not now" on a phone.
    expect(find.text('Later'), findsNothing);

    final buttons = tester
        .widgetList<FButton>(
          find.descendant(
            of: find.byType(FDialog),
            matching: find.byType(FButton),
          ),
        )
        .toList();
    expect(buttons, hasLength(2));
  });

  testWidgets('the phone fine print describes only the action it has', (
    tester,
  ) async {
    // The desktop note spends its first sentence on "Later". On a phone that
    // sentence describes a button which is not on screen.
    await _pumpApp(
      tester,
      size: const Size(412, 915),
      seed: AppUpdateState(
        status: UpdateStatus.available,
        currentVersion: '2.0.3-alpha',
        release: _release(body: '## What changed\n\n- a thing'),
      ),
    );
    await _open(tester);

    expect(find.textContaining('hides only this version'), findsOneWidget);
    expect(find.textContaining('Later leaves the update'), findsNothing);
  });

  testWidgets('drops the ignore explainer once the decision is behind us', (
    tester,
  ) async {
    // The fine print names "Ignore this version", which only exists while the
    // prompt is asking. On the install step it promised a button that is not
    // on screen.
    await _pumpApp(
      tester,
      seed: AppUpdateState(
        status: UpdateStatus.downloaded,
        currentVersion: '2.0.3-alpha',
        release: _release(body: '## What changed\n\n- a thing'),
      ),
    );
    await _open(tester);

    expect(find.text('Restart Miru to apply 2.1.0.'), findsOneWidget);
    expect(find.textContaining('hides only this version'), findsNothing);
    expect(find.text('Ignore this version'), findsNothing);
    expect(find.text('Install'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
  });

  testWidgets(
    'says "Restart now" on desktop, where the build is already unpacked',
    (tester) async {
      // Android hands the APK to the package installer, so "Install" is the
      // honest verb there. The desktop updater has already unpacked the build
      // beside the install, so the same button restarts into it.
      debugUpdatePlatform = UpdatePlatform.linux;
      addTearDown(() => debugUpdatePlatform = null);

      await _pumpApp(
        tester,
        seed: AppUpdateState(
          status: UpdateStatus.downloaded,
          currentVersion: '2.0.3-alpha',
          release: _release(body: '## What changed\n\n- a thing'),
        ),
      );
      await _open(tester);

      expect(find.text('Restart now'), findsOneWidget);
      expect(find.text('Install'), findsNothing);
    },
  );

  testWidgets(
    'reports a failed download as a download failure, not a feed one',
    (tester) async {
      await _pumpApp(
        tester,
        seed: AppUpdateState(
          status: UpdateStatus.failed,
          currentVersion: '2.0.3-alpha',
          release: _release(),
          error: 'settings.update.download_failed',
        ),
      );
      await _open(tester);

      // The error is stored as an i18n *key*; the dialog has to resolve it.
      expect(
        find.textContaining('The download did not finish'),
        findsOneWidget,
      );
      expect(find.textContaining('settings.update.'), findsNothing);
      // And the title follows the same split — the check itself worked.
      expect(find.text('Download failed'), findsOneWidget);
    },
  );

  testWidgets('offers no way to close while the download is running', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      seed: AppUpdateState(
        status: UpdateStatus.downloading,
        currentVersion: '2.0.3-alpha',
        release: _release(),
        progress: 0.42,
      ),
    );
    await _open(tester);

    // A cold launch has no banner behind this dialog, so closing it would hide
    // the only progress readout for a multi-minute download.
    expect(find.text('Later'), findsNothing);
    expect(find.text('Ignore this version'), findsNothing);
    expect(find.text('42% of the new build'), findsOneWidget);
    expect(find.byType(FDeterminateProgress), findsOneWidget);
  });

  testWidgets('closes itself rather than lingering without a release', (
    tester,
  ) async {
    final opened = await _pumpApp(tester);
    await _open(tester);

    // A background re-check that finds nothing clears `release` while the
    // dialog is open; a title with no body and no buttons is a dead end.
    opened.notifier.seed = AppUpdateState(
      status: UpdateStatus.upToDate,
      currentVersion: '2.1.0',
    );
    opened.container.refresh(appUpdateProvider);
    await tester.pumpAndSettle();

    expect(find.byType(FDialog), findsNothing);
  });

  testWidgets('ignore closes the dialog and skips the version', (tester) async {
    final opened = await _pumpApp(tester);
    final container = opened.container;
    await _open(tester);

    await tester.tap(find.text('Ignore this version'));
    await tester.pumpAndSettle();

    final state = container.read(appUpdateProvider);
    expect(state.ignored, isTrue);
    expect(state.promptable, isFalse);
    expect(
      MiruSettings.getSettingSync<String>(SettingKey.ignoredUpdateVersion),
      '2.1.0',
    );
    expect(find.byType(FDialog), findsNothing);
  });

  testWidgets('later postpones the prompt without hiding the banner', (
    tester,
  ) async {
    final opened = await _pumpApp(tester);
    final container = opened.container;
    await _open(tester);

    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();

    final state = container.read(appUpdateProvider);
    // Closing is not forgetting: the version is remembered, so the next launch
    // does not raise this dialog again.
    expect(state.latered, isTrue);
    expect(state.ignored, isFalse);
    expect(
      MiruSettings.getSettingSync<String>(SettingKey.laterUpdateVersion),
      '2.1.0',
    );
    expect(
      MiruSettings.getSettingSync<String>(SettingKey.ignoredUpdateVersion),
      isEmpty,
    );
    // The settings banner is the whole point of "later" — it stays.
    expect(state.dismissed, isFalse);
    expect(state.visible, isTrue);
    expect(state.promptable, isFalse);
    expect(find.byType(FDialog), findsNothing);
  });

  group('UpdatePromptListener wiring', () {
    testWidgets('raises the prompt once the check finds a newer build', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          appUpdateProvider.overrideWith(
            () => _SeededAppUpdate(
              AppUpdateState(
                status: UpdateStatus.available,
                currentVersion: '2.0.3-alpha',
                release: _release(),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // The real shell: the listener sits in the router's `builder` and reaches
      // the root navigator through RouterUtil.rootNavigatorKey, so the key has
      // to be the app's own.
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: RouterUtil.rootNavigatorKey,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: _delegates,
            supportedLocales: FLocalizations.supportedLocales,
            builder: (context, child) => FTheme(
              data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
              child: UpdatePromptListener(child: child!),
            ),
            home: const Scaffold(body: Text('home')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Update now'), findsOneWidget);
      expect(find.text('Ignore this version'), findsOneWidget);
      expect(find.textContaining('ready to install'), findsOneWidget);
      // The version may not be broken across lines: a word joiner follows the
      // hyphen, so "2.0.3-" can never end a line and "alpha." start the next.
      final message = tester
          .widget<Text>(find.textContaining('ready to install'))
          .data!;
      expect(message, contains('2.0.3-\u2060alpha'));
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('stays quiet for a version the user skipped', (tester) async {
      MiruSettings.setSettingSync(SettingKey.ignoredUpdateVersion, '2.1.0');
      final container = ProviderContainer(
        overrides: [
          appUpdateProvider.overrideWith(
            () => _SeededAppUpdate(
              AppUpdateState(
                status: UpdateStatus.available,
                currentVersion: '2.0.3-alpha',
                release: _release(),
                ignored: true,
                dismissed: true,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: RouterUtil.rootNavigatorKey,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: _delegates,
            supportedLocales: FLocalizations.supportedLocales,
            builder: (context, child) => FTheme(
              data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
              child: UpdatePromptListener(child: child!),
            ),
            home: const Scaffold(body: Text('home')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FDialog), findsNothing);
    });
  });
}
