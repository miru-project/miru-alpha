import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb;
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/watch/epidsode_provider.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/ui/features/detail/widget/mobile_detail_tile.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_favorite_button.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_metadata_card.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_header_section.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_content_body.dart'
    show EpisodeList;
import 'package:miru_alpha/ui/features/watch/video_player/widget/side_settings_menu.dart';
import 'package:miru_alpha/ui/features/watch/widget/watch_tracker_bar.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:video_player/video_player.dart';

const _url = 'https://example.com/daemons';

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
  }) {
    // The settings tabs read the controller's `dataSource` for the
    // quality/mirror selection marks — an uninitialized late field would
    // throw the moment the sheet opens. Constructing (not initializing) the
    // controller touches no platform channels.
    vidController = VideoPlayerController.networkUrl(Uri.parse(_url));
    return VideoPlayerTickState(
      isPlaying: true,
      speed: 1.0,
      duration: const Duration(minutes: 24),
    );
  }

  /// Test seam: flips the playing flag without touching the real controller.
  void setPlaying(bool value) {
    state = state.copyWith(isPlaying: value);
  }
}

/// [DownloadNotifier] without the database/gRPC init — the tile only reads
/// preparing/active lists.
class _FakeDownloads extends DownloadNotifier {
  @override
  AsyncValue<DownloadState> build() =>
      AsyncData(DownloadState(history: const [], active: const []));
}

FavoritePageState _favoriteState(List<Favorite> favorites) => FavoritePageState(
  favorites: favorites,
  favoriteGroups: [],
  filteredFavorites: [],
  selectedFavoriteGroups: [],
);

/// [FavoritePageNotifier] that records mutations; the real delete path hits
/// the database, so it is overridden with the same in-memory behaviour.
class _FakeFavorites extends FavoritePageNotifier {
  _FakeFavorites({this.seed = const []});

  final List<Favorite> seed;
  final List<Favorite> added = [];
  final List<Favorite> deleted = [];

  @override
  FavoritePageState build() => _favoriteState(seed);

  @override
  void addFavorite(Favorite favorite) {
    added.add(favorite);
    state = state.copyWith(favorites: [favorite, ...state.favorites]);
  }

  @override
  void deleteFavorite(Favorite favorite) {
    deleted.add(favorite);
    state = state.copyWith(
      favorites: state.favorites.where((f) => f.id != favorite.id).toList(),
    );
  }
}

Favorite _seededFavorite() => Favorite(
  package: 'test.pkg',
  url: _url,
  type: 'bangumi',
  title: 'Daemons of the Shadow Realm',
  date: DateTime(2026, 1, 1),
);

