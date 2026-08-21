// This is a generated file - do not edit.
//
// Generated from proto/download.proto.

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

import 'download.pb.dart' as $0;

export 'download.pb.dart';

@$pb.GrpcServiceName('miru.DownloadService')
class DownloadServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  DownloadServiceClient(super.channel, {super.options, super.interceptors});

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

  $grpc.ResponseFuture<$0.DownloadResponse> download(
    $0.DownloadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$download, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetAllDownloadsResponse> getAllDownloads(
    $0.GetAllDownloadsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getAllDownloads, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteDownloadResponse> deleteDownload(
    $0.DeleteDownloadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteDownload, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetDownloadsByPackageAndDetailUrlResponse>
      getDownloadsByPackageAndDetailUrl(
    $0.GetDownloadsByPackageAndDetailUrlRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDownloadsByPackageAndDetailUrl, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.GetDownloadByPackageWatchUrlDetailUrlResponse>
      getDownloadByPackageWatchUrlDetailUrl(
    $0.GetDownloadByPackageWatchUrlDetailUrlRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDownloadByPackageWatchUrlDetailUrl, request,
        options: options);
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

  $grpc.ResponseFuture<$0.UpdateDownloadStatusResponse> updateDownloadStatus(
    $0.UpdateDownloadStatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateDownloadStatus, request, options: options);
  }

  /// Concurrency-limited scheduler controls.
  $grpc.ResponseFuture<$0.SetDownloadPriorityResponse> setDownloadPriority(
    $0.SetDownloadPriorityRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setDownloadPriority, request, options: options);
  }

  $grpc.ResponseFuture<$0.SetDownloadConcurrentResponse> setDownloadConcurrent(
    $0.SetDownloadConcurrentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setDownloadConcurrent, request, options: options);
  }

  $grpc.ResponseFuture<$0.ReorderDownloadsResponse> reorderDownloads(
    $0.ReorderDownloadsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$reorderDownloads, request, options: options);
  }

  /// Returns per-category storage usage for the given download path, including
  /// bytes occupied by in-progress (temp) downloads.
  $grpc.ResponseFuture<$0.GetStorageStatsResponse> getStorageStats(
    $0.GetStorageStatsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getStorageStats, request, options: options);
  }

  // method descriptors

  static final _$getDownloadStatus = $grpc.ClientMethod<
          $0.GetDownloadStatusRequest, $0.GetDownloadStatusResponse>(
      '/miru.DownloadService/GetDownloadStatus',
      ($0.GetDownloadStatusRequest value) => value.writeToBuffer(),
      $0.GetDownloadStatusResponse.fromBuffer);
  static final _$cancelDownload =
      $grpc.ClientMethod<$0.CancelDownloadRequest, $0.CancelDownloadResponse>(
          '/miru.DownloadService/CancelDownload',
          ($0.CancelDownloadRequest value) => value.writeToBuffer(),
          $0.CancelDownloadResponse.fromBuffer);
  static final _$resumeDownload =
      $grpc.ClientMethod<$0.ResumeDownloadRequest, $0.ResumeDownloadResponse>(
          '/miru.DownloadService/ResumeDownload',
          ($0.ResumeDownloadRequest value) => value.writeToBuffer(),
          $0.ResumeDownloadResponse.fromBuffer);
  static final _$pauseDownload =
      $grpc.ClientMethod<$0.PauseDownloadRequest, $0.PauseDownloadResponse>(
          '/miru.DownloadService/PauseDownload',
          ($0.PauseDownloadRequest value) => value.writeToBuffer(),
          $0.PauseDownloadResponse.fromBuffer);
  static final _$download =
      $grpc.ClientMethod<$0.DownloadRequest, $0.DownloadResponse>(
          '/miru.DownloadService/Download',
          ($0.DownloadRequest value) => value.writeToBuffer(),
          $0.DownloadResponse.fromBuffer);
  static final _$getAllDownloads =
      $grpc.ClientMethod<$0.GetAllDownloadsRequest, $0.GetAllDownloadsResponse>(
          '/miru.DownloadService/GetAllDownloads',
          ($0.GetAllDownloadsRequest value) => value.writeToBuffer(),
          $0.GetAllDownloadsResponse.fromBuffer);
  static final _$deleteDownload =
      $grpc.ClientMethod<$0.DeleteDownloadRequest, $0.DeleteDownloadResponse>(
          '/miru.DownloadService/DeleteDownload',
          ($0.DeleteDownloadRequest value) => value.writeToBuffer(),
          $0.DeleteDownloadResponse.fromBuffer);
  static final _$getDownloadsByPackageAndDetailUrl = $grpc.ClientMethod<
          $0.GetDownloadsByPackageAndDetailUrlRequest,
          $0.GetDownloadsByPackageAndDetailUrlResponse>(
      '/miru.DownloadService/GetDownloadsByPackageAndDetailUrl',
      ($0.GetDownloadsByPackageAndDetailUrlRequest value) =>
          value.writeToBuffer(),
      $0.GetDownloadsByPackageAndDetailUrlResponse.fromBuffer);
  static final _$getDownloadByPackageWatchUrlDetailUrl = $grpc.ClientMethod<
          $0.GetDownloadByPackageWatchUrlDetailUrlRequest,
          $0.GetDownloadByPackageWatchUrlDetailUrlResponse>(
      '/miru.DownloadService/GetDownloadByPackageWatchUrlDetailUrl',
      ($0.GetDownloadByPackageWatchUrlDetailUrlRequest value) =>
          value.writeToBuffer(),
      $0.GetDownloadByPackageWatchUrlDetailUrlResponse.fromBuffer);
  static final _$listTorrent =
      $grpc.ClientMethod<$0.ListTorrentRequest, $0.ListTorrentResponse>(
          '/miru.DownloadService/ListTorrent',
          ($0.ListTorrentRequest value) => value.writeToBuffer(),
          $0.ListTorrentResponse.fromBuffer);
  static final _$addTorrent =
      $grpc.ClientMethod<$0.AddTorrentRequest, $0.AddTorrentResponse>(
          '/miru.DownloadService/AddTorrent',
          ($0.AddTorrentRequest value) => value.writeToBuffer(),
          $0.AddTorrentResponse.fromBuffer);
  static final _$deleteTorrent =
      $grpc.ClientMethod<$0.DeleteTorrentRequest, $0.DeleteTorrentResponse>(
          '/miru.DownloadService/DeleteTorrent',
          ($0.DeleteTorrentRequest value) => value.writeToBuffer(),
          $0.DeleteTorrentResponse.fromBuffer);
  static final _$addMagnet =
      $grpc.ClientMethod<$0.AddMagnetRequest, $0.AddMagnetResponse>(
          '/miru.DownloadService/AddMagnet',
          ($0.AddMagnetRequest value) => value.writeToBuffer(),
          $0.AddMagnetResponse.fromBuffer);
  static final _$updateDownloadStatus = $grpc.ClientMethod<
          $0.UpdateDownloadStatusRequest, $0.UpdateDownloadStatusResponse>(
      '/miru.DownloadService/UpdateDownloadStatus',
      ($0.UpdateDownloadStatusRequest value) => value.writeToBuffer(),
      $0.UpdateDownloadStatusResponse.fromBuffer);
  static final _$setDownloadPriority = $grpc.ClientMethod<
          $0.SetDownloadPriorityRequest, $0.SetDownloadPriorityResponse>(
      '/miru.DownloadService/SetDownloadPriority',
      ($0.SetDownloadPriorityRequest value) => value.writeToBuffer(),
      $0.SetDownloadPriorityResponse.fromBuffer);
  static final _$setDownloadConcurrent = $grpc.ClientMethod<
          $0.SetDownloadConcurrentRequest, $0.SetDownloadConcurrentResponse>(
      '/miru.DownloadService/SetDownloadConcurrent',
      ($0.SetDownloadConcurrentRequest value) => value.writeToBuffer(),
      $0.SetDownloadConcurrentResponse.fromBuffer);
  static final _$reorderDownloads = $grpc.ClientMethod<
          $0.ReorderDownloadsRequest, $0.ReorderDownloadsResponse>(
      '/miru.DownloadService/ReorderDownloads',
      ($0.ReorderDownloadsRequest value) => value.writeToBuffer(),
      $0.ReorderDownloadsResponse.fromBuffer);
  static final _$getStorageStats =
      $grpc.ClientMethod<$0.GetStorageStatsRequest, $0.GetStorageStatsResponse>(
          '/miru.DownloadService/GetStorageStats',
          ($0.GetStorageStatsRequest value) => value.writeToBuffer(),
          $0.GetStorageStatsResponse.fromBuffer);
}

