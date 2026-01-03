// This is a generated file - do not edit.
//
// Generated from events.proto.

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

import 'events.pb.dart' as $0;

export 'events.pb.dart';

@$pb.GrpcServiceName('miru.EventService')
class EventServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  EventServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseStream<$0.WatchEventsResponse> watchEvents(
    $0.WatchEventsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$watchEvents, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$watchEvents =
      $grpc.ClientMethod<$0.WatchEventsRequest, $0.WatchEventsResponse>(
          '/miru.EventService/WatchEvents',
          ($0.WatchEventsRequest value) => value.writeToBuffer(),
          $0.WatchEventsResponse.fromBuffer);
}

@$pb.GrpcServiceName('miru.EventService')
abstract class EventServiceBase extends $grpc.Service {
  $core.String get $name => 'miru.EventService';

  EventServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.WatchEventsRequest, $0.WatchEventsResponse>(
            'WatchEvents',
            watchEvents_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.WatchEventsRequest.fromBuffer(value),
            ($0.WatchEventsResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.WatchEventsResponse> watchEvents_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WatchEventsRequest> $request) async* {
    yield* watchEvents($call, await $request);
  }

  $async.Stream<$0.WatchEventsResponse> watchEvents(
      $grpc.ServiceCall call, $0.WatchEventsRequest request);
}
