// This is a generated file - do not edit.
//
// Generated from proto/app_setting.proto.

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

import 'app_setting.pb.dart' as $0;

export 'app_setting.pb.dart';

@$pb.GrpcServiceName('miru.AppSettingService')
class AppSettingServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AppSettingServiceClient(super.channel, {super.options, super.interceptors});

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

  // method descriptors

  static final _$getAppSetting =
      $grpc.ClientMethod<$0.GetAppSettingRequest, $0.GetAppSettingResponse>(
          '/miru.AppSettingService/GetAppSetting',
          ($0.GetAppSettingRequest value) => value.writeToBuffer(),
          $0.GetAppSettingResponse.fromBuffer);
  static final _$setAppSetting =
      $grpc.ClientMethod<$0.SetAppSettingRequest, $0.SetAppSettingResponse>(
          '/miru.AppSettingService/SetAppSetting',
          ($0.SetAppSettingRequest value) => value.writeToBuffer(),
          $0.SetAppSettingResponse.fromBuffer);
}

@$pb.GrpcServiceName('miru.AppSettingService')
abstract class AppSettingServiceBase extends $grpc.Service {
  $core.String get $name => 'miru.AppSettingService';

  AppSettingServiceBase() {
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
  }

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
}
