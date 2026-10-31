import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/home/home_trending_provider.dart';
import 'package:miru_alpha/provider/tracking/anilist_provider.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/core/widget/miru_segmented_control.dart';
import 'package:miru_alpha/ui/features/favorite/widget/favorite_group_sheet.dart';
import 'package:miru_alpha/ui/features/home/views/home_view.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_dashboard_view.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_dynamic_feed.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_poster_rail.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_quick_access_grid.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_resume_rail.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_section_header.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_top_bar.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_trending_rail.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_type_switch.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

/// Geometry and structure numbers transcribed from the
/// "Miru - Bento Dashboard & Media Browser" mockup HTML. Every test below
/// compares the rendered widgets against these values.
class MockupSpec {
  /// px-margin-mobile — page gutter on both sides.
  static const pageGutter = 16.0;

  /// Continue Playing card `w-[280px]` / cover `h-[158px]`.
  static const resumeCardWidth = 280.0;
  static const resumeCoverHeight = 158.0;

  /// Poster tiles `w-[130px]` with `aspect-[2/3]` -> 195px.
  static const posterWidth = 130.0;
  static const posterHeight = 195.0;

  /// Quick Access `gap-2` — 8px between the three shortcut tiles.
  static const gridGap = 8.0;

  /// Quick Access tile chip `w-7 h-7`.
  static const gridIconChip = 28.0;

  /// Quick Access tile `min-h-[76px]`.
  static const gridTileMinHeight = 76.0;

  /// Top-bar quick actions `w-11 h-11` (44 on touch; the test surface runs the
  /// desktop platform variant, whose floor is 40).
  static const minTopBarAction = 40.0;

  /// Top-bar pinned extent the sliver header reserves.
  static const topBarExtent = HomeTopBar.extent;

  /// Mockup `space-y-6` — the rhythm between sections.
  static const sectionGap = 24.0;

  /// Segmented switcher: All / Bangumi / Manga / Novel.
  static const typeSegments = 4;
}

class _FakeFavoritePageNotifier extends FavoritePageNotifier {
  _FakeFavoritePageNotifier(this._state);
  final FavoritePageState _state;

  @override
  FavoritePageState build() => _state;

  // Hermetic delete: the real method fires an unawaited gRPC persist whose
  // client does not exist in the test zone. State mutation mirrors the
  // real method.
  @override
  void deleteFavoriteGroup(FavoriteGroup favoriateGroup) {
    state = state.copyWith(
      favoriteGroups: state.favoriteGroups
          .where((e) => e.id != favoriateGroup.id)
          .toList(),
    );
  }
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
  _FakeAnilistAccount(this._user);

  @override
  Future<AnilistUser?> build() async => _user;
  final AnilistUser? _user;
}

class _FakeHomeTrending extends HomeTrending {
  _FakeHomeTrending(this._items);

  @override
  Future<List<AnilistMedia>> build() async => _items;
  final List<AnilistMedia> _items;
}

/// Loading state the test resolves manually, so the fake-async zone ends with
/// every future completed (a dangling error future trips flutter_test's
/// pending-timer invariant at teardown).
class _ControlledHomeTrending extends HomeTrending {
  final _completer = Completer<List<AnilistMedia>>();

  @override
  Future<List<AnilistMedia>> build() => _completer.future;

  void complete(List<AnilistMedia> items) => _completer.complete(items);

  void fail() => _completer.completeError(Exception('AniList unreachable'));
}

class _FakeApplicationController extends ApplicationController {
  _FakeApplicationController(this._state);
  final ApplicationState _state;

  @override
  ApplicationState build() => _state;
}

