import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
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
  final double score;

  static const undefined = Object();

  AnilistTrackPageState({
    this.isLoading = true,
    this.isSaving = false,
    this.media,
    this.entry,
    this.status = AnilistMediaListStatus.current,
    this.progress = 0,
    this.score = 0.0,
  });

  AnilistTrackPageState copyWith({
    bool? isLoading,
    bool? isSaving,
    Object? media = undefined,
    Object? entry = undefined,
    AnilistMediaListStatus? status,
    int? progress,
    double? score,
  }) {
    return AnilistTrackPageState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      media: media == undefined ? this.media : media as AnilistMedia?,
      entry: entry == undefined ? this.entry : entry as AnilistEntry?,
      status: status ?? this.status,
      progress: progress ?? this.progress,
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
      final res = await AniListProvider.getMediaList(mediaId);
      final newState = state.copyWith(isLoading: false, media: res);

      if (res.mediaListEntry != null) {
        state = newState.copyWith(
          entry: res.mediaListEntry,
          status: AniListProvider.stringToMediaListStatus(
            res.mediaListEntry!.status,
          ),
          progress: res.mediaListEntry!.progress,
          score: res.mediaListEntry!.score,
        );
      } else {
        state = newState;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
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

      // Bind with detail
      try {
        await MiruGrpcClient.dbClient.upsertDetail(
          proto.UpsertDetailRequest()
            ..package = package
            ..detailUrl = detailUrl
            ..title = title
            ..trackIds.addAll({'ANILIST': mediaId.toString()}),
        );
      } catch (e) {
        // Ignore upsert error
      }

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }

  Future<bool> deleteEntry() async {
    if (state.entry == null) return false;
    state = state.copyWith(isSaving: true);
    try {
      await AniListProvider.deleteList(id: state.entry!.id!);
      state = state.copyWith(isSaving: false, entry: null);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }
}
