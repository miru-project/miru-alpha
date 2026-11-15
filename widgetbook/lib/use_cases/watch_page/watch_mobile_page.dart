/// Mirrors test/ui/features/watch/watch_mobile_page_test.dart states for the
/// catalog.
///
/// Skipped states (behaviour / size audits with no distinct visuals):
/// - skipped: 'header quick actions keep the 44px touch floor' — same render
///   as 'Episode 1 of 5 · Up Next card'; size assertion only.
/// - skipped: 'Up Next Play advances' — live here: tap Play on the card.
/// - skipped: 'controls auto-hide after 3s while playing' and 'paused surface
///   keeps its controls' — VideoPlayerNotifier timer behaviour; no player
///   surface is mounted by this test's harness.
/// - skipped: 'metadata card with no description and no tags' — the widget
///   renders SizedBox.shrink() (empty output, nothing to show).

library;

import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb;
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_tile.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/side_settings_menu.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_content_body.dart'
    show EpisodeList;
import 'package:miru_alpha/ui/features/watch/widget/watch_favorite_button.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_header_section.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_metadata_card.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_tracker_bar.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

const _url = 'https://example.com/daemons';

/// The mirrored-from-tests components of the mobile watch page test.
List<WidgetbookComponent> buildMobilePageComponents() => [
  WidgetbookComponent(
    name: 'WatchHeaderSection',
    useCases: [
      WidgetbookUseCase(
        name: 'Episode 1 of 5 · Up Next card',
        builder: (context) => catalogFrame(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: _Scope(
              create: () => ProviderContainer(
                overrides: [
                  favoritePageProvider.overrideWith(_FakeFavorites.new),
                ],
              ),
              child: WatchHeaderSection(
                showTitle: 'Daemons of the Shadow Realm',
                groupTitle: 'Season 1',
                episodeIndex: 0,
                episodeName: 'Episode 1',
                detail: _pageDetail(_param(episode: 0, total: 5)),
                meta: _meta(),
                detailUrl: _url,
                epProvider: episodeProvider(_param(episode: 0, total: 5)),
                favorited: false,
              ),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Last episode · no Up Next card',
        builder: (context) => catalogFrame(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: _Scope(
              create: () => ProviderContainer(
                overrides: [
                  favoritePageProvider.overrideWith(_FakeFavorites.new),
                ],
              ),
              child: WatchHeaderSection(
                showTitle: 'Daemons of the Shadow Realm',
                groupTitle: 'Season 1',
                episodeIndex: 4,
                episodeName: 'Episode 5',
                detail: _pageDetail(_param(episode: 4, total: 5)),
                meta: _meta(),
                detailUrl: _url,
                epProvider: episodeProvider(_param(episode: 4, total: 5)),
                favorited: false,
              ),
            ),
          ),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'EpisodeList',
    useCases: [
      WidgetbookUseCase(
        name: 'Page body · header + Episodes/Overview tabs (Phone)',
        builder: (context) => PhoneFrame(
          child: _Scope(
            create: () => ProviderContainer(
              overrides: [
                downloadProvider.overrideWith(_FakeDownloads.new),
                historyPageProvider.overrideWith(_FakeHistory.new),
                favoritePageProvider.overrideWith(_FakeFavorites.new),
              ],
            ),
            child: _PageBodyHarness(param: _param(episode: 0, total: 5)),
          ),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'MobileDetailTile',
    useCases: [
      WidgetbookUseCase(
        name: 'Playing row · NOW badge',
        builder: (context) => catalogFrame(
          _Scope(
            create: () => ProviderContainer(
              overrides: [downloadProvider.overrideWith(_FakeDownloads.new)],
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: MobileDetailTile(
                item: _episodes(3).first.urls[0],
                idx: 0,
                position: 1,
                selectedGpIndex: 0,
                detail: _pageDetail(_param(episode: 0, total: 3)),
                meta: _meta(),
                detailUrl: _url,
                detailPr: null,
                history: null,
                isDownloaded: false,
                selected: true,
                onPress: () {},
              ),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Watch-progress row · no status badge',
        builder: (context) => catalogFrame(
          _Scope(
            create: () => ProviderContainer(
              overrides: [downloadProvider.overrideWith(_FakeDownloads.new)],
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: MobileDetailTile(
                item: _episodes(3).first.urls[0],
                idx: 0,
                position: 1,
                selectedGpIndex: 0,
                detail: _pageDetail(_param(episode: 0, total: 3)),
                meta: _meta(),
                detailUrl: _url,
                detailPr: null,
                history: _progressHistory(),
                isDownloaded: false,
                selected: false,
                onPress: () {},
              ),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Playing row with progress · NOW badge wins',
        builder: (context) => catalogFrame(
          _Scope(
            create: () => ProviderContainer(
              overrides: [downloadProvider.overrideWith(_FakeDownloads.new)],
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: MobileDetailTile(
                item: _episodes(3).first.urls[0],
                idx: 0,
                position: 1,
                selectedGpIndex: 0,
                detail: _pageDetail(_param(episode: 0, total: 3)),
                meta: _meta(),
                detailUrl: _url,
                detailPr: null,
                history: _progressHistory(),
                isDownloaded: false,
                selected: true,
                onPress: () {},
              ),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Bare backend name · human label',
        builder: (context) => catalogFrame(
          _Scope(
            create: () => ProviderContainer(
              overrides: [downloadProvider.overrideWith(_FakeDownloads.new)],
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: MobileDetailTile(
                item: ExtensionEpisode(name: '0', url: '$_url/ep0'),
                idx: 0,
                position: 1,
                selectedGpIndex: 0,
                detail: _pageDetail(_param(episode: 0, total: 3)),
                meta: _meta(),
                detailUrl: _url,
                detailPr: null,
                history: null,
                isDownloaded: false,
                onPress: () {},
              ),
            ),
          ),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'WatchTrackerBar',
    useCases: [
      WidgetbookUseCase(
        name: 'Synced (1)',
        builder: (context) => catalogFrame(
          WatchTrackerBar(
            trackers: [
              proto.Tracker()
                ..provider = 'anilist'
                ..trackerId = '21',
            ],
          ),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'WatchFavoriteButton',
    useCases: [
      WidgetbookUseCase(
        name: 'Not favorited · bookmark',
        builder: (context) => catalogFrame(
          _Scope(
            create: () => ProviderContainer(
              overrides: [
                favoritePageProvider.overrideWith(_FakeFavorites.new),
              ],
            ),
            child: WatchFavoriteButton(
              favorited: false,
              detail: Detail(
                title: 'Daemons',
                detailUrl: _url,
                package: 'test.pkg',
              ),
              meta: _meta(),
              detailUrl: _url,
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Favorited · bookmark check',
        builder: (context) => catalogFrame(
          _Scope(
            create: () => ProviderContainer(
              overrides: [
                favoritePageProvider.overrideWith(
                  () => _FakeFavorites(seed: [_seededFavorite()]),
                ),
              ],
            ),
            child: WatchFavoriteButton(
              favorited: true,
              detail: Detail(
                title: 'Daemons',
                detailUrl: _url,
                package: 'test.pkg',
              ),
              meta: _meta(),
              detailUrl: _url,
            ),
          ),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'WatchMetadataCard',
    useCases: [
      WidgetbookUseCase(
        name: 'Long description + tags (collapsed)',
        builder: (context) => catalogFrame(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: WatchMetadataCard(
              detail: Detail(
                title: 'Daemons of the Shadow Realm',
                detailUrl: _url,
                package: 'test.pkg',
                desc:
                    'In a remote mountain village under the watchful eyes '
                    'of two stone guardians, the young Yuru lives peacefully. '
                    'But when an unexpected assault tears his sanctuary apart, '
                    'dark secrets regarding twins and realm boundaries emerge '
                    'and the story turns toward the boundary gate.',
                tags: const ['Action', 'Supernatural', 'Dark Fantasy'],
              ),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Short description · no read-more',
        builder: (context) => catalogFrame(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: WatchMetadataCard(
              detail: Detail(
                title: 'Daemons',
                detailUrl: _url,
                package: 'test.pkg',
                desc: 'This is an example description.',
              ),
            ),
          ),
        ),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'PlayerSettingsTabs',
    useCases: [
      // The portrait sheet chrome (handle + title) is replicated here; the
      // test opens the real bottom sheet via showPlayerSettingsSheet.
      WidgetbookUseCase(
        name: 'Portrait sheet · Resolution pane (no Episodes tab)',
        builder: (context) => PhoneFrame(child: _PlayerSheet(initialTab: 0)),
      ),
      WidgetbookUseCase(
        name: 'Portrait sheet · deep-linked Speed pane (tab 99)',
        builder: (context) => PhoneFrame(child: _PlayerSheet(initialTab: 99)),
      ),
    ],
  ),
];

Detail _pageDetail(WatchParams param) => Detail(
  title: param.name,
  detailUrl: param.detailUrl,
  package: param.meta.packageName,
  episodes: param.epGroup,
);

/// The test's `_pumpSpecs` composition: header section, then the tabbed
/// Episodes / Overview architecture.
class _PageBodyHarness extends StatelessWidget {
  const _PageBodyHarness({required this.param});

  final WatchParams param;

  @override
  Widget build(BuildContext context) {
    final epProvider = episodeProvider(param);
    final detail = _pageDetail(param);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer(
            builder: (context, ref, _) {
              final ep = ref.watch(epProvider);
              final group = ep.epGroup.elementAtOrNull(ep.selectedGroupIndex);
              return WatchHeaderSection(
                showTitle: param.name,
                groupTitle: group?.title ?? '',
                episodeIndex: ep.selectedEpisodeIndex,
                episodeName:
                    group?.urls
                        .elementAtOrNull(ep.selectedEpisodeIndex)
                        ?.name ??
                    '',
                detail: detail,
                meta: param.meta,
                detailUrl: param.detailUrl,
                epProvider: epProvider,
                favorited: false,
              );
            },
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, _) {
              final ep = ref.watch(epProvider);
              final group = ep.epGroup.elementAtOrNull(ep.selectedGroupIndex);
              final episodes = group?.urls ?? const <ExtensionEpisode>[];
              return FTabs(
                expands: false,
                children: [
                  FTabEntry(
                    label: Text(
                      '${'media.episodes'.i18n} (${episodes.length})',
                    ),
                    child: EpisodeList(
                      param: param,
                      detail: detail,
                      epProvider: epProvider,
                      histories: const [],
                      groupIndex: ep.selectedGroupIndex,
                      episodes: episodes,
                      favorited: false,
                    ),
                  ),
                  const FTabEntry(
                    label: Text('Overview'),
                    child: SizedBox.shrink(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// The playback settings sheet body (portrait): handle + title + the real
/// [PlayerSettingsTabs] with the Episodes tab dropped.
class _PlayerSheet extends StatelessWidget {
  const _PlayerSheet({required this.initialTab});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    final vidPr = videoPlayerProvider(null);
    return _Scope(
      create: () => ProviderContainer(
        overrides: [vidPr.overrideWith(_FakeVideoPlayer.new)],
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: ColoredBox(
            color: context.theme.colors.background.withAlpha(216),
            child: SizedBox(
              height: 567,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 10, bottom: 6),
                      decoration: BoxDecoration(
                        color: context.theme.colors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Text(
                      'watch.playback_settings'.i18n,
                      style: context.theme.typography.body.lg.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: PlayerSettingsTabs(
                      vidPr: vidPr,
                      epProvider: episodeProvider(_param()),
                      meta: _meta(),
                      initialTab: initialTab,
                      showEpisodes: false,
                      expandable: false,
                      onClose: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Holds one [ProviderContainer] for the use-case's lifetime — the catalog
/// stand-in for the tests' addTearDown(container.dispose).
class _Scope extends StatefulWidget {
  const _Scope({required this.create, required this.child});

  /// Builds the use-case's [ProviderContainer] (with its overrides) once.
  final ProviderContainer Function() create;
  final Widget child;

  @override
  State<_Scope> createState() => _ScopeState();
}

class _ScopeState extends State<_Scope> {
  late final ProviderContainer _container = widget.create();

  @override
  void dispose() {
    _container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      UncontrolledProviderScope(container: _container, child: widget.child);
}

ExtensionMeta _meta() => ExtensionMeta(
  name: 'ExampleA',
  version: '2.0.0',
  author: 't',
  license: 'MIT',
  lang: 'en',
  packageName: 'test.pkg',
  webSite: 'https://example.com',
  description: 'test provider',
  tags: const [],
  api: 'v2',
  type: ExtensionType.bangumi,
);

List<ExtensionEpisodeGroup> _episodes(int count) => [
  ExtensionEpisodeGroup(
    title: 'Season 1',
    urls: [
      for (var i = 1; i <= count; i++)
        ExtensionEpisode(name: 'Episode $i', url: '$_url/ep$i'),
    ],
  ),
];

WatchParams _param({int episode = 0, int total = 18}) => WatchParams(
  meta: _meta(),
  type: ExtensionType.bangumi,
  url: '$_url/ep${episode + 1}',
  selectedGroupIndex: 0,
  selectedEpisodeIndex: episode,
  name: 'Daemons of the Shadow Realm',
  detailImageUrl: '',
  detailUrl: _url,
  savePath: null,
  epGroup: _episodes(total),
);

History _progressHistory() => History(
  package: 'test.pkg',
  url: '$_url/ep1',
  detailUrl: _url,
  type: 'bangumi',
  episodeGroupId: 0,
  episodeId: 0,
  title: 'Daemons',
  episodeTitle: 'Episode 1',
  progress: 234,
  totalProgress: 634,
  date: DateTime(2026, 1, 1),
);

Favorite _seededFavorite() => Favorite(
  package: 'test.pkg',
  url: _url,
  type: 'bangumi',
  title: 'Daemons of the Shadow Realm',
  date: DateTime(2026, 1, 1),
);

/// [VideoPlayerNotifier] without the real controller — the harness must not
/// touch platform channels, only serve playback state.
class _FakeVideoPlayer extends VideoPlayerNotifier {
  @override
  VideoPlayerTickState build(
    String? mediaUrl, {
    List<pb.ExtensionBangumiWatchSubtitle>? subtitlesRaw,
    Map<String, String>? headers,
    Size? initialRatio,
    ExtensionBangumiWatchTorrent? torrent,
    String? localPath,
    pb.ExtensionWatch? v2watch,
    Map<String, String> qualityMap = const {},
  }) {
    // Constructing (not initializing) the controller touches no platform
    // channels; the settings panes read `dataSource` for their marks.
    vidController = VideoPlayerController.networkUrl(Uri.parse(_url));
    return VideoPlayerTickState(
      isPlaying: true,
      speed: 1.0,
      duration: const Duration(minutes: 24),
    );
  }
}

/// [DownloadNotifier] without the database/gRPC init.
class _FakeDownloads extends DownloadNotifier {
  @override
  AsyncValue<DownloadState> build() =>
      AsyncData(DownloadState(history: const [], active: const []));
}

/// [HistoryPageNotifier] without the database.
class _FakeHistory extends HistoryPageNotifier {
  @override
  HistoryPageState build() =>
      HistoryPageState(history: const [], filteredHistory: const []);
}

/// [FavoritePageNotifier] with the same in-memory behaviour as the test's
/// fake (the real delete/add paths hit the database).
class _FakeFavorites extends FavoritePageNotifier {
  _FakeFavorites({this.seed = const []});

  final List<Favorite> seed;

  @override
  FavoritePageState build() => FavoritePageState(
    favorites: seed,
    favoriteGroups: [],
    filteredFavorites: [],
    selectedFavoriteGroups: [],
  );

  @override
  void addFavorite(Favorite favorite) =>
      state = state.copyWith(favorites: [favorite, ...state.favorites]);

  @override
  void deleteFavorite(Favorite favorite) => state = state.copyWith(
    favorites: state.favorites.where((f) => f.id != favorite.id).toList(),
  );
}
