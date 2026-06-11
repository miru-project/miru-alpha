import 'dart:convert';
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'package:miru_alpha/widgets/core/toast.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;

part 'anilist_track_page_provider.g.dart';

class AnilistTrackPageState {
  final bool isLoading;
  final bool isSaving;
  final AnilistMedia? media;
  final AnilistEntry? entry;
  final AnilistMediaListStatus status;
  final int progress;
  final int totalProgress;
  final double score;

  static const undefined = Object();

  AnilistTrackPageState({
    this.isLoading = true,
    this.isSaving = false,
    this.media,
    this.entry,
    this.status = AnilistMediaListStatus.current,
    this.progress = 0,
    this.totalProgress = 0,
    this.score = 0.0,
  });

  AnilistTrackPageState copyWith({
    bool? isLoading,
    bool? isSaving,
    Object? media = undefined,
    Object? entry = undefined,
    AnilistMediaListStatus? status,
    int? progress,
    int? totalProgress,
    double? score,
  }) {
    return AnilistTrackPageState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      media: media == undefined ? this.media : media as AnilistMedia?,
      entry: entry == undefined ? this.entry : entry as AnilistEntry?,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      totalProgress: totalProgress ?? this.totalProgress,
      score: score ?? this.score,
    );
  }
}

@riverpod
class AnilistTrackPage extends _$AnilistTrackPage {
  @override
  AnilistTrackPageState build(int mediaId) {
    _loadData();
    return AnilistTrackPageState();
  }

  Future<void> _loadData() async {
    try {
      // 1. Try to fetch from local cache (Track table)
      final cache = await MiruGrpcClient.dbClient.getTrack(
        proto.GetTrackRequest()
          ..trackingId = mediaId.toString()
          ..provider = 'anilist',
      );

      if (cache.hasTrack() && cache.track.data.isNotEmpty) {
        final cachedMedia = AnilistMedia.fromJson(
          jsonDecode(cache.track.data) as Map<String, dynamic>,
        );
        final newState = state.copyWith(isLoading: false, media: cachedMedia);

        if (cachedMedia.mediaListEntry != null) {
          state = newState.copyWith(
            entry: cachedMedia.mediaListEntry,
            status: AniListProvider.stringToMediaListStatus(
              cachedMedia.mediaListEntry!.status,
            ),
            progress: cachedMedia.mediaListEntry!.progress,
            totalProgress: cachedMedia.episodes ?? cachedMedia.chapters ?? 0,
            score: cachedMedia.mediaListEntry!.score,
          );
        } else {
          state = newState;
        }

        // 2. Then fetch from AniList to update cache
        await _fetchFromAniList();
      } else {
        // 3. If no local record, fetch from online
        await _fetchFromAniList();
      }
    } catch (e) {
      // Fallback to online if anything fails
      await _fetchFromAniList();
    }
  }

  Future<void> _fetchFromAniList() async {
    try {
      final res = await AniListProvider.getMediaList(mediaId);
      final newState = state.copyWith(isLoading: false, media: res);

      if (res.mediaListEntry != null) {
        state = newState.copyWith(
          entry: res.mediaListEntry,
          status: AniListProvider.stringToMediaListStatus(
            res.mediaListEntry!.status,
          ),
          progress: res.mediaListEntry!.progress,
          totalProgress: res.episodes ?? res.chapters ?? 0,
          score: res.mediaListEntry!.score,
        );
      } else {
        state = newState;
      }

      // Save to local cache
      await MiruGrpcClient.dbClient.putTrack(
        proto.PutTrackRequest()
          ..trackingId = mediaId.toString()
          ..provider = 'anilist'
          ..mediaType = res.type ?? ''
          ..data = jsonEncode(res.toJson()),
      );
    } catch (e) {
      // Ignore update error
    }
  }

  void setStatus(AnilistMediaListStatus s) {
    state = state.copyWith(status: s);
  }

  void setProgress(int p) {
    state = state.copyWith(progress: p);
  }

  void setScore(double s) {
    state = state.copyWith(score: s);
  }

  Future<bool> saveProgress({
    required String detailUrl,
    required String package,
    required String title,
  }) async {
    state = state.copyWith(isSaving: true);
    try {
      await AniListProvider.editList(
        mediaId: mediaId,
        status: state.status,
        progress: state.progress,
        score: state.score,
      );

      // Refresh cache from AniList to get latest entry state
      await _fetchFromAniList();

      // Save to local tracker db
      try {
        await MiruGrpcClient.dbClient.upsertTracker(
          proto.UpsertTrackerRequest()
            ..package = package
            ..detailUrl = detailUrl
            ..tracker = (proto.Tracker()
              ..trackerId = mediaId.toString()
              ..provider = 'anilist'
              ..status = AniListProvider.mediaListStatusToQuery(state.status)
              ..progress = state.progress
              ..score = state.score.toInt()
              ..totalProgress =
                  state.media?.episodes ?? state.media?.chapters ?? 0),
        );
      } catch (e) {
        showSimpleToast('Failed to save to local database');
      }

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }

  Future<bool> unlinkTracker({
    required String detailUrl,
    required String package,
  }) async {
    state = state.copyWith(isSaving: true);
    try {
      await MiruGrpcClient.dbClient.deleteTracker(
        proto.DeleteTrackerRequest()
          ..package = package
          ..detailUrl = detailUrl
          ..provider = 'anilist',
      );
      state = state.copyWith(isSaving: false, entry: null);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }

  Future<bool> deleteEntry({
    required String detailUrl,
    required String package,
  }) async {
    if (state.entry == null) return false;
    state = state.copyWith(isSaving: true);
    try {
      // 1. Unlink from local DB first
      await MiruGrpcClient.dbClient.deleteTracker(
        proto.DeleteTrackerRequest()
          ..package = package
          ..detailUrl = detailUrl
          ..provider = 'anilist',
      );

      // 2. Delete from external provider
      await AniListProvider.deleteList(id: state.entry!.id!);

      // 3. Delete global tracker record and cache
      await MiruGrpcClient.dbClient.deleteTrackerByTrackerId(
        proto.DeleteTrackerByTrackerIdRequest()
          ..trackerId = mediaId.toString()
          ..provider = 'anilist',
      );

      state = state.copyWith(isSaving: false, entry: null);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }
}
