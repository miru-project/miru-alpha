import 'package:miru_alpha/data/services/tracking_service.dart';
import 'package:miru_alpha/domain/models/tracking.dart';

class TrackingRepository {
  final TrackingService _trackingService;

  TrackingRepository(this._trackingService);

  Future<DomainTrackingAccount?> loginAnilist(String token) async {
    final account = await _trackingService.loginAnilist(token);
    if (account == null) return null;

    return DomainTrackingAccount(
      id: account.id,
      name: account.name,
      avatar: account.avatar.large ?? account.avatar.medium,
      provider: TrackingProvider.anilist,
    );
  }

  Future<List<DomainTrackingProgress>> searchAnilist(String query) async {
    final results = await _trackingService.searchAnilist(query);
    return results
        .map(
          (result) => DomainTrackingProgress(
            id: result.id,
            mediaId: result.id,
            status: '',
            progress: 0,
            score: 0,
            mediaType: result.type,
            title: result.title.userPreferred,
            cover: result.coverImage.large ?? result.coverImage.medium,
          ),
        )
        .toList();
  }

  Future<List<DomainTrackingProgress>> getAnilistProgress() async {
    final lists = await _trackingService.getAnilistProgress();
    final entries = lists.expand((list) => list.entries).toList();
    return entries.map((entry) {
      final media = entry.media;
      return DomainTrackingProgress(
        id: entry.id ?? 0,
        mediaId: media?.id ?? 0,
        status: entry.status,
        progress: entry.progress,
        score: entry.score,
        mediaType: media?.type,
        title: media?.title.userPreferred,
        cover: media == null
            ? null
            : (media.coverImage.large ?? media.coverImage.medium),
      );
    }).toList();
  }

  Future<void> updateAnilistProgress(int mediaId, int progress) async {
    await _trackingService.updateAnilistProgress(mediaId, progress);
  }

  Future<DomainTMDBTrack?> getTMDBDetail(int tmdbId, String mediaType) async {
    final detail = await _trackingService.getTMDBDetail(tmdbId, mediaType);
    if (detail == null) return null;

    return DomainTMDBTrack(
      id: detail.id,
      mediaId: detail.id,
      mediaType: detail.mediaType,
      title: detail.title,
      cover: detail.cover,
      overview: detail.overview,
      status: detail.status,
      runtime: detail.runtime,
      genres: detail.genres,
      updatedAt: DateTime.now(),
    );
  }

  Future<List<DomainTMDBCast>> getTMDBCasts(
    int tmdbId,
    String mediaType,
  ) async {
    final casts = await _trackingService.getTMDBCasts(tmdbId, mediaType);
    return casts
        .map(
          (cast) => DomainTMDBCast(
            name: cast.name,
            character: cast.character,
            profilePath: cast.profilePath,
          ),
        )
        .toList();
  }
}
