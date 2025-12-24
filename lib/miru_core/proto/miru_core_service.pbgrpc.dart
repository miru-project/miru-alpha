// This is a generated file - do not edit.
//
// Generated from miru_core_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'miru_core_service.pb.dart' as $0;

export 'miru_core_service.pb.dart';

@$pb.GrpcServiceName('miru.MiruCoreService')
class MiruCoreServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  MiruCoreServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.HelloMiruResponse> helloMiru(
    $0.HelloMiruRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$helloMiru, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetAppSettingResponse> getAppSetting(
    $0.GetAppSettingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getAppSetting, request, options: options);
  }

  $grpc.ResponseFuture<$0.SetAppSettingResponse> setAppSetting(
    $0.SetAppSettingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setAppSetting, request, options: options);
  }

  $grpc.ResponseFuture<$0.SearchResponse> search(
    $0.SearchRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$search, request, options: options);
  }

  $grpc.ResponseFuture<$0.LatestResponse> latest(
    $0.LatestRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$latest, request, options: options);
  }

  $grpc.ResponseFuture<$0.DetailResponse> detail(
    $0.DetailRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$detail, request, options: options);
  }

  $grpc.ResponseFuture<$0.WatchResponse> watch(
    $0.WatchRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$watch, request, options: options);
  }

  /// DB - Detail
  $grpc.ResponseFuture<$0.GetDetailResponse> getDetail(
    $0.GetDetailRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDetail, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpsertDetailResponse> upsertDetail(
    $0.UpsertDetailRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$upsertDetail, request, options: options);
  }

  /// DB - Favorite
  $grpc.ResponseFuture<$0.GetAllFavoriteResponse> getAllFavorite(
    $0.GetAllFavoriteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getAllFavorite, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetFavoriteByPackageAndUrlResponse>
      getFavoriteByPackageAndUrl(
    $0.GetFavoriteByPackageAndUrlRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getFavoriteByPackageAndUrl, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.PutFavoriteByIndexResponse> putFavoriteByIndex(
    $0.PutFavoriteByIndexRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$putFavoriteByIndex, request, options: options);
  }

  $grpc.ResponseFuture<$0.PutFavoriteResponse> putFavorite(
    $0.PutFavoriteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$putFavorite, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteFavoriteResponse> deleteFavorite(
    $0.DeleteFavoriteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteFavorite, request, options: options);
  }

  /// DB - Favorite Group
  $grpc.ResponseFuture<$0.GetFavoriteGroupsByIdResponse> getFavoriteGroupsById(
    $0.GetFavoriteGroupsByIdRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getFavoriteGroupsById, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetAllFavoriteGroupResponse> getAllFavoriteGroup(
    $0.GetAllFavoriteGroupRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getAllFavoriteGroup, request, options: options);
  }

  $grpc.ResponseFuture<$0.PutFavoriteGroupResponse> putFavoriteGroup(
    $0.PutFavoriteGroupRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$putFavoriteGroup, request, options: options);
  }

  $grpc.ResponseFuture<$0.RenameFavoriteGroupResponse> renameFavoriteGroup(
    $0.RenameFavoriteGroupRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$renameFavoriteGroup, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteFavoriteGroupResponse> deleteFavoriteGroup(
    $0.DeleteFavoriteGroupRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteFavoriteGroup, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetFavoriteGroupsByFavoriteResponse>
      getFavoriteGroupsByFavorite(
    $0.GetFavoriteGroupsByFavoriteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getFavoriteGroupsByFavorite, request,
        options: options);
  }

  /// DB - History
  $grpc.ResponseFuture<$0.GetHistoriesByTypeResponse> getHistoriesByType(
    $0.GetHistoriesByTypeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getHistoriesByType, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetHistoryByPackageAndUrlResponse>
      getHistoryByPackageAndUrl(
    $0.GetHistoryByPackageAndUrlRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getHistoryByPackageAndUrl, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.PutHistoryResponse> putHistory(
    $0.PutHistoryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$putHistory, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteHistoryByPackageAndUrlResponse>
      deleteHistoryByPackageAndUrl(
    $0.DeleteHistoryByPackageAndUrlRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteHistoryByPackageAndUrl, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.DeleteAllHistoryResponse> deleteAllHistory(
    $0.DeleteAllHistoryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteAllHistory, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetHistorysFilteredResponse> getHistorysFiltered(
    $0.GetHistorysFilteredRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getHistorysFiltered, request, options: options);
  }

  /// Download
  $grpc.ResponseFuture<$0.GetDownloadStatusResponse> getDownloadStatus(
    $0.GetDownloadStatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDownloadStatus, request, options: options);
  }

  $grpc.ResponseFuture<$0.CancelDownloadResponse> cancelDownload(
    $0.CancelDownloadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$cancelDownload, request, options: options);
  }

  $grpc.ResponseFuture<$0.ResumeDownloadResponse> resumeDownload(
    $0.ResumeDownloadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$resumeDownload, request, options: options);
  }

  $grpc.ResponseFuture<$0.PauseDownloadResponse> pauseDownload(
    $0.PauseDownloadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pauseDownload, request, options: options);
  }

  $grpc.ResponseFuture<$0.DownloadBangumiResponse> downloadBangumi(
    $0.DownloadBangumiRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$downloadBangumi, request, options: options);
  }

  /// Torrent
  $grpc.ResponseFuture<$0.ListTorrentResponse> listTorrent(
    $0.ListTorrentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listTorrent, request, options: options);
  }

  $grpc.ResponseFuture<$0.AddTorrentResponse> addTorrent(
    $0.AddTorrentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addTorrent, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteTorrentResponse> deleteTorrent(
    $0.DeleteTorrentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteTorrent, request, options: options);
  }

  $grpc.ResponseFuture<$0.AddMagnetResponse> addMagnet(
    $0.AddMagnetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addMagnet, request, options: options);
  }

  /// Repo
  $grpc.ResponseFuture<$0.GetReposResponse> getRepos(
    $0.GetReposRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getRepos, request, options: options);
  }

  $grpc.ResponseFuture<$0.SetRepoResponse> setRepo(
    $0.SetRepoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setRepo, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteRepoResponse> deleteRepo(
    $0.DeleteRepoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteRepo, request, options: options);
  }

  $grpc.ResponseFuture<$0.FetchRepoListResponse> fetchRepoList(
    $0.FetchRepoListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$fetchRepoList, request, options: options);
  }

  /// Extension Management
  $grpc.ResponseFuture<$0.DownloadExtensionResponse> downloadExtension(
    $0.DownloadExtensionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$downloadExtension, request, options: options);
  }

  $grpc.ResponseFuture<$0.RemoveExtensionResponse> removeExtension(
    $0.RemoveExtensionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeExtension, request, options: options);
  }

  /// Network
  $grpc.ResponseFuture<$0.SetCookieResponse> setCookie(
    $0.SetCookieRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setCookie, request, options: options);
  }

  // method descriptors

  static final _$helloMiru =
      $grpc.ClientMethod<$0.HelloMiruRequest, $0.HelloMiruResponse>(
          '/miru.MiruCoreService/HelloMiru',
          ($0.HelloMiruRequest value) => value.writeToBuffer(),
          $0.HelloMiruResponse.fromBuffer);
  static final _$getAppSetting =
      $grpc.ClientMethod<$0.GetAppSettingRequest, $0.GetAppSettingResponse>(
          '/miru.MiruCoreService/GetAppSetting',
          ($0.GetAppSettingRequest value) => value.writeToBuffer(),
          $0.GetAppSettingResponse.fromBuffer);
  static final _$setAppSetting =
      $grpc.ClientMethod<$0.SetAppSettingRequest, $0.SetAppSettingResponse>(
          '/miru.MiruCoreService/SetAppSetting',
          ($0.SetAppSettingRequest value) => value.writeToBuffer(),
          $0.SetAppSettingResponse.fromBuffer);
  static final _$search =
      $grpc.ClientMethod<$0.SearchRequest, $0.SearchResponse>(
          '/miru.MiruCoreService/Search',
          ($0.SearchRequest value) => value.writeToBuffer(),
          $0.SearchResponse.fromBuffer);
  static final _$latest =
      $grpc.ClientMethod<$0.LatestRequest, $0.LatestResponse>(
          '/miru.MiruCoreService/Latest',
          ($0.LatestRequest value) => value.writeToBuffer(),
          $0.LatestResponse.fromBuffer);
  static final _$detail =
      $grpc.ClientMethod<$0.DetailRequest, $0.DetailResponse>(
          '/miru.MiruCoreService/Detail',
          ($0.DetailRequest value) => value.writeToBuffer(),
          $0.DetailResponse.fromBuffer);
  static final _$watch = $grpc.ClientMethod<$0.WatchRequest, $0.WatchResponse>(
      '/miru.MiruCoreService/Watch',
      ($0.WatchRequest value) => value.writeToBuffer(),
      $0.WatchResponse.fromBuffer);
  static final _$getDetail =
      $grpc.ClientMethod<$0.GetDetailRequest, $0.GetDetailResponse>(
          '/miru.MiruCoreService/GetDetail',
          ($0.GetDetailRequest value) => value.writeToBuffer(),
          $0.GetDetailResponse.fromBuffer);
  static final _$upsertDetail =
      $grpc.ClientMethod<$0.UpsertDetailRequest, $0.UpsertDetailResponse>(
          '/miru.MiruCoreService/UpsertDetail',
          ($0.UpsertDetailRequest value) => value.writeToBuffer(),
          $0.UpsertDetailResponse.fromBuffer);
  static final _$getAllFavorite =
      $grpc.ClientMethod<$0.GetAllFavoriteRequest, $0.GetAllFavoriteResponse>(
          '/miru.MiruCoreService/GetAllFavorite',
          ($0.GetAllFavoriteRequest value) => value.writeToBuffer(),
          $0.GetAllFavoriteResponse.fromBuffer);
  static final _$getFavoriteByPackageAndUrl = $grpc.ClientMethod<
          $0.GetFavoriteByPackageAndUrlRequest,
          $0.GetFavoriteByPackageAndUrlResponse>(
      '/miru.MiruCoreService/GetFavoriteByPackageAndUrl',
      ($0.GetFavoriteByPackageAndUrlRequest value) => value.writeToBuffer(),
      $0.GetFavoriteByPackageAndUrlResponse.fromBuffer);
  static final _$putFavoriteByIndex = $grpc.ClientMethod<
          $0.PutFavoriteByIndexRequest, $0.PutFavoriteByIndexResponse>(
      '/miru.MiruCoreService/PutFavoriteByIndex',
      ($0.PutFavoriteByIndexRequest value) => value.writeToBuffer(),
      $0.PutFavoriteByIndexResponse.fromBuffer);
  static final _$putFavorite =
      $grpc.ClientMethod<$0.PutFavoriteRequest, $0.PutFavoriteResponse>(
          '/miru.MiruCoreService/PutFavorite',
          ($0.PutFavoriteRequest value) => value.writeToBuffer(),
          $0.PutFavoriteResponse.fromBuffer);
  static final _$deleteFavorite =
      $grpc.ClientMethod<$0.DeleteFavoriteRequest, $0.DeleteFavoriteResponse>(
          '/miru.MiruCoreService/DeleteFavorite',
          ($0.DeleteFavoriteRequest value) => value.writeToBuffer(),
          $0.DeleteFavoriteResponse.fromBuffer);
  static final _$getFavoriteGroupsById = $grpc.ClientMethod<
          $0.GetFavoriteGroupsByIdRequest, $0.GetFavoriteGroupsByIdResponse>(
      '/miru.MiruCoreService/GetFavoriteGroupsById',
      ($0.GetFavoriteGroupsByIdRequest value) => value.writeToBuffer(),
      $0.GetFavoriteGroupsByIdResponse.fromBuffer);
  static final _$getAllFavoriteGroup = $grpc.ClientMethod<
          $0.GetAllFavoriteGroupRequest, $0.GetAllFavoriteGroupResponse>(
      '/miru.MiruCoreService/GetAllFavoriteGroup',
      ($0.GetAllFavoriteGroupRequest value) => value.writeToBuffer(),
      $0.GetAllFavoriteGroupResponse.fromBuffer);
  static final _$putFavoriteGroup = $grpc.ClientMethod<
          $0.PutFavoriteGroupRequest, $0.PutFavoriteGroupResponse>(
      '/miru.MiruCoreService/PutFavoriteGroup',
      ($0.PutFavoriteGroupRequest value) => value.writeToBuffer(),
      $0.PutFavoriteGroupResponse.fromBuffer);
  static final _$renameFavoriteGroup = $grpc.ClientMethod<
          $0.RenameFavoriteGroupRequest, $0.RenameFavoriteGroupResponse>(
      '/miru.MiruCoreService/RenameFavoriteGroup',
      ($0.RenameFavoriteGroupRequest value) => value.writeToBuffer(),
      $0.RenameFavoriteGroupResponse.fromBuffer);
  static final _$deleteFavoriteGroup = $grpc.ClientMethod<
          $0.DeleteFavoriteGroupRequest, $0.DeleteFavoriteGroupResponse>(
      '/miru.MiruCoreService/DeleteFavoriteGroup',
      ($0.DeleteFavoriteGroupRequest value) => value.writeToBuffer(),
      $0.DeleteFavoriteGroupResponse.fromBuffer);
  static final _$getFavoriteGroupsByFavorite = $grpc.ClientMethod<
          $0.GetFavoriteGroupsByFavoriteRequest,
          $0.GetFavoriteGroupsByFavoriteResponse>(
      '/miru.MiruCoreService/GetFavoriteGroupsByFavorite',
      ($0.GetFavoriteGroupsByFavoriteRequest value) => value.writeToBuffer(),
      $0.GetFavoriteGroupsByFavoriteResponse.fromBuffer);
  static final _$getHistoriesByType = $grpc.ClientMethod<
          $0.GetHistoriesByTypeRequest, $0.GetHistoriesByTypeResponse>(
      '/miru.MiruCoreService/GetHistoriesByType',
      ($0.GetHistoriesByTypeRequest value) => value.writeToBuffer(),
      $0.GetHistoriesByTypeResponse.fromBuffer);
  static final _$getHistoryByPackageAndUrl = $grpc.ClientMethod<
          $0.GetHistoryByPackageAndUrlRequest,
          $0.GetHistoryByPackageAndUrlResponse>(
      '/miru.MiruCoreService/GetHistoryByPackageAndUrl',
      ($0.GetHistoryByPackageAndUrlRequest value) => value.writeToBuffer(),
      $0.GetHistoryByPackageAndUrlResponse.fromBuffer);
  static final _$putHistory =
      $grpc.ClientMethod<$0.PutHistoryRequest, $0.PutHistoryResponse>(
          '/miru.MiruCoreService/PutHistory',
          ($0.PutHistoryRequest value) => value.writeToBuffer(),
          $0.PutHistoryResponse.fromBuffer);
  static final _$deleteHistoryByPackageAndUrl = $grpc.ClientMethod<
          $0.DeleteHistoryByPackageAndUrlRequest,
          $0.DeleteHistoryByPackageAndUrlResponse>(
      '/miru.MiruCoreService/DeleteHistoryByPackageAndUrl',
      ($0.DeleteHistoryByPackageAndUrlRequest value) => value.writeToBuffer(),
      $0.DeleteHistoryByPackageAndUrlResponse.fromBuffer);
  static final _$deleteAllHistory = $grpc.ClientMethod<
          $0.DeleteAllHistoryRequest, $0.DeleteAllHistoryResponse>(
      '/miru.MiruCoreService/DeleteAllHistory',
      ($0.DeleteAllHistoryRequest value) => value.writeToBuffer(),
      $0.DeleteAllHistoryResponse.fromBuffer);
  static final _$getHistorysFiltered = $grpc.ClientMethod<
          $0.GetHistorysFilteredRequest, $0.GetHistorysFilteredResponse>(
      '/miru.MiruCoreService/GetHistorysFiltered',
      ($0.GetHistorysFilteredRequest value) => value.writeToBuffer(),
      $0.GetHistorysFilteredResponse.fromBuffer);
  static final _$getDownloadStatus = $grpc.ClientMethod<
          $0.GetDownloadStatusRequest, $0.GetDownloadStatusResponse>(
      '/miru.MiruCoreService/GetDownloadStatus',
      ($0.GetDownloadStatusRequest value) => value.writeToBuffer(),
      $0.GetDownloadStatusResponse.fromBuffer);
  static final _$cancelDownload =
      $grpc.ClientMethod<$0.CancelDownloadRequest, $0.CancelDownloadResponse>(
          '/miru.MiruCoreService/CancelDownload',
          ($0.CancelDownloadRequest value) => value.writeToBuffer(),
          $0.CancelDownloadResponse.fromBuffer);
  static final _$resumeDownload =
      $grpc.ClientMethod<$0.ResumeDownloadRequest, $0.ResumeDownloadResponse>(
          '/miru.MiruCoreService/ResumeDownload',
          ($0.ResumeDownloadRequest value) => value.writeToBuffer(),
          $0.ResumeDownloadResponse.fromBuffer);
  static final _$pauseDownload =
      $grpc.ClientMethod<$0.PauseDownloadRequest, $0.PauseDownloadResponse>(
          '/miru.MiruCoreService/PauseDownload',
          ($0.PauseDownloadRequest value) => value.writeToBuffer(),
          $0.PauseDownloadResponse.fromBuffer);
  static final _$downloadBangumi =
      $grpc.ClientMethod<$0.DownloadBangumiRequest, $0.DownloadBangumiResponse>(
          '/miru.MiruCoreService/DownloadBangumi',
          ($0.DownloadBangumiRequest value) => value.writeToBuffer(),
          $0.DownloadBangumiResponse.fromBuffer);
  static final _$listTorrent =
      $grpc.ClientMethod<$0.ListTorrentRequest, $0.ListTorrentResponse>(
          '/miru.MiruCoreService/ListTorrent',
          ($0.ListTorrentRequest value) => value.writeToBuffer(),
          $0.ListTorrentResponse.fromBuffer);
  static final _$addTorrent =
      $grpc.ClientMethod<$0.AddTorrentRequest, $0.AddTorrentResponse>(
          '/miru.MiruCoreService/AddTorrent',
          ($0.AddTorrentRequest value) => value.writeToBuffer(),
          $0.AddTorrentResponse.fromBuffer);
  static final _$deleteTorrent =
      $grpc.ClientMethod<$0.DeleteTorrentRequest, $0.DeleteTorrentResponse>(
          '/miru.MiruCoreService/DeleteTorrent',
          ($0.DeleteTorrentRequest value) => value.writeToBuffer(),
          $0.DeleteTorrentResponse.fromBuffer);
  static final _$addMagnet =
      $grpc.ClientMethod<$0.AddMagnetRequest, $0.AddMagnetResponse>(
          '/miru.MiruCoreService/AddMagnet',
          ($0.AddMagnetRequest value) => value.writeToBuffer(),
          $0.AddMagnetResponse.fromBuffer);
  static final _$getRepos =
      $grpc.ClientMethod<$0.GetReposRequest, $0.GetReposResponse>(
          '/miru.MiruCoreService/GetRepos',
          ($0.GetReposRequest value) => value.writeToBuffer(),
          $0.GetReposResponse.fromBuffer);
  static final _$setRepo =
      $grpc.ClientMethod<$0.SetRepoRequest, $0.SetRepoResponse>(
          '/miru.MiruCoreService/SetRepo',
          ($0.SetRepoRequest value) => value.writeToBuffer(),
          $0.SetRepoResponse.fromBuffer);
  static final _$deleteRepo =
      $grpc.ClientMethod<$0.DeleteRepoRequest, $0.DeleteRepoResponse>(
          '/miru.MiruCoreService/DeleteRepo',
          ($0.DeleteRepoRequest value) => value.writeToBuffer(),
          $0.DeleteRepoResponse.fromBuffer);
  static final _$fetchRepoList =
      $grpc.ClientMethod<$0.FetchRepoListRequest, $0.FetchRepoListResponse>(
          '/miru.MiruCoreService/FetchRepoList',
          ($0.FetchRepoListRequest value) => value.writeToBuffer(),
          $0.FetchRepoListResponse.fromBuffer);
  static final _$downloadExtension = $grpc.ClientMethod<
          $0.DownloadExtensionRequest, $0.DownloadExtensionResponse>(
      '/miru.MiruCoreService/DownloadExtension',
      ($0.DownloadExtensionRequest value) => value.writeToBuffer(),
      $0.DownloadExtensionResponse.fromBuffer);
  static final _$removeExtension =
      $grpc.ClientMethod<$0.RemoveExtensionRequest, $0.RemoveExtensionResponse>(
          '/miru.MiruCoreService/RemoveExtension',
          ($0.RemoveExtensionRequest value) => value.writeToBuffer(),
          $0.RemoveExtensionResponse.fromBuffer);
  static final _$setCookie =
      $grpc.ClientMethod<$0.SetCookieRequest, $0.SetCookieResponse>(
          '/miru.MiruCoreService/SetCookie',
          ($0.SetCookieRequest value) => value.writeToBuffer(),
          $0.SetCookieResponse.fromBuffer);
}

