// This is a generated file - do not edit.
//
// Generated from repo.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use getReposRequestDescriptor instead')
const GetReposRequest$json = {
  '1': 'GetReposRequest',
};

/// Descriptor for `GetReposRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getReposRequestDescriptor =
    $convert.base64Decode('Cg9HZXRSZXBvc1JlcXVlc3Q=');

@$core.Deprecated('Use getReposResponseDescriptor instead')
const GetReposResponse$json = {
  '1': 'GetReposResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 9, '10': 'data'},
  ],
};

/// Descriptor for `GetReposResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getReposResponseDescriptor = $convert
    .base64Decode('ChBHZXRSZXBvc1Jlc3BvbnNlEhIKBGRhdGEYASABKAlSBGRhdGE=');

@$core.Deprecated('Use setRepoRequestDescriptor instead')
const SetRepoRequest$json = {
  '1': 'SetRepoRequest',
  '2': [
    {'1': 'repo_url', '3': 1, '4': 1, '5': 9, '10': 'repoUrl'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `SetRepoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setRepoRequestDescriptor = $convert.base64Decode(
    'Cg5TZXRSZXBvUmVxdWVzdBIZCghyZXBvX3VybBgBIAEoCVIHcmVwb1VybBISCgRuYW1lGAIgAS'
    'gJUgRuYW1l');

@$core.Deprecated('Use setRepoResponseDescriptor instead')
const SetRepoResponse$json = {
  '1': 'SetRepoResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `SetRepoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setRepoResponseDescriptor = $convert.base64Decode(
    'Cg9TZXRSZXBvUmVzcG9uc2USGAoHbWVzc2FnZRgBIAEoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use deleteRepoRequestDescriptor instead')
const DeleteRepoRequest$json = {
  '1': 'DeleteRepoRequest',
  '2': [
    {'1': 'repo_url', '3': 1, '4': 1, '5': 9, '10': 'repoUrl'},
  ],
};

/// Descriptor for `DeleteRepoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteRepoRequestDescriptor = $convert.base64Decode(
    'ChFEZWxldGVSZXBvUmVxdWVzdBIZCghyZXBvX3VybBgBIAEoCVIHcmVwb1VybA==');

@$core.Deprecated('Use deleteRepoResponseDescriptor instead')
const DeleteRepoResponse$json = {
  '1': 'DeleteRepoResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `DeleteRepoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteRepoResponseDescriptor =
    $convert.base64Decode(
        'ChJEZWxldGVSZXBvUmVzcG9uc2USGAoHbWVzc2FnZRgBIAEoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use fetchRepoListRequestDescriptor instead')
const FetchRepoListRequest$json = {
  '1': 'FetchRepoListRequest',
};

/// Descriptor for `FetchRepoListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fetchRepoListRequestDescriptor =
    $convert.base64Decode('ChRGZXRjaFJlcG9MaXN0UmVxdWVzdA==');

@$core.Deprecated('Use fetchRepoListResponseDescriptor instead')
const FetchRepoListResponse$json = {
  '1': 'FetchRepoListResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 9, '10': 'data'},
  ],
};

/// Descriptor for `FetchRepoListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fetchRepoListResponseDescriptor =
    $convert.base64Decode(
        'ChVGZXRjaFJlcG9MaXN0UmVzcG9uc2USEgoEZGF0YRgBIAEoCVIEZGF0YQ==');
