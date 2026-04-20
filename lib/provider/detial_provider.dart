import 'package:flutter/widgets.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/tmdb_model.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/tracking/tmdb_provider.dart';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;

part 'detial_provider.g.dart';

class DetialState {
  final ValueNotifier<int> selectedGroup;
  final List<History> historyList;
  final List<proto.Download> downloadList;
  final Favorite? favorite;
  final List<FavoriteGroup>? favoriateGroup;
  final TMDBDetail? tmdbDetail;
  final String castSource;
  final proto.Detail? detailInfo;

  static const undefined = Object();

  DetialState({
    required this.selectedGroup,
    this.historyList = const [],
    this.downloadList = const [],
    this.favorite,
    this.favoriateGroup,
    this.tmdbDetail,
    this.castSource = "tmdb",
    this.detailInfo,
  });

  DetialState copyWith({
    ValueNotifier<int>? selectedGroup,
    List<History>? historyList,
    List<proto.Download>? downloadList,
    Object? favorite = undefined,
    Object? favoriateGroup = undefined,
    Object? tmdbDetail = undefined,
    String? castSource,
    Object? detailInfo = undefined,
  }) {
    return DetialState(
      selectedGroup: selectedGroup ?? this.selectedGroup,
      historyList: historyList ?? this.historyList,
      downloadList: downloadList ?? this.downloadList,
      favorite: favorite == undefined ? this.favorite : favorite as Favorite?,
      favoriateGroup: favoriateGroup == undefined
          ? this.favoriateGroup
          : favoriateGroup as List<FavoriteGroup>?,
      tmdbDetail: tmdbDetail == undefined
          ? this.tmdbDetail
          : tmdbDetail as TMDBDetail?,
      castSource: castSource ?? this.castSource,
      detailInfo: detailInfo == undefined
          ? this.detailInfo
          : detailInfo as proto.Detail?,
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
    fetchDetailInfo(packageName, detailUrl);
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
    ref.read(favoritePageProvider.notifier).deleteFavorite(f);
  }

  void setSelectedGroup(int v) {
    state.selectedGroup.value = v;
    state = state.copyWith();
  }

  Future<void> initDetail(String pkg, String url) async {
    final downloads = await ref
        .read(downloadProvider.notifier)
        .getDownloadsByPackageAndDetailUrl(pkg, url);

    if (!ref.mounted) return;
    state = state.copyWith(downloadList: downloads);
  }

  void setCastSource(String source) {
    state = state.copyWith(castSource: source);
  }

  Future<void> fetchDetailInfo(String pkg, String url) async {
    try {
      final resp = await MiruGrpcClient.dbClient.getDetail(
        proto.GetDetailRequest()
          ..package = pkg
          ..detailUrl = url,
      );
      if (resp.hasDetail()) {
        if (!ref.mounted) return;
        state = state.copyWith(detailInfo: resp.detail);
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> fetchTMDBDetail(String title, String mediaType) async {
    // 1. Check if we already have the ID in our DB
    String? tmdbIdStr = state.detailInfo?.trackIds['TMDB'];

    if (tmdbIdStr != null) {
      final detail = await ref
          .read(tMDBProvider.notifier)
          .getDetail(int.parse(tmdbIdStr), mediaType);
      if (!ref.mounted) return;
      state = state.copyWith(tmdbDetail: detail);
      return;
    }

    // 2. Not found, search for it
    final searchResult = await ref
        .read(tMDBProvider.notifier)
        .searchAndGetDetail(title, mediaType);

    if (!ref.mounted) return;
    if (searchResult != null) {
      final tmdbId = searchResult.id;
      // 3. Update our DB with this mapping
      final detailInfo =
          state.detailInfo ??
          (proto.Detail()
            ..package = meta.packageName
            ..detailUrl = detailUrl
            ..title = title);

      detailInfo.trackIds['TMDB'] = tmdbId.toString();

      try {
        await MiruGrpcClient.dbClient.upsertDetail(
          proto.UpsertDetailRequest()
            ..package = detailInfo.package
            ..detailUrl = detailInfo.detailUrl
            ..title = detailInfo.title
            ..trackIds.addAll(detailInfo.trackIds),
        );
        state = state.copyWith(detailInfo: detailInfo);
      } catch (e) {
        // Ignore upsert error
      }

      // 4. Finally get full details (this will also cache the 'TMDB' track)
      final fullDetail = await ref
          .read(tMDBProvider.notifier)
          .getDetail(tmdbId, mediaType);
      if (!ref.mounted) return;
      state = state.copyWith(tmdbDetail: fullDetail);
    }
  }
}