@$pb.GrpcServiceName('miru.MiruCoreService')
abstract class MiruCoreServiceBase extends $grpc.Service {
  $core.String get $name => 'miru.MiruCoreService';

  MiruCoreServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.HelloMiruRequest, $0.HelloMiruResponse>(
        'HelloMiru',
        helloMiru_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HelloMiruRequest.fromBuffer(value),
        ($0.HelloMiruResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetAppSettingRequest, $0.GetAppSettingResponse>(
            'GetAppSetting',
            getAppSetting_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetAppSettingRequest.fromBuffer(value),
            ($0.GetAppSettingResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SetAppSettingRequest, $0.SetAppSettingResponse>(
            'SetAppSetting',
            setAppSetting_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SetAppSettingRequest.fromBuffer(value),
            ($0.SetAppSettingResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SearchRequest, $0.SearchResponse>(
        'Search',
        search_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SearchRequest.fromBuffer(value),
        ($0.SearchResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LatestRequest, $0.LatestResponse>(
        'Latest',
        latest_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LatestRequest.fromBuffer(value),
        ($0.LatestResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DetailRequest, $0.DetailResponse>(
        'Detail',
        detail_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DetailRequest.fromBuffer(value),
        ($0.DetailResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WatchRequest, $0.WatchResponse>(
        'Watch',
        watch_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.WatchRequest.fromBuffer(value),
        ($0.WatchResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetDetailRequest, $0.GetDetailResponse>(
        'GetDetail',
        getDetail_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetDetailRequest.fromBuffer(value),
        ($0.GetDetailResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.UpsertDetailRequest, $0.UpsertDetailResponse>(
            'UpsertDetail',
            upsertDetail_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.UpsertDetailRequest.fromBuffer(value),
            ($0.UpsertDetailResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetAllFavoriteRequest,
            $0.GetAllFavoriteResponse>(
        'GetAllFavorite',
        getAllFavorite_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetAllFavoriteRequest.fromBuffer(value),
        ($0.GetAllFavoriteResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetFavoriteByPackageAndUrlRequest,
            $0.GetFavoriteByPackageAndUrlResponse>(
        'GetFavoriteByPackageAndUrl',
        getFavoriteByPackageAndUrl_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetFavoriteByPackageAndUrlRequest.fromBuffer(value),
        ($0.GetFavoriteByPackageAndUrlResponse value) =>
            value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PutFavoriteByIndexRequest,
            $0.PutFavoriteByIndexResponse>(
        'PutFavoriteByIndex',
        putFavoriteByIndex_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.PutFavoriteByIndexRequest.fromBuffer(value),
        ($0.PutFavoriteByIndexResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.PutFavoriteRequest, $0.PutFavoriteResponse>(
            'PutFavorite',
            putFavorite_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.PutFavoriteRequest.fromBuffer(value),
            ($0.PutFavoriteResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteFavoriteRequest,
            $0.DeleteFavoriteResponse>(
        'DeleteFavorite',
        deleteFavorite_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteFavoriteRequest.fromBuffer(value),
        ($0.DeleteFavoriteResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetFavoriteGroupsByIdRequest,
            $0.GetFavoriteGroupsByIdResponse>(
        'GetFavoriteGroupsById',
        getFavoriteGroupsById_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetFavoriteGroupsByIdRequest.fromBuffer(value),
        ($0.GetFavoriteGroupsByIdResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetAllFavoriteGroupRequest,
            $0.GetAllFavoriteGroupResponse>(
        'GetAllFavoriteGroup',
        getAllFavoriteGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetAllFavoriteGroupRequest.fromBuffer(value),
        ($0.GetAllFavoriteGroupResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PutFavoriteGroupRequest,
            $0.PutFavoriteGroupResponse>(
        'PutFavoriteGroup',
        putFavoriteGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.PutFavoriteGroupRequest.fromBuffer(value),
        ($0.PutFavoriteGroupResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RenameFavoriteGroupRequest,
            $0.RenameFavoriteGroupResponse>(
        'RenameFavoriteGroup',
        renameFavoriteGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RenameFavoriteGroupRequest.fromBuffer(value),
        ($0.RenameFavoriteGroupResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteFavoriteGroupRequest,
            $0.DeleteFavoriteGroupResponse>(
        'DeleteFavoriteGroup',
        deleteFavoriteGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteFavoriteGroupRequest.fromBuffer(value),
        ($0.DeleteFavoriteGroupResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetFavoriteGroupsByFavoriteRequest,
            $0.GetFavoriteGroupsByFavoriteResponse>(
        'GetFavoriteGroupsByFavorite',
        getFavoriteGroupsByFavorite_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetFavoriteGroupsByFavoriteRequest.fromBuffer(value),
        ($0.GetFavoriteGroupsByFavoriteResponse value) =>
            value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetHistoriesByTypeRequest,
            $0.GetHistoriesByTypeResponse>(
        'GetHistoriesByType',
        getHistoriesByType_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetHistoriesByTypeRequest.fromBuffer(value),
        ($0.GetHistoriesByTypeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetHistoryByPackageAndUrlRequest,
            $0.GetHistoryByPackageAndUrlResponse>(
        'GetHistoryByPackageAndUrl',
        getHistoryByPackageAndUrl_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetHistoryByPackageAndUrlRequest.fromBuffer(value),
        ($0.GetHistoryByPackageAndUrlResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PutHistoryRequest, $0.PutHistoryResponse>(
        'PutHistory',
        putHistory_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PutHistoryRequest.fromBuffer(value),
        ($0.PutHistoryResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteHistoryByPackageAndUrlRequest,
            $0.DeleteHistoryByPackageAndUrlResponse>(
        'DeleteHistoryByPackageAndUrl',
        deleteHistoryByPackageAndUrl_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteHistoryByPackageAndUrlRequest.fromBuffer(value),
        ($0.DeleteHistoryByPackageAndUrlResponse value) =>
            value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteAllHistoryRequest,
            $0.DeleteAllHistoryResponse>(
        'DeleteAllHistory',
        deleteAllHistory_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteAllHistoryRequest.fromBuffer(value),
        ($0.DeleteAllHistoryResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetHistorysFilteredRequest,
            $0.GetHistorysFilteredResponse>(
        'GetHistorysFiltered',
        getHistorysFiltered_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetHistorysFilteredRequest.fromBuffer(value),
        ($0.GetHistorysFilteredResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetDownloadStatusRequest,
            $0.GetDownloadStatusResponse>(
        'GetDownloadStatus',
        getDownloadStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetDownloadStatusRequest.fromBuffer(value),
        ($0.GetDownloadStatusResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CancelDownloadRequest,
            $0.CancelDownloadResponse>(
        'CancelDownload',
        cancelDownload_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CancelDownloadRequest.fromBuffer(value),
        ($0.CancelDownloadResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ResumeDownloadRequest,
            $0.ResumeDownloadResponse>(
        'ResumeDownload',
        resumeDownload_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ResumeDownloadRequest.fromBuffer(value),
        ($0.ResumeDownloadResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.PauseDownloadRequest, $0.PauseDownloadResponse>(
            'PauseDownload',
            pauseDownload_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.PauseDownloadRequest.fromBuffer(value),
            ($0.PauseDownloadResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DownloadBangumiRequest,
            $0.DownloadBangumiResponse>(
        'DownloadBangumi',
        downloadBangumi_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DownloadBangumiRequest.fromBuffer(value),
        ($0.DownloadBangumiResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListTorrentRequest, $0.ListTorrentResponse>(
            'ListTorrent',
            listTorrent_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListTorrentRequest.fromBuffer(value),
            ($0.ListTorrentResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddTorrentRequest, $0.AddTorrentResponse>(
        'AddTorrent',
        addTorrent_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddTorrentRequest.fromBuffer(value),
        ($0.AddTorrentResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DeleteTorrentRequest, $0.DeleteTorrentResponse>(
            'DeleteTorrent',
            deleteTorrent_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DeleteTorrentRequest.fromBuffer(value),
            ($0.DeleteTorrentResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddMagnetRequest, $0.AddMagnetResponse>(
        'AddMagnet',
        addMagnet_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddMagnetRequest.fromBuffer(value),
        ($0.AddMagnetResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetReposRequest, $0.GetReposResponse>(
        'GetRepos',
        getRepos_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetReposRequest.fromBuffer(value),
        ($0.GetReposResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetRepoRequest, $0.SetRepoResponse>(
        'SetRepo',
        setRepo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetRepoRequest.fromBuffer(value),
        ($0.SetRepoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteRepoRequest, $0.DeleteRepoResponse>(
        'DeleteRepo',
        deleteRepo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeleteRepoRequest.fromBuffer(value),
        ($0.DeleteRepoResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.FetchRepoListRequest, $0.FetchRepoListResponse>(
            'FetchRepoList',
            fetchRepoList_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.FetchRepoListRequest.fromBuffer(value),
            ($0.FetchRepoListResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DownloadExtensionRequest,
            $0.DownloadExtensionResponse>(
        'DownloadExtension',
        downloadExtension_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DownloadExtensionRequest.fromBuffer(value),
        ($0.DownloadExtensionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RemoveExtensionRequest,
            $0.RemoveExtensionResponse>(
        'RemoveExtension',
        removeExtension_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RemoveExtensionRequest.fromBuffer(value),
        ($0.RemoveExtensionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetCookieRequest, $0.SetCookieResponse>(
        'SetCookie',
        setCookie_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetCookieRequest.fromBuffer(value),
        ($0.SetCookieResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.HelloMiruResponse> helloMiru_Pre($grpc.ServiceCall $call,
      $async.Future<$0.HelloMiruRequest> $request) async {
    return helloMiru($call, await $request);
  }

  $async.Future<$0.HelloMiruResponse> helloMiru(
      $grpc.ServiceCall call, $0.HelloMiruRequest request);

  $async.Future<$0.GetAppSettingResponse> getAppSetting_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetAppSettingRequest> $request) async {
    return getAppSetting($call, await $request);
  }

  $async.Future<$0.GetAppSettingResponse> getAppSetting(
      $grpc.ServiceCall call, $0.GetAppSettingRequest request);

  $async.Future<$0.SetAppSettingResponse> setAppSetting_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SetAppSettingRequest> $request) async {
    return setAppSetting($call, await $request);
  }

  $async.Future<$0.SetAppSettingResponse> setAppSetting(
      $grpc.ServiceCall call, $0.SetAppSettingRequest request);

  $async.Future<$0.SearchResponse> search_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.SearchRequest> $request) async {
    return search($call, await $request);
  }

  $async.Future<$0.SearchResponse> search(
      $grpc.ServiceCall call, $0.SearchRequest request);

  $async.Future<$0.LatestResponse> latest_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LatestRequest> $request) async {
    return latest($call, await $request);
  }

  $async.Future<$0.LatestResponse> latest(
      $grpc.ServiceCall call, $0.LatestRequest request);

  $async.Future<$0.DetailResponse> detail_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.DetailRequest> $request) async {
    return detail($call, await $request);
  }

  $async.Future<$0.DetailResponse> detail(
      $grpc.ServiceCall call, $0.DetailRequest request);

  $async.Future<$0.WatchResponse> watch_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.WatchRequest> $request) async {
    return watch($call, await $request);
  }

  $async.Future<$0.WatchResponse> watch(
      $grpc.ServiceCall call, $0.WatchRequest request);

  $async.Future<$0.GetDetailResponse> getDetail_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetDetailRequest> $request) async {
    return getDetail($call, await $request);
  }

  $async.Future<$0.GetDetailResponse> getDetail(
      $grpc.ServiceCall call, $0.GetDetailRequest request);

  $async.Future<$0.UpsertDetailResponse> upsertDetail_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpsertDetailRequest> $request) async {
    return upsertDetail($call, await $request);
  }

  $async.Future<$0.UpsertDetailResponse> upsertDetail(
      $grpc.ServiceCall call, $0.UpsertDetailRequest request);

  $async.Future<$0.GetAllFavoriteResponse> getAllFavorite_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetAllFavoriteRequest> $request) async {
    return getAllFavorite($call, await $request);
  }

  $async.Future<$0.GetAllFavoriteResponse> getAllFavorite(
      $grpc.ServiceCall call, $0.GetAllFavoriteRequest request);

  $async.Future<$0.GetFavoriteByPackageAndUrlResponse>
      getFavoriteByPackageAndUrl_Pre($grpc.ServiceCall $call,
          $async.Future<$0.GetFavoriteByPackageAndUrlRequest> $request) async {
    return getFavoriteByPackageAndUrl($call, await $request);
  }

  $async.Future<$0.GetFavoriteByPackageAndUrlResponse>
      getFavoriteByPackageAndUrl(
          $grpc.ServiceCall call, $0.GetFavoriteByPackageAndUrlRequest request);

  $async.Future<$0.PutFavoriteByIndexResponse> putFavoriteByIndex_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PutFavoriteByIndexRequest> $request) async {
    return putFavoriteByIndex($call, await $request);
  }

  $async.Future<$0.PutFavoriteByIndexResponse> putFavoriteByIndex(
      $grpc.ServiceCall call, $0.PutFavoriteByIndexRequest request);

  $async.Future<$0.PutFavoriteResponse> putFavorite_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PutFavoriteRequest> $request) async {
    return putFavorite($call, await $request);
  }

  $async.Future<$0.PutFavoriteResponse> putFavorite(
      $grpc.ServiceCall call, $0.PutFavoriteRequest request);

  $async.Future<$0.DeleteFavoriteResponse> deleteFavorite_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteFavoriteRequest> $request) async {
    return deleteFavorite($call, await $request);
  }

  $async.Future<$0.DeleteFavoriteResponse> deleteFavorite(
      $grpc.ServiceCall call, $0.DeleteFavoriteRequest request);

  $async.Future<$0.GetFavoriteGroupsByIdResponse> getFavoriteGroupsById_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetFavoriteGroupsByIdRequest> $request) async {
    return getFavoriteGroupsById($call, await $request);
  }

  $async.Future<$0.GetFavoriteGroupsByIdResponse> getFavoriteGroupsById(
      $grpc.ServiceCall call, $0.GetFavoriteGroupsByIdRequest request);

  $async.Future<$0.GetAllFavoriteGroupResponse> getAllFavoriteGroup_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetAllFavoriteGroupRequest> $request) async {
    return getAllFavoriteGroup($call, await $request);
  }

  $async.Future<$0.GetAllFavoriteGroupResponse> getAllFavoriteGroup(
      $grpc.ServiceCall call, $0.GetAllFavoriteGroupRequest request);

  $async.Future<$0.PutFavoriteGroupResponse> putFavoriteGroup_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PutFavoriteGroupRequest> $request) async {
    return putFavoriteGroup($call, await $request);
  }

  $async.Future<$0.PutFavoriteGroupResponse> putFavoriteGroup(
      $grpc.ServiceCall call, $0.PutFavoriteGroupRequest request);

  $async.Future<$0.RenameFavoriteGroupResponse> renameFavoriteGroup_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RenameFavoriteGroupRequest> $request) async {
    return renameFavoriteGroup($call, await $request);
  }

  $async.Future<$0.RenameFavoriteGroupResponse> renameFavoriteGroup(
      $grpc.ServiceCall call, $0.RenameFavoriteGroupRequest request);

  $async.Future<$0.DeleteFavoriteGroupResponse> deleteFavoriteGroup_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteFavoriteGroupRequest> $request) async {
    return deleteFavoriteGroup($call, await $request);
  }

  $async.Future<$0.DeleteFavoriteGroupResponse> deleteFavoriteGroup(
      $grpc.ServiceCall call, $0.DeleteFavoriteGroupRequest request);

  $async.Future<$0.GetFavoriteGroupsByFavoriteResponse>
      getFavoriteGroupsByFavorite_Pre($grpc.ServiceCall $call,
          $async.Future<$0.GetFavoriteGroupsByFavoriteRequest> $request) async {
    return getFavoriteGroupsByFavorite($call, await $request);
  }

  $async.Future<$0.GetFavoriteGroupsByFavoriteResponse>
      getFavoriteGroupsByFavorite($grpc.ServiceCall call,
          $0.GetFavoriteGroupsByFavoriteRequest request);

  $async.Future<$0.GetHistoriesByTypeResponse> getHistoriesByType_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetHistoriesByTypeRequest> $request) async {
    return getHistoriesByType($call, await $request);
  }

  $async.Future<$0.GetHistoriesByTypeResponse> getHistoriesByType(
      $grpc.ServiceCall call, $0.GetHistoriesByTypeRequest request);

  $async.Future<$0.GetHistoryByPackageAndUrlResponse>
      getHistoryByPackageAndUrl_Pre($grpc.ServiceCall $call,
          $async.Future<$0.GetHistoryByPackageAndUrlRequest> $request) async {
    return getHistoryByPackageAndUrl($call, await $request);
  }

  $async.Future<$0.GetHistoryByPackageAndUrlResponse> getHistoryByPackageAndUrl(
      $grpc.ServiceCall call, $0.GetHistoryByPackageAndUrlRequest request);

  $async.Future<$0.PutHistoryResponse> putHistory_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PutHistoryRequest> $request) async {
    return putHistory($call, await $request);
  }

  $async.Future<$0.PutHistoryResponse> putHistory(
      $grpc.ServiceCall call, $0.PutHistoryRequest request);

  $async.Future<$0.DeleteHistoryByPackageAndUrlResponse>
      deleteHistoryByPackageAndUrl_Pre(
          $grpc.ServiceCall $call,
          $async.Future<$0.DeleteHistoryByPackageAndUrlRequest>
              $request) async {
    return deleteHistoryByPackageAndUrl($call, await $request);
  }

  $async.Future<$0.DeleteHistoryByPackageAndUrlResponse>
      deleteHistoryByPackageAndUrl($grpc.ServiceCall call,
          $0.DeleteHistoryByPackageAndUrlRequest request);

  $async.Future<$0.DeleteAllHistoryResponse> deleteAllHistory_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteAllHistoryRequest> $request) async {
    return deleteAllHistory($call, await $request);
  }

  $async.Future<$0.DeleteAllHistoryResponse> deleteAllHistory(
      $grpc.ServiceCall call, $0.DeleteAllHistoryRequest request);

  $async.Future<$0.GetHistorysFilteredResponse> getHistorysFiltered_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetHistorysFilteredRequest> $request) async {
    return getHistorysFiltered($call, await $request);
  }

  $async.Future<$0.GetHistorysFilteredResponse> getHistorysFiltered(
      $grpc.ServiceCall call, $0.GetHistorysFilteredRequest request);

  $async.Future<$0.GetDownloadStatusResponse> getDownloadStatus_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetDownloadStatusRequest> $request) async {
    return getDownloadStatus($call, await $request);
  }

  $async.Future<$0.GetDownloadStatusResponse> getDownloadStatus(
      $grpc.ServiceCall call, $0.GetDownloadStatusRequest request);

  $async.Future<$0.CancelDownloadResponse> cancelDownload_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CancelDownloadRequest> $request) async {
    return cancelDownload($call, await $request);
  }

  $async.Future<$0.CancelDownloadResponse> cancelDownload(
      $grpc.ServiceCall call, $0.CancelDownloadRequest request);

  $async.Future<$0.ResumeDownloadResponse> resumeDownload_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ResumeDownloadRequest> $request) async {
    return resumeDownload($call, await $request);
  }

  $async.Future<$0.ResumeDownloadResponse> resumeDownload(
      $grpc.ServiceCall call, $0.ResumeDownloadRequest request);

  $async.Future<$0.PauseDownloadResponse> pauseDownload_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PauseDownloadRequest> $request) async {
    return pauseDownload($call, await $request);
  }

  $async.Future<$0.PauseDownloadResponse> pauseDownload(
      $grpc.ServiceCall call, $0.PauseDownloadRequest request);

  $async.Future<$0.DownloadBangumiResponse> downloadBangumi_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DownloadBangumiRequest> $request) async {
    return downloadBangumi($call, await $request);
  }

  $async.Future<$0.DownloadBangumiResponse> downloadBangumi(
      $grpc.ServiceCall call, $0.DownloadBangumiRequest request);

  $async.Future<$0.ListTorrentResponse> listTorrent_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListTorrentRequest> $request) async {
    return listTorrent($call, await $request);
  }

  $async.Future<$0.ListTorrentResponse> listTorrent(
      $grpc.ServiceCall call, $0.ListTorrentRequest request);

  $async.Future<$0.AddTorrentResponse> addTorrent_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AddTorrentRequest> $request) async {
    return addTorrent($call, await $request);
  }

  $async.Future<$0.AddTorrentResponse> addTorrent(
      $grpc.ServiceCall call, $0.AddTorrentRequest request);

  $async.Future<$0.DeleteTorrentResponse> deleteTorrent_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteTorrentRequest> $request) async {
    return deleteTorrent($call, await $request);
  }

  $async.Future<$0.DeleteTorrentResponse> deleteTorrent(
      $grpc.ServiceCall call, $0.DeleteTorrentRequest request);

  $async.Future<$0.AddMagnetResponse> addMagnet_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AddMagnetRequest> $request) async {
    return addMagnet($call, await $request);
  }

  $async.Future<$0.AddMagnetResponse> addMagnet(
      $grpc.ServiceCall call, $0.AddMagnetRequest request);

  $async.Future<$0.GetReposResponse> getRepos_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetReposRequest> $request) async {
    return getRepos($call, await $request);
  }

  $async.Future<$0.GetReposResponse> getRepos(
      $grpc.ServiceCall call, $0.GetReposRequest request);

  $async.Future<$0.SetRepoResponse> setRepo_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetRepoRequest> $request) async {
    return setRepo($call, await $request);
  }

  $async.Future<$0.SetRepoResponse> setRepo(
      $grpc.ServiceCall call, $0.SetRepoRequest request);

  $async.Future<$0.DeleteRepoResponse> deleteRepo_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteRepoRequest> $request) async {
    return deleteRepo($call, await $request);
  }

  $async.Future<$0.DeleteRepoResponse> deleteRepo(
      $grpc.ServiceCall call, $0.DeleteRepoRequest request);

  $async.Future<$0.FetchRepoListResponse> fetchRepoList_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.FetchRepoListRequest> $request) async {
    return fetchRepoList($call, await $request);
  }

  $async.Future<$0.FetchRepoListResponse> fetchRepoList(
      $grpc.ServiceCall call, $0.FetchRepoListRequest request);

  $async.Future<$0.DownloadExtensionResponse> downloadExtension_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DownloadExtensionRequest> $request) async {
    return downloadExtension($call, await $request);
  }

  $async.Future<$0.DownloadExtensionResponse> downloadExtension(
      $grpc.ServiceCall call, $0.DownloadExtensionRequest request);

  $async.Future<$0.RemoveExtensionResponse> removeExtension_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RemoveExtensionRequest> $request) async {
    return removeExtension($call, await $request);
  }

  $async.Future<$0.RemoveExtensionResponse> removeExtension(
      $grpc.ServiceCall call, $0.RemoveExtensionRequest request);

  $async.Future<$0.SetCookieResponse> setCookie_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetCookieRequest> $request) async {
    return setCookie($call, await $request);
  }

  $async.Future<$0.SetCookieResponse> setCookie(
      $grpc.ServiceCall call, $0.SetCookieRequest request);
}
