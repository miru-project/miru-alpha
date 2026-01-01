// This is a generated file - do not edit.
//
// Generated from proto/network.proto.

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

import 'network.pb.dart' as $0;

export 'network.pb.dart';

@$pb.GrpcServiceName('miru.NetworkService')
class NetworkServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  NetworkServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.SetCookieResponse> setCookie(
    $0.SetCookieRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setCookie, request, options: options);
  }

  // method descriptors

  static final _$setCookie =
      $grpc.ClientMethod<$0.SetCookieRequest, $0.SetCookieResponse>(
          '/miru.NetworkService/SetCookie',
          ($0.SetCookieRequest value) => value.writeToBuffer(),
          $0.SetCookieResponse.fromBuffer);
}

@$pb.GrpcServiceName('miru.NetworkService')
abstract class NetworkServiceBase extends $grpc.Service {
  $core.String get $name => 'miru.NetworkService';

  NetworkServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SetCookieRequest, $0.SetCookieResponse>(
        'SetCookie',
        setCookie_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetCookieRequest.fromBuffer(value),
        ($0.SetCookieResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.SetCookieResponse> setCookie_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetCookieRequest> $request) async {
    return setCookie($call, await $request);
  }

  $async.Future<$0.SetCookieResponse> setCookie(
      $grpc.ServiceCall call, $0.SetCookieRequest request);
}
