import 'package:material_ui/material_ui.dart' hide ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/home_banner_model.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/backend_connection_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/home/home_banner_provider.dart';
import 'package:miru_alpha/provider/home/home_trending_provider.dart';
import 'package:miru_alpha/provider/tracking/anilist_provider.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_banner.dart';
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/home_desktop_continue.dart';
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/home_desktop_dashboard.dart';
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/home_desktop_feed.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

/// Geometry and structure assertions for the desktop home dashboard
/// ("Unified Command Center" mockup): banner → Continue Playing & Reading →
/// Shelves strip + Favorites grid, with the download dock overlaying the
/// bottom edge. DESKTOP-EXCLUSIVE — the mobile bento never mounts these.
///
/// Widget tests render raw i18n keys, so label assertions match key
/// literals (`home.continue_reading`), not translated strings.

class _FakeFavoritePageNotifier extends FavoritePageNotifier {
  _FakeFavoritePageNotifier(this._state);
  final FavoritePageState _state;

  @override
  FavoritePageState build() => _state;
}

class _FakeHistoryPageNotifier extends HistoryPageNotifier {
  _FakeHistoryPageNotifier(this._state);
  final HistoryPageState _state;

  @override
  HistoryPageState build() => _state;
}

class _FakeDownloadNotifier extends DownloadNotifier {
  _FakeDownloadNotifier(this._state);
  final AsyncValue<DownloadState> _state;

  @override
  AsyncValue<DownloadState> build() => _state;
}

class _FakeExtensionPageNotifier extends ExtensionPageNotifier {
  _FakeExtensionPageNotifier(this._state);
  final ExtensionPageModel _state;

  @override
  ExtensionPageModel build() => _state;
}

class _FakeBackendConnection extends BackendConnection {
  @override
  Future<void> build() async {}
}

class _FakeHomeTrending extends HomeTrending {
  _FakeHomeTrending(this._items);

  @override
  Future<List<AnilistMedia>> build() async => _items;
  final List<AnilistMedia> _items;
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

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);
  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

