import 'package:material_ui/material_ui.dart' hide ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart' show Override;
import 'package:material_ui/material_ui.dart'
    show GlobalMaterialLocalizations, ThemeMode;
import 'package:miru_alpha/model/home_banner_model.dart';
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/backend_connection_provider.dart';
import 'package:miru_alpha/provider/tracking/anilist_provider.dart';
import 'package:miru_alpha/provider/home/home_banner_provider.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_banner.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/utils/tracking/tmdb.dart';

class _FakeBackendConnection extends BackendConnection {
  @override
  Future<void> build() async {}
}

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);
  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

class _FakeHomeBanner extends HomeBanner {
  _FakeHomeBanner(this._items);

  @override
  Future<List<HomeBannerItem>> build() async => _items;
  final List<HomeBannerItem> _items;
}

class _FakeAnilistAccount extends AnilistAccount {
  // ignore: avoid_unused_constructor_parameters
  _FakeAnilistAccount(this._user);

  @override
  Future<AnilistUser?> build() async => _user;
  final AnilistUser? _user;
}

class _FailingHomeBanner extends HomeBanner {
  _FailingHomeBanner(this._error);

  @override
  Future<List<HomeBannerItem>> build() async => throw _error;
  final Object _error;
}

/// Pins the selection so the source-switch test starts from a known state.
class _PinnedSelection extends HomeBannerSelection {
  _PinnedSelection(this._state);

  @override
  HomeBannerSelectionState build() => _state;
  final HomeBannerSelectionState _state;
}

/// Mirrors the app root: it watches the application controller, so a
/// language change rebuilds the tree the way `app_bootstrap` does.
class _BannerScreen extends ConsumerWidget {
  const _BannerScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(applicationControllerProvider).language;
    // A const child is skipped by the element update; key the banner by the
    // language so the subtree rebuilds with the swapped catalog.
    return Scaffold(body: HomeBannerSection(key: ValueKey(language)));
  }
}

HomeBannerItem bannerItem(int rank, {String title = 'Frieren'}) =>
    HomeBannerItem(
      title: title,
      rank: rank,
      subtitle: 'Sousou no Frieren',
      // Empty: a live URL would hang the fake-async zone in a pending
      // network load; the errChild path is what the tests exercise.
      backdrop: '',
      description: 'The adventure is over.',
      score: 9.1,
      anilistMediaId: rank,
      episodeCount: 12,
      externalUrl: 'https://anilist.co/anime/$rank',
    );

var _proxySeeded = false;

