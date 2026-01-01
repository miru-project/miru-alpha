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

  $grpc.ResponseFuture<$0.DownloadBangumiResponse> downloadBangumi(
    $0.DownloadBangumiRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$downloadBangumi, request, options: options);
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
  static final _$downloadBangumi =
      $grpc.ClientMethod<$0.DownloadBangumiRequest, $0.DownloadBangumiResponse>(
          '/miru.DownloadService/DownloadBangumi',
          ($0.DownloadBangumiRequest value) => value.writeToBuffer(),
          $0.DownloadBangumiResponse.fromBuffer);
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
    $addMethod($grpc.ServiceMethod<$0.DownloadBangumiRequest,
            $0.DownloadBangumiResponse>(
        'DownloadBangumi',
        downloadBangumi_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DownloadBangumiRequest.fromBuffer(value),
        ($0.DownloadBangumiResponse value) => value.writeToBuffer()));
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

  $async.Future<$0.DownloadBangumiResponse> downloadBangumi_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DownloadBangumiRequest> $request) async {
    return downloadBangumi($call, await $request);
  }

  $async.Future<$0.DownloadBangumiResponse> downloadBangumi(
      $grpc.ServiceCall call, $0.DownloadBangumiRequest request);

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
}
