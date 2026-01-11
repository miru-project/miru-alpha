// This is a generated file - do not edit.
//
// Generated from proto/repo.proto.

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

import 'repo.pb.dart' as $0;

export 'repo.pb.dart';

@$pb.GrpcServiceName('miru.RepoService')
class RepoServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  RepoServiceClient(super.channel, {super.options, super.interceptors});

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

  // method descriptors

  static final _$getRepos =
      $grpc.ClientMethod<$0.GetReposRequest, $0.GetReposResponse>(
          '/miru.RepoService/GetRepos',
          ($0.GetReposRequest value) => value.writeToBuffer(),
          $0.GetReposResponse.fromBuffer);
  static final _$setRepo =
      $grpc.ClientMethod<$0.SetRepoRequest, $0.SetRepoResponse>(
          '/miru.RepoService/SetRepo',
          ($0.SetRepoRequest value) => value.writeToBuffer(),
          $0.SetRepoResponse.fromBuffer);
  static final _$deleteRepo =
      $grpc.ClientMethod<$0.DeleteRepoRequest, $0.DeleteRepoResponse>(
          '/miru.RepoService/DeleteRepo',
          ($0.DeleteRepoRequest value) => value.writeToBuffer(),
          $0.DeleteRepoResponse.fromBuffer);
  static final _$fetchRepoList =
      $grpc.ClientMethod<$0.FetchRepoListRequest, $0.FetchRepoListResponse>(
          '/miru.RepoService/FetchRepoList',
          ($0.FetchRepoListRequest value) => value.writeToBuffer(),
          $0.FetchRepoListResponse.fromBuffer);
}

@$pb.GrpcServiceName('miru.RepoService')
abstract class RepoServiceBase extends $grpc.Service {
  $core.String get $name => 'miru.RepoService';

  RepoServiceBase() {
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
  }

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
}