Future<void> pumpBanner(
  WidgetTester tester, {
  List<Override> overrides = const [],
  Size surface = const Size(1280, 800),
  AnilistUser? accountUser,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = surface;
  addTearDown(tester.view.reset);

  // ImageWidget routes artwork through the local proxy; tests run it against
  // a dead port so the fake HttpClient fails the load into the fallback.
  // late final — seed once per process.
  if (!_proxySeeded) {
    MiruRequest.ensureInitalized(host: 'http://127.0.0.1:1');
    _proxySeeded = true;
  }
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      backendConnectionProvider.overrideWith(_FakeBackendConnection.new),
      anilistAccountProvider.overrideWith(
        () => _FakeAnilistAccount(accountUser),
      ),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: FTheme(
        data: ThemeUtils.getThemeData(MiruThemes.zinc.dark),
        child: MaterialApp(home: Scaffold(body: HomeBannerSection())),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders picker pills, badges, title, dots and counter', (
    tester,
  ) async {
    await pumpBanner(
      tester,
      overrides: [
        homeBannerProvider.overrideWith(
          () => _FakeHomeBanner([bannerItem(1), bannerItem(2), bannerItem(3)]),
        ),
      ],
    );

    // Widget tests render raw i18n keys. The chip row carries rank,
    // format and score; the catalogue picker (source + format tabs) docks
    // top-left (2026-11-13: TMDB movie/show selectable in the banner).
    expect(find.text('#1 Trending'), findsOneWidget);
    // `.i18n` returns the raw key in the bare harness (no uppercasing in
    // this chip) — the eyebrow chip AND the picker's Anime tab both show
    // it (harness trap).
    expect(find.text('home.banner.anime'), findsNWidgets(2));
    expect(find.text('9.1 / 10'), findsOneWidget);
    expect(find.text('Frieren'), findsOneWidget);
    expect(find.text('Sousou no Frieren'), findsOneWidget);
    expect(find.text('The adventure is over.'), findsOneWidget);
    expect(find.text('home.banner.watch'), findsOneWidget);
    // Not linked to AniList: the bookmark CTA stays hidden.
    expect(find.text('home.banner.bookmark'), findsNothing);
    expect(find.text('home.dock_queue'), findsOneWidget);
    expect(find.byIcon(FLucideIcons.info), findsOneWidget);
    expect(find.byKey(const Key('bannerCataloguePicker')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('next arrow advances the counter and dots', (tester) async {
    await pumpBanner(
      tester,
      overrides: [
        homeBannerProvider.overrideWith(
          () => _FakeHomeBanner([bannerItem(1), bannerItem(2)]),
        ),
      ],
    );
    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(scrollable.position.pixels, 0);

    await tester.tap(find.byIcon(FLucideIcons.chevronRight));
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(0));

    // End of the list: the next arrow is disabled.
    await tester.tap(find.byIcon(FLucideIcons.chevronRight));
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop-width surface renders the compact hero band', (
    tester,
  ) async {
    await pumpBanner(
      tester,
      surface: const Size(1200, 800),
      overrides: [
        homeBannerProvider.overrideWith(() => _FakeHomeBanner([bannerItem(1)])),
      ],
    );
    final carouselBox = tester.getSize(find.byType(PageView).first);
    // Fixed hero height (2026-11-12, user directive): 340 at every canvas —
    // the mock's `min-h-[340px]`, no responsive resize.
    expect(carouselBox.height, 340);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty catalogue shows the empty state', (tester) async {
    await pumpBanner(
      tester,
      overrides: [
        homeBannerProvider.overrideWith(() => _FakeHomeBanner(const [])),
      ],
    );
    expect(find.text('home.banner.empty'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('offline error shows the retry affordance', (tester) async {
    await pumpBanner(
      tester,
      overrides: [
        homeBannerProvider.overrideWith(
          () => _FailingHomeBanner(Exception('down')),
        ),
      ],
    );
    expect(find.text('home.banner.offline'), findsOneWidget);
    expect(find.text('search.retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing TMDB key shows the settings hint', (tester) async {
    await pumpBanner(
      tester,
      overrides: [
        homeBannerSelectionProvider.overrideWith(
          () => _PinnedSelection(
            const HomeBannerSelectionState(
              source: HomeBannerSource.tmdb,
              format: HomeBannerFormat.movie,
            ),
          ),
        ),
        homeBannerProvider.overrideWith(
          () => _FailingHomeBanner(const TmdbApiKeyMissingException()),
        ),
      ],
    );
    expect(find.text('home.banner.no_key'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('linked AniList account shows the bookmark CTA', (tester) async {
    await pumpBanner(
      tester,
      accountUser: AnilistUser(
        name: 'user',
        id: 1,
        avatar: AnilistAvatar(),
        statistics: AnilistStatistics(
          anime: AnilistMediaStatistics(),
          manga: AnilistMediaStatistics(),
        ),
      ),
      overrides: [
        homeBannerProvider.overrideWith(() => _FakeHomeBanner([bannerItem(1)])),
      ],
    );
    expect(find.text('home.banner.bookmark'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'the format picker resolves the structured home.banner.* keys through '
    'the shipped catalogs (en + zh), never a raw key',
    (tester) async {
      MiruSettings.seedDefaultsForTest();
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1280, 800);
      addTearDown(tester.view.reset);
      if (!_proxySeeded) {
        MiruRequest.ensureInitalized(host: 'http://127.0.0.1:1');
        _proxySeeded = true;
      }

      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          backendConnectionProvider.overrideWith(_FakeBackendConnection.new),
          anilistAccountProvider.overrideWith(() => _FakeAnilistAccount(null)),
          homeBannerProvider.overrideWith(
            () => _FakeHomeBanner([bannerItem(1)]),
          ),
          applicationControllerProvider.overrideWith(
            () => _FakeApplicationController(
              ApplicationState(
                themeText: 'light',
                baseColor: 'zinc',
                primaryColor: 'zinc',
                themeData: ThemeUtils.getThemeData(MiruThemes.zinc.dark),
                themeMode: ThemeMode.system,
                language: 'en',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // The app's real i18n wiring: the shipped delegate over the shipped
      // asset files, with the root navigator key `.i18n` resolves through.
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: FTheme(
            data: ThemeUtils.getThemeData(MiruThemes.zinc.dark),
            child: MaterialApp.router(
              routerConfig: GoRouter(
                navigatorKey: RouterUtil.rootNavigatorKey,
                routes: [
                  GoRoute(path: '/', builder: (_, _) => const _BannerScreen()),
                ],
              ),
              localizationsDelegates: [
                I18nUtils.flutterI18nDelegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              supportedLocales: const [Locale('en'), Locale('zh')],
            ),
          ),
        ),
      );
      // The skeleton's minimum-visible window (600ms) plus the async
      // notifier resolution: pump past both before asserting labels.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      // The chip row and the catalogue picker's Anime tab both resolve the
      // nested home.banner.anime label.
      expect(find.text('Anime'), findsNWidgets(2));
      expect(find.text('home.banner.anime'), findsNothing);

      // The app's own language switch (what the settings screen calls): the
      // controller update rebuilds the tree, the refresh swaps the catalog.
      await I18nUtils.changeLanguage('zh');
      container
          .read(applicationControllerProvider.notifier)
          .changeLanguage('zh');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('动漫'), findsNWidgets(2));
      expect(find.text('Anime'), findsNothing);
      expect(find.text('home.banner.anime'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