void main() {
  History history(
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

  Favorite favorite(String title, String type) => Favorite(
    package: 'pkg',
    url: 'url-$title',
    type: type,
    title: title,
    cover: '',
    date: DateTime.now(),
  );

  proto.Download download(String title, {DateTime? date}) => proto.Download()
    ..title = title
    ..package = 'pkg'
    ..detailUrl = 'detail-$title'
    ..date = (date ?? DateTime.now().subtract(const Duration(days: 3)))
        .toIso8601String();

  proto.DownloadProgress activeDownload({
    required int progress,
    required int total,
  }) => proto.DownloadProgress()
    ..taskId = 1
    ..title = 'Ep'
    ..status = proto.DownloadStatus.DOWNLOADING
    ..progress = progress
    ..total = total;

  AnilistMedia trendingMedia(
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

  /// Pumps the mobile dashboard at a phone-sized surface with fake providers.
  ///
  /// Widget tests load raw i18n keys, so label assertions match the key
  /// literals (`home.continue_playing`), not the translated strings.
  Future<void> pumpDashboard(
    WidgetTester tester, {
    List<History> historyItems = const [],
    List<Favorite> favoriteItems = const [],
    List<proto.Download> downloads = const [],
    List<proto.DownloadProgress> activeDownloads = const [],
    List<AnilistMedia> trendingItems = _emptyTrending,
    HomeTrending Function()? trendingOverride,
    AnilistUser? accountUser,
    List<String> recentPackages = const [],
  }) async {
    MiruSettings.seedDefaultsForTest();
    if (recentPackages.isNotEmpty) {
      MiruSettings.setSettingSync(
        SettingKey.recentExtensions,
        '[${recentPackages.map((p) => '"$p"').join(',')}]',
      );
    }

    // retry: null stops Riverpod 3's automatic failure retry, whose backoff
    // Timer would outlive the widget tree and trip flutter_test's
    // pending-timer invariant. Production keeps the default backoff.
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
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
    );
    addTearDown(container.dispose);

    await tester.binding.setSurfaceSize(dashboardTestSurface);
    addTearDown(() async => tester.binding.setSurfaceSize(null));

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
                  builder: (context, state) => const HomeView(),
                ),
                // Probe target for the shortcut tiles' tap wiring: the tests
                // assert the tap CARRIED the navigation, not just that the
                // widget renders.
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

  Finder segment(String label) => find.descendant(
    of: find.byType(HomeTypeSwitch),
    matching: find.text(label),
  );

  List<FButton> typeSwitchButtons(WidgetTester tester) => tester
      .widgetList<FButton>(
        find.descendant(
          of: find.byType(HomeTypeSwitch),
          matching: find.byType(FButton),
        ),
      )
      .toList();

  testWidgets('top bar: brand, badge and the search action', (tester) async {
    await pumpDashboard(tester);

    final bar = tester.getSize(find.byType(HomeTopBar));
    expect(bar.height, MockupSpec.topBarExtent);

    // The pinned brand bar carries the Home wordmark; the Miru/ALPHA badge
    // group is gone from the header (brand bar reads one wordmark now).
    expect(find.text('common.home'), findsOneWidget);

    // One 44px header action (search) — no tune/sync sheet. The pinned 48px
    // bar spends 8px on vertical padding (home_top_bar.dart), so the action
    // fills the remaining ~31.5px height; its 44px width carries the tap
    // target, so only the width floor is enforceable here.
    final actions = find.byType(FHeaderAction);
    expect(actions, findsOneWidget);
    for (final box in tester.renderObjectList<RenderBox>(actions)) {
      expect(box.size.width, greaterThanOrEqualTo(MockupSpec.minTopBarAction));
      // The action must fill the pinned bar, not shrink inside it.
      expect(
        box.size.height,
        greaterThanOrEqualTo(HomeTopBar.extent - 16 - 0.5),
        reason: 'vertical padding (16) + hairline border (0.5)',
      );
    }
    expect(find.bySemanticsLabel('common.search_globally'), findsOneWidget);
    expect(find.bySemanticsLabel('common.filters'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no tune action: the dashboard keeps itself current', (
    tester,
  ) async {
    await pumpDashboard(tester);

    // The "Filters and Sync Options" sheet was removed as a fake feature —
    // the dashboard's providers are updated directly by their writers
    // (watching writes history, favoriting writes favorites), so no manual
    // sync/reload exists. Pull-to-refresh is the one explicit gesture.
    expect(find.bySemanticsLabel('common.filters'), findsNothing);
    expect(find.text('home.dashboard_options'), findsNothing);
    expect(find.text('home.sync_sources'), findsNothing);
    expect(find.text('home.reload_library'), findsNothing);
    // The search action remains the single header action.
    expect(find.bySemanticsLabel('common.search_globally'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('type switcher: four equal segments, primary on selected', (
    tester,
  ) async {
    await pumpDashboard(tester);

    final buttons = typeSwitchButtons(tester);
    expect(buttons.length, MockupSpec.typeSegments);
    // Mockup: selected = bg-primary, rest = transparent on the track.
    expect(buttons[0].variant, FButtonVariant.primary);
    for (final button in buttons.skip(1)) {
      expect(button.variant, FButtonVariant.ghost);
    }
    // Mockup: the track is the inset darkest surface (bg-surface-container-
    // lowest), not a raised muted slab.
    final track = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(HomeTypeSwitch),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect(
      (track.decoration as BoxDecoration).color,
      ThemeUtils.getThemeData(MiruThemes.zinc.light).colors.background,
    );
    // Mockup: flex-1 -> equal columns.
    final widths = tester
        .renderObjectList<RenderBox>(
          find.descendant(
            of: find.byType(HomeTypeSwitch),
            matching: find.byType(FButton),
          ),
        )
        .map((box) => box.size.width)
        .toList();
    for (final width in widths) {
      expect(width, closeTo(widths.first, 0.5));
    }

    // HTML ref: `py-1.5` segment = 32px inside the `p-1` + border track
    // (42px) — forui's touch `.sm` alone is 42px per segment.
    final heights = tester
        .renderObjectList<RenderBox>(
          find.descendant(
            of: find.byType(HomeTypeSwitch),
            matching: find.byType(FButton),
          ),
        )
        .map((box) => box.size.height)
        .toList();
    for (final height in heights) {
      expect(height, 32.0);
    }

    // Tapping a segment writes the dashboard type filter.
    await tester.tap(segment('media.manga'));
    await tester.pumpAndSettle();
    expect(typeSwitchButtons(tester)[2].variant, FButtonVariant.primary);
    expect(tester.takeException(), isNull);
  });

  testWidgets('continue playing: card spec, chips, progress and actions', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      historyItems: [
        history('Video Title', 'bangumi'),
        history('Manga Title', 'manga', progress: 82, totalProgress: 100),
      ],
    );

    // Mockup: "N In Progress" counter next to the header.
    expect(find.text('home.in_progress'), findsOneWidget);

    // Mockup: card w-[280px], cover h-[158px].
    final covers = tester.renderObjectList<RenderBox>(
      find.byKey(const Key('homeResumeCover')),
    );
    expect(covers.length, 2);
    for (final cover in covers) {
      expect(cover.size.height, MockupSpec.resumeCoverHeight);
      expect(cover.size.width, MockupSpec.resumeCardWidth);
    }

    // Mockup: percent chip bottom-right + progress line fraction. Video shows
    // remaining time ("2m left" for the 100s left in the fixture); print media
    // shows the percent.
    expect(find.text('home.time_left'), findsOneWidget);
    expect(find.text('82%'), findsOneWidget);

    // No per-card action button: the whole card is the tap target (the old
    // Play/Read button duplicated it). The card body is title + progress line.
    // (Scoped to the cards — the header's "N In Progress" pill is an FButton.)
    expect(find.text('home.play_episode'), findsNothing);
    expect(find.text('home.read_chapter'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(MiruCard),
        matching: find.byType(FButton),
      ),
      findsNothing,
    );

    // Card height matches the rail (mockup: cover + title + progress line).
    final cardBox = tester.renderObject<RenderBox>(
      find
          .descendant(
            of: find.byType(HomeResumeRail),
            matching: find.byType(MiruCard),
          )
          .first,
    );
    expect(cardBox.size.height, closeTo(220, 4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('command grid: recent sources first, then stable entries', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      favoriteItems: [favorite('Fav Anime', 'bangumi')],
      recentPackages: const ['pkg'],
    );

    // Mockup: "Quick Access" header with a muted "Shortcuts" label.
    expect(find.text('home.quick_access'), findsOneWidget);
    expect(find.text('home.shortcuts'), findsOneWidget);

    // Recency-driven: the recently accessed source is its own tile (label =
    // the source's name, tap enters its catalogue), then the downloads and
    // tracker entries. No generic tile while a recent exists, and no
    // Favorites tile — the local-collection entry lives in the Favorite
    // Tags header (audit round 2: duplicate pathway).
    expect(find.text('Pkg Source'), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);
    expect(find.text('extension.name'), findsNothing);
    expect(find.text('download.name'), findsOneWidget);
    expect(find.text('home.trackers'), findsOneWidget);
    expect(find.text('home.local_favorites'), findsNothing);
    // No Tags tile — the Favorite Tags section below owns tag management.
    expect(find.text('home.local_tags'), findsNothing);

    // 28px icon chips, one per tile.
    final chips = find.byKey(const Key('homeGridIconChip'));
    expect(chips, findsNWidgets(3));
    for (final box in tester.renderObjectList<RenderBox>(chips)) {
      expect(box.size.width, MockupSpec.gridIconChip);
      expect(box.size.height, MockupSpec.gridIconChip);
    }

    // Three equal-width tiles on ONE row (the mock's grid-cols-3 — the
    // 2×2 variant was reverted for vertical viewport waste), each at least
    // the mock's min-h-[76px].
    final tiles = tester
        .renderObjectList<RenderBox>(find.byType(MiruCard))
        .map(
          (box) => (
            width: box.size.width,
            height: box.size.height,
            top: box.localToGlobal(Offset.zero).dy,
          ),
        )
        .where((t) => t.width < 250)
        .toList();
    expect(tiles.length, 3);
    expect(tiles.map((t) => t.width).toSet().length, 1);
    expect(tiles.map((t) => t.top).toSet().length, 1);
    for (final tile in tiles) {
      expect(tile.height, greaterThanOrEqualTo(MockupSpec.gridTileMinHeight));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('command grid without recents: browse-sources entry', (
    tester,
  ) async {
    await pumpDashboard(tester);

    // No recent access yet: the generic extension tile offers the source
    // count and routes to the extension manager.
    expect(find.text('extension.name'), findsOneWidget);
    expect(find.text('home.sources_value'), findsOneWidget);
    expect(find.text('download.name'), findsOneWidget);
    expect(find.text('home.trackers'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('trackers card shows AniList statistics when linked', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      accountUser: AnilistUser(
        name: 'user',
        id: 1,
        avatar: AnilistAvatar(),
        statistics: AnilistStatistics(
          anime: AnilistMediaStatistics(episodesWatched: 12),
          manga: AnilistMediaStatistics(chaptersRead: 4),
        ),
      ),
    );

    expect(find.text('home.synced_count'), findsOneWidget);
    expect(find.text('home.not_linked'), findsNothing);
  });

  test('trackers metric compacts thousands into one line of caption', () {
    expect(compactCount(940), '940');
    expect(compactCount(1000), '1.0k');
    expect(compactCount(2891), '2.9k');
  });

  testWidgets('favorite tags header: no favorites shortcut (removed pill)', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      favoriteItems: [favorite('Fav Anime', 'bangumi')],
    );

    // The consolidated "Favorites (N)" pill was removed from the header in
    // b310d2b — intentional absence guards, so a reintroduction of either
    // label is caught by the suite.
    expect(find.text('home.favorites_entry'), findsNothing);
    expect(find.text('home.local_favorites'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('downloads tile tap enters the download manager', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.text('download.name'));
    // Two pumps: the first processes the tap and the router's push, the
    // second builds the pushed page.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('probe-download'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('downloads tile: active count caption and progress ring', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      activeDownloads: [
        activeDownload(progress: 30, total: 100),
        activeDownload(progress: 90, total: 100),
      ],
    );

    expect(find.text('download.active_count'), findsOneWidget);
    // Tasks running: the mock's donut replaces the tile's chevron.
    expect(find.byKey(const Key('homeDownloadsProgressRing')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('downloads tile idle: count caption, no ring', (tester) async {
    await pumpDashboard(tester);

    expect(find.text('download.active_count'), findsOneWidget);
    expect(find.byKey(const Key('homeDownloadsProgressRing')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tag strip: chips with counts, select toggle, manage', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      favoriteItems: [favorite('Fav Anime', 'bangumi')],
    );

    expect(find.text('home.favorite_tags'), findsOneWidget);
    expect(find.text('common.manage'), findsOneWidget);
    expect(find.text('common.new_tag'), findsOneWidget);
    // Simplified mockup: no "#" leads and no count badge on the header.
    expect(find.text('#'), findsNothing);
    expect(find.text('home.custom_tags'), findsNothing);

    Finder groupChipButton() => find.ancestor(
      of: find.text('Group One (1)'),
      matching: find.byType(FButton),
    );
    expect(
      tester.widget<FButton>(groupChipButton()).variant,
      FButtonVariant.outline,
    );

    // Tapping selects the group (primary) and scopes the Dynamic Feed.
    await tester.tap(groupChipButton());
    await tester.pumpAndSettle();
    expect(
      tester.widget<FButton>(groupChipButton()).variant,
      FButtonVariant.primary,
    );
    expect(find.text('home.feed_title'), findsOneWidget);

    // Tapping again clears the selection.
    await tester.tap(groupChipButton());
    await tester.pumpAndSettle();
    expect(find.text('home.feed_title'), findsOneWidget);

    // "Manage" opens the SAME tag manager the favorites page uses — the
    // bottom sheet (no route jump, no second tag-manager implementation).
    await tester.tap(find.text('common.manage'));
    await tester.pumpAndSettle();
    expect(find.text('favorite.select_groups'), findsOneWidget);
    // Section labels are uppercase micro-labels (same treatment as the
    // search filter panel).
    expect(find.text('FAVORITE.FILTER_MODE'), findsOneWidget);
    expect(find.text('FAVORITE.CURRENT_GROUPS'), findsOneWidget);
    // Sheet height budget: the sheet may not pass 45% of the viewport, so
    // the feed behind stays visible for the live preview.
    final sheetHeight = tester.getSize(find.byType(FavoriteGroupSheet)).height;
    expect(
      sheetHeight,
      lessThanOrEqualTo(dashboardTestSurface.height * 0.45 + 2),
    );
    // AND/OR is the shared segmented control: selected = primary fill,
    // unselected = bordered outline (dark-mode contrast fix).
    final modeControl = find.byType(MiruSegmentedControl<FavoriteFilterMode>);
    expect(modeControl, findsOneWidget);
    FButton andSegment() => tester.widget<FButton>(
      find
          .ancestor(
            of: find.text('favorite.and'),
            matching: find.byType(FButton),
          )
          .first,
    );
    // Provider default is OR: AND renders the bordered outline variant.
    expect(andSegment().variant, FButtonVariant.outline);
    // Tapping a segment commits the mode immediately — auto-apply, nothing
    // to confirm ("make sure the buttons are function"). The active mode is
    // the solid primary fill (surface differentiation; the radio dot
    // disambiguates it from a plain raised button).
    await tester.tap(find.text('favorite.and'));
    await tester.pumpAndSettle();
    expect(andSegment().variant, FButtonVariant.primary);

    // Tag management covers removal: the group's ✕ deletes it, and the
    // strip chip disappears with it (same provider, reactive). The sheet
    // chip shows the BARE name (counters are browsing-surface metadata);
    // the strip chip keeps the count.
    expect(find.text('Group One (1)'), findsOneWidget);
    expect(find.text('Group One'), findsOneWidget);
    // The chip's LABEL toggles selection (its own target) — the ✕ inside
    // the chip is a separate one.
    final sheetChip = find
        .descendant(
          of: find.byType(FavoriteGroupSheet),
          matching: find.ancestor(
            of: find.text('Group One'),
            matching: find.byType(FButton),
          ),
        )
        .first;
    await tester.tap(sheetChip);
    await tester.pumpAndSettle();
    expect(tester.widget<FButton>(sheetChip).variant, FButtonVariant.primary);
    // ONE selection everywhere: picking the group in the sheet also selects
    // it on the homepage's tag strip (same favoritePageProvider state).
    expect(
      tester.widget<FButton>(groupChipButton()).variant,
      FButtonVariant.primary,
    );

    // Tapping the ✕ removes the group instead of toggling it.
    await tester.tap(find.byIcon(FLucideIcons.x));
    await tester.pumpAndSettle();
    expect(find.text('Group One (1)'), findsNothing);
    expect(find.text('Group One'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dynamic feed: posters, type line, view all', (tester) async {
    await pumpDashboard(
      tester,
      favoriteItems: [favorite('Fav Anime', 'bangumi')],
    );

    // Mockup: "Feed: All" header + View All pill; no count subtitle.
    expect(find.text('home.feed_title'), findsOneWidget);
    expect(find.text('home.titles_value'), findsNothing);
    expect(find.text('home.view_all'), findsOneWidget);

    // Mockup: poster w-[130px], aspect 2/3.
    final fallback = tester.getSize(
      find.byKey(const Key('homePosterFallback')),
    );
    expect(fallback.width, MockupSpec.posterWidth);
    expect(fallback.height, closeTo(MockupSpec.posterHeight, 0.5));

    // Card content: title + bare type label (no source chip, no tag badge).
    expect(find.text('Fav Anime'), findsOneWidget);
    expect(find.text('media.bangumi'), findsWidgets);
    expect(find.textContaining('Pkg Source'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('section header trailing is pinned to the right edge', (
    tester,
  ) async {
    // Bare header with a deliberately short trailing: the dashboard's own
    // trailings are too wide (or too close to half the row) to tell
    // pinned-right from the old midpoint float. The old code made the
    // trailing a second flex child — Expanded and Flexible split the
    // leftover width 1:1 — so a short pill was laid out at the row's
    // midpoint instead of the right edge.
    await tester.binding.setSurfaceSize(const Size(400, 200));
    addTearDown(() async => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      FTheme(
        data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
        child: MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HomeSectionHeader(
                title: 'Trending',
                trailing: const HomeChip(label: 'X'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final headerRect = tester.getRect(find.byType(HomeSectionHeader));
    final chipRect = tester.getRect(find.byType(HomeChip));

    // Premise: the chip is much narrower than the row, so the assertions
    // below really do tell pinned-right from midpoint.
    expect(chipRect.width, lessThan(headerRect.width / 2));
    // Flush right (the core alignment contract)…
    expect(chipRect.right, closeTo(headerRect.right, 0.5));
    // …and clearly on the right half — fails if the trailing ever
    // regresses to the old midpoint placement.
    expect(chipRect.left, greaterThan(headerRect.left + headerRect.width / 2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dynamic feed header carries the selected tag, no badges', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      favoriteItems: [favorite('Fav Anime', 'bangumi')],
    );

    Finder feedBadge() => find.descendant(
      of: find.byType(HomeDynamicFeed),
      matching: find.text('#Group One'),
    );
    expect(feedBadge(), findsNothing);
    await tester.tap(find.text('Group One (1)'));
    await tester.pumpAndSettle();
    // The simplified mockup scopes the header but drops poster badges.
    expect(find.text('home.feed_title'), findsOneWidget);
    expect(feedBadge(), findsNothing);
  });

  testWidgets('trending: posters with scores, no rank badges', (tester) async {
    await pumpDashboard(
      tester,
      trendingItems: [
        trendingMedia(1, 'Trending One', meanScore: 88),
        trendingMedia(2, 'Trending Two', type: 'MANGA', meanScore: 86),
        trendingMedia(3, 'Trending Three', meanScore: 84),
      ],
    );

    expect(find.text('home.trending'), findsOneWidget);
    expect(find.text('extension.source'), findsOneWidget);
    // The type switcher repeats the manga label; scope to the rail.
    Finder railText(String label) => find.descendant(
      of: find.byType(HomeTrendingRail),
      matching: find.text(label),
    );
    // Simplified mockup: score chips only — no #1/#2/#3 rank badges.
    expect(railText('#1'), findsNothing);
    expect(railText('#2'), findsNothing);
    expect(railText('#3'), findsNothing);
    expect(railText('8.8'), findsOneWidget);
    expect(railText('8.6'), findsOneWidget);
    expect(railText('8.4'), findsOneWidget);
    expect(railText('Trending One'), findsOneWidget);
    expect(railText('media.manga'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('trending: loading skeleton then offline retry on failure', (
    tester,
  ) async {
    final trending = _ControlledHomeTrending();
    await pumpDashboard(tester, trendingOverride: () => trending);

    // Mockup: while the catalogue is in flight the rail shows placeholders.
    expect(find.text('home.trending_offline'), findsNothing);
    expect(find.byType(HomePosterRail), findsNothing);
    expect(tester.takeException(), isNull);

    // Failure -> offline empty state with a Retry action.
    trending.fail();
    await tester.pump();
    await tester.pump();
    expect(find.text('home.trending_offline'), findsOneWidget);
    expect(find.text('search.retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'source feed: rows with source, inline language, time',
    // WIP: HomeSourceFeed is unplugged from the dashboard for now
    // (home_dashboard_view.dart keeps the section commented out), so the
    // feed rows render nowhere. Skip until the section ships.
    skip: true,
    (tester) async {
      await pumpDashboard(tester, downloads: [download('Solo Leveling')]);

      expect(find.text('home.source_feed'), findsOneWidget);
      expect(find.text('home.view_all'), findsOneWidget);
      expect(find.text('Pkg Source'), findsOneWidget);
      // Mockup: language moved inline as "(EN)", no separate chip.
      expect(find.text('Solo Leveling (EN)'), findsOneWidget);
      expect(find.text('common.days_ago'), findsOneWidget);
      expect(find.byType(FTile), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'source feed empty state',
    skip: true, // HomeSourceFeed is commented out of the dashboard (WIP)
    (tester) async {
      await pumpDashboard(tester);
      expect(find.text('download.no_download_history'), findsOneWidget);
      expect(find.byType(FTile), findsNothing);
    },
  );

  testWidgets('every section shares the 16px gutter (mock px-margin-mobile)', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      favoriteItems: [favorite('Fav Anime', 'bangumi')],
      recentPackages: const ['pkg'],
      historyItems: [history('Video Title', 'bangumi')],
      downloads: [download('Solo Leveling')],
    );

    // The ref pads the header AND every section with px-margin-mobile (16):
    // the brand, each section header, and the leading card/tile of every
    // rail must sit on the same left edge — a 4px drift is what reads as
    // "the padding looks weird".
    double leftOf(Finder finder) => tester.getRect(finder).left;
    final contract = <String, double>{
      'brand': leftOf(find.text('common.home')),
      'type-switch': leftOf(find.byType(HomeTypeSwitch)),
      'resume-header': leftOf(find.text('home.continue_playing')),
      'resume-card': leftOf(find.byKey(const Key('homeResumeCover'))),
      'quick-access-header': leftOf(find.text('home.quick_access')),
      // Card containers, not their centered labels — a centered text's left
      // edge depends on its own width, not the gutter.
      'quick-access-card': leftOf(find.byType(MiruCard).first),
      'tags-header': leftOf(find.text('home.favorite_tags')),
      'feed-header': leftOf(find.text('home.feed_title')),
      'trending-header': leftOf(find.text('home.trending')),
    };
    contract.forEach((name, left) {
      // Headers with a leading icon carry the icon at the gutter and the
      // text after it (16 + 18 icon + 6 gap = 40); bare headers sit the
      // title on the gutter itself.
      final expected = name == 'feed-header'
          ? MockupSpec.pageGutter + 24
          : MockupSpec.pageGutter;
      expect(left, closeTo(expected, 0.5), reason: '$name off-gutter');
    });
    expect(tester.takeException(), isNull);
  });

  testWidgets('section order and rhythm match the mockup', (tester) async {
    await pumpDashboard(
      tester,
      historyItems: [history('Video Title', 'bangumi')],
      favoriteItems: [favorite('Fav Anime', 'bangumi')],
    );

    // Mockup section order: switcher, continue playing, command grid, tags,
    // dynamic feed, trending. The Source Feed at the tail is WIP (commented
    // out of the dashboard) and returns to this list when it ships.
    double dy(String key) => tester.getTopLeft(find.text(key)).dy;
    final order = [
      'home.continue_playing',
      'home.quick_access',
      'home.favorite_tags',
      'home.feed_title',
      'home.trending',
    ];
    for (var i = 1; i < order.length; i++) {
      expect(dy(order[i]), greaterThan(dy(order[i - 1])), reason: order[i]);
    }
    // The switcher sits above the first section.
    expect(
      dy('home.continue_playing'),
      greaterThan(tester.getTopLeft(segment('common.all')).dy),
    );
    // Mockup space-y-xl between sections.
    expect(kHomeSectionGap, MockupSpec.sectionGap);
    expect(tester.takeException(), isNull);
  });

  testWidgets('type switcher filters the rails', (tester) async {
    await pumpDashboard(
      tester,
      historyItems: [
        history('Video Title', 'bangumi'),
        history('Manga Title', 'manga'),
      ],
      favoriteItems: [favorite('Fav Anime', 'bangumi')],
    );

    expect(find.text('Video Title'), findsOneWidget);
    expect(find.text('Manga Title'), findsOneWidget);

    // Scope to the switcher: the resume card's own type badge repeats the
    // same label.
    await tester.tap(segment('media.manga'));
    await tester.pumpAndSettle();

    expect(find.text('Video Title'), findsNothing);
    expect(find.text('Manga Title'), findsOneWidget);
    // The favorites rail filtered down to nothing under the manga type.
    expect(find.text('home.feed_empty'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const _emptyTrending = <AnilistMedia>[];

/// Harness viewport for the full-dashboard pumps. Tall enough that every
/// section (the 2×2 Quick Access grid through the Source Feed) is built
/// inside the surface — below-the-fold slivers materialize lazily and their
/// finders would report nothing. Width stays at 400: every width-based
/// mockup assertion depends on it.
const dashboardTestSurface = Size(400, 1080);
