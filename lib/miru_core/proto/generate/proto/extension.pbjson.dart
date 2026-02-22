// This is a generated file - do not edit.
//
// Generated from proto/extension.proto.

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

@$core.Deprecated('Use searchRequestDescriptor instead')
const SearchRequest$json = {
  '1': 'SearchRequest',
  '2': [
    {'1': 'pkg', '3': 1, '4': 1, '5': 9, '10': 'pkg'},
    {'1': 'kw', '3': 2, '4': 1, '5': 9, '10': 'kw'},
    {'1': 'page', '3': 3, '4': 1, '5': 5, '10': 'page'},
    {'1': 'filter', '3': 4, '4': 1, '5': 9, '10': 'filter'},
  ],
};

/// Descriptor for `SearchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchRequestDescriptor = $convert.base64Decode(
    'Cg1TZWFyY2hSZXF1ZXN0EhAKA3BrZxgBIAEoCVIDcGtnEg4KAmt3GAIgASgJUgJrdxISCgRwYW'
    'dlGAMgASgFUgRwYWdlEhYKBmZpbHRlchgEIAEoCVIGZmlsdGVy');

@$core.Deprecated('Use searchResponseDescriptor instead')
const SearchResponse$json = {
  '1': 'SearchResponse',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.ExtensionListItem',
      '10': 'items'
    },
  ],
};

/// Descriptor for `SearchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchResponseDescriptor = $convert.base64Decode(
    'Cg5TZWFyY2hSZXNwb25zZRItCgVpdGVtcxgBIAMoCzIXLm1pcnUuRXh0ZW5zaW9uTGlzdEl0ZW'
    '1SBWl0ZW1z');

@$core.Deprecated('Use latestRequestDescriptor instead')
const LatestRequest$json = {
  '1': 'LatestRequest',
  '2': [
    {'1': 'pkg', '3': 1, '4': 1, '5': 9, '10': 'pkg'},
    {'1': 'page', '3': 2, '4': 1, '5': 5, '10': 'page'},
  ],
};

/// Descriptor for `LatestRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List latestRequestDescriptor = $convert.base64Decode(
    'Cg1MYXRlc3RSZXF1ZXN0EhAKA3BrZxgBIAEoCVIDcGtnEhIKBHBhZ2UYAiABKAVSBHBhZ2U=');

@$core.Deprecated('Use latestResponseDescriptor instead')
const LatestResponse$json = {
  '1': 'LatestResponse',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.ExtensionListItem',
      '10': 'items'
    },
  ],
};

/// Descriptor for `LatestResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List latestResponseDescriptor = $convert.base64Decode(
    'Cg5MYXRlc3RSZXNwb25zZRItCgVpdGVtcxgBIAMoCzIXLm1pcnUuRXh0ZW5zaW9uTGlzdEl0ZW'
    '1SBWl0ZW1z');

