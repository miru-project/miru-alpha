import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:miru_alpha/data/repositories/tracking_repository.dart';
import 'package:miru_alpha/data/services/tracking_service.dart';
import 'package:miru_alpha/domain/models/tracking.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tracking_view_model.freezed.dart';
part 'tracking_view_model.g.dart';

@freezed
abstract class TrackingViewState with _$TrackingViewState {
  const factory TrackingViewState({
    DomainTrackingAccount? anilistAccount,
    @Default([]) List<DomainTrackingProgress> progress,
    @Default([]) List<DomainTMDBTrack> tmdbTracks,
    @Default(false) bool isLoading,
  }) = _TrackingViewState;
}

@riverpod
class TrackingViewModel extends _$TrackingViewModel {
  @override
  Future<TrackingViewState> build() async {
    return const TrackingViewState(
      anilistAccount: null,
      progress: [],
      tmdbTracks: [],
      isLoading: false,
    );
  }

  Future<void> loginAnilist(String token) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(isLoading: true));

    try {
      final repository = TrackingRepository(TrackingService());
      final account = await repository.loginAnilist(token);

      state = AsyncValue.data(
        current.copyWith(anilistAccount: account, isLoading: false),
      );
    } catch (e) {
      state = AsyncValue.data(current.copyWith(isLoading: false));
    }
  }

  Future<void> loadAnilistProgress() async {
    final current = state.value;
    if (current == null) return;

    final repository = TrackingRepository(TrackingService());
    final progress = await repository.getAnilistProgress();
    state = AsyncValue.data(current.copyWith(progress: progress));
  }

  Future<void> updateProgress(int mediaId, int progress) async {
    final repository = TrackingRepository(TrackingService());
    await repository.updateAnilistProgress(mediaId, progress);
    ref.invalidateSelf();
  }

  Future<void> loadTMDBDetail(int tmdbId, String mediaType) async {
    final current = state.value;
    if (current == null) return;

    final repository = TrackingRepository(TrackingService());
    final track = await repository.getTMDBDetail(tmdbId, mediaType);

    if (track != null) {
      final tracks = List<DomainTMDBTrack>.from(current.tmdbTracks);
      final index = tracks.indexWhere((t) => t.id == tmdbId);
      if (index >= 0) {
        tracks[index] = track;
      } else {
        tracks.add(track);
      }
      state = AsyncValue.data(current.copyWith(tmdbTracks: tracks));
    }
  }
}
