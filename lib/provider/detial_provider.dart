import 'package:flutter/widgets.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/favorite_page_provider.dart';
import 'package:miru_app_new/provider/history_page_provider.dart';
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
  final List<FavoriteGroup>? favoriateGroup;

  DetialState({
    required this.selectedGroup,
    this.historyList = const [],
    this.downloadList = const [],
    this.favorite,
    this.favoriateGroup,
  });

  DetialState copyWith({
    ValueNotifier<int>? selectedGroup,
    List<History>? historyList,
    List<proto.Download>? downloadList,
    Favorite? favorite,
    List<FavoriteGroup>? favoriateGroup,
  }) {
    return DetialState(
      selectedGroup: selectedGroup ?? this.selectedGroup,
      historyList: historyList ?? this.historyList,
      downloadList: downloadList ?? this.downloadList,
      favorite: favorite ?? this.favorite,
      favoriateGroup: favoriateGroup ?? this.favoriateGroup,
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
        .read(historyPageProvider)
        .history
        .where((e) => e.package == packageName && e.detailUrl == detailUrl)
        .toList();
    final favorite = ref
        .read(favoritePageProvider)
        .favorites
        .where((e) => e.package == packageName && e.url == detailUrl)
        .firstOrNull;
    final favoriateGroup = ref
        .read(favoritePageProvider)
        .favoriteGroups
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

    // query db LEAVE FOR FUTURE USE
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

  void putHistory(History h) {
    state = state.copyWith(historyList: [...state.historyList, h]);
  }

  void putFavorite(Favorite? f) {
    state = state.copyWith(favorite: f);
    if (f != null) {
      ref.read(favoritePageProvider.notifier).addFavorite(f);
    }
  }

  void putFavoriteGroup(List<FavoriteGroup>? f) {
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

  Future<void> initDetail(String pkg, String url) async {
    final downloads = await ref
        .read(downloadProvider.notifier)
        .getDownloadsByPackageAndDetailUrl(pkg, url);

    state = state.copyWith(downloadList: downloads);
  }
}
