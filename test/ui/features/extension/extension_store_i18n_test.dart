import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/domain/models/extension.dart';
import 'package:miru_alpha/domain/models/extension_view.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/ui/features/extension/views/extension_list_view.dart';
import 'package:miru_alpha/ui/features/extension/view_models/extension_view_model.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

/// The store screen is the app's i18n canary: its filter strip is built from
/// shipped catalog entries (`extension.available`, `common.status`, ...), so a
/// broken or half-translated catalog shows up as raw keys in the live tree.
///
/// This drives the real wiring - the shipped delegate, the shipped asset
/// files, the app's own language switch - and then keeps interacting with the
/// screen in the switched locale, which is where a half-translated catalog
/// breaks.

DomainExtensionMeta _meta(
  String pkg,
  String name,
  ExtensionType type, {
  String version = '1.0.0',
  bool nsfw = false,
}) => DomainExtensionMeta(
  name: name,
  packageName: pkg,
  version: version,
  author: 't',
  lang: 'en',
  type: type,
  nsfw: nsfw,
);

class _FakeExtensionViewModel extends ExtensionViewModel {
  _FakeExtensionViewModel(this._seed);

  final DomainExtensionViewState _seed;

  @override
  DomainExtensionViewState build() => _seed;

  @override
  Future<void> loadRepos({force = false}) async {
    // No backend in tests; the seeded repo is already the whole world.
  }
}

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);

  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

DomainExtensionViewState _seedState() {
  final extensions = [
    for (var i = 0; i < 30; i++)
      _meta(
        'pkg$i',
        'Ext$i',
        i.isEven ? ExtensionType.bangumi : ExtensionType.manga,
        nsfw: i == 29,
      ),
  ];
  return DomainExtensionViewState(
    repos: [
      DomainExtensionRepo(
        name: 'Miru Project',
        url: 'https://raw.example.com/index.json',
        extensions: extensions,
      ),
    ],
    installedPackages: const ['pkg2', 'pkg4'],
    metadata: [
      _meta('pkg2', 'Ext2', ExtensionType.bangumi, version: '0.9.0'),
      _meta('pkg4', 'Ext4', ExtensionType.bangumi, version: '1.0.0'),
    ],
  );
}

Finder _statusPill() => find.byKey(const ValueKey('extension-status-pill'));

/// The screen rebuilds when the language changes (the app root watches the
/// controller the same way); the router keeps its page, so the screen itself
/// has to take the dependency for the new catalog to show up.
class _StoreScreen extends ConsumerWidget {
  const _StoreScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(applicationControllerProvider);
    // A fresh element for the new language: a const child widget would be
    // skipped by the element update, leaving the old strings on screen.
    return ExtensionListView(key: ValueKey(controller.language));
  }
}

/// Mirrors the app root: the shipped delegate and the shipped asset files do
/// the translating, and the root watches the controller so a language change
/// rebuilds the tree.
class _AppRoot extends ConsumerWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(applicationControllerProvider);
    return MaterialApp.router(
      routerConfig: GoRouter(
        navigatorKey: RouterUtil.rootNavigatorKey,
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (context, state) => const _StoreScreen()),
        ],
      ),
      localizationsDelegates: [
        I18nUtils.flutterI18nDelegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: const [Locale('en'), Locale('zh')],
      locale: Locale(controller.language),
    );
  }
}

Future<ProviderContainer> _pumpStore(WidgetTester tester) async {
  final theme = ThemeUtils.getThemeData(MiruThemes.zinc.light);

  final container = ProviderContainer(
    overrides: [
      extensionViewModelProvider.overrideWith(
        () => _FakeExtensionViewModel(_seedState()),
      ),
      applicationControllerProvider.overrideWith(
        () => _FakeApplicationController(
          ApplicationState(
            themeText: 'light',
            baseColor: 'zinc',
            primaryColor: 'zinc',
            themeData: theme,
            themeMode: ThemeMode.light,
            language: 'en',
          ),
        ),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.binding.setSurfaceSize(const Size(420, 900));
  addTearDown(() async => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: FTheme(
        data: theme,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(420, 900)),
          // Same wiring as the app: the GoRouter's navigator carries
          // RouterUtil.rootNavigatorKey (which `.i18n` resolves through) and
          // the real asset translations load.
          child: const _AppRoot(),
        ),
      ),
    ),
  );
  // Let the build, the post-frame "Available" filter and the async asset
  // translation load settle.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
  return container;
}

/// A raw key in the tree means the catalog did not resolve it.
void _expectNoRawKeys(WidgetTester tester) {
  for (final raw in ['extension.', 'common.', 'media.', 'settings.']) {
    expect(
      find.textContaining(raw),
      findsNothing,
      reason: 'unresolved i18n key "$raw..." rendered',
    );
  }
}

void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);

  testWidgets(
    'the store renders shipped labels, survives a language switch and keeps '
    'working in the switched locale',
    (tester) async {
      final container = await _pumpStore(tester);

      // English: the strip shows the shipped label, not the catalog key.
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('All'), findsWidgets);
      _expectNoRawKeys(tester);

      // The app's own language switch (what the settings screen calls): the
      // refresh swaps the loaded catalog, the controller update rebuilds the
      // tree so every `.i18n` call reads the new catalog.
      await I18nUtils.changeLanguage('zh');
      container
          .read(applicationControllerProvider.notifier)
          .changeLanguage('zh');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Chinese: the same widget now renders the Chinese catalog entry.
      expect(find.text('可用'), findsOneWidget);
      expect(find.text('全部'), findsWidgets);
      _expectNoRawKeys(tester);

      // Interaction in the switched locale: the status sheet is built from
      // catalog entries too (`common.status`, `extension.installed`).
      await tester.tap(_statusPill());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('状态'), findsOneWidget);
      expect(find.textContaining('已安装'), findsWidgets);
      _expectNoRawKeys(tester);

      // Picking a row still refilters through the real notifier logic.
      await tester.tap(find.textContaining('已安装').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        container.read(extensionViewModelProvider).installFilter,
        ExtensionInstallStatus.installed,
      );
      _expectNoRawKeys(tester);

      // Back to English for the next test / the app's persisted default.
      await I18nUtils.changeLanguage('en');
      container
          .read(applicationControllerProvider.notifier)
          .changeLanguage('en');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('Installed'), findsWidgets);
      _expectNoRawKeys(tester);
    },
  );
}
