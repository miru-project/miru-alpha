import 'package:flutter/widgets.dart';
import 'package:miru_app_new/utils/store/database_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_app_new/miru_core/network.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/network_provider.dart';

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
      history: history,
      favorite: favorite,
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

  void removeFavorite(Favorite f) {
    DatabaseService.deleteFavorite(f.package, f.url);
    state = state.copyWith(favorite: null);
  }

  void setSelectedGroup(int v) {
    state.selectedGroup.value = v;
    // update state to notify listeners
    state = state.copyWith();
  }

  /// Invalidate the fetchExtensionDetail provider so any watchers will refetch.
  void refreshExtensionDetail(String pkg, String url) {
    ref.invalidate(fetchExtensionDetailProvider(pkg, url));
    // update state to notify listeners
    state = state.copyWith();
  }

  /// Force reload and return the fetched detail. This uses ref.refresh which
  /// re-evaluates and returns the new Future result.
  /// Force reload and return the fetched detail.
  Future<void> reloadDetail(String pkg, String url) async {
    ref.invalidate(fetchExtensionDetailProvider(pkg, url));
    await fetchDetailFromExtension(pkg, url);
  }

  Future<Detail?> fetchDetailFromExtension(String pkg, String url) async {
    try {
      final data = await ref.read(
        fetchExtensionDetailProvider(pkg, url).future,
      );

      final newDetail = Detail.fromExtensionDetail(
        data,
        detailUrl: url,
        package: pkg,
      );
      await MiruCoreEndpoint.upsertDbDetail(newDetail);

      state = state.copyWith(detailState: AsyncValue.data(data));
    } catch (e, st) {
      state = state.copyWith(
        detailState: AsyncValue<ExtensionDetail>.error(e, st),
      );
    }
    return null;
  }

  Future<Detail?> fetchDetailFromDb(String pkg, String url) async {
    final dbDetail = await MiruCoreEndpoint.getDbDetail(pkg, url);
    if (dbDetail != null) {
      state = state.copyWith(
        detailState: AsyncValue.data(dbDetail.toExtensionDetail()),
      );
      return dbDetail;
    } else {
      state = state.copyWith(detailState: const AsyncValue.loading());
      return null;
    }
  }

  /// Fetch detail (without invalidating). Updates `detailState` and notifies listeners.
  Future<void> initDetail(String pkg, String url) async {
    // 1. Try to fetch from DB
    final detail = await fetchDetailFromDb(pkg, url);
    if (detail != null) {
      return;
    }
    // 2. Fetch from Extension
    if (detail == null) {
      await fetchDetailFromExtension(pkg, url);
    }
  }
}
