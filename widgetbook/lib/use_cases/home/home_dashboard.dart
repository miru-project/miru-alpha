import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/backend_connection_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/home/home_trending_provider.dart';
import 'package:miru_alpha/provider/tracking/anilist_provider.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_section_header.dart';
import 'package:miru_alpha/ui/features/home/views/home_view.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// Mirrors test/ui/features/home/home_dashboard_test.dart states for the
/// catalog.
///
/// The test pumps the full HomeView at a 400x1080 surface; here the same
/// fake-provider scope renders inside PhoneFrame (412x915 — the
/// width-breakpoint picks the mobile branch the same way). Covers covers,
/// chips, the quick-access tiles, the tag strip, the feed and the trending
/// rail. i18n renders raw keys (`home.continue_playing`) — the
/// bare-harness regime. Covers stay empty (`cover: ''`): ImageWidget falls
/// back without touching the network.
///
/// skipped: tag-manager sheet + downloads-tap navigation + tag/type toggle
/// filtering — interaction-driven, no distinct build state (taps work live
/// in the catalog). The `compactCount` unit test is pure arithmetic — no
/// visual state. The source-feed tests are `skip: true` upstream (the
/// section is unplugged from the dashboard, WIP).
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

class _FakeAnilistAccount extends AnilistAccount {
  // ignore: avoid_unused_constructor_parameters
  _FakeAnilistAccount(this._user);

  @override
  Future<AnilistUser?> build() async => _user;
  final AnilistUser? _user;
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

/// Stays in the loading phase forever — the rail's placeholder row shimmers
/// (the live catalog has no pumpAndSettle invariant to violate).
class _PendingHomeTrending extends HomeTrending {
  _PendingHomeTrending(this._future);

  @override
  Future<List<AnilistMedia>> build() => _future;
  final Future<List<AnilistMedia>> _future;
}

class _FailingHomeTrending extends HomeTrending {
  _FailingHomeTrending(this._error);

  @override
  Future<List<AnilistMedia>> build() async => throw _error;
  final Object _error;
}

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);
  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

History _history(
  String title,
  String type, {
  int progress = 100,
  int totalProgress = 200,
}) => History(
  package: 'pkg',
  url: 'url-$title',
  detailUrl: 'detail-$title',
  cover: '',
  type: type,
  episodeGroupId: 0,
  episodeId: 0,
  title: title,
  episodeTitle: 'Episode 1',
  progress: progress,
  totalProgress: totalProgress,
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

proto.DownloadProgress _activeDownload({
  required int progress,
  required int total,
}) => proto.DownloadProgress()
  ..taskId = 1
  ..title = 'Ep'
  ..status = proto.DownloadStatus.DOWNLOADING
  ..progress = progress
  ..total = total;

AnilistMedia _trendingMedia(
  int id,
  String title, {
  String type = 'ANIME',
  int? meanScore,
}) => AnilistMedia(
  id: id,
  type: type,
  status: 'RELEASING',
  episodes: 12,
  meanScore: meanScore,
  title: AnilistTitle(userPreferred: title),
  coverImage: AnilistCoverImage(large: ''),
);

/// The test's pumpDashboard: the same override set, rendered at phone size.
Widget _bentoDashboard({
  List<History> historyItems = const [],
  List<Favorite> favoriteItems = const [],
  List<proto.Download> downloads = const [],
  List<proto.DownloadProgress> activeDownloads = const [],
  List<AnilistMedia> trendingItems = const [],
  HomeTrending Function()? trendingOverride,
  AnilistUser? accountUser,
  List<String> recentPackages = const [],
}) {
  MiruSettings.seedDefaults();
  if (recentPackages.isNotEmpty) {
    // Same recency seeding as the test (the cache write is synchronous; the
    // backend write fails harmlessly without a core).
    MiruSettings.setSettingSync(
      SettingKey.recentExtensions,
      '[${recentPackages.map((p) => '"$p"').join(',')}]',
    );
  }

  return PhoneFrame(
    child: ProviderScope(
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
                history: downloads,
                active: activeDownloads,
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
        anilistAccountProvider.overrideWith(
          () => _FakeAnilistAccount(accountUser),
        ),
        homeTrendingProvider.overrideWith(
          trendingOverride ?? () => _FakeHomeTrending(trendingItems),
        ),
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
        routerConfig: GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, _) => const HomeView()),
            GoRoute(
              path: '/home/download',
              builder: (_, _) =>
                  const Scaffold(body: Center(child: Text('probe-download'))),
            ),
          ],
        ),
      ),
    ),
  );
}