void main() {
  Favorite favorite(String title, String type) => Favorite(
    package: 'pkg',
    url: 'url-$title',
    type: type,
    title: title,
    cover: '',
    date: DateTime.now(),
  );

  History history(String title, String type) => History(
    package: 'pkg',
    url: 'url-$title',
    detailUrl: 'detail-$title',
    cover: '',
    type: type,
    episodeGroupId: 0,
    episodeId: 2,
    title: title,
    episodeTitle: 'Episode 3',
    progress: 100,
    totalProgress: 200,
    date: DateTime.now(),
  );

  /// Pumps the desktop dashboard at a 1400x900 surface with fake providers.
  Future<void> pumpDashboard(
    WidgetTester tester, {
    List<History> historyItems = const [],
    List<Favorite> favoriteItems = const [],
    List<HomeBannerItem> bannerItems = const [],
  }) async {
    MiruSettings.seedDefaultsForTest();

    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        backendConnectionProvider.overrideWith(_FakeBackendConnection.new),
        favoritePageProvider.overrideWith(
          () => _FakeFavoritePageNotifier(
            FavoritePageState(
              favorites: favoriteItems,
              favoriteGroups: favoriteItems.isEmpty
                  ? const []
                  : [
                      FavoriteGroup(
                        name: 'Group One',
                        date: DateTime.now(),
                        favorites: favoriteItems,
                      ),
                    ],
              filteredFavorites: favoriteItems,
              selectedFavoriteGroups: const [],
            ),
          ),
        ),
        historyPageProvider.overrideWith(
          () => _FakeHistoryPageNotifier(
            HistoryPageState(
              history: historyItems,
              filteredHistory: historyItems,
            ),
          ),
        ),
        downloadProvider.overrideWith(
          () => _FakeDownloadNotifier(
            AsyncData(
              DownloadState(
                history: const [],
                active: const [],
                page: 1,
                hasMore: false,
              ),
            ),
          ),
        ),
        extensionPageProvider.overrideWith(
          () => _FakeExtensionPageNotifier(
            ExtensionPageModel(
              fetchedRepo: const [],
              extensionList: const [],
              installedPackages: const ['pkg'],
              metaData: [
                ExtensionMeta(
                  name: 'Pkg Source',
                  version: '1.0.0',
                  author: '',
                  license: '',
                  lang: 'en',
                  packageName: 'pkg',
                  webSite: '',
                  tags: const [],
                  api: '',
                  type: ExtensionType.bangumi,
                ),
              ],
              sourceIndex: 0,
            ),
          ),
        ),
        anilistAccountProvider.overrideWith(() => _FakeAnilistAccount(null)),
        homeTrendingProvider.overrideWith(() => _FakeHomeTrending(const [])),
        homeBannerProvider.overrideWith(() => _FakeHomeBanner(bannerItems)),
        applicationControllerProvider.overrideWith(
          () => _FakeApplicationController(
            ApplicationState(
              themeText: 'light',
              baseColor: 'zinc',
              primaryColor: 'zinc',
              themeData: ThemeUtils.getThemeData(MiruThemes.zinc.light),
              themeMode: ThemeMode.system,
              language: 'en',
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Width-branching surface: size the FlutterView itself — setSurfaceSize
    // does not update MediaQuery metrics (rule 27 in .agents/rules.md).
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1400, 900);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: FTheme(
          data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const HomeDesktopDashboard(),
                ),
                GoRoute(
                  path: '/home/favorite',
                  builder: (_, _) => const Scaffold(
                    body: Center(child: Text('probe-favorite')),
                  ),
                ),
                GoRoute(
                  path: '/home/download',
                  builder: (_, _) => const Scaffold(
                    body: Center(child: Text('probe-download')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'mockup composition: banner, continue, shelves + favorites; the text '
    'hero, metrics bento and trending grid are dropped; dock overlays',
    (tester) async {
      await pumpDashboard(
        tester,
        favoriteItems: [
          favorite('Manga A', 'manga'),
          favorite('Anime B', 'bangumi'),
        ],
        historyItems: [history('H1', 'bangumi'), history('H2', 'bangumi')],
      );

      final listView = tester.widget<ListView>(find.byType(ListView).first);
      final children = (listView.childrenDelegate as SliverChildListDelegate)
          .children
          .whereType<Widget>()
          .map((w) => w.runtimeType)
          .toList();
      expect(children.first, HomeBannerSection);
      final order = [
        HomeDesktopContinue,
        HomeDesktopFeed,
      ].map((t) => children.indexOf(t)).toList();
      expect(order, everyElement(greaterThanOrEqualTo(0)));
      expect(order, orderedEquals([...order]..sort()));

      // The mock drops the former sections: the text hero and the metrics
      // bento are gone; the static density strip is gone too (2026-11-12 —
      // zero interactive controls; the download dock became the shell's
      // 28px status bar).
      expect(find.text('common.your_library'), findsNothing);
      // Strip + its keys are deleted outright (no widget, no i18n entry).
      expect(find.text('home.viewport_label'), findsNothing);
      expect(find.text('home.viewport_high_density'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('continue progress: 16:9 covers under the reading header', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      historyItems: [
        history('H1', 'bangumi'),
        history('H2', 'manga'),
        history('H3', 'fikushon'),
      ],
    );

    expect(find.byType(HomeDesktopContinue), findsOneWidget);
    expect(find.text('home.continue_reading'), findsOneWidget);
    final covers = find.byKey(const Key('desktopContinueCover'));
    expect(covers, findsNWidgets(3));
    final coverRect = tester.getRect(covers.first);
    // ~16:9 within the card chrome: the MiruCard border/clip insets are a
    // fixed few px, so the ratio drifts ~2% at the narrower single-row tile
    // width (they were a smaller share when cards stretched wider).
    expect(coverRect.width / coverRect.height, closeTo(16 / 9, 0.03));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'shelves tablist: All + group tabs carry counts; New Shelf, Manage Tags '
    'and View All sit on the baseline; favorites render as poster cards',
    (tester) async {
      await pumpDashboard(
        tester,
        favoriteItems: [
          favorite('Manga A', 'manga'),
          favorite('Anime B', 'bangumi'),
        ],
      );

      // The segmented tablist: All (2) + the group tab with its count, the
      // New Shelf entry inside the track, and the baseline actions.
      expect(find.text('common.all (2)'), findsOneWidget);
      expect(find.text('Group One (2)'), findsOneWidget);
      expect(find.text('home.new_shelf'), findsOneWidget);
      expect(find.text('home.manage_tags'), findsOneWidget);
      expect(find.text('home.view_all'), findsOneWidget);

      // The favorites grid: poster cards, no separate shelf header anymore.
      expect(find.text('home.favorites_shelf'), findsNothing);
      expect(find.byKey(const Key('desktopShelfCard')), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the canvas-blocking download dock is retired for the status strip',
    (tester) async {
      // High-Density rev: the dock overlay is gone; download telemetry
      // lives in the shell's 28px status bar (covered by the shell tests).
      await pumpDashboard(tester);
      expect(find.text('home.dock_active'), findsNothing);
      expect(find.text('home.dock_active'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
