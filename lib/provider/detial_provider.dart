import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_app_new/miru_core/network.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/widgets/core/toast.dart';

part 'detial_provider.g.dart';

class DetialState {
  final ValueNotifier<int> selectedGroup;
  final History? history;
  final Favorite? favorite;
  final AsyncValue<ExtensionDetail>? detailState;

  DetialState({
    required this.selectedGroup,
    this.history,
    this.favorite,
    this.detailState,
  });

  DetialState copyWith({
    ValueNotifier<int>? selectedGroup,
    History? history,
    Favorite? favorite,
    AsyncValue<ExtensionDetail>? detailState,
  }) {
    return DetialState(
      selectedGroup: selectedGroup ?? this.selectedGroup,
      history: history ?? this.history,
      favorite: favorite ?? this.favorite,
      detailState: detailState ?? this.detailState,
    );
  }
}

@riverpod
class Detial extends _$Detial {
  @override
  DetialState build() {
    return DetialState(selectedGroup: ValueNotifier<int>(0));
  }

  void putHistory(History? h) {
    state = state.copyWith(history: h);
  }

  void putFavorite(Favorite? f) {
    state = state.copyWith(favorite: f);
  }

  void setSelectedGroup(int v) {
    state.selectedGroup.value = v;
    // update state to notify listeners
    state = state.copyWith();
  }

  /// Invalidate the fetchExtensionDetail provider so any watchers will refetch.
  void refreshDetail(String pkg, String url) {
    ref.invalidate(fetchExtensionDetailProvider(pkg, url));
    // update state to notify listeners
    state = state.copyWith();
  }

  /// Force reload and return the fetched detail. This uses ref.refresh which
  /// re-evaluates and returns the new Future result.
  Future<ExtensionDetail> reloadDetail(String pkg, String url) async {
    try {
      final res = await ref.refresh(
        fetchExtensionDetailProvider(pkg, url).future,
      );
      // Upsert to DB
      final detail = Detail.fromExtensionDetail(
        res,
        detailUrl: url,
        package: pkg,
      );
      await MiruCoreEndpoint.upsertDbDetail(detail);

      state = state.copyWith(detailState: AsyncValue.data(res));
      return res;
    } catch (e) {
      showSimpleToast("Update failed: $e");
      rethrow;
    }
  }

  /// Fetch detail (without invalidating). Updates `detailState` and notifies listeners.
  Future<void> fetchDetail(String pkg, String url) async {
    // 1. Try to fetch from DB
    final dbDetail = await MiruCoreEndpoint.getDbDetail(pkg, url);
    if (dbDetail != null) {
      state = state.copyWith(
        detailState: AsyncValue.data(dbDetail.toExtensionDetail()),
      );
    } else {
      state = state.copyWith(detailState: const AsyncValue.loading());
    }

    // 2. Fetch from Extension
    try {
      final data = await ref.read(
        fetchExtensionDetailProvider(pkg, url).future,
      );

      // 3. Upsert to DB if success
      // If we had old DB data, we should probably preserve 'downloaded' list.
      // But for simplicity as per "replace the old db entry", we create new one.
      final newDetail = Detail.fromExtensionDetail(
        data,
        detailUrl: url,
        package: pkg,
        downloaded: dbDetail?.downloaded ?? [],
      );
      await MiruCoreEndpoint.upsertDbDetail(newDetail);

      state = state.copyWith(detailState: AsyncValue.data(data));
    } catch (e, st) {
      if (dbDetail != null) {
        // 4. Show snackbar if error and we have DB data
        showSimpleToast("Fetch failed, showing cached data: $e");
      } else {
        state = state.copyWith(
          detailState: AsyncValue<ExtensionDetail>.error(e, st),
        );
      }
    }
  }
}