@$pb.GrpcServiceName('miru.DownloadService')
abstract class DownloadServiceBase extends $grpc.Service {
  $core.String get $name => 'miru.DownloadService';

  DownloadServiceBase() {
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
    $addMethod($grpc.ServiceMethod<$0.DownloadRequest, $0.DownloadResponse>(
        'Download',
        download_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DownloadRequest.fromBuffer(value),
        ($0.DownloadResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetAllDownloadsRequest,
            $0.GetAllDownloadsResponse>(
        'GetAllDownloads',
        getAllDownloads_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetAllDownloadsRequest.fromBuffer(value),
        ($0.GetAllDownloadsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteDownloadRequest,
            $0.DeleteDownloadResponse>(
        'DeleteDownload',
        deleteDownload_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteDownloadRequest.fromBuffer(value),
        ($0.DeleteDownloadResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetDownloadsByPackageAndDetailUrlRequest,
            $0.GetDownloadsByPackageAndDetailUrlResponse>(
        'GetDownloadsByPackageAndDetailUrl',
        getDownloadsByPackageAndDetailUrl_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetDownloadsByPackageAndDetailUrlRequest.fromBuffer(value),
        ($0.GetDownloadsByPackageAndDetailUrlResponse value) =>
            value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<
            $0.GetDownloadByPackageWatchUrlDetailUrlRequest,
            $0.GetDownloadByPackageWatchUrlDetailUrlResponse>(
        'GetDownloadByPackageWatchUrlDetailUrl',
        getDownloadByPackageWatchUrlDetailUrl_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetDownloadByPackageWatchUrlDetailUrlRequest.fromBuffer(value),
        ($0.GetDownloadByPackageWatchUrlDetailUrlResponse value) =>
            value.writeToBuffer()));
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
    $addMethod($grpc.ServiceMethod<$0.UpdateDownloadStatusRequest,
            $0.UpdateDownloadStatusResponse>(
        'UpdateDownloadStatus',
        updateDownloadStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateDownloadStatusRequest.fromBuffer(value),
        ($0.UpdateDownloadStatusResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetDownloadPriorityRequest,
            $0.SetDownloadPriorityResponse>(
        'SetDownloadPriority',
        setDownloadPriority_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetDownloadPriorityRequest.fromBuffer(value),
        ($0.SetDownloadPriorityResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetDownloadConcurrentRequest,
            $0.SetDownloadConcurrentResponse>(
        'SetDownloadConcurrent',
        setDownloadConcurrent_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetDownloadConcurrentRequest.fromBuffer(value),
        ($0.SetDownloadConcurrentResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ReorderDownloadsRequest,
            $0.ReorderDownloadsResponse>(
        'ReorderDownloads',
        reorderDownloads_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ReorderDownloadsRequest.fromBuffer(value),
        ($0.ReorderDownloadsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetStorageStatsRequest,
            $0.GetStorageStatsResponse>(
        'GetStorageStats',
        getStorageStats_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetStorageStatsRequest.fromBuffer(value),
        ($0.GetStorageStatsResponse value) => value.writeToBuffer()));
  }

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

  $async.Future<$0.DownloadResponse> download_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DownloadRequest> $request) async {
    return download($call, await $request);
  }

  $async.Future<$0.DownloadResponse> download(
      $grpc.ServiceCall call, $0.DownloadRequest request);

  $async.Future<$0.GetAllDownloadsResponse> getAllDownloads_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetAllDownloadsRequest> $request) async {
    return getAllDownloads($call, await $request);
  }

  $async.Future<$0.GetAllDownloadsResponse> getAllDownloads(
      $grpc.ServiceCall call, $0.GetAllDownloadsRequest request);

  $async.Future<$0.DeleteDownloadResponse> deleteDownload_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteDownloadRequest> $request) async {
    return deleteDownload($call, await $request);
  }

  $async.Future<$0.DeleteDownloadResponse> deleteDownload(
      $grpc.ServiceCall call, $0.DeleteDownloadRequest request);

  $async.Future<$0.GetDownloadsByPackageAndDetailUrlResponse>
      getDownloadsByPackageAndDetailUrl_Pre(
          $grpc.ServiceCall $call,
          $async.Future<$0.GetDownloadsByPackageAndDetailUrlRequest>
              $request) async {
    return getDownloadsByPackageAndDetailUrl($call, await $request);
  }

  $async.Future<$0.GetDownloadsByPackageAndDetailUrlResponse>
      getDownloadsByPackageAndDetailUrl($grpc.ServiceCall call,
          $0.GetDownloadsByPackageAndDetailUrlRequest request);

  $async.Future<$0.GetDownloadByPackageWatchUrlDetailUrlResponse>
      getDownloadByPackageWatchUrlDetailUrl_Pre(
          $grpc.ServiceCall $call,
          $async.Future<$0.GetDownloadByPackageWatchUrlDetailUrlRequest>
              $request) async {
    return getDownloadByPackageWatchUrlDetailUrl($call, await $request);
  }

  $async.Future<$0.GetDownloadByPackageWatchUrlDetailUrlResponse>
      getDownloadByPackageWatchUrlDetailUrl($grpc.ServiceCall call,
          $0.GetDownloadByPackageWatchUrlDetailUrlRequest request);

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

  $async.Future<$0.UpdateDownloadStatusResponse> updateDownloadStatus_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateDownloadStatusRequest> $request) async {
    return updateDownloadStatus($call, await $request);
  }

  $async.Future<$0.UpdateDownloadStatusResponse> updateDownloadStatus(
      $grpc.ServiceCall call, $0.UpdateDownloadStatusRequest request);

  $async.Future<$0.SetDownloadPriorityResponse> setDownloadPriority_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SetDownloadPriorityRequest> $request) async {
    return setDownloadPriority($call, await $request);
  }

  $async.Future<$0.SetDownloadPriorityResponse> setDownloadPriority(
      $grpc.ServiceCall call, $0.SetDownloadPriorityRequest request);

  $async.Future<$0.SetDownloadConcurrentResponse> setDownloadConcurrent_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SetDownloadConcurrentRequest> $request) async {
    return setDownloadConcurrent($call, await $request);
  }

  $async.Future<$0.SetDownloadConcurrentResponse> setDownloadConcurrent(
      $grpc.ServiceCall call, $0.SetDownloadConcurrentRequest request);

  $async.Future<$0.ReorderDownloadsResponse> reorderDownloads_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ReorderDownloadsRequest> $request) async {
    return reorderDownloads($call, await $request);
  }

  $async.Future<$0.ReorderDownloadsResponse> reorderDownloads(
      $grpc.ServiceCall call, $0.ReorderDownloadsRequest request);

  $async.Future<$0.GetStorageStatsResponse> getStorageStats_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetStorageStatsRequest> $request) async {
    return getStorageStats($call, await $request);
  }

  $async.Future<$0.GetStorageStatsResponse> getStorageStats(
      $grpc.ServiceCall call, $0.GetStorageStatsRequest request);
}
