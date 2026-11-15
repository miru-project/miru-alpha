import 'dart:async';

import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/home_banner_model.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/backend_connection_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/home/home_banner_provider.dart';
import 'package:miru_alpha/provider/home/home_trending_provider.dart';
import 'package:miru_alpha/provider/tracking/anilist_provider.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_banner_skeleton.dart';
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/home_desktop_dashboard.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// Mirrors test/ui/features/home/home_banner_skeleton_test.dart states for
/// the catalog.
///
/// The test holds the banner provider on a pending future inside the REAL
/// desktop dashboard; the same trick drives the loading use-case (a
/// never-completing fake — the live catalog has no pumpAndSettle invariant,
/// so the shimmer may run forever). The loaded use-case is the swap's end
/// state the geometry-parity test pins. i18n renders raw keys — the
/// bare-harness regime. Desktop dashboards render bare; the viewport addon
/// picks the canvas size.
///
/// skipped: none — the minimum-visible-window and parity checks are
/// behavior contracts whose two visual end states are the use-cases below.
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

/// Stays in the loading phase forever — the skeleton shimmers for as long
/// as the use-case is on canvas.
class _PendingHomeBanner extends HomeBanner {
  _PendingHomeBanner(this._future);

  @override
  Future<List<HomeBannerItem>> build() => _future;
  final Future<List<HomeBannerItem>> _future;
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

HomeBannerItem _bannerItem(int rank) => HomeBannerItem(
  title: 'Frieren',
  rank: rank,
  subtitle: 'Sousou no Frieren',
  backdrop: '',
  description: 'The adventure is over.',
  score: 9.1,
  anilistMediaId: rank,
  episodeCount: 12,
  externalUrl: 'https://anilist.co/anime/$rank',
);

/// The test's 1400x900 desktop pump with the same empty library fakes.
Widget _dashboard({required HomeBanner Function() bannerFactory}) {
  MiruSettings.seedDefaults();
  return ProviderScope(
    retry: (_, _) => null,
    overrides: [
      backendConnectionProvider.overrideWith(_FakeBackendConnection.new),
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
          HistoryPageState(history: const [], filteredHistory: const []),
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
      homeBannerProvider.overrideWith(bannerFactory),
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
            builder: (_, _) => const _ProbePage('probe-favorite'),
          ),
          GoRoute(
            path: '/home/download',
            builder: (_, _) => const _ProbePage('probe-download'),
          ),
        ],
      ),
    ),
  );
}

/// The probe target the test wires for the shelf/dock taps.
class _ProbePage extends StatelessWidget {
  const _ProbePage(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(label)));
  }
}

WidgetbookComponent buildHomeBannerSkeletonComponent() {
  return WidgetbookComponent(
    name: 'HomeBannerSkeleton',
    useCases: [
      WidgetbookUseCase(
        name: 'Dashboard · banner loading skeleton',
        builder: (context) => _dashboard(
          bannerFactory: () =>
              _PendingHomeBanner(Completer<List<HomeBannerItem>>().future),
        ),
      ),
      // The swap's end state: same box, chips/title/actions/dock mirrored,
      // the continue section below never reflows.
      WidgetbookUseCase(
        name: 'Dashboard · loaded carousel',
        builder: (context) => _dashboard(
          bannerFactory: () =>
              _FakeHomeBanner([_bannerItem(1), _bannerItem(2), _bannerItem(3)]),
        ),
      ),
      // The skeleton alone: the mock's #151516 charcoal canvas with the
      // shimmer bars and the bottom-right dock placeholder.
      WidgetbookUseCase(
        name: 'Skeleton · standalone leaf',
        builder: (context) =>
            catalogFrame(const HomeBannerSkeleton(height: 340)),
      ),
    ],
  );
}