Widget _harness(Widget child) => FTheme(
  data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
  child: MaterialApp(
    navigatorKey: RouterUtil.rootNavigatorKey,
    supportedLocales: FLocalizations.supportedLocales,
    localizationsDelegates: [
      I18nUtils.flutterI18nDelegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

Future<
  (ProviderContainer, EpisodeNotifierProvider, VideoPlayerNotifierProvider)
>
_pumpSpecs(WidgetTester tester, {required WatchParams param}) async {
  final vidPr = videoPlayerProvider(null);
  final epProvider = episodeProvider(param);
  final container = ProviderContainer(
    overrides: [vidPr.overrideWith(() => _FakeVideoPlayer())],
  );
  addTearDown(container.dispose);

  // Mirrors the real page body: header section, then the tabbed
  // Episodes / Overview architecture.
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: _harness(
        Column(
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
                  detail: Detail(
                    title: param.name,
                    detailUrl: param.detailUrl,
                    package: param.meta.packageName,
                    episodes: param.epGroup,
                  ),
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
                        detail: Detail(
                          title: param.name,
                          detailUrl: param.detailUrl,
                          package: param.meta.packageName,
                          episodes: param.epGroup,
                        ),
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
      ),
    ),
  );
  await tester.pump();
  return (container, epProvider, vidPr);
}

void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);
  setUp(() async {
    // I18nUtils.flutterI18nDelegate reads the language setting at first use.
    MiruSettings.setSettingSync(SettingKey.language, 'en');
  });

  group('WatchHeaderSection', () {
    testWidgets('renders title, meta line, quick actions and Up Next', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      await _pumpSpecs(tester, param: _param(episode: 0, total: 5));

      expect(find.text('Daemons of the Shadow Realm'), findsOneWidget);
      // Self-labelling "Episode 1" reads clean without quotes.
      expect(find.text('Season 1 · Episode 1'), findsOneWidget);
      expect(find.byIcon(FLucideIcons.share), findsOneWidget);
      // Up Next quick trigger with the second episode.
      expect(find.text('UP NEXT'), findsOneWidget); // badge is uppercase
      expect(find.text('Ep 2 · Episode 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Up Next Play advances; the card hides on the last episode', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      final (container, epProvider, _) = await _pumpSpecs(
        tester,
        param: _param(episode: 0, total: 5),
      );

      await tester.tap(find.text('Play'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(container.read(epProvider).selectedEpisodeIndex, 1);
      expect(tester.takeException(), isNull);

      // Jump to the last episode: no next episode, no card.
      container.read(epProvider.notifier).selectEpisode(0, 4);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('UP NEXT'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('header quick actions keep the 44px touch floor', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      final (_, _, _) = await _pumpSpecs(
        tester,
        param: _param(episode: 1, total: 18),
      );

      for (final icon in [FLucideIcons.bookmark, FLucideIcons.share]) {
        final box = tester.getSize(
          find.ancestor(of: find.byIcon(icon), matching: find.byType(FButton)),
        );
        expect(box.height, greaterThanOrEqualTo(44), reason: '$icon');
        expect(box.width, greaterThanOrEqualTo(44), reason: '$icon');
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('playing row shows the NOW badge once, no equalizer bars', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      final downloadPr = downloadProvider;
      final container = ProviderContainer(
        overrides: [downloadPr.overrideWith(() => _FakeDownloads())],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _harness(
            MobileDetailTile(
              item: _episodes(3).first.urls[0],
              idx: 0,
              position: 1,
              selectedGpIndex: 0,
              detail: Detail(
                title: 'Daemons',
                detailUrl: _url,
                package: 'test.pkg',
                episodes: _episodes(3),
              ),
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
      );
      await tester.pump();

      expect(find.text('Now'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('partial rows show Watching once and never a trailing dot', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      final downloadPr = downloadProvider;
      final container = ProviderContainer(
        overrides: [downloadPr.overrideWith(() => _FakeDownloads())],
      );
      addTearDown(container.dispose);

      Widget tile({required bool selected}) => MobileDetailTile(
        item: _episodes(3).first.urls[0],
        idx: 0,
        position: 1,
        selectedGpIndex: 0,
        detail: Detail(
          title: 'Daemons',
          detailUrl: _url,
          package: 'test.pkg',
          episodes: _episodes(3),
        ),
        meta: _meta(),
        detailUrl: _url,
        detailPr: null,
        history: History(
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
        ),
        isDownloaded: false,
        selected: selected,
        onPress: () {},
      );

      // Non-selected partial row: progress bar + time carry the state —
      // no "Watching" badge (the active row's NOW badge is the only status
      // badge; per-item badges duplicated what the progress bar already
      // says on long lists), no orphan dot.
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _harness(tile(selected: false)),
        ),
      );
      await tester.pump();
      expect(find.text('Watching'), findsNothing);
      expect(find.text('Now'), findsNothing);
      expect(find.text(' • '), findsNothing);
      expect(find.textContaining('03:54 / 10:34'), findsOneWidget);

      // Selected row: NOW badge wins, no second status badge.
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _harness(tile(selected: true)),
        ),
      );
      await tester.pump();
      expect(find.text('Now'), findsOneWidget);
      expect(find.text('Watching'), findsNothing);
      expect(find.text(' • '), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('bare backend episode names render as human labels', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      final bareGroup = ExtensionEpisodeGroup(
        title: 'Season 1',
        urls: [
          for (var i = 0; i < 5; i++)
            ExtensionEpisode(name: '$i', url: '$_url/ep$i'),
        ],
      );
      final param = WatchParams(
        meta: _meta(),
        type: ExtensionType.bangumi,
        url: '$_url/ep1',
        selectedGroupIndex: 0,
        selectedEpisodeIndex: 0,
        name: 'Daemons',
        detailImageUrl: '',
        detailUrl: _url,
        savePath: null,
        epGroup: [bareGroup],
      );
      final downloadPr = downloadProvider;
      final container = ProviderContainer(
        overrides: [downloadPr.overrideWith(() => _FakeDownloads())],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _harness(
            MobileDetailTile(
              item: bareGroup.urls[0],
              idx: 0,
              position: 1,
              selectedGpIndex: 0,
              detail: Detail(
                title: 'Daemons',
                detailUrl: _url,
                package: 'test.pkg',
                episodes: [bareGroup],
              ),
              meta: param.meta,
              detailUrl: _url,
              detailPr: null,
              history: null,
              isDownloaded: false,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Episode 1'), findsOneWidget);
      expect(find.text('0'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no Up Next on the last episode; the list still renders', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      await _pumpSpecs(tester, param: _param(episode: 17, total: 18));

      // The forward affordance is the Up Next card — absent at the end.
      expect(find.text('UP NEXT'), findsNothing);
      expect(find.text('Episode 18'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('settings sheet opens from the pill; portrait sheet drops '
        'the group picker (the base page owns groups)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      final groups = _episodes(2);
      final param = WatchParams(
        meta: _meta(),
        type: ExtensionType.bangumi,
        url: '$_url/ep1',
        selectedGroupIndex: 0,
        selectedEpisodeIndex: 0,
        name: 'Daemons of the Shadow Realm',
        detailImageUrl: '',
        detailUrl: _url,
        savePath: null,
        epGroup: groups,
      );
      final (container, epProvider, vidPr) = await _pumpSpecs(
        tester,
        param: param,
      );

      // The sheet entry moved into the viewport (subtitle pill / quality
      // chip) — open it directly here: the harness has no viewport.
      showPlayerSettingsSheet(
        tester.element(find.byType(FTabs)),
        vidPr: vidPr,
        epProvider: epProvider,
        meta: param.meta,
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // The portrait sheet dropped the Episodes tab — the base page already
      // lists episodes and owns the group switcher — so its tabs carry the
      // playback settings only.
      expect(find.text('Episodes'), findsOneWidget); // the page's list label
      expect(find.text('Source'), findsNothing);
      // The group picker no longer exists anywhere in the sheet.
      expect(find.text('Season 2'), findsNothing);
      // The sheet's tab bar is the normal icon FTabs bar now — every item is
      // a visible icon slot inside the SHEET's FTabs (`.last` — the page
      // behind the translucent sheet mounts its own FTabs first).
      final sheetTabs = find.descendant(
        of: find.byType(FTabs).last,
        matching: find.byIcon(FLucideIcons.gauge),
      );
      expect(sheetTabs, findsOneWidget); // the Speed tab
      // The default pane (Resolution) is mounted.
      expect(find.text('No quality options'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('playback settings sheet deep-links to the requested pane', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      final groups = _episodes(2);
      final param = WatchParams(
        meta: _meta(),
        type: ExtensionType.bangumi,
        url: '$_url/ep1',
        selectedGroupIndex: 0,
        selectedEpisodeIndex: 0,
        name: 'Daemons of the Shadow Realm',
        detailImageUrl: '',
        detailUrl: _url,
        savePath: null,
        epGroup: groups,
      );
      final (container, epProvider, vidPr) = await _pumpSpecs(
        tester,
        param: param,
      );

      // initialTab 99 clamps to the last entry — the Speed pane mounts with
      // its group title visible (the chip deep-links rely on this path).
      showPlayerSettingsSheet(
        tester.element(find.byType(FTabs).last),
        vidPr: vidPr,
        epProvider: epProvider,
        meta: param.meta,
        initialTab: 99,
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Playback speed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('controls auto-hide after 3s while playing', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      final (container, _, vidPr) = await _pumpSpecs(
        tester,
        param: _param(episode: 0),
      );
      // The real viewport watches the player provider; the harness's header
      // does not, so hold the autoDispose provider open for the timer.
      container.listen(vidPr, (_, _) {});
      final notifier = container.read(vidPr.notifier);

      notifier.setShowControls(true);
      expect(container.read(vidPr).showControls, isTrue);
      await tester.pump(const Duration(seconds: 3));
      expect(container.read(vidPr).showControls, isFalse);
    });

    testWidgets('paused surface keeps its controls (play/pause visible)', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      final (container, _, vidPr) = await _pumpSpecs(
        tester,
        param: _param(episode: 0),
      );
      // Hold the autoDispose player provider open (see the auto-hide test).
      container.listen(vidPr, (_, _) {});
      // The override guarantees the fake; the static notifier type doesn't
      // carry the test seam.
      final notifier = container.read(vidPr.notifier) as _FakeVideoPlayer;
      notifier.setPlaying(false);

      notifier.setShowControls(true);
      await tester.pump(const Duration(seconds: 3));
      // The 3s auto-hide is skipped while paused, so the play/pause
      // affordance never disappears on a paused surface.
      expect(container.read(vidPr).showControls, isTrue);
    });
  });

  group('WatchTrackerBar', () {
    testWidgets('shows only the synced count — no ep counter, no bookmark', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      final container = ProviderContainer(
        overrides: [
          favoritePageProvider.overrideWith(
            () => _FakeFavorites(seed: const []),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _harness(
            WatchTrackerBar(
              trackers: [
                proto.Tracker()
                  ..provider = 'anilist'
                  ..trackerId = '21',
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      // The Ep x/y counter duplicates the episodes header badge and the
      // bookmark lives in the episodes header — neither belongs here.
      expect(find.text('Synced (1)'), findsOneWidget);
      expect(find.textContaining('Ep '), findsNothing);
      expect(find.byIcon(FLucideIcons.bookmark), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('WatchFavoriteButton', () {
    testWidgets('tap adds a favorite', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      final favorites = _FakeFavorites(seed: const []);
      final container = ProviderContainer(
        overrides: [favoritePageProvider.overrideWith(() => favorites)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _harness(
            WatchFavoriteButton(
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
      );
      await tester.pump();

      final bookmarkFinder = find.byIcon(FLucideIcons.bookmark);
      expect(bookmarkFinder, findsOneWidget);
      await tester.tap(bookmarkFinder, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));

      expect(favorites.added, hasLength(1));
      expect(favorites.added.first.url, _url);
      expect(favorites.added.first.package, 'test.pkg');
      expect(favorites.added.first.title, 'Daemons');
      expect(tester.takeException(), isNull);
    });

    testWidgets('tap removes an existing favorite', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
      final favorites = _FakeFavorites(seed: [_seededFavorite()]);
      final container = ProviderContainer(
        overrides: [favoritePageProvider.overrideWith(() => favorites)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _harness(
            WatchFavoriteButton(
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
      );
      await tester.pump();

      final bookmarkFinder = find.byIcon(FLucideIcons.bookmarkCheck);
      expect(bookmarkFinder, findsOneWidget);
      await tester.tap(bookmarkFinder, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));

      expect(favorites.deleted, hasLength(1));
      expect(favorites.deleted.first.url, _url);
      expect(tester.takeException(), isNull);
    });
  });

  group('WatchMetadataCard', () {
    testWidgets('renders description with read-more and tag chips', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _harness(
          WatchMetadataCard(
            detail: Detail(
              title: 'Daemons of the Shadow Realm',
              detailUrl: _url,
              package: 'test.pkg',
              desc:
                  'In a remote mountain village under the watchful eyes of '
                  'two stone guardians, the young Yuru lives peacefully. '
                  'But when an unexpected assault tears his sanctuary apart, '
                  'dark secrets regarding twins and realm boundaries emerge '
                  'and the story turns toward the boundary gate.',
              tags: const ['Action', 'Supernatural', 'Dark Fantasy'],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Daemons of the Shadow Realm'), findsOneWidget);
      expect(find.text('Read more'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Supernatural'), findsOneWidget);
      expect(find.text('Dark Fantasy'), findsOneWidget);

      await tester.tap(find.text('Read more'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Show less'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('short description hides the read-more toggle', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _harness(
          WatchMetadataCard(
            detail: Detail(
              title: 'Daemons',
              detailUrl: _url,
              package: 'test.pkg',
              desc: 'This is an example description.',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('This is an example description.'), findsOneWidget);
      expect(find.text('Read more'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no description and no tags collapse the whole card', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 844));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _harness(
          WatchMetadataCard(
            detail: Detail(
              title: 'Daemons',
              detailUrl: _url,
              package: 'test.pkg',
            ),
          ),
        ),
      );
      await tester.pump();

      // The viewport header already carries the title, so a card with only
      // a title row and no synopsis/tags is pure chrome — it renders nothing.
      expect(find.text('Daemons'), findsNothing);
      expect(find.textContaining('Currently no description'), findsNothing);
      expect(find.text('Read more'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
