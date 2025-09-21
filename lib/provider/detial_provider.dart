import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
    final res = await ref.refresh(
      fetchExtensionDetailProvider(pkg, url).future,
    );
    state = state.copyWith(detailState: AsyncValue.data(res));
    return res;
  }

  /// Fetch detail (without invalidating). Updates `detailState` and notifies listeners.
  Future<void> fetchDetail(String pkg, String url) async {
    state = state.copyWith(detailState: const AsyncValue.loading());
    try {
      final data = await ref.read(
        fetchExtensionDetailProvider(pkg, url).future,
      );
      state = state.copyWith(detailState: AsyncValue.data(data));
    } catch (e, st) {
      state = state.copyWith(
        detailState: AsyncValue<ExtensionDetail>.error(e, st),
      );
    }
  }
}
