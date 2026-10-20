import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/search/global_search_provider.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/ui/features/search/mobile_search_input_page.dart';
import 'package:miru_alpha/ui/features/search/mobile_search_page.dart';
import 'package:miru_alpha/ui/features/search/mobile_search_results.dart';
import 'package:miru_alpha/ui/core/grid_view/miru_grid_tile_loading_box.dart';
import 'package:miru_alpha/ui/features/search/widget/search_field.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/ui/features/search/widget/search_page_header.dart';
import 'package:miru_alpha/ui/features/search/widget/search_results_header.dart';
import 'package:miru_alpha/ui/features/search/widget/search_settings_sheet.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

ExtensionMeta _meta(
  String pkg,
  String name, {
  ExtensionType type = ExtensionType.bangumi,
}) => ExtensionMeta(
  name: name,
  version: '2.0.0',
  author: 't',
  license: 'MIT',
  lang: 'en',
  packageName: pkg,
  webSite: 'https://example.com',
  description: '$name provider',
  tags: const [],
  api: 'v2',
  type: type,
);

/// Same as [_entry], but on a later page of its source — the predictor reads
/// pages in arrival order, so a test has to be able to place a hit on page two.
GlobalSearchEntry _entryOnPage(ExtensionMeta meta, String title, int page) =>
    GlobalSearchEntry(
      meta: meta,
      item: (ExtensionListItem()
        ..title = title
        ..url = 'https://example.com/$title'),
      sourcePinned: true,
      origin: 0,
      page: page,
    );

GlobalSearchEntry _entry(
  ExtensionMeta meta,
  String title, {
  String update = '',
}) => GlobalSearchEntry(
  meta: meta,
  item: (ExtensionListItem()
    ..title = title
    ..url = 'https://example.com/item'
    ..update = update),
  sourcePinned: true,
  origin: 0,
);

class _FakeSearchPage extends SearchPageNotifier {
  _FakeSearchPage(this._metas, {this.pinned = const {}});

  final List<ExtensionMeta> _metas;
  final Set<String> pinned;

  @override
  SearchPageState build() => SearchPageState(
    metaData: _metas,
    pinnedExtensions: {},
    query: '',
    existedPinnedExtensions: pinned,
    scopeMode: SearchScopeMode.all,
    history: ['Frieren', 'Berserk'],
  );
}

/// Installed-extension metadata for the real [SearchPageNotifier], which reads
/// it through `extensionPageProvider` to decide the initial search scope.
class _FakeExtensionPage extends ExtensionPageNotifier {
  _FakeExtensionPage(this._metas);

  final List<ExtensionMeta> _metas;

  @override
  ExtensionPageModel build() => ExtensionPageModel(
    fetchedRepo: const [],
    extensionList: const [],
    installedPackages: const [],
    metaData: _metas,
    sourceIndex: 0,
  );
}

class _FakeHistoryPage extends HistoryPageNotifier {
  _FakeHistoryPage(this._history);
  final List<History> _history;

  @override
  HistoryPageState build() =>
      HistoryPageState(history: _history, filteredHistory: _history);
}

class _FakeFavoritePage extends FavoritePageNotifier {
  _FakeFavoritePage(this._favorites);
  final List<Favorite> _favorites;

  @override
  FavoritePageState build() {
    Future.microtask(() {}); // never touch the database in tests
    return FavoritePageState(
      favorites: _favorites,
      favoriteGroups: const [],
      filteredFavorites: _favorites,
      selectedFavoriteGroups: const [],
    );
  }
}

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);
  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

ApplicationState _appState(FThemeData theme, {bool dark = false}) =>
    ApplicationState(
      themeText: dark ? 'dark' : 'light',
      baseColor: 'zinc',
      primaryColor: 'zinc',
      themeData: theme,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      language: 'en',
    );