@$core.Deprecated('Use detailRequestDescriptor instead')
const DetailRequest$json = {
  '1': 'DetailRequest',
  '2': [
    {'1': 'pkg', '3': 1, '4': 1, '5': 9, '10': 'pkg'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `DetailRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detailRequestDescriptor = $convert.base64Decode(
    'Cg1EZXRhaWxSZXF1ZXN0EhAKA3BrZxgBIAEoCVIDcGtnEhAKA3VybBgCIAEoCVIDdXJs');

@$core.Deprecated('Use detailResponseDescriptor instead')
const DetailResponse$json = {
  '1': 'DetailResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.miru.ExtensionDetail',
      '10': 'data'
    },
  ],
};

/// Descriptor for `DetailResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detailResponseDescriptor = $convert.base64Decode(
    'Cg5EZXRhaWxSZXNwb25zZRIpCgRkYXRhGAEgASgLMhUubWlydS5FeHRlbnNpb25EZXRhaWxSBG'
    'RhdGE=');

@$core.Deprecated('Use watchRequestDescriptor instead')
const WatchRequest$json = {
  '1': 'WatchRequest',
  '2': [
    {'1': 'pkg', '3': 1, '4': 1, '5': 9, '10': 'pkg'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `WatchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchRequestDescriptor = $convert.base64Decode(
    'CgxXYXRjaFJlcXVlc3QSEAoDcGtnGAEgASgJUgNwa2cSEAoDdXJsGAIgASgJUgN1cmw=');

@$core.Deprecated('Use watchResponseDescriptor instead')
const WatchResponse$json = {
  '1': 'WatchResponse',
  '2': [
    {
      '1': 'bangumi',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.miru.ExtensionBangumiWatch',
      '9': 0,
      '10': 'bangumi'
    },
    {
      '1': 'manga',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.miru.ExtensionMangaWatch',
      '9': 0,
      '10': 'manga'
    },
    {
      '1': 'fikushon',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.miru.ExtensionFikushonWatch',
      '9': 0,
      '10': 'fikushon'
    },
    {'1': 'raw', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'raw'},
  ],
  '8': [
    {'1': 'data'},
  ],
};

/// Descriptor for `WatchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchResponseDescriptor = $convert.base64Decode(
    'Cg1XYXRjaFJlc3BvbnNlEjcKB2Jhbmd1bWkYASABKAsyGy5taXJ1LkV4dGVuc2lvbkJhbmd1bW'
    'lXYXRjaEgAUgdiYW5ndW1pEjEKBW1hbmdhGAIgASgLMhkubWlydS5FeHRlbnNpb25NYW5nYVdh'
    'dGNoSABSBW1hbmdhEjoKCGZpa3VzaG9uGAMgASgLMhwubWlydS5FeHRlbnNpb25GaWt1c2hvbl'
    'dhdGNoSABSCGZpa3VzaG9uEhIKA3JhdxgEIAEoCUgAUgNyYXdCBgoEZGF0YQ==');

@$core.Deprecated('Use downloadExtensionRequestDescriptor instead')
const DownloadExtensionRequest$json = {
  '1': 'DownloadExtensionRequest',
  '2': [
    {'1': 'repo_url', '3': 1, '4': 1, '5': 9, '10': 'repoUrl'},
    {'1': 'pkg', '3': 2, '4': 1, '5': 9, '10': 'pkg'},
  ],
};

/// Descriptor for `DownloadExtensionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadExtensionRequestDescriptor =
    $convert.base64Decode(
        'ChhEb3dubG9hZEV4dGVuc2lvblJlcXVlc3QSGQoIcmVwb191cmwYASABKAlSB3JlcG9VcmwSEA'
        'oDcGtnGAIgASgJUgNwa2c=');

@$core.Deprecated('Use downloadExtensionResponseDescriptor instead')
const DownloadExtensionResponse$json = {
  '1': 'DownloadExtensionResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `DownloadExtensionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadExtensionResponseDescriptor =
    $convert.base64Decode(
        'ChlEb3dubG9hZEV4dGVuc2lvblJlc3BvbnNlEhgKB21lc3NhZ2UYASABKAlSB21lc3NhZ2U=');

@$core.Deprecated('Use removeExtensionRequestDescriptor instead')
const RemoveExtensionRequest$json = {
  '1': 'RemoveExtensionRequest',
  '2': [
    {'1': 'pkg', '3': 2, '4': 1, '5': 9, '10': 'pkg'},
  ],
};

/// Descriptor for `RemoveExtensionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeExtensionRequestDescriptor = $convert
    .base64Decode('ChZSZW1vdmVFeHRlbnNpb25SZXF1ZXN0EhAKA3BrZxgCIAEoCVIDcGtn');

@$core.Deprecated('Use removeExtensionResponseDescriptor instead')
const RemoveExtensionResponse$json = {
  '1': 'RemoveExtensionResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `RemoveExtensionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeExtensionResponseDescriptor =
    $convert.base64Decode(
        'ChdSZW1vdmVFeHRlbnNpb25SZXNwb25zZRIYCgdtZXNzYWdlGAEgASgJUgdtZXNzYWdl');
