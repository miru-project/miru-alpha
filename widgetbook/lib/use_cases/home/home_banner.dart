import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart' show Override;
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/model/home_banner_model.dart';
import 'package:miru_alpha/provider/backend_connection_provider.dart';
import 'package:miru_alpha/provider/home/home_banner_provider.dart';
import 'package:miru_alpha/provider/tracking/anilist_provider.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_banner.dart';
import 'package:miru_alpha/utils/tracking/tmdb.dart';
import 'package:widgetbook/widgetbook.dart';

/// Mirrors test/ui/features/home/home_banner_test.dart states for the
/// catalog.
///
/// Same fakes as the test: the banner list, the backend gate and the AniList
/// account are overridden, the selection stays the default (AniList anime)
/// unless a state pins it. Fixtures keep `backdrop: ''` like the test —
/// ImageWidget short-circuits an empty URL into its fallback child, so no
/// proxy/network is touched. i18n renders raw keys (`home.banner.watch`) —
/// the bare-harness regime. Rendered bare: the banner is a desktop-layout
/// section, the viewport addon picks the canvas size.
///
/// skipped: the shipped-catalog i18n language-switch test — behavior-only
/// (delegates swap on a controller change; the catalog renders raw keys by
/// convention, never loads delegates).
class _FakeBackendConnection extends BackendConnection {
  @override
  Future<void> build() async {}
}

class _FakeAnilistAccount extends AnilistAccount {
  // ignore: avoid_unused_constructor_parameters
  _FakeAnilistAccount(this._user);

  @override
  Future<AnilistUser?> build() async => _user;
  final AnilistUser? _user;
}

class _FakeHomeBanner extends HomeBanner {
  _FakeHomeBanner(this._items);

  @override
  Future<List<HomeBannerItem>> build() async => _items;
  final List<HomeBannerItem> _items;
}

class _FailingHomeBanner extends HomeBanner {
  _FailingHomeBanner(this._error);

  @override
  Future<List<HomeBannerItem>> build() async => throw _error;
  final Object _error;
}

/// Pins the selection so the TMDB-key state starts from a known slice.
class _PinnedSelection extends HomeBannerSelection {
  _PinnedSelection(this._state);

  @override
  HomeBannerSelectionState build() => _state;
  final HomeBannerSelectionState _state;
}

HomeBannerItem _bannerItem(int rank) => HomeBannerItem(
  title: 'Frieren',
  rank: rank,
  subtitle: 'Sousou no Frieren',
  // Empty: a live URL would fetch through the core proxy; the errChild
  // fallback is what the tests exercise (their dead-port trick, minus the
  // network).
  backdrop: '',
  description: 'The adventure is over.',
  score: 9.1,
  anilistMediaId: rank,
  episodeCount: 12,
  externalUrl: 'https://anilist.co/anime/$rank',
);

/// The test's pump: faked providers over MaterialApp.router hosting the
/// banner on the '/' route, so the CTA row's `context.push` wiring is real.
Widget _bannerScreen({required List<Override> overrides}) {
  return ProviderScope(
    retry: (_, _) => null,
    overrides: [
      backendConnectionProvider.overrideWith(_FakeBackendConnection.new),
      anilistAccountProvider.overrideWith(() => _FakeAnilistAccount(null)),
      ...overrides,
    ],
    child: MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              backgroundColor: context.theme.colors.background,
              body: const HomeBannerSection(),
            ),
          ),
        ],
      ),
    ),
  );
}

WidgetbookComponent buildHomeBannerComponent() {
  return WidgetbookComponent(
    name: 'HomeBannerSection',
    useCases: [
      WidgetbookUseCase(
        name: 'Loaded · 3 slides (unlinked)',
        builder: (context) => _bannerScreen(
          overrides: [
            homeBannerProvider.overrideWith(
              () => _FakeHomeBanner([
                _bannerItem(1),
                _bannerItem(2),
                _bannerItem(3),
              ]),
            ),
          ],
        ),
      ),
      // The desktop-width surface test: same fixed 340 hero, one slide —
      // the dock's next arrow renders disabled at the end of the list.
      WidgetbookUseCase(
        name: 'Loaded · single slide (desktop width)',
        builder: (context) => _bannerScreen(
          overrides: [
            homeBannerProvider.overrideWith(
              () => _FakeHomeBanner([_bannerItem(1)]),
            ),
          ],
        ),
      ),
      // A linked AniList account + an item with a media id adds the
      // bookmark CTA to the action row.
      WidgetbookUseCase(
        name: 'Loaded · bookmark CTA (AniList linked)',
        builder: (context) => _bannerScreen(
          overrides: [
            anilistAccountProvider.overrideWith(
              () => _FakeAnilistAccount(
                AnilistUser(
                  name: 'user',
                  id: 1,
                  avatar: AnilistAvatar(),
                  statistics: AnilistStatistics(
                    anime: AnilistMediaStatistics(),
                    manga: AnilistMediaStatistics(),
                  ),
                ),
              ),
            ),
            homeBannerProvider.overrideWith(
              () => _FakeHomeBanner([_bannerItem(1)]),
            ),
          ],
        ),
      ),
      WidgetbookUseCase(
        name: 'Empty · home.banner.empty',
        builder: (context) => _bannerScreen(
          overrides: [
            homeBannerProvider.overrideWith(() => _FakeHomeBanner(const [])),
          ],
        ),
      ),
      WidgetbookUseCase(
        name: 'Error · offline · retry',
        builder: (context) => _bannerScreen(
          overrides: [
            homeBannerProvider.overrideWith(
              () => _FailingHomeBanner(Exception('down')),
            ),
          ],
        ),
      ),
      // The picker stays reachable on the error state so a missing key
      // never traps the user (switch back to AniList right there).
      WidgetbookUseCase(
        name: 'Error · TMDB key missing',
        builder: (context) => _bannerScreen(
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
        ),
      ),
    ],
  );
}
