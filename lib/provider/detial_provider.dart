import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/tmdb_model.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/tracking/tmdb_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;

part 'detial_provider.g.dart';

/// Lifecycle of the upstream `GetDetail` gRPC call inside [Detial]. The page
/// widgets switch on this to render a skeleton, real content, or an inline retry
/// tile — without each one having to know the others exist.
enum DetialStatus { loading, ready, error }

class DetialState {
  final ValueNotifier<int> selectedGroup;
  final List<History> historyList;
  final List<proto.Download> downloadList;
  final Favorite? favorite;
  final List<FavoriteGroup>? favoriateGroup;
  final TMDBDetail? tmdbDetail;
  final String castSource;
  final proto.Detail? detailInfo;

  /// Where the [GetDetail] call currently is. Defaults to [DetialStatus.loading]
  /// so the first frame of every page is askeleton instead of a content flash.
  final DetialStatus status;

  /// Last error message from a failed [GetDetail] call; null while loading or
  /// after a successful retry.
  final String? lastError;

  /// Optional toast message to show to user (e.g., refresh failed, using cached data).
  final String? toastMessage;

  /// Monotonic counter incremented by [Detial.retry]. Every retry bumps it so
  /// widgets can use it as a `ref.watch` key to rebuild independently.
  final int retryToken;

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
    this.status = DetialStatus.loading,
    this.lastError,
    this.toastMessage,
    this.retryToken = 0,
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
    DetialStatus? status,
    Object? lastError = undefined,
    Object? toastMessage = undefined,
    int? retryToken,
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
      status: status ?? this.status,
      lastError: lastError == undefined ? this.lastError : lastError as String?,
      toastMessage: toastMessage == undefined
          ? this.toastMessage
          : toastMessage as String?,
      retryToken: retryToken ?? this.retryToken,
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
      status: DetialStatus.loading,
      retryToken: 0,
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
      if (resp.hasDetail() && resp.detail.package.isNotEmpty) {
        if (!ref.mounted) return;
        state = state.copyWith(
          detailInfo: resp.detail,
          status: DetialStatus.ready,
          lastError: null,
        );
        return;
      }
      // DB doesn't have detail — try extension (first load from web)
      try {
        final extDetail = await MiruCoreEndpoint.detail(pkg, url);
        final saved = await MiruCoreEndpoint.upsertDbDetail(extDetail);
        if (!ref.mounted) return;
        final protoDetail = proto.Detail()
          ..title = saved.title
          ..cover = saved.cover ?? ''
          ..desc = saved.desc ?? ''
          ..detailUrl = saved.detailUrl
          ..package = saved.package
          ..episodes = saved.episodes != null
              ? jsonEncode(
                  saved.episodes!.map((e) => e.toProto3Json()).toList(),
                )
              : ''
          ..headers = saved.headers != null ? jsonEncode(saved.headers) : '';
        state = state.copyWith(
          detailInfo: protoDetail,
          status: DetialStatus.ready,
          lastError: null,
        );
      } catch (e) {
        if (!ref.mounted) return;
        state = state.copyWith(
          status: DetialStatus.error,
          lastError: 'detail.load_failed'.i18n,
        );
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        status: DetialStatus.error,
        lastError: e.toString(),
      );
    }
  }

  /// Re-fetches the detail from the backend and bumps [DetialState.retryToken]
  /// so widgets watching it can rebuild independently of the gRPC status.
  /// Preserves the previous [detailInfo] and [status: ready] during refresh;
  /// on failure: keeps cached data + shows toast; only shows error if no cache.
  Future<void> retry() async {
    // Bump retryToken so widgets can react, clear lastError
    state = state.copyWith(lastError: null, retryToken: state.retryToken + 1);

    debugPrint(
      '[DetailProvider] retry() called for ${meta.packageName} $detailUrl',
    );

    try {
      final resp = await MiruGrpcClient.dbClient.getDetail(
        proto.GetDetailRequest()
          ..package = meta.packageName
          ..detailUrl = detailUrl,
      );
      debugPrint(
        '[DetailProvider] retry() response: hasDetail=${resp.hasDetail()}',
      );
      if (resp.hasDetail()) {
        if (!ref.mounted) return;
        state = state.copyWith(
          detailInfo: resp.detail,
          status: DetialStatus.ready,
          lastError: null,
          toastMessage: null,
        );
      } else {
        _handleRefreshFailure('detail_not_found'.i18n);
      }
    } catch (e, st) {
      debugPrint('[DetailProvider] retry() error: $e\n$st');
      _handleRefreshFailure(e.toString());
    }
  }

  void _handleRefreshFailure(String errorMsg) {
    if (!ref.mounted) return;
    final hasCachedData = state.detailInfo != null;
    if (hasCachedData) {
      // Keep cached data, show toast, don't switch to error state
      state = state.copyWith(
        toastMessage: 'common.refresh_failed_using_cache'.i18n,
        lastError: errorMsg,
      );
    } else {
      // No cached data - show error state
      state = state.copyWith(
        status: DetialStatus.error,
        lastError: errorMsg,
        toastMessage: errorMsg,
      );
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

  /// Force refresh detail from extension (web).
  /// Fetches fresh data from extension, saves to DB on success, shows toast and keeps old data on failure.
  Future<void> forceRefreshDetail(
    Ref ref,
    String detailUrl,
    ExtensionMeta meta,
  ) async {
    final provider = detialProvider(detailUrl, meta: meta);
    final state = ref.read(provider);
    final retryToken = state.retryToken;

    // Bump retry token
    ref.read(provider.notifier).state = state.copyWith(
      lastError: null,
      retryToken: retryToken + 1,
    );

    debugPrint(
      '[DetailProvider] forceRefreshDetail called for ${meta.packageName} $detailUrl',
    );

    try {
      // Fetch fresh data from extension (web)
      final resp = await MiruGrpcClient.extensionClient.detail(
        proto.DetailRequest()
          ..pkg = meta.packageName
          ..url = detailUrl,
      );
      debugPrint(
        '[DetailProvider] forceRefreshDetail extension response received',
      );

      final extDetail = resp.data;
      // Save fresh data to DB
      await MiruGrpcClient.dbClient.upsertDetail(
        proto.UpsertDetailRequest()
          ..title = extDetail.title
          ..cover = extDetail.cover
          ..desc = extDetail.desc
          ..detailUrl = detailUrl
          ..package = meta.packageName
          ..episodes = extDetail.episodes.toString()
          ..headers = '',
      );
      debugPrint('[DetailProvider] forceRefreshDetail data saved to DB');

      final newDetail = proto.Detail()
        ..title = extDetail.title
        ..cover = extDetail.cover
        ..desc = extDetail.desc
        ..detailUrl = detailUrl
        ..package = meta.packageName;
      if (extDetail.episodes.isNotEmpty) {
        final episodesJson = extDetail.episodes
            .map((e) => e.toProto3Json())
            .toList();
        newDetail.episodes = episodesJson.toString();
      }

      ref.read(provider.notifier).state = state.copyWith(
        detailInfo: newDetail,
        status: DetialStatus.ready,
        lastError: null,
        toastMessage: 'common.force_refresh_success'.i18n,
      );
    } catch (e, st) {
      debugPrint('[DetailProvider] forceRefreshDetail error: $e\n$st');
      _handleForceRefreshFailureDetail(ref, detailUrl, meta, e.toString());
    }
  }

  void _handleForceRefreshFailureDetail(
    Ref ref,
    String detailUrl,
    ExtensionMeta meta,
    String errorMsg,
  ) {
    final provider = detialProvider(detailUrl, meta: meta);
    final state = ref.read(provider);
    if (state.detailInfo != null) {
      // Keep cached data, show toast, don't switch to error state
      ref.read(provider.notifier).state = state.copyWith(
        toastMessage: 'common.force_refresh_failed_using_cache'.i18n,
        lastError: errorMsg,
      );
    } else {
      // No cached data - show error state
      ref.read(provider.notifier).state = state.copyWith(
        status: DetialStatus.error,
        lastError: errorMsg,
        toastMessage: errorMsg,
      );
    }
  }
}
