import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/model/home_banner_model.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/backend_connection_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/home/home_banner_provider.dart';
import 'package:miru_alpha/provider/home/home_trending_provider.dart';
import 'package:miru_alpha/provider/tracking/anilist_provider.dart';
import 'package:miru_alpha/ui/features/home/views/home_view.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:widgetbook/widgetbook.dart';

/// Mirrors test/ui/features/home/home_view_test.dart states for the
/// catalog.
///
/// The test's single pump: HomeView at a 1200x800 surface resolving to
/// HomeViewDesktop (the width branch — below the forui `lg` breakpoint the
/// mobile bento mounts instead, mirrored by the 'HomeView · mobile bento'
/// component). Same fake values as the test; the backend, AniList account,
/// extension catalogue and trending providers are additionally pinned to
/// fakes so the render is fakes-only (the test leaves them real — they idle
/// harmlessly in the test zone, but here they would fire network calls).
/// i18n renders raw keys — the bare-harness regime. Rendered bare: pick a
/// wide viewport for the desktop branch.
///
/// skipped: none — the test has one visual state.
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

WidgetbookComponent buildHomeViewComponent() {
  return WidgetbookComponent(
    name: 'HomeView · desktop',
    useCases: [
      WidgetbookUseCase(
        name: 'Desktop composition (1200×800)',
        builder: (context) {
          MiruSettings.seedDefaults();
          return ProviderScope(
            retry: (_, _) => null,
            overrides: [
              backendConnectionProvider.overrideWith(
                _FakeBackendConnection.new,
              ),
              favoritePageProvider.overrideWith(
                () => _FakeFavoritePageNotifier(
                  FavoritePageState(
                    favorites: const [],
                    favoriteGroups: const [],
                    filteredFavorites: const [],
                    selectedFavoriteGroups: const [],
                  ),
                ),
              ),
              historyPageProvider.overrideWith(
                () => _FakeHistoryPageNotifier(
                  HistoryPageState(
                    history: const [],
                    filteredHistory: const [],
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
                      hasMore: true,
                    ),
                  ),
                ),
              ),
              extensionPageProvider.overrideWith(
                () => _FakeExtensionPageNotifier(
                  ExtensionPageModel(
                    fetchedRepo: const [],
                    extensionList: const [],
                    installedPackages: const [],
                    metaData: const [],
                    sourceIndex: 0,
                  ),
                ),
              ),
              anilistAccountProvider.overrideWith(
                () => _FakeAnilistAccount(null),
              ),
              homeTrendingProvider.overrideWith(
                () => _FakeHomeTrending(const []),
              ),
              homeBannerProvider.overrideWith(() => _FakeHomeBanner(const [])),
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
                  GoRoute(path: '/', builder: (_, _) => const HomeView()),
                ],
              ),
            ),
          );
        },
      ),
    ],
  );
}
