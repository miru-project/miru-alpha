import 'package:flutter/widgets.dart';
import 'package:miru_app_new/utils/store/database_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_app_new/miru_core/network.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/network_provider.dart';

part 'detial_provider.g.dart';

class DetialState {
  final ValueNotifier<int> selectedGroup;
  final List<History> historyList;
  final Favorite? favorite;
  final AsyncValue<ExtensionDetail>? detailState;

  DetialState({
    required this.selectedGroup,
    this.historyList = const [],
    this.favorite,
    this.detailState,
  });

  DetialState copyWith({
    ValueNotifier<int>? selectedGroup,
    List<History>? historyList,
    Favorite? favorite,
    AsyncValue<ExtensionDetail>? detailState,
  }) {
    return DetialState(
      selectedGroup: selectedGroup ?? this.selectedGroup,
      historyList: historyList ?? this.historyList,
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

  void putHistoryList(List<History> l) {
    state = state.copyWith(historyList: l);
  }

  void putHistory(History h) {
    state = state.copyWith(historyList: [...state.historyList, h]);
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
    state = state.copyWith();
  }

  void refreshExtensionDetail(String pkg, String url) {
    ref.invalidate(fetchExtensionDetailProvider(pkg, url));
    state = state.copyWith();
  }

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

  Future<void> initDetail(String pkg, String url) async {
    final detail = await fetchDetailFromDb(pkg, url);
    if (detail != null) {
      return;
    }
    if (detail == null) {
      await fetchDetailFromExtension(pkg, url);
    }
  }
}
