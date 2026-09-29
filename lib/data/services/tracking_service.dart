import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/model/tmdb_model.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'package:miru_alpha/utils/tracking/tmdb.dart';

class TrackingService {
  Future<AnilistUser?> loginAnilist(String token) async {
    try {
      return await AniListProvider.getuserData();
    } catch (e) {
      return null;
    }
  }

  Future<List<AnilistMedia>> searchAnilist(String query) async {
    try {
      return await AniListProvider.mediaQuerypage(
        searchString: query,
        type: AnilistType.anime,
      );
    } catch (e) {
      return [];
    }
  }

  Future<List<AnilistList>> getAnilistProgress() async {
    try {
      return await AniListProvider.getCollection(AnilistType.anime, 0);
    } catch (e) {
      return [];
    }
  }

  Future<void> updateAnilistProgress(int mediaId, int progress) async {
    try {
      await AniListProvider.editList(
        status: AnilistMediaListStatus.current,
        mediaId: mediaId,
        progress: progress,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<TMDBDetail?> getTMDBDetail(int tmdbId, String mediaType) async {
    try {
      return await TMDBProvider.apiGetDetail(tmdbId, mediaType);
    } catch (e) {
      return null;
    }
  }

  Future<List<TMDBCast>> getTMDBCasts(int tmdbId, String mediaType) async {
    try {
      final detail = await TMDBProvider.apiGetDetail(tmdbId, mediaType);
      return detail?.casts ?? [];
    } catch (e) {
      return [];
    }
  }
}
