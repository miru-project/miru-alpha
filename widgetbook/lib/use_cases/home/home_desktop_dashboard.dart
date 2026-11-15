import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
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
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/home_desktop_dashboard.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:widgetbook/widgetbook.dart';

/// Mirrors test/ui/features/home/home_desktop_dashboard_test.dart states
/// for the catalog.
///
/// The 1400x900 desktop pump: banner → Continue Playing & Reading →
/// shelves strip + favorites grid. Same fake provider set as the test; i18n
/// renders raw keys (`home.continue_reading`) — the bare-harness regime.
/// Rendered bare — the viewport addon picks the canvas size (pick a wide
/// one).
///
/// skipped: the dock-retirement and dropped-section checks are absence
/// assertions with no visual state of their own — both use-cases render the
/// retired state (no dock, no text hero, no metrics bento).
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

History _history(String title, String type) => History(
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

Favorite _favorite(String title, String type) => Favorite(
  package: 'pkg',
  url: 'url-$title',
  type: type,
  title: title,
  cover: '',
  date: DateTime.now(),
);

/// The test's pumpDashboard: same fakes, parameterized by the fixture lists.
Widget _desktopDashboard({
  List<History> historyItems = const [],
  List<Favorite> favoriteItems = const [],
  List<HomeBannerItem> bannerItems = const [],
}) {
  MiruSettings.seedDefaults();
  return ProviderScope(
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
    child: MaterialApp.router(
      builder: (context, child) => ColoredBox(
        color: context.theme.colors.background,
        child: child ?? const SizedBox.shrink(),
      ),
      routerConfig: GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const HomeDesktopDashboard()),
          GoRoute(
            path: '/home/favorite',
            builder: (_, _) =>
                const Scaffold(body: Center(child: Text('probe-favorite'))),
          ),
          GoRoute(
            path: '/home/download',
            builder: (_, _) =>
                const Scaffold(body: Center(child: Text('probe-download'))),
          ),
        ],
      ),
    ),
  );
}

WidgetbookComponent buildHomeDesktopDashboardComponent() {
  return WidgetbookComponent(
    name: 'HomeDesktopDashboard',
    useCases: [
      WidgetbookUseCase(
        name: 'Populated · banner + continue + shelves',
        builder: (context) => _desktopDashboard(
          favoriteItems: [
            _favorite('Manga A', 'manga'),
            _favorite('Anime B', 'bangumi'),
          ],
          historyItems: [_history('H1', 'bangumi'), _history('H2', 'bangumi')],
        ),
      ),
      // The empty-library invite: the dashed Favorites panel and the
      // continue section's bordered empty card (the dock-retired canvas).
      WidgetbookUseCase(
        name: 'Empty · library invite',
        builder: (context) => _desktopDashboard(),
      ),
    ],
  );
}
