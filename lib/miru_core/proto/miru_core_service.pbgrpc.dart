// This is a generated file - do not edit.
//
// Generated from proto/miru_core_service.proto.

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

  // method descriptors

  static final _$helloMiru =
      $grpc.ClientMethod<$0.HelloMiruRequest, $0.HelloMiruResponse>(
          '/miru.MiruCoreService/HelloMiru',
          ($0.HelloMiruRequest value) => value.writeToBuffer(),
          $0.HelloMiruResponse.fromBuffer);
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
  }

  $async.Future<$0.HelloMiruResponse> helloMiru_Pre($grpc.ServiceCall $call,
      $async.Future<$0.HelloMiruRequest> $request) async {
    return helloMiru($call, await $request);
  }

  $async.Future<$0.HelloMiruResponse> helloMiru(
      $grpc.ServiceCall call, $0.HelloMiruRequest request);
}
