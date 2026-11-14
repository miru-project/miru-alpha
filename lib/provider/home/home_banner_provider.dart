import 'package:miru_alpha/model/home_banner_model.dart';
import 'package:miru_alpha/provider/backend_connection_provider.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'package:miru_alpha/utils/tracking/tmdb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_banner_provider.g.dart';

/// Selected banner catalogue: the source and the format slice it shows.
/// In-memory like the dashboard's type filter; the default (AniList anime)
/// needs no credential, so a fresh install has a live banner.
class HomeBannerSelectionState {
  const HomeBannerSelectionState({
    this.source = HomeBannerSource.anilist,
    this.format = HomeBannerFormat.anime,
  });

  final HomeBannerSource source;
  final HomeBannerFormat format;

  HomeBannerSelectionState copyWith({
    HomeBannerSource? source,
    HomeBannerFormat? format,
  }) => HomeBannerSelectionState(
    source: source ?? this.source,
    format: format ?? this.format,
  );
}

@riverpod
class HomeBannerSelection extends _$HomeBannerSelection {
  @override
  HomeBannerSelectionState build() => const HomeBannerSelectionState();

  /// Switching source resets the format to the source's first entry — the two
  /// pickers share one state, so a stale format can never drive a fetch.
  void setSource(HomeBannerSource source) => state = HomeBannerSelectionState(
    source: source,
    format: source.formats.first,
  );

  void setFormat(HomeBannerFormat format) {
    if (!state.source.formats.contains(format)) return;
    state = state.copyWith(format: format);
  }
}

/// Home banner catalogue for the current [HomeBannerSelectionState].
///
/// keepAlive like [HomeTrending]: revisiting the home tab must not re-query
/// TMDB or AniList; the fetch re-runs only when the selection changes or
/// through [refresh]. Rides the backend connection gate first.
@Riverpod(keepAlive: true)
class HomeBanner extends _$HomeBanner {
  static const _perPage = 5;

  @override
  Future<List<HomeBannerItem>> build() async {
    await ref.watch(backendConnectionProvider.future);
    return _fetch(ref.watch(homeBannerSelectionProvider));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(ref.read(homeBannerSelectionProvider)),
    );
  }

  Future<List<HomeBannerItem>> _fetch(HomeBannerSelectionState selection) =>
      switch (selection.source) {
        HomeBannerSource.tmdb => _fetchTmdb(selection.format),
        HomeBannerSource.anilist => _fetchAnilist(selection.format),
      };

  Future<List<HomeBannerItem>> _fetchTmdb(HomeBannerFormat format) async {
    final mediaType = format.tmdbType;
    final results = await TMDBProvider.apiDiscoverNewOnStreaming(
      mediaType: mediaType,
    );
    return [
      // Discover always answers a 20-row page; the banner cycles the mock's
      // 5-slide depth like the AniList slice.
      for (final (index, result) in results.take(_perPage).indexed)
        HomeBannerItem.fromTmdbResult(
          result as Map<String, dynamic>,
          index + 1,
          mediaType,
          TMDBProvider.getBackdropUrl,
        ),
    ];
  }

  Future<List<HomeBannerItem>> _fetchAnilist(HomeBannerFormat format) async {
    final media = await AniListProvider.trendingBannerPage(
      type: format == HomeBannerFormat.manga
          ? AnilistType.manga
          : AnilistType.anime,
      perPage: _perPage,
    );
    return [
      for (final (index, item) in media.indexed)
        HomeBannerItem.fromAnilistMedia(item, index + 1),
    ];
  }
}