Future<ProviderContainer> pumpSearch(
  WidgetTester tester, {
  List<ExtensionMeta>? metas,
  Set<String> pinned = const {},
  GlobalSearchAggregate? aggregate,
  String location = '/',
  bool dark = false,
  // Stands in for the real per-source search, so a test can count the requests
  // a screen actually makes: (package, page, query) -> the page's hits.
  Future<List<ExtensionListItem>> Function(String, int, String)? search,
  // A stand-in for the installed-extension notifier, so a test can observe
  // (or fake) the strip's sync without touching the repository layer.
  ExtensionPageNotifier? extensionPage,
  // Wires the app's real navigator key plus the English asset translations,
  // exactly like the app. Needed only by tests that trigger
  // `RouterUtil.rootNavigatorKey`-resolved UI (the tune button's sheet);
  // every other test keeps the raw i18n keys the assertions are written
  // against, because `.i18n` returns its key when no context resolves.
  bool useRootNavigator = false,
}) async {
  final theme = ThemeUtils.getThemeData(
    dark ? MiruThemes.zinc.dark : MiruThemes.zinc.light,
  );
  final extensions =
      metas ??
      [
        _meta('a.pkg', 'Miruro'),
        _meta('b.pkg', 'Rawkuma', type: ExtensionType.manga),
        _meta('c.pkg', 'Nyaa'),
      ];

  final container = ProviderContainer(
    overrides: [
      searchPageProvider.overrideWith(
        () => _FakeSearchPage(extensions, pinned: pinned),
      ),
      applicationControllerProvider.overrideWith(
        () => _FakeApplicationController(_appState(theme, dark: dark)),
      ),
      historyPageProvider.overrideWith(() => _FakeHistoryPage(const [])),
      favoritePageProvider.overrideWith(() => _FakeFavoritePage(const [])),
      if (aggregate != null)
        globalSearchAggregateProvider.overrideWith((ref) => aggregate),
      if (search != null)
        fetchExtensionSearchLatestProvider.overrideWith((ref, arg) async {
          final (pkg, page, query: q, filter: _) = arg;
          return search(pkg, page, q ?? '');
        }),
      if (extensionPage != null)
        extensionPageProvider.overrideWith(() => extensionPage),
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
          child: MaterialApp.router(
            routerConfig: GoRouter(
              navigatorKey: useRootNavigator
                  ? RouterUtil.rootNavigatorKey
                  : null,
              initialLocation: location,
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const MobileSearchPage(),
                ),
                GoRoute(
                  path: '/search/input',
                  builder: (context, state) => const MobileSearchInputPage(),
                ),
                GoRoute(
                  path: '/search/single',
                  builder: (context, state) {
                    final extra = state.extra! as SearchPageParam;
                    return Scaffold(
                      body: Center(
                        child: Text(
                          'single:${extra.meta.packageName}'
                          ':${extra.query ?? '-'}',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            localizationsDelegates: useRootNavigator
                ? [I18nUtils.flutterI18nDelegate]
                : null,
            supportedLocales: const [Locale('en')],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  if (useRootNavigator) {
    // The asset translations load asynchronously; two frames for the build
    // plus the load settle, same as the extension-store harness.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
  }
  return container;
}

/// The results grid's own scroll view.
///
/// `find.byType(CustomScrollView).first` is the scaffold's outer view (the
/// pinned headers live there); paging is driven by the body's inner view.
Finder _resultsScrollView() => find.descendant(
  of: find.byType(MobileSearchResultsBody),
  matching: find.byType(CustomScrollView),
);

void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);

  group('search tab (/search)', () {
    testWidgets('renders the title, source list and the pinned-scope switch', (
      tester,
    ) async {
      await pumpSearch(tester);

      expect(find.text('common.search'), findsOneWidget);
      expect(find.text('search.extension_sources'), findsOneWidget);
      // The mock's heading badge replaces the old "Total: N" text: the count
      // of sources the tab actually shows.
      expect(find.text('search.sources_available'), findsOneWidget);
      expect(find.text('search.all_sources'), findsOneWidget);
      for (final name in ['Miruro', 'Rawkuma', 'Nyaa']) {
        expect(find.text(name), findsOneWidget);
      }
      // The tab is a source list only: no query UI lives here.
      expect(find.byType(EditableText), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the field pushes the search page, Cancel pops back', (
      tester,
    ) async {
      await pumpSearch(tester);

      await tester.tap(find.byType(SearchFieldStub));
      await tester.pumpAndSettle();

      expect(find.byType(MobileSearchInputPage), findsOneWidget);
      // The pushed page's heading names the aggregate flow it runs, distinct
      // from the tab's plain "Search".
      expect(
        find.descendant(
          of: find.byType(MobileSearchInputPage),
          matching: find.text('search.global_search'),
        ),
        findsOneWidget,
      );
      expect(find.text('search.suggestions'), findsNothing);
      expect(find.text('common.cancel'), findsOneWidget);

      await tester.tap(find.text('common.cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(MobileSearchInputPage), findsNothing);
      expect(find.byType(MobileSearchPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('search input page (/search/input)', () {
    testWidgets('shows the capped recents and the filters once typing', (
      tester,
    ) async {
      await pumpSearch(tester, location: '/search/input');

      await tester.enterText(find.byType(EditableText).first, 'frie');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('common.cancel'), findsOneWidget);
      // Recent Searches is the only history surface: the seeded history has
      // two entries, both listed unfiltered while typing, with the query's
      // scope / content-type / sort filters below.
      expect(find.text('extension.recent_searches'), findsOneWidget);
      expect(find.text('search.suggestions'), findsNothing);
      expect(find.text('search.scope'), findsOneWidget);
      expect(find.text('search.content_type'), findsOneWidget);
      expect(find.text('search.sort_by'), findsOneWidget);
      expect(find.text('Berserk'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Recent Searches never lists more than six entries', (
      tester,
    ) async {
      final container = await pumpSearch(tester, location: '/search/input');
      final notifier = container.read(searchPageProvider.notifier);
      for (var i = 0; i < 9; i++) {
        notifier.addHistory('query $i');
      }
      await tester.pump();

      // Newest first: the six rendered are query 8..query 3.
      expect(find.text('query 8'), findsOneWidget);
      expect(find.text('query 3'), findsOneWidget);
      expect(find.text('query 2'), findsNothing); // the 7th is cut off
    });

    testWidgets('submitting a query swaps the body for aggregated results', (
      tester,
    ) async {
      final miruro = _meta('a.pkg', 'Miruro');
      final rawkuma = _meta('b.pkg', 'Rawkuma', type: ExtensionType.manga);
      final aggregate = GlobalSearchAggregate(
        entries: [
          _entry(miruro, 'Frieren: Beyond Journey', update: '2026-01-02 10:00'),
          _entry(rawkuma, 'Frieren manga'),
        ],
        done: 2,
        total: 2,
        failed: const [],
      );

      await pumpSearch(tester, aggregate: aggregate, location: '/search/input');
      await tester.enterText(find.byType(EditableText).first, 'Frieren');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Status bar, the view toggle and cards are all driven by the aggregate.
      expect(find.textContaining('search.results_count'), findsOneWidget);
      expect(find.text('search.sources_done'), findsOneWidget);
      expect(find.text('search.view_relevance'), findsOneWidget);
      expect(find.text('search.view_by_extension'), findsOneWidget);
      // The flat grid shows the exact-match poster cards.
      expect(find.text('Frieren: Beyond Journey'), findsOneWidget);
      expect(find.text('search.pinned_only'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('typing never queries a source; Enter does', (tester) async {
      var sourceCalls = 0;
      final container = await pumpSearch(
        tester,
        location: '/search/input',
        search: (pkg, page, query) {
          sourceCalls++;
          // Only the first page has anything to give: three hits fill less
          // than a screen, so the buffer trigger buys the winner's page two —
          // and stops as soon as every source has come back dry.
          if (page > 1) return Future.value(const <ExtensionListItem>[]);
          return Future.value([
            ExtensionListItem()
              ..title = '$pkg page $page'
              ..url = 'https://example.com/$pkg/$page',
          ]);
        },
      );

      // Every keystroke lands in the field and nowhere else: the provider's
      // query keys every source's fetch, so a live sync would fan one request
      // per installed extension, per keystroke, at the origin servers.
      await tester.enterText(find.byType(EditableText).first, 'frie');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(container.read(searchPageProvider).query, '');
      expect(sourceCalls, 0);
      expect(find.byType(MobileSearchResultsBody), findsNothing);

      // Enter submits: the query is committed once and the sources are asked.
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(container.read(searchPageProvider).query, 'frie');
      expect(sourceCalls, greaterThan(0));
      expect(find.byType(MobileSearchResultsBody), findsOneWidget);

      // Let the buffer prefetch run its course (one winner per page, until
      // every source is dry) before counting what "clearing" costs.
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      final callsAfterSubmit = sourceCalls;
      await tester.enterText(find.byType(EditableText).first, '');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(MobileSearchResultsBody), findsNothing);
      expect(sourceCalls, callsAfterSubmit);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a recent search submits it and shows results', (
      tester,
    ) async {
      final miruro = _meta('a.pkg', 'Miruro');
      final aggregate = GlobalSearchAggregate(
        entries: [_entry(miruro, 'Frieren: Beyond Journey')],
        done: 1,
        total: 1,
        failed: const [],
      );
      await pumpSearch(tester, aggregate: aggregate, location: '/search/input');

      // The field starts empty; the recents come from the seeded history.
      // (EasyRefresh schedules a ballistic-simulation timer when the body
      // swaps, so pump long enough for it to fire inside fake async.)
      await tester.tap(find.text('Frieren').last);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(seconds: 1));

      // The results body replaced the suggest list — the tap actually ran.
      expect(find.text('search.suggestions'), findsNothing);
      expect(find.text('Frieren: Beyond Journey'), findsOneWidget);
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText).first)
            .controller
            .text,
        'Frieren',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('the By Extension mode groups hits into shelves', (
      tester,
    ) async {
      final miruro = _meta('a.pkg', 'Miruro');
      final rawkuma = _meta('b.pkg', 'Rawkuma', type: ExtensionType.manga);
      final aggregate = GlobalSearchAggregate(
        entries: [
          _entry(miruro, 'Frieren: Beyond Journey'),
          _entry(rawkuma, 'Frieren manga'),
        ],
        done: 2,
        total: 3,
        failed: const [],
      );

      await pumpSearch(tester, aggregate: aggregate, location: '/search/input');
      await tester.enterText(find.byType(EditableText).first, 'Frieren');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Switch to the shelf layout. (The aggregate is still pending in one
      // scope slot, so a spinner runs — settle by fixed pumps instead.)
      await tester.tap(find.text('search.view_by_extension'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // One shelf per hit-bearing source: a header naming the source, then a
      // horizontal rail of poster cards (no source tag repeated per card); the
      // scope's third (empty) source lands in the empty-shelves footer.
      expect(find.text('Miruro'), findsWidgets);
      expect(find.text('Rawkuma'), findsWidgets);

      // Cards carry the extension's own @description as the informative line
      // under the title, and no action button.
      expect(find.text('Rawkuma provider'), findsOneWidget);
      expect(find.text('search.read'), findsNothing);
      expect(find.text('search.open'), findsNothing);
      expect(find.text('history_tools.watch'), findsNothing);

      // The empty-shelves footer sits below the fold; bring it in.
      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, -900),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('search.empty_shelves'), findsOneWidget);
      expect(find.textContaining('search.empty_shelves_desc'), findsOneWidget);

      // Back to the flat grid: shelves disappear.
      await tester.tap(find.text('search.view_relevance'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('search.empty_shelves'), findsNothing);
      expect(find.text('Frieren: Beyond Journey'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a shelf header opens the extension with the keyword', (
      tester,
    ) async {
      final miruro = _meta('a.pkg', 'Miruro');
      final aggregate = GlobalSearchAggregate(
        entries: [
          _entry(miruro, 'Frieren: Beyond Journey'),
          _entry(miruro, 'Frieren OVA'),
        ],
        done: 1,
        total: 1,
        failed: const [],
      );

      await pumpSearch(tester, aggregate: aggregate, location: '/search/input');
      await tester.enterText(find.byType(EditableText).first, 'Frieren');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.text('search.view_by_extension'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The shelf header (extension name) navigates to the extension's own
      // search page, carrying the keyword that produced these results.
      await tester.tap(find.text('Miruro'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('single:a.pkg:Frieren'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('orderGlobalResults', () {
    final miruro = _meta('a.pkg', 'Miruro');
    final rawkuma = _meta('b.pkg', 'Rawkuma');

    test('relevance ranks exact matches above loose ones', () {
      final entries = [
        GlobalSearchEntry(
          meta: miruro,
          item: (ExtensionListItem()
            ..title = 'Something else'
            ..url = 'https://example.com/a'),
          sourcePinned: true,
          origin: 0,
        ),
        GlobalSearchEntry(
          meta: miruro,
          item: (ExtensionListItem()
            ..title = 'Frieren'
            ..url = 'https://example.com/b'),
          sourcePinned: true,
          origin: 1,
        ),
        GlobalSearchEntry(
          meta: rawkuma,
          item: (ExtensionListItem()
            ..title = 'Frieren goes on'
            ..url = 'https://example.com/c'),
          sourcePinned: false,
          origin: 0,
        ),
      ];

      final ordered = orderGlobalResults(
        entries,
        SearchSortMode.relevance,
        'frieren',
      );

      expect(ordered.map((e) => e.item.title), [
        'Frieren',
        'Frieren goes on',
        'Something else',
      ]);
    });

    test('latest prefers the newest parseable timestamp', () {
      final entries = [
        GlobalSearchEntry(
          meta: miruro,
          item: (ExtensionListItem()
            ..title = 'old'
            ..url = 'https://example.com/a'
            ..update = '2024-01-01 00:00'),
          sourcePinned: true,
          origin: 0,
        ),
        GlobalSearchEntry(
          meta: miruro,
          item: (ExtensionListItem()
            ..title = 'new'
            ..url = 'https://example.com/b'
            ..update = '2026-05-05 12:00'),
          sourcePinned: true,
          origin: 1,
        ),
      ];

      final ordered = orderGlobalResults(entries, SearchSortMode.latest, '');

      expect(ordered.map((e) => e.item.title), ['new', 'old']);
    });

    test('latest understands relative timestamps too', () {
      final entries = [
        GlobalSearchEntry(
          meta: miruro,
          item: (ExtensionListItem()
            ..title = 'older'
            ..url = 'https://example.com/old'
            ..update = '3 days ago'),
          sourcePinned: true,
          origin: 0,
        ),
        GlobalSearchEntry(
          meta: miruro,
          item: (ExtensionListItem()
            ..title = 'newest'
            ..url = 'https://example.com/new'
            ..update = '5 minutes ago'),
          sourcePinned: true,
          origin: 1,
        ),
      ];

      final ordered = orderGlobalResults(entries, SearchSortMode.latest, '');

      expect(ordered.map((e) => e.item.title), ['newest', 'older']);
    });

    test('sourcePriority puts pinned sources first', () {
      final entries = [
        GlobalSearchEntry(
          meta: rawkuma,
          item: (ExtensionListItem()
            ..title = 'unpinned'
            ..url = 'https://example.com/a'),
          sourcePinned: false,
          origin: 0,
        ),
        GlobalSearchEntry(
          meta: miruro,
          item: (ExtensionListItem()
            ..title = 'pinned'
            ..url = 'https://example.com/b'),
          sourcePinned: true,
          origin: 0,
        ),
      ];

      final ordered = orderGlobalResults(
        entries,
        SearchSortMode.sourcePriority,
        '',
      );

      expect(ordered.map((e) => e.item.title), ['pinned', 'unpinned']);
    });
  });

  group('SearchPageState filters', () {
    SearchPageState state({
      Set<ExtensionType>? contentTypes,
      SearchScopeMode scopeMode = SearchScopeMode.all,
      Set<String> pinned = const {},
      Set<String> specific = const {},
    }) => SearchPageState(
      metaData: [
        _meta('a.pkg', 'Miruro', type: ExtensionType.bangumi),
        _meta('b.pkg', 'Rawkuma', type: ExtensionType.manga),
        _meta('c.pkg', 'Novel', type: ExtensionType.fikushon),
      ],
      pinnedExtensions: {},
      query: '',
      existedPinnedExtensions: pinned,
      contentTypes: contentTypes,
      scopeMode: scopeMode,
      specificPackages: specific,
    );

    test('an unfiltered scope keeps every source', () {
      expect(state().searchScopePackages, {'a.pkg', 'b.pkg', 'c.pkg'});
    });

    test('narrowing to manga drops the other types', () {
      final scoped = state(contentTypes: {ExtensionType.manga});
      expect(scoped.searchScopePackages, {'b.pkg'});
      expect(scoped.selectedType, ExtensionType.manga);
    });

    test('pinned and specific scopes each select their own subset', () {
      expect(
        state(
          scopeMode: SearchScopeMode.pinned,
          pinned: {'b.pkg'},
        ).searchScopePackages,
        {'b.pkg'},
      );
      expect(
        state(
          scopeMode: SearchScopeMode.specific,
          specific: {'c.pkg'},
        ).searchScopePackages,
        {'c.pkg'},
      );
    });

    test('an all-typed extension survives content-type narrowing', () {
      final all = SearchPageState(
        metaData: [
          _meta('general.pkg', 'General', type: ExtensionType.all),
          _meta('manga.pkg', 'MangaOnly', type: ExtensionType.manga),
        ],
        pinnedExtensions: {},
        query: '',
        existedPinnedExtensions: const {},
        // The subject here is the content-type filter, so the scope that
        // carries it is named instead of left at its pinned default.
        scopeMode: SearchScopeMode.all,
        contentTypes: {ExtensionType.manga},
      );
      expect(all.searchScopePackages, {'general.pkg', 'manga.pkg'});
    });
  });

  group('scope default', () {
    test('a new search opens on the pinned scope, never every extension', () {
      MiruSettings.seedDefaultsForTest();
      MiruSettings.setSettingSync(
        SettingKey.pinnedExtension,
        {'a.pkg'}.toString(),
      );
      final container = ProviderContainer(
        overrides: [
          extensionPageProvider.overrideWith(
            () => _FakeExtensionPage([
              _meta('a.pkg', 'Miruro'),
              _meta('b.pkg', 'Nyaa'),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(searchPageProvider);
      expect(state.scopeMode, SearchScopeMode.pinned);
      expect(state.searchScopePackages, {'a.pkg'});
    });

    test('with nothing pinned the scope stays pinned and empty', () {
      MiruSettings.seedDefaultsForTest();
      final container = ProviderContainer(
        overrides: [
          extensionPageProvider.overrideWith(
            () => _FakeExtensionPage([_meta('a.pkg', 'Miruro')]),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Nothing is pinned, so the scope is empty and the search never fans
      // out to every installed extension on its own.
      final state = container.read(searchPageProvider);
      expect(state.scopeMode, SearchScopeMode.pinned);
      expect(state.searchScopePackages, isEmpty);
    });

    test('only the user moves it off pinned', () {
      MiruSettings.seedDefaultsForTest();
      final container = ProviderContainer(
        overrides: [
          extensionPageProvider.overrideWith(
            () => _FakeExtensionPage([
              _meta('a.pkg', 'Miruro'),
              _meta('b.pkg', 'Nyaa'),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(searchPageProvider.notifier);

      expect(
        container.read(searchPageProvider).scopeMode,
        SearchScopeMode.pinned,
      );

      notifier.setPinnedScope(false);
      expect(container.read(searchPageProvider).scopeMode, SearchScopeMode.all);

      notifier.setPinnedScope(true);
      expect(
        container.read(searchPageProvider).scopeMode,
        SearchScopeMode.pinned,
      );
    });
  });

  group('global search pagination', () {
    test('loadMore pages one source at a time and reset clears the depth', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(globalSearchPagesProvider.notifier);

      // Everyone sits at page one until something is actually paged.
      expect(container.read(globalSearchPagesProvider), isEmpty);
      expect(notifier.depthOf('a.pkg'), 1);

      // Allocation is per source: the winner deepens, the rest stay put.
      notifier.loadMore('a.pkg');
      notifier.loadMore('a.pkg');
      expect(container.read(globalSearchPagesProvider), {'a.pkg': 3});
      expect(notifier.depthOf('b.pkg'), 1);

      notifier.reset();
      expect(container.read(globalSearchPagesProvider), isEmpty);
      expect(notifier.depthOf('a.pkg'), 1);
    });

    test(
      'the aggregate grows with the depth and stops on an empty page',
      () async {
        final container = ProviderContainer(
          overrides: [
            searchPageProvider.overrideWith(
              () => _FakeSearchPage([_meta('a.pkg', 'Miruro')]),
            ),
            fetchExtensionSearchLatestProvider.overrideWith((ref, arg) async {
              final (pkg, page, query: _, filter: _) = arg;
              // Only the first page has anything to give.
              if (page > 1) return const <ExtensionListItem>[];
              return [
                for (var i = 0; i < 2; i++)
                  ExtensionListItem()
                    ..title = '$pkg $i'
                    ..url = 'https://example.com/$pkg/$i',
              ];
            }),
          ],
        );
        addTearDown(container.dispose);
        container.listen(
          globalSearchAggregateProvider,
          (_, _) {},
          fireImmediately: true,
        );
        // The fetch override is async: the first build still sees a loading
        // snapshot, so let its data land before reading the aggregate.
        await pumpEventQueue();

        final first = container.read(globalSearchAggregateProvider);
        expect(first.entries.length, 2);
        expect(first.hasMore, isTrue);

        container.read(globalSearchPagesProvider.notifier).loadMore('a.pkg');
        await pumpEventQueue();
        final second = container.read(globalSearchAggregateProvider);
        // Page two was empty: nothing was appended, and the list stops offering
        // more instead of growing depth forever.
        expect(second.entries.length, 2);
        expect(second.hasMore, isFalse);
      },
    );

    testWidgets('relevance mode auto-fills a grid shorter than the viewport', (
      tester,
    ) async {
      final aggregate = GlobalSearchAggregate(
        entries: [_entry(_meta('a.pkg', 'Miruro'), 'Frieren')],
        done: 1,
        total: 1,
        failed: const [],
        hasMore: true,
      );
      final container = await pumpSearch(
        tester,
        aggregate: aggregate,
        location: '/search/input',
      );
      await tester.enterText(find.byType(EditableText).first, 'Frieren');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // No button: there is nothing to scroll, so the body asks for the next
      // page as soon as it settles and shows the skeleton row for it (the
      // harness pins the aggregate, so the trigger fires once — the live
      // provider recomputes a fresh aggregate per page and keeps going until
      // hasMore is false or the viewport is full).
      expect(find.text('search.load_more'), findsNothing);
      expect(find.byType(MobileTileLoadingBox), findsWidgets);
      // The predictor picked the only source that answered — and paged it.
      expect(container.read(globalSearchPagesProvider), {'a.pkg': 2});
      await tester.pump(const Duration(milliseconds: 300));

      // No runaway loop: with nothing new arriving the depth stays put.
      expect(container.read(globalSearchPagesProvider), {'a.pkg': 2});
      expect(tester.takeException(), isNull);
    });

    testWidgets('a tall relevance grid waits for the reader to scroll down', (
      tester,
    ) async {
      final miruro = _meta('a.pkg', 'Miruro');
      final aggregate = GlobalSearchAggregate(
        entries: [for (var i = 0; i < 24; i++) _entry(miruro, 'Frieren $i')],
        done: 1,
        total: 1,
        failed: const [],
        hasMore: true,
      );
      final container = await pumpSearch(
        tester,
        aggregate: aggregate,
        location: '/search/input',
      );
      await tester.enterText(find.byType(EditableText).first, 'Frieren');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // The grid overflows and the reader is at the top: with more than ten
      // hits still below the fold, nothing is fetched.
      expect(container.read(globalSearchPagesProvider), isEmpty);

      // Draining the buffer (every hit now seen) asks for exactly one more
      // page — from the winner — by itself.
      await tester.drag(_resultsScrollView(), const Offset(0, -4000));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(container.read(globalSearchPagesProvider), {'a.pkg': 2});

      // Further scrolling cannot ask for the same page twice: the latch holds
      // until a fetch is visibly under way, which the pinned aggregate never
      // reports.
      await tester.drag(_resultsScrollView(), const Offset(0, -200));
      await tester.pump(const Duration(milliseconds: 300));
      expect(container.read(globalSearchPagesProvider), {'a.pkg': 2});
      expect(tester.takeException(), isNull);
    });

    testWidgets('a short buffer refills without the reader scrolling', (
      tester,
    ) async {
      final miruro = _meta('a.pkg', 'Miruro');
      final aggregate = GlobalSearchAggregate(
        entries: [for (var i = 0; i < 12; i++) _entry(miruro, 'Frieren $i')],
        done: 1,
        total: 1,
        failed: const [],
        hasMore: true,
      );
      final container = await pumpSearch(
        tester,
        aggregate: aggregate,
        location: '/search/input',
      );
      await tester.enterText(find.byType(EditableText).first, 'Frieren');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Twelve hits over six rows leaves fewer than ten unseen right at the
      // top, so the prefetch fires with no scroll gesture at all — the trigger
      // is the buffer, not the bottom of the list.
      expect(container.read(globalSearchPagesProvider), {'a.pkg': 2});
      expect(tester.takeException(), isNull);
    });

    testWidgets('a refresh rewinds the depth and paging still works after', (
      tester,
    ) async {
      final miruro = _meta('a.pkg', 'Miruro');
      final aggregate = GlobalSearchAggregate(
        entries: [for (var i = 0; i < 24; i++) _entry(miruro, 'Frieren $i')],
        done: 1,
        total: 1,
        failed: const [],
        hasMore: true,
      );
      final container = await pumpSearch(
        tester,
        aggregate: aggregate,
        location: '/search/input',
      );
      await tester.enterText(find.byType(EditableText).first, 'Frieren');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.drag(_resultsScrollView(), const Offset(0, -4000));
      // Fixed pumps, not pumpAndSettle: the skeleton shimmer animates forever.
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(container.read(globalSearchPagesProvider), {'a.pkg': 2});

      // Pull-to-refresh hands every source back to page one, and nothing
      // re-asks for a page while the reader is simply parked there.
      container
          .read(globalSearchPagesProvider.notifier)
          .refresh(const [], 'Frieren');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(container.read(globalSearchPagesProvider), isEmpty);

      // Backing out past the prefetch runway — more than ten hits still below
      // the fold — keeps it quiet: armed, not stuck.
      await tester.drag(_resultsScrollView(), const Offset(0, 4000));
      await tester.pump();
      expect(container.read(globalSearchPagesProvider), isEmpty);

      // Draining the buffer again: paging works after the rewind, the old
      // ask is not mistaken for a fresh one.
      await tester.drag(_resultsScrollView(), const Offset(0, -4000));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(container.read(globalSearchPagesProvider), {'a.pkg': 2});
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'the next page sits behind skeleton cards while it is in flight',
      (tester) async {
        final aggregate = GlobalSearchAggregate(
          entries: [_entry(_meta('a.pkg', 'Miruro'), 'Frieren')],
          done: 1,
          total: 2,
          failed: const [],
          pages: 2,
          hasMore: false,
        );
        await pumpSearch(
          tester,
          aggregate: aggregate,
          location: '/search/input',
        );
        await tester.enterText(find.byType(EditableText).first, 'Frieren');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Page two is still out: the skeleton row stands in for it, and the
        // bottom spinner (a first-page affordance) stays out of the way.
        expect(find.byType(MobileTileLoadingBox), findsWidgets);
        expect(
          find.descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(FCircularProgress),
          ),
          findsNothing,
        );
        expect(find.text('search.load_more'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('by-extension mode keeps pagination manual (no auto-load)', (
      tester,
    ) async {
      final aggregate = GlobalSearchAggregate(
        entries: [_entry(_meta('a.pkg', 'Miruro'), 'Frieren')],
        done: 1,
        total: 1,
        failed: const [],
        hasMore: true,
      );
      final container = await pumpSearch(
        tester,
        aggregate: aggregate,
        location: '/search/input',
      );
      await tester.enterText(find.byType(EditableText).first, 'Frieren');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('search.view_by_extension'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Rails have no sentinel and no skeletons: the shelf layout does not
      // auto-grow the page depth.
      expect(find.byType(MobileTileLoadingBox), findsNothing);
      final before = container.read(globalSearchPagesProvider);
      await tester.pump(const Duration(milliseconds: 200));

      expect(container.read(globalSearchPagesProvider), before);
      expect(tester.takeException(), isNull);
    });
  });

  group('score and allocation', () {
    test('matchScore is 1 for an identical title and 0 for a miss', () {
      final miruro = _meta('a.pkg', 'Miruro');
      expect(matchScore(_entry(miruro, 'Frieren'), 'frieren'), 1);
      expect(matchScore(_entry(miruro, '  Frieren  '), 'Frieren'), 1);
      expect(
        matchScore(_entry(miruro, 'Frieren: Beyond Journey'), 'Frieren'),
        0,
      );
      expect(matchScore(_entry(miruro, 'Frieren'), ''), 0);
    });

    test("a source's pages are scored as length and avg", () {
      final miruro = _meta('a.pkg', 'Miruro');
      final yields = pageYields(
        [
          _entryOnPage(miruro, 'miss one', 1),
          _entryOnPage(miruro, 'miss two', 1),
          _entryOnPage(miruro, 'Frieren', 2),
        ],
        'a.pkg',
        'Frieren',
      );

      expect(yields.map((y) => y.page), [1, 2]);
      expect(yields[0].length, 2);
      expect(yields[0].avg, 0);
      expect(yields[1].length, 1);
      expect(yields[1].avg, 1);
    });

    test('the prediction is prev_avg + slope * prev_content_len', () {
      // Observations (4, 0) then (2, 1): slope = -0.5, so the next page is
      // predicted at 1 + -0.5 * 2 = 0.
      const yields = [
        PageYield(page: 1, length: 4, avg: 0),
        PageYield(page: 2, length: 2, avg: 1),
      ];
      expect(yieldSlope(yields), closeTo(-0.5, 1e-9));
      expect(predictNextAvg(yields), closeTo(0, 1e-9));

      // One observation — or a flat content length — has no slope to ride:
      // the prediction is simply the last average.
      expect(predictNextAvg(yields.skip(1).toList()), 1);
      const flat = [
        PageYield(page: 1, length: 4, avg: 0),
        PageYield(page: 2, length: 4, avg: 1),
      ];
      expect(yieldSlope(flat), 0);
      expect(predictNextAvg(flat), 1);
    });

    test('the biggest predicted avg wins the next fetch', () {
      final alpha = _meta('a.pkg', 'Alpha');
      final beta = _meta('b.pkg', 'Beta');
      GlobalSearchAggregate aggregateOf(
        List<GlobalSearchEntry> entries,
        Map<String, bool> more,
      ) => GlobalSearchAggregate(
        entries: entries,
        done: 2,
        total: 2,
        failed: const [],
        hasMore: true,
        more: more,
      );

      // Alpha's hit is identical (avg 1), Beta's is a miss (avg 0): the
      // higher prediction takes the fetch.
      final ranked = aggregateOf(
        [_entry(alpha, 'Frieren'), _entry(beta, 'Something Else')],
        {'a.pkg': true, 'b.pkg': true},
      );
      expect(pickNextFetchPackage(ranked, 'Frieren'), 'a.pkg');

      // Nobody matched: every prediction is 0, so the source with the longer
      // last page takes it.
      final tied = aggregateOf(
        [
          for (var i = 0; i < 3; i++) _entryOnPage(alpha, 'miss $i', 1),
          _entryOnPage(beta, 'miss', 1),
        ],
        {'a.pkg': true, 'b.pkg': true},
      );
      expect(pickNextFetchPackage(tied, 'Frieren'), 'a.pkg');

      // A source whose last page came back empty is done, not a candidate.
      final exhausted = aggregateOf(
        [_entry(beta, 'Frieren')],
        {'a.pkg': false, 'b.pkg': true},
      );
      expect(pickNextFetchPackage(exhausted, 'Frieren'), 'b.pkg');
    });
  });

  group('filter controls', () {
    test('toggleContentType narrows and re-widens the searched types', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(searchPageProvider.notifier);
      final before = container.read(searchPageProvider).contentTypes.length;

      notifier.toggleContentType(ExtensionType.manga);
      expect(
        container.read(searchPageProvider).contentTypes.length,
        before - 1,
      );

      notifier.toggleContentType(ExtensionType.manga);
      expect(container.read(searchPageProvider).contentTypes.length, before);
    });

    testWidgets('the scope pill reports the scope actually searched', (
      tester,
    ) async {
      final aggregate = GlobalSearchAggregate(
        entries: [_entry(_meta('a.pkg', 'Miruro'), 'Frieren')],
        done: 1,
        total: 1,
        failed: const [],
      );
      final container = await pumpSearch(
        tester,
        aggregate: aggregate,
        location: '/search/input',
      );
      final summary = find.descendant(
        of: find.byType(MobileSearchScopeSummary),
        matching: find.byType(Text),
      );
      expect(container.read(searchPageProvider).scopeMode, SearchScopeMode.all);

      // Switch the scope directly: with the drawer gone the results header is
      // the only scope surface, and the summary must follow whatever the
      // provider says.
      container
          .read(searchPageProvider.notifier)
          .setScopeMode(SearchScopeMode.pinned);
      await tester.pumpAndSettle();

      expect(
        container.read(searchPageProvider).scopeMode,
        SearchScopeMode.pinned,
      );

      // Results mount the header pill, which must follow the scope instead of
      // always claiming "pinned".
      await tester.enterText(find.byType(EditableText).first, 'Frieren');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(summary, findsWidgets);
      final label = searchScopeLabel(container.read(searchPageProvider));
      expect(
        tester.widgetList<Text>(summary).map((t) => t.data),
        contains(label),
      );
    });

    test('the language filter narrows the searched sources', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(searchPageProvider.notifier)
          .setFilters(
            scopeMode: SearchScopeMode.all,
            specificPackages: {},
            contentTypes: kSearchContentTypes.toSet(),
            sort: SearchSortMode.relevance,
            selectedLang: 'en',
          );
      expect(container.read(searchPageProvider).selectedLang, 'en');

      container
          .read(searchPageProvider.notifier)
          .setFilters(
            scopeMode: SearchScopeMode.all,
            specificPackages: {},
            contentTypes: kSearchContentTypes.toSet(),
            sort: SearchSortMode.relevance,
            selectedLang: '',
          );
      expect(container.read(searchPageProvider).selectedLang, isNull);
    });

    test('batch setFilters keeps unmentioned fields untouched', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(searchPageProvider.notifier)
          .setFilters(
            scopeMode: SearchScopeMode.all,
            specificPackages: {},
            contentTypes: {ExtensionType.manga},
            sort: SearchSortMode.relevance,
            selectedLang: 'en',
          );
      final after = container.read(searchPageProvider);
      expect(after.contentTypes, {ExtensionType.manga});
      expect(after.selectedLang, 'en');
      expect(after.scopeMode, SearchScopeMode.all);
    });
  });

  group('failure handling', () {
    testWidgets('a failed source offers a retry', (tester) async {
      final aggregate = GlobalSearchAggregate(
        entries: [_entry(_meta('a.pkg', 'Miruro'), 'Frieren')],
        done: 1,
        total: 2,
        failed: const ['RoyalRoad'],
        failedPackages: const ['royal.pkg'],
      );
      await pumpSearch(tester, aggregate: aggregate, location: '/search/input');
      await tester.enterText(find.byType(EditableText).first, 'Frieren');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('search.failed_sources'), findsOneWidget);
      expect(find.text('search.retry'), findsOneWidget);

      await tester.tap(find.text('search.retry'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the search tab in the dark theme', (tester) async {
      await pumpSearch(tester, dark: true);

      expect(find.text('search.extension_sources'), findsOneWidget);
      expect(find.text('Miruro'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders results in the dark theme without exceptions', (
      tester,
    ) async {
      final aggregate = GlobalSearchAggregate(
        entries: [_entry(_meta('a.pkg', 'Miruro'), 'Frieren')],
        done: 1,
        total: 1,
        failed: const [],
      );
      await pumpSearch(
        tester,
        dark: true,
        aggregate: aggregate,
        location: '/search/input',
      );
      await tester.enterText(find.byType(EditableText).first, 'Frieren');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // One hit reads as "1 result" (singular), so match either label.
      expect(find.textContaining('search.result'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('pinned filter bar', () {
    testWidgets('pills stay pinned; label and caption travel with the list', (
      tester,
    ) async {
      // Enough sources that the list overflows a 900px surface, otherwise the
      // page has nothing to scroll and the title has nothing to collapse from.
      await pumpSearch(
        tester,
        metas: [for (var i = 0; i < 12; i++) _meta('p$i.pkg', 'Source $i')],
      );

      // Only the pill row is pinned; label, badge and cards are body content.
      expect(find.byType(SearchSourceFilterBar), findsOneWidget);
      expect(find.text('search.all_sources'), findsOneWidget);
      expect(find.text('search.extension_sources'), findsOneWidget);
      expect(find.text('search.sources_available'), findsOneWidget);

      // Reading order: pinned pills, then the label — the label row opens
      // the scrolling body below the pinned bar.
      final labelY = tester
          .getTopLeft(find.text('search.extension_sources'))
          .dy;
      final pillY = tester.getTopLeft(find.text('search.all_sources')).dy;
      expect(pillY, lessThan(labelY));

      // The delegate clips its own box to the remaining extent while the title
      // keeps its natural height, so the wrapper is what has to shrink.
      final titleBox = find
          .ancestor(
            of: find.byType(SearchPageTitle),
            matching: find.byType(SizedBox),
          )
          .first;
      expect(tester.getSize(titleBox).height, greaterThan(0));
      final barAtRest = tester.getTopLeft(find.byType(SearchSourceFilterBar));

      // Scroll the cards: the big title gives way, the field and pills stay.
      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();

      // The title is either unmounted or clipped to nothing once scrolled.
      final titleCollapsed =
          find.byType(SearchPageTitle).evaluate().isEmpty ||
          tester.getSize(titleBox).height == 0;
      expect(titleCollapsed, isTrue);
      expect(find.byType(SearchFieldRow), findsOneWidget);
      // The bar moves up with the title's space and keeps the pills on screen.
      final barScrolled = tester.getTopLeft(find.byType(SearchSourceFilterBar));
      expect(barScrolled.dy, lessThan(barAtRest.dy));
      expect(find.text('search.all_sources'), findsOneWidget);
      // The label travelled with the list: it is now gone above the fold.
      expect(find.text('search.extension_sources'), findsNothing);
    });
  });

  group('source visibility and sync (mock)', () {
    testWidgets('heading badge counts sources, footnote reports sync health', (
      tester,
    ) async {
      await pumpSearch(tester);

      // The heading badge ("{count} Available") and the quiet footnote
      // ("all synced") are the mock's two status surfaces. Raw keys: the
      // widget harness loads no i18n.
      expect(find.text('search.sources_available'), findsOneWidget);
      expect(find.text('search.all_synced'), findsOneWidget);
      expect(find.byIcon(FLucideIcons.circleCheck), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hiding a source removes it from list and search scope', (
      tester,
    ) async {
      final container = await pumpSearch(tester);

      // Pinned-first then name: Miruro is the first card; its eye hides it.
      await tester.tap(find.byIcon(FLucideIcons.eyeOff).first);
      await tester.pump();

      expect(find.text('Miruro'), findsNothing);
      expect(find.text('Rawkuma'), findsOneWidget);
      // Persisted like the pinned set, and out of the query scope.
      expect(
        MiruSettings.getSettingSync<Set<String>>(SettingKey.hiddenExtension),
        {'a.pkg'},
      );
      final state = container.read(searchPageProvider);
      expect(state.visibleMetaData.length, 2);
      expect(state.searchScopePackages.contains('a.pkg'), isFalse);

      // The Hidden status view is how it comes back. The strip's pill row
      // scrolls horizontally under the pinned sync button, so scroll the
      // Status pill onto the screen before tapping it — a finder matches
      // content that is still off the right edge, and that tap would land
      // on nothing.
      await tester.ensureVisible(find.text('common.status'));
      await tester.pump();
      await tester.tap(find.text('common.status'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.ancestor(
          of: find.text('search.status_hidden'),
          matching: find.byType(FTile),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Miruro'), findsOneWidget);
      // In the hidden view the eye points the other way: restore.
      expect(find.byIcon(FLucideIcons.eye), findsOneWidget);

      await tester.tap(find.byIcon(FLucideIcons.eye));
      await tester.pump();
      expect(find.text('Miruro'), findsNothing);
      expect(
        MiruSettings.getSettingSync<Set<String>>(SettingKey.hiddenExtension),
        isEmpty,
      );
      // FTappable waits out its 100ms pressed-exit before flipping state;
      // drain that timer or the fake-async binding fails on it at teardown.
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull);
    });

    testWidgets('pinned cards trade the eye for the unpin', (tester) async {
      await pumpSearch(tester, pinned: {'a.pkg'});

      // Miruro pinned: unpin + settings, no eye. The two unpinned cards keep
      // pin + eye + settings.
      expect(find.byIcon(FLucideIcons.eyeOff), findsNWidgets(2));
      expect(find.byIcon(FLucideIcons.pinOff), findsOneWidget);
      expect(find.byIcon(FLucideIcons.pin), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the query-side filter sheet renders its sections', (
      tester,
    ) async {
      // The sheet resolves its context from RouterUtil.rootNavigatorKey, so
      // this test — and only this one — wires the real navigator key, which
      // requires the i18n delegate: `.i18n` then returns the shipped English
      // strings, so the assertions below use them. The tab carries no header
      // trigger for the sheet anymore, so the test opens it directly.
      await pumpSearch(tester, useRootNavigator: true);

      unawaited(showSearchSettingsSheet());
      await tester.pumpAndSettle();

      expect(find.text('Edit Filters'), findsOneWidget);
      expect(find.byType(SearchScopeSegmented), findsOneWidget);
      expect(find.text('Content Type'), findsOneWidget);
      expect(find.text('Sort By'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('display labels', () {
    test('a version already carrying its v is not prefixed again', () {
      expect(searchVersionLabel('v2.0.0'), 'v2.0.0');
      expect(searchVersionLabel('2.0.0'), 'v2.0.0');
      expect(searchVersionLabel(''), '');
    });
  });
}
