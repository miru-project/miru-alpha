import 'dart:async';

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
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_poster_rail.dart';
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/home_desktop_dashboard.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

/// Parity contract between the banner's loading skeleton and its loaded
/// carousel, asserted on the REAL desktop dashboard (`HomeDesktopDashboard`):
/// the banner sits inside the dashboard's scrolling scaffold with the
/// Continue section below it, so the swap must not reflow the banner, its
/// contents, or anything under it.
///
/// The middle stack's top edge is content-dependent (the loaded title /
/// description line count varies per item), so only its left gutter is
/// pinned; everything else (banner box, badge row, CTA row, cluster anchor,
/// the section below) is pinned exactly.

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

/// Stays in the loading phase until the test completes its future.
class _PendingHomeBanner extends HomeBanner {
  _PendingHomeBanner(this._future);

  @override
  Future<List<HomeBannerItem>> build() => _future;
  final Future<List<HomeBannerItem>> _future;
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

HomeBannerItem bannerItem(int rank) => HomeBannerItem(
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

/// Pumps the real desktop dashboard at 1400x900 with fake providers. The
/// banner phase is chosen by [pendingBanner]: non-null keeps the banner in
/// its loading skeleton (fixed pumps only — the skeleton shimmers forever
/// and pumpAndSettle would hang); null loads [bannerItems] and settles.
Future<ProviderContainer> _pumpDashboard(
  WidgetTester tester, {
  Completer<List<HomeBannerItem>>? pendingBanner,
  List<HomeBannerItem> bannerItems = const [],
}) async {
  MiruSettings.seedDefaultsForTest();

  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1400, 900);
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
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
      homeBannerProvider.overrideWith(
        pendingBanner != null
            ? () => _PendingHomeBanner(pendingBanner.future)
            : () => _FakeHomeBanner(bannerItems),
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
      ),
    ),
  );

  if (pendingBanner != null) {
    // Fixed frames only while the skeleton shimmers.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  } else {
    await tester.pumpAndSettle();
  }
  return container;
}

void main() {
  testWidgets(
    'loading renders the banner-shaped skeleton inside the dashboard, not '
    'the generic box',
    (tester) async {
      final pending = Completer<List<HomeBannerItem>>();
      addTearDown(() {
        if (!pending.isCompleted) pending.complete(const []);
      });

      final container = await _pumpDashboard(tester, pendingBanner: pending);
      // Hold the keepAlive provider open for the whole test.
      container.listen(homeBannerProvider.future, (_, _) {});
      await tester.pump();

      expect(find.byType(HomeBannerSkeleton), findsOneWidget);
      expect(find.byType(HomeMediaSkeletonBox), findsNothing);
      // The loading surface is the mock's #151516 charcoal — not the loaded
      // slide's near-black scrim, which reads as a dead black box over
      // nothing while nothing has loaded.
      final canvas =
          tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(
                          of: find.byKey(const Key('banner-skeleton')),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;
      expect(canvas.color, const Color(0xFF151516));
      // The skeleton claims the loaded carousel's full box: dashboard gutter
      // (28) + the banner's own 16px gutter, top pad 24, fixed height 340.
      expect(
        tester.getRect(find.byKey(const Key('banner-skeleton'))),
        const Rect.fromLTRB(44, 24, 1356, 364),
      );
      // The section below renders while the banner loads.
      expect(find.text('home.continue_reading'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a fast fetch still shows the skeleton for the minimum-visible window',
    (tester) async {
      final pending = Completer<List<HomeBannerItem>>();
      final container = await _pumpDashboard(tester, pendingBanner: pending);
      container.listen(homeBannerProvider.future, (_, _) {});
      await tester.pump();
      expect(find.byType(HomeBannerSkeleton), findsOneWidget);

      // Data lands: the skeleton must LINGER for the minimum window instead
      // of flashing away faster than the eye registers it.
      pending.complete([bannerItem(1), bannerItem(2), bannerItem(3)]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        find.byType(HomeBannerSkeleton),
        findsOneWidget,
        reason: 'skeleton hid before the minimum-visible window closed',
      );

      // Past the window: the loaded carousel replaces it.
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      expect(find.byType(HomeBannerSkeleton), findsNothing);
      expect(find.text('#1 Trending'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'skeleton and loaded carousel share the same geometry — the dashboard '
    'below the banner never reflows across the swap',
    (tester) async {
      final pending = Completer<List<HomeBannerItem>>();
      final container = await _pumpDashboard(tester, pendingBanner: pending);
      container.listen(homeBannerProvider.future, (_, _) {});
      await tester.pump();

      Rect rect(Finder finder) => tester.getRect(finder);

      final skeletonBox = rect(find.byKey(const Key('banner-skeleton')));
      final skeletonChips = rect(find.byKey(const Key('skeleton-chips')));
      final skeletonTitle = rect(find.byKey(const Key('skeleton-title')));
      final skeletonActions = rect(find.byKey(const Key('skeleton-actions')));
      final skeletonCluster = rect(find.byKey(const Key('skeleton-dock')));
      final continueHeaderTop = tester
          .getRect(find.text('home.continue_reading'))
          .top;

      pending.complete([bannerItem(1), bannerItem(2), bannerItem(3)]);
      await tester.pumpAndSettle();

      expect(find.byType(HomeBannerSkeleton), findsNothing);

      final loadedBox = rect(find.byType(PageView));
      final loadedChips = rect(
        find
            .ancestor(of: find.text('#1 Trending'), matching: find.byType(Wrap))
            .first,
      );
      final loadedTitle = rect(find.text('Frieren'));
      final loadedActions = rect(
        find
            .ancestor(
              of: find.text('home.banner.watch'),
              matching: find.byType(Wrap),
            )
            .first,
      );
      final loadedButton = rect(
        find
            .ancestor(
              of: find.text('home.banner.watch'),
              matching: find.byType(FButton),
            )
            .first,
      );
      final loadedCluster = rect(
        find.byKey(const Key('bannerCarouselCluster')),
      );
      final loadedContinueHeaderTop = tester
          .getRect(find.text('home.continue_reading'))
          .top;

      // The banner box itself: identical.
      expect(skeletonBox, loadedBox);

      // Chip row: same left gutter (the loaded slide's 16px padding); its
      // top tracks the loaded title's line count, which the skeleton
      // previews at the clamp.
      expect(skeletonChips.left, closeTo(loadedChips.left, 2));

      // Title bar: same left gutter (its top tracks the loaded text's line
      // count, which the skeleton previews at the clamp).
      expect(skeletonTitle.left, closeTo(loadedTitle.left, 2));

      // CTA row: same left gutter, same bottom anchor, and the skeleton's
      // primary bar matches the real button's height.
      expect(skeletonActions.left, closeTo(loadedActions.left, 2));
      expect(skeletonActions.bottom, closeTo(loadedActions.bottom, 2));
      expect(
        skeletonActions.height,
        closeTo(loadedButton.height, 2),
        reason: 'skeleton CTA bar vs loaded primary FButton height',
      );
      expect(loadedActions.height, closeTo(loadedButton.height, 2));

      // Carousel dock: same right-12/bottom-12 anchor.
      expect(skeletonCluster.right, closeTo(loadedCluster.right, 2));
      expect(skeletonCluster.bottom, closeTo(loadedCluster.bottom, 2));

      // The dashboard content BELOW the banner never moves across the swap.
      expect(continueHeaderTop, loadedContinueHeaderTop);

      expect(tester.takeException(), isNull);
    },
  );
}
