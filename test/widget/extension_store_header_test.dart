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

/// Store-page regressions for the reference-driven redesign: one consolidated
/// filter row, 44dp header targets, category glyphs on the fallback covers and
/// the search/filter header that stays pinned while the list scrolls.

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

/// The view model with the Go backend cut out and the state seeded, so the
/// page renders offline.
class _FakeExtensionViewModel extends ExtensionViewModel {
  _FakeExtensionViewModel(this._seed);

  final DomainExtensionViewState _seed;

  @override
  DomainExtensionViewState build() => _seed;

  @override
  Future<void> loadRepos({bool force = false}) async {
    // No backend in tests; the seeded repo is already the whole world.
  }
}

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);

  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

/// Enough extensions to scroll: 30 tiles of ~76px against a 900px viewport.
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
    // Two installed, one of them behind the repo version (an update).
    installedPackages: const ['pkg2', 'pkg4'],
    metadata: [
      _meta('pkg2', 'Ext2', ExtensionType.bangumi, version: '0.9.0'),
      _meta('pkg4', 'Ext4', ExtensionType.bangumi, version: '1.0.0'),
    ],
  );
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
          // The same wiring as the app: the GoRouter's navigator carries
          // RouterUtil.rootNavigatorKey (which `.i18n` resolves through) and
          // the real English asset translations load, so the layout under
          // test gets the shipped short labels, not raw keys.
          child: MaterialApp.router(
            routerConfig: GoRouter(
              navigatorKey: RouterUtil.rootNavigatorKey,
              initialLocation: '/',
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const ExtensionListView(),
                ),
              ],
            ),
            localizationsDelegates: [I18nUtils.flutterI18nDelegate],
            supportedLocales: const [Locale('en')],
          ),
        ),
      ),
    ),
  );
  // Two frames for the build, then let the post-frame "mobile opens on
  // Available" filter, the async asset translation load and the FTheme paint
  // settle.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
  return container;
}

/// The status pill: keyed in the view so tests (and support) can find it
/// despite the repo picker sharing the dropdown-chevron look.
Finder _statusPill() => find.byKey(const ValueKey('extension-status-pill'));

void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);

  testWidgets(
    'the status picker, category chips and repo picker share one strip',
    (tester) async {
      final container = await _pumpStore(tester);

      // The mobile default opened on Available, with the seeded counts.
      expect(_statusPill(), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      // 30 seeded - 2 installed - 1 nsfw-hidden = 27 available.
      expect(find.text('27'), findsOneWidget);
      // ...next to the category chips and repo picker, in the SAME strip
      // (one row now); the repo pill shows just its label until narrowed.
      final strip = find.ancestor(
        of: _statusPill(),
        matching: find.byType(SingleChildScrollView),
      );
      expect(strip, findsOneWidget);
      expect(
        find.descendant(of: strip, matching: find.text('All')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: strip, matching: find.text('Repository')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: strip, matching: find.text('18+ NSFW')),
        findsOneWidget,
      );

      // Picking a status from the pill's sheet refilters through the real
      // notifier logic.
      await tester.tap(_statusPill());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Available (27)'), findsOneWidget);

      // The sheet's All row: the FTile carrying the layers icon.
      await tester.tap(
        find.ancestor(
          of: find.byIcon(FLucideIcons.layers),
          matching: find.byType(FTile),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final state = container.read(extensionViewModelProvider);
      expect(state.installFilter, ExtensionInstallStatus.all);
      expect(find.text('All'), findsWidgets);
    },
  );

  testWidgets('the header actions are 44dp touch targets', (tester) async {
    await _pumpStore(tester);

    for (final key in const [
      ValueKey('extension-header-repos'),
      ValueKey('extension-header-import'),
    ]) {
      final size = tester.getSize(find.byKey(key));
      expect(size.width, greaterThanOrEqualTo(44), reason: '$key width');
      expect(size.height, greaterThanOrEqualTo(44), reason: '$key height');
    }
  });

  testWidgets(
    'the search and filter header stays pinned while the list scrolls',
    (tester) async {
      await _pumpStore(tester);

      final pillTop = tester.getTopLeft(_statusPill()).dy;
      final fieldTop = tester.getTopLeft(find.byType(TextField)).dy;

      // First drag: only the 56px title bar above the block collapses, so
      // the field and pill slide up by exactly that — and no further.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // The list really scrolled (otherwise the position checks are
      // vacuous).
      final offset = tester
          .state<ScrollableState>(
            find.byWidgetPredicate(
              (w) => w is Scrollable && w.axis == Axis.vertical,
            ),
          )
          .position
          .pixels;
      expect(offset, greaterThan(300), reason: 'list scroll offset');

      final pillPinned = tester.getTopLeft(_statusPill()).dy;
      final fieldPinned = tester.getTopLeft(find.byType(TextField)).dy;
      expect(
        pillTop - pillPinned,
        closeTo(56, 2),
        reason: 'pill rises by the title collapse only',
      );
      expect(
        fieldTop - fieldPinned,
        closeTo(56, 2),
        reason: 'field rises by the title collapse only',
      );

      // Second drag: the pinned block must not move at all while the list
      // keeps scrolling — a collapsible header would keep sliding away.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        (tester.getTopLeft(_statusPill()).dy - pillPinned).abs(),
        lessThan(2),
        reason: 'pill',
      );
      expect(
        (tester.getTopLeft(find.byType(TextField)).dy - fieldPinned).abs(),
        lessThan(2),
        reason: 'field',
      );
    },
  );

  testWidgets('covers without an icon show the category glyph', (tester) async {
    await _pumpStore(tester);

    // Manga tiles fall back to the open-book glyph, anime tiles to play.
    expect(find.byIcon(FLucideIcons.bookOpen), findsWidgets);
    expect(find.byIcon(FLucideIcons.play), findsWidgets);
  });
}
