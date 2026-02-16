import 'package:flutter/widgets.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/watch/main_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/download_provider.dart';
import 'package:miru_app_new/miru_core/proto/proto.dart' as proto;

part 'detial_provider.g.dart';

class DetialState {
  final ValueNotifier<int> selectedGroup;
  final List<History> historyList;
  final List<proto.Download> downloadList;
  final Favorite? favorite;
  final List<FavoriateGroup>? favoriateGroup;
  // final AsyncValue<ExtensionDetail>? detailState;

  DetialState({
    required this.selectedGroup,
    this.historyList = const [],
    this.downloadList = const [],
    this.favorite,
    this.favoriateGroup,
    // this.detailState,
  });

  DetialState copyWith({
    ValueNotifier<int>? selectedGroup,
    List<History>? historyList,
    List<proto.Download>? downloadList,
    Favorite? favorite,
    List<FavoriateGroup>? favoriateGroup,
    // AsyncValue<ExtensionDetail>? detailState,
  }) {
    return DetialState(
      selectedGroup: selectedGroup ?? this.selectedGroup,
      historyList: historyList ?? this.historyList,
      downloadList: downloadList ?? this.downloadList,
      favorite: favorite ?? this.favorite,
      favoriateGroup: favoriateGroup ?? this.favoriateGroup,
      // detailState: detailState ?? this.detailState,
    );
  }
}

@riverpod
class Detial extends _$Detial {
  @override
  DetialState build(String detailUrl, {required ExtensionMeta meta}) {
    return _init(meta.packageName, detailUrl);
  }

  DetialState _init(String packageName, String detailUrl) {
    final historyList = ref
        .read(mainProvider)
        .history
        .where((e) => e.package == packageName && e.detailUrl == detailUrl)
        .toList();
    final favorite = ref
        .read(mainProvider)
        .favorites
        .where((e) => e.package == packageName && e.url == detailUrl)
        .firstOrNull;
    final favoriateGroup = ref
        .read(mainProvider)
        .favoriateGroups
        .where(
          (e) => e.favorites.any(
            (f) => f.package == packageName && f.url == detailUrl,
          ),
        )
        .toList();
    initDetail(packageName, detailUrl);
    return DetialState(
      selectedGroup: ValueNotifier<int>(0),
      historyList: historyList,
      favorite: favorite,
      favoriateGroup: favoriateGroup,
    );

    // query db
    //   Future.microtask(() async {
    //   final historyList = await DatabaseService.getHistoryByPackageAndDetailUrl(
    //     packageName,
    //     detailUrl,
    //   );
    //   putHistoryList(historyList);

    //   final favorite = await DatabaseService.getFavoriteByPackageAndUrl(
    //     packageName,
    //     detailUrl,
    //   );
    //   final favoriateGroup = await DatabaseService.getFavoriteGroupsByFavorite(
    //     packageName,
    //     detailUrl,
    //   );
    //   putFavorite(favorite);
    //   putFavoriateGroup(favoriateGroup);
    // });
  }

  // void putHistoryList(List<History> l) {
  //   state = state.copyWith(historyList: l);
  // }

  void putHistory(History h) {
    state = state.copyWith(historyList: [...state.historyList, h]);
  }

  void putFavorite(Favorite? f) {
    state = state.copyWith(favorite: f);
    if (f != null) {
      ref.read(mainProvider.notifier).addFavorite(f);
    }
  }

  void putFavoriteGroup(List<FavoriateGroup>? f) {
    state = state.copyWith(favoriateGroup: f);
  }

  void removeFavorite(Favorite f) {
    state = state.copyWith(favorite: null);
    // ref.read(mainProvider.notifier).removeFavorite(f);
  }

  void setSelectedGroup(int v) {
    state.selectedGroup.value = v;
    state = state.copyWith();
  }

  // void refreshExtensionDetail(String pkg, String url) {
  //   ref.invalidate(fetchExtensionDetailProvider(pkg, url));
  //   state = state.copyWith();
  // }

  // Future<void> reloadDetail(String pkg, String url) async {
  //   ref.invalidate(fetchExtensionDetailProvider(pkg, url));
  //   await fetchDetailFromExtension(pkg, url);
  // }

  // Future<Detail?> fetchDetailFromExtension(String pkg, String url) async {
  //   try {
  //     final data = await ref.read(
  //       fetchExtensionDetailProvider(pkg, url).future,
  //     );

  //     final newDetail = Detail.fromExtensionDetail(
  //       data,
  //       detailUrl: url,
  //       package: pkg,
  //     );
  //     await MiruCoreEndpoint.upsertDbDetail(newDetail);

  //     state = state.copyWith(detailState: AsyncValue.data(data));
  //   } catch (e, st) {
  //     state = state.copyWith(
  //       detailState: AsyncValue<ExtensionDetail>.error(e, st),
  //     );
  //   }
  //   return null;
  // }

  // Future<Detail?> fetchDetailFromDb(String pkg, String url) async {
  //   final dbDetail = await MiruCoreEndpoint.getDbDetail(pkg, url);
  //   if (dbDetail != null) {
  //     state = state.copyWith(
  //       detailState: AsyncValue.data(dbDetail.toExtensionDetail()),
  //     );
  //     return dbDetail;
  //   } else {
  //     state = state.copyWith(detailState: const AsyncValue.loading());
  //     return null;
  //   }
  // }

  Future<void> initDetail(String pkg, String url) async {
    final downloads = await ref
        .read(downloadProvider.notifier)
        .getDownloadsByPackageAndDetailUrl(pkg, url);

    state = state.copyWith(downloadList: downloads);
  }
}