WidgetbookComponent buildHomeMobileBentoComponent() {
  return WidgetbookComponent(
    name: 'HomeView · mobile bento',
    useCases: [
      // Top bar, type switcher, resume guidance, browse-sources tile,
      // idle downloads caption, trending empty — the default pump's state.
      WidgetbookUseCase(
        name: 'Empty dashboard',
        builder: (context) => _bentoDashboard(),
      ),
      WidgetbookUseCase(
        name: 'Continue playing · cards',
        builder: (context) => _bentoDashboard(
          historyItems: [
            _history('Video Title', 'bangumi'),
            _history('Manga Title', 'manga', progress: 82, totalProgress: 100),
          ],
        ),
      ),
      WidgetbookUseCase(
        name: 'Quick access · recent source tile',
        builder: (context) => _bentoDashboard(
          favoriteItems: [_favorite('Fav Anime', 'bangumi')],
          recentPackages: const ['pkg'],
        ),
      ),
      // Tasks running: the downloads tile's donut replaces the chevron.
      WidgetbookUseCase(
        name: 'Quick access · active downloads ring',
        builder: (context) => _bentoDashboard(
          activeDownloads: [
            _activeDownload(progress: 30, total: 100),
            _activeDownload(progress: 90, total: 100),
          ],
        ),
      ),
      WidgetbookUseCase(
        name: 'Trackers · AniList synced',
        builder: (context) => _bentoDashboard(
          accountUser: AnilistUser(
            name: 'user',
            id: 1,
            avatar: AnilistAvatar(),
            statistics: AnilistStatistics(
              anime: AnilistMediaStatistics(episodesWatched: 12),
              manga: AnilistMediaStatistics(chaptersRead: 4),
            ),
          ),
        ),
      ),
      // One fixture drives both sections, as in the tests: the tag strip's
      // group chip scopes the feed header below it.
      WidgetbookUseCase(
        name: 'Favorites · tag strip + feed posters',
        builder: (context) =>
            _bentoDashboard(favoriteItems: [_favorite('Fav Anime', 'bangumi')]),
      ),
      WidgetbookUseCase(
        name: 'Trending · posters with scores',
        builder: (context) => _bentoDashboard(
          trendingItems: [
            _trendingMedia(1, 'Trending One', meanScore: 88),
            _trendingMedia(2, 'Trending Two', type: 'MANGA', meanScore: 86),
            _trendingMedia(3, 'Trending Three', meanScore: 84),
          ],
        ),
      ),
      WidgetbookUseCase(
        name: 'Trending · loading skeleton',
        builder: (context) => _bentoDashboard(
          trendingOverride: () =>
              _PendingHomeTrending(Completer<List<AnilistMedia>>().future),
        ),
      ),
      WidgetbookUseCase(
        name: 'Trending · offline · retry',
        builder: (context) => _bentoDashboard(
          trendingOverride: () =>
              _FailingHomeTrending(Exception('AniList unreachable')),
        ),
      ),
      // The bare-header geometry state: a short trailing must pin to the
      // row's right edge, never float at the midpoint.
      WidgetbookUseCase(
        name: 'Section header · trailing pinned right',
        builder: (context) => catalogFrame(
          SizedBox(
            width: 400,
            child: HomeSectionHeader(
              title: 'Trending',
              trailing: const HomeChip(label: 'X'),
            ),
          ),
        ),
      ),
    ],
  );
}
