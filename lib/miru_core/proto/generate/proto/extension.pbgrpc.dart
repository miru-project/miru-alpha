// This is a generated file - do not edit.
//
// Generated from proto/extension.proto.

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

import 'extension.pb.dart' as $0;

export 'extension.pb.dart';

@$pb.GrpcServiceName('miru.ExtensionService')
class ExtensionServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ExtensionServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.SearchResponse> search(
    $0.SearchRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$search, request, options: options);
  }

  $grpc.ResponseFuture<$0.CreateFilterResponse> createFilter(
    $0.CreateFilterRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createFilter, request, options: options);
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

  $grpc.ResponseFuture<$0.MirrorResponse> mirror(
    $0.MirrorRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$mirror, request, options: options);
  }

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

  $grpc.ResponseFuture<$0.GetExtensionSettingsResponse> getExtensionSettings(
    $0.GetExtensionSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getExtensionSettings, request, options: options);
  }

  $grpc.ResponseFuture<$0.SaveExtensionSettingsResponse> saveExtensionSettings(
    $0.SaveExtensionSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$saveExtensionSettings, request, options: options);
  }

  // method descriptors

  static final _$search =
      $grpc.ClientMethod<$0.SearchRequest, $0.SearchResponse>(
          '/miru.ExtensionService/Search',
          ($0.SearchRequest value) => value.writeToBuffer(),
          $0.SearchResponse.fromBuffer);
  static final _$createFilter =
      $grpc.ClientMethod<$0.CreateFilterRequest, $0.CreateFilterResponse>(
          '/miru.ExtensionService/CreateFilter',
          ($0.CreateFilterRequest value) => value.writeToBuffer(),
          $0.CreateFilterResponse.fromBuffer);
  static final _$latest =
      $grpc.ClientMethod<$0.LatestRequest, $0.LatestResponse>(
          '/miru.ExtensionService/Latest',
          ($0.LatestRequest value) => value.writeToBuffer(),
          $0.LatestResponse.fromBuffer);
  static final _$detail =
      $grpc.ClientMethod<$0.DetailRequest, $0.DetailResponse>(
          '/miru.ExtensionService/Detail',
          ($0.DetailRequest value) => value.writeToBuffer(),
          $0.DetailResponse.fromBuffer);
  static final _$watch = $grpc.ClientMethod<$0.WatchRequest, $0.WatchResponse>(
      '/miru.ExtensionService/Watch',
      ($0.WatchRequest value) => value.writeToBuffer(),
      $0.WatchResponse.fromBuffer);
  static final _$mirror =
      $grpc.ClientMethod<$0.MirrorRequest, $0.MirrorResponse>(
          '/miru.ExtensionService/Mirror',
          ($0.MirrorRequest value) => value.writeToBuffer(),
          $0.MirrorResponse.fromBuffer);
  static final _$downloadExtension = $grpc.ClientMethod<
          $0.DownloadExtensionRequest, $0.DownloadExtensionResponse>(
      '/miru.ExtensionService/DownloadExtension',
      ($0.DownloadExtensionRequest value) => value.writeToBuffer(),
      $0.DownloadExtensionResponse.fromBuffer);
  static final _$removeExtension =
      $grpc.ClientMethod<$0.RemoveExtensionRequest, $0.RemoveExtensionResponse>(
          '/miru.ExtensionService/RemoveExtension',
          ($0.RemoveExtensionRequest value) => value.writeToBuffer(),
          $0.RemoveExtensionResponse.fromBuffer);
  static final _$getExtensionSettings = $grpc.ClientMethod<
          $0.GetExtensionSettingsRequest, $0.GetExtensionSettingsResponse>(
      '/miru.ExtensionService/GetExtensionSettings',
      ($0.GetExtensionSettingsRequest value) => value.writeToBuffer(),
      $0.GetExtensionSettingsResponse.fromBuffer);
  static final _$saveExtensionSettings = $grpc.ClientMethod<
          $0.SaveExtensionSettingsRequest, $0.SaveExtensionSettingsResponse>(
      '/miru.ExtensionService/SaveExtensionSettings',
      ($0.SaveExtensionSettingsRequest value) => value.writeToBuffer(),
      $0.SaveExtensionSettingsResponse.fromBuffer);
}

@$pb.GrpcServiceName('miru.ExtensionService')
abstract class ExtensionServiceBase extends $grpc.Service {
  $core.String get $name => 'miru.ExtensionService';

  ExtensionServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SearchRequest, $0.SearchResponse>(
        'Search',
        search_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SearchRequest.fromBuffer(value),
        ($0.SearchResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.CreateFilterRequest, $0.CreateFilterResponse>(
            'CreateFilter',
            createFilter_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CreateFilterRequest.fromBuffer(value),
            ($0.CreateFilterResponse value) => value.writeToBuffer()));
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
    $addMethod($grpc.ServiceMethod<$0.MirrorRequest, $0.MirrorResponse>(
        'Mirror',
        mirror_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.MirrorRequest.fromBuffer(value),
        ($0.MirrorResponse value) => value.writeToBuffer()));
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
    $addMethod($grpc.ServiceMethod<$0.GetExtensionSettingsRequest,
            $0.GetExtensionSettingsResponse>(
        'GetExtensionSettings',
        getExtensionSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetExtensionSettingsRequest.fromBuffer(value),
        ($0.GetExtensionSettingsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SaveExtensionSettingsRequest,
            $0.SaveExtensionSettingsResponse>(
        'SaveExtensionSettings',
        saveExtensionSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SaveExtensionSettingsRequest.fromBuffer(value),
        ($0.SaveExtensionSettingsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.SearchResponse> search_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.SearchRequest> $request) async {
    return search($call, await $request);
  }

  $async.Future<$0.SearchResponse> search(
      $grpc.ServiceCall call, $0.SearchRequest request);

  $async.Future<$0.CreateFilterResponse> createFilter_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateFilterRequest> $request) async {
    return createFilter($call, await $request);
  }

  $async.Future<$0.CreateFilterResponse> createFilter(
      $grpc.ServiceCall call, $0.CreateFilterRequest request);

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

  $async.Future<$0.MirrorResponse> mirror_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.MirrorRequest> $request) async {
    return mirror($call, await $request);
  }

  $async.Future<$0.MirrorResponse> mirror(
      $grpc.ServiceCall call, $0.MirrorRequest request);

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

  $async.Future<$0.GetExtensionSettingsResponse> getExtensionSettings_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetExtensionSettingsRequest> $request) async {
    return getExtensionSettings($call, await $request);
  }

  $async.Future<$0.GetExtensionSettingsResponse> getExtensionSettings(
      $grpc.ServiceCall call, $0.GetExtensionSettingsRequest request);

  $async.Future<$0.SaveExtensionSettingsResponse> saveExtensionSettings_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SaveExtensionSettingsRequest> $request) async {
    return saveExtensionSettings($call, await $request);
  }

  $async.Future<$0.SaveExtensionSettingsResponse> saveExtensionSettings(
      $grpc.ServiceCall call, $0.SaveExtensionSettingsRequest request);
}
