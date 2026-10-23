import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_trending_provider.g.dart';

/// Trending catalogue for the home rail.
///
/// One merged query over AniList's public trending list (anime and manga
/// mixed), fetched once per app run and refreshed only through [refresh] —
/// keepAlive so revisiting the home tab never re-queries the API.
@Riverpod(keepAlive: true)
class HomeTrending extends _$HomeTrending {
  static const _perPage = 14;

  @override
  Future<List<AnilistMedia>> build() => _fetch();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<List<AnilistMedia>> _fetch() =>
      AniListProvider.trendingMediaPage(perPage: _perPage);
}
