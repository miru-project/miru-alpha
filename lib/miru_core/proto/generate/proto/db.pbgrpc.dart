// This is a generated file - do not edit.
//
// Generated from proto/db.proto.

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

import 'db.pb.dart' as $0;

export 'db.pb.dart';

@$pb.GrpcServiceName('miru.DbService')
class DbServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  DbServiceClient(super.channel, {super.options, super.interceptors});

  /// Detail
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

  /// Favorite
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

  /// Favorite Group
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

  /// History
  $grpc.ResponseFuture<$0.GetHistoriesByTypeResponse> getHistoriesByType(
    $0.GetHistoriesByTypeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getHistoriesByType, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetHistoryByPackageAndDetailUrlResponse>
      getHistoryByPackageAndDetailUrl(
    $0.GetHistoryByPackageAndDetailUrlRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getHistoryByPackageAndDetailUrl, request,
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

  // method descriptors

  static final _$getDetail =
      $grpc.ClientMethod<$0.GetDetailRequest, $0.GetDetailResponse>(
          '/miru.DbService/GetDetail',
          ($0.GetDetailRequest value) => value.writeToBuffer(),
          $0.GetDetailResponse.fromBuffer);
  static final _$upsertDetail =
      $grpc.ClientMethod<$0.UpsertDetailRequest, $0.UpsertDetailResponse>(
          '/miru.DbService/UpsertDetail',
          ($0.UpsertDetailRequest value) => value.writeToBuffer(),
          $0.UpsertDetailResponse.fromBuffer);
  static final _$getAllFavorite =
      $grpc.ClientMethod<$0.GetAllFavoriteRequest, $0.GetAllFavoriteResponse>(
          '/miru.DbService/GetAllFavorite',
          ($0.GetAllFavoriteRequest value) => value.writeToBuffer(),
          $0.GetAllFavoriteResponse.fromBuffer);
  static final _$getFavoriteByPackageAndUrl = $grpc.ClientMethod<
          $0.GetFavoriteByPackageAndUrlRequest,
          $0.GetFavoriteByPackageAndUrlResponse>(
      '/miru.DbService/GetFavoriteByPackageAndUrl',
      ($0.GetFavoriteByPackageAndUrlRequest value) => value.writeToBuffer(),
      $0.GetFavoriteByPackageAndUrlResponse.fromBuffer);
  static final _$putFavoriteByIndex = $grpc.ClientMethod<
          $0.PutFavoriteByIndexRequest, $0.PutFavoriteByIndexResponse>(
      '/miru.DbService/PutFavoriteByIndex',
      ($0.PutFavoriteByIndexRequest value) => value.writeToBuffer(),
      $0.PutFavoriteByIndexResponse.fromBuffer);
  static final _$putFavorite =
      $grpc.ClientMethod<$0.PutFavoriteRequest, $0.PutFavoriteResponse>(
          '/miru.DbService/PutFavorite',
          ($0.PutFavoriteRequest value) => value.writeToBuffer(),
          $0.PutFavoriteResponse.fromBuffer);
  static final _$deleteFavorite =
      $grpc.ClientMethod<$0.DeleteFavoriteRequest, $0.DeleteFavoriteResponse>(
          '/miru.DbService/DeleteFavorite',
          ($0.DeleteFavoriteRequest value) => value.writeToBuffer(),
          $0.DeleteFavoriteResponse.fromBuffer);
  static final _$getFavoriteGroupsById = $grpc.ClientMethod<
          $0.GetFavoriteGroupsByIdRequest, $0.GetFavoriteGroupsByIdResponse>(
      '/miru.DbService/GetFavoriteGroupsById',
      ($0.GetFavoriteGroupsByIdRequest value) => value.writeToBuffer(),
      $0.GetFavoriteGroupsByIdResponse.fromBuffer);
  static final _$getAllFavoriteGroup = $grpc.ClientMethod<
          $0.GetAllFavoriteGroupRequest, $0.GetAllFavoriteGroupResponse>(
      '/miru.DbService/GetAllFavoriteGroup',
      ($0.GetAllFavoriteGroupRequest value) => value.writeToBuffer(),
      $0.GetAllFavoriteGroupResponse.fromBuffer);
  static final _$putFavoriteGroup = $grpc.ClientMethod<
          $0.PutFavoriteGroupRequest, $0.PutFavoriteGroupResponse>(
      '/miru.DbService/PutFavoriteGroup',
      ($0.PutFavoriteGroupRequest value) => value.writeToBuffer(),
      $0.PutFavoriteGroupResponse.fromBuffer);
  static final _$renameFavoriteGroup = $grpc.ClientMethod<
          $0.RenameFavoriteGroupRequest, $0.RenameFavoriteGroupResponse>(
      '/miru.DbService/RenameFavoriteGroup',
      ($0.RenameFavoriteGroupRequest value) => value.writeToBuffer(),
      $0.RenameFavoriteGroupResponse.fromBuffer);
  static final _$deleteFavoriteGroup = $grpc.ClientMethod<
          $0.DeleteFavoriteGroupRequest, $0.DeleteFavoriteGroupResponse>(
      '/miru.DbService/DeleteFavoriteGroup',
      ($0.DeleteFavoriteGroupRequest value) => value.writeToBuffer(),
      $0.DeleteFavoriteGroupResponse.fromBuffer);
  static final _$getFavoriteGroupsByFavorite = $grpc.ClientMethod<
          $0.GetFavoriteGroupsByFavoriteRequest,
          $0.GetFavoriteGroupsByFavoriteResponse>(
      '/miru.DbService/GetFavoriteGroupsByFavorite',
      ($0.GetFavoriteGroupsByFavoriteRequest value) => value.writeToBuffer(),
      $0.GetFavoriteGroupsByFavoriteResponse.fromBuffer);
  static final _$getHistoriesByType = $grpc.ClientMethod<
          $0.GetHistoriesByTypeRequest, $0.GetHistoriesByTypeResponse>(
      '/miru.DbService/GetHistoriesByType',
      ($0.GetHistoriesByTypeRequest value) => value.writeToBuffer(),
      $0.GetHistoriesByTypeResponse.fromBuffer);
  static final _$getHistoryByPackageAndDetailUrl = $grpc.ClientMethod<
          $0.GetHistoryByPackageAndDetailUrlRequest,
          $0.GetHistoryByPackageAndDetailUrlResponse>(
      '/miru.DbService/GetHistoryByPackageAndDetailUrl',
      ($0.GetHistoryByPackageAndDetailUrlRequest value) =>
          value.writeToBuffer(),
      $0.GetHistoryByPackageAndDetailUrlResponse.fromBuffer);
  static final _$putHistory =
      $grpc.ClientMethod<$0.PutHistoryRequest, $0.PutHistoryResponse>(
          '/miru.DbService/PutHistory',
          ($0.PutHistoryRequest value) => value.writeToBuffer(),
          $0.PutHistoryResponse.fromBuffer);
  static final _$deleteHistoryByPackageAndUrl = $grpc.ClientMethod<
          $0.DeleteHistoryByPackageAndUrlRequest,
          $0.DeleteHistoryByPackageAndUrlResponse>(
      '/miru.DbService/DeleteHistoryByPackageAndUrl',
      ($0.DeleteHistoryByPackageAndUrlRequest value) => value.writeToBuffer(),
      $0.DeleteHistoryByPackageAndUrlResponse.fromBuffer);
  static final _$deleteAllHistory = $grpc.ClientMethod<
          $0.DeleteAllHistoryRequest, $0.DeleteAllHistoryResponse>(
      '/miru.DbService/DeleteAllHistory',
      ($0.DeleteAllHistoryRequest value) => value.writeToBuffer(),
      $0.DeleteAllHistoryResponse.fromBuffer);
  static final _$getHistorysFiltered = $grpc.ClientMethod<
          $0.GetHistorysFilteredRequest, $0.GetHistorysFilteredResponse>(
      '/miru.DbService/GetHistorysFiltered',
      ($0.GetHistorysFilteredRequest value) => value.writeToBuffer(),
      $0.GetHistorysFilteredResponse.fromBuffer);
}

@$pb.GrpcServiceName('miru.DbService')
abstract class DbServiceBase extends $grpc.Service {
  $core.String get $name => 'miru.DbService';

  DbServiceBase() {
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
    $addMethod($grpc.ServiceMethod<$0.GetHistoryByPackageAndDetailUrlRequest,
            $0.GetHistoryByPackageAndDetailUrlResponse>(
        'GetHistoryByPackageAndDetailUrl',
        getHistoryByPackageAndDetailUrl_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetHistoryByPackageAndDetailUrlRequest.fromBuffer(value),
        ($0.GetHistoryByPackageAndDetailUrlResponse value) =>
            value.writeToBuffer()));
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
  }

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

  $async.Future<$0.GetHistoryByPackageAndDetailUrlResponse>
      getHistoryByPackageAndDetailUrl_Pre(
          $grpc.ServiceCall $call,
          $async.Future<$0.GetHistoryByPackageAndDetailUrlRequest>
              $request) async {
    return getHistoryByPackageAndDetailUrl($call, await $request);
  }

  $async.Future<$0.GetHistoryByPackageAndDetailUrlResponse>
      getHistoryByPackageAndDetailUrl($grpc.ServiceCall call,
          $0.GetHistoryByPackageAndDetailUrlRequest request);

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
}
