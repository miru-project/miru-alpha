// This is a generated file - do not edit.
//
// Generated from proto/db.proto.

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

@$core.Deprecated('Use getDetailRequestDescriptor instead')
const GetDetailRequest$json = {
  '1': 'GetDetailRequest',
  '2': [
    {'1': 'package', '3': 1, '4': 1, '5': 9, '10': 'package'},
    {'1': 'detail_url', '3': 2, '4': 1, '5': 9, '10': 'detailUrl'},
  ],
};

/// Descriptor for `GetDetailRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDetailRequestDescriptor = $convert.base64Decode(
    'ChBHZXREZXRhaWxSZXF1ZXN0EhgKB3BhY2thZ2UYASABKAlSB3BhY2thZ2USHQoKZGV0YWlsX3'
    'VybBgCIAEoCVIJZGV0YWlsVXJs');

@$core.Deprecated('Use getDetailResponseDescriptor instead')
const GetDetailResponse$json = {
  '1': 'GetDetailResponse',
  '2': [
    {
      '1': 'detail',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.miru.Detail',
      '10': 'detail'
    },
  ],
};

/// Descriptor for `GetDetailResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDetailResponseDescriptor = $convert.base64Decode(
    'ChFHZXREZXRhaWxSZXNwb25zZRIkCgZkZXRhaWwYASABKAsyDC5taXJ1LkRldGFpbFIGZGV0YW'
    'ls');

@$core.Deprecated('Use upsertDetailRequestDescriptor instead')
const UpsertDetailRequest$json = {
  '1': 'UpsertDetailRequest',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'title', '17': true},
    {'1': 'cover', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'cover', '17': true},
    {'1': 'desc', '3': 3, '4': 1, '5': 9, '9': 2, '10': 'desc', '17': true},
    {'1': 'detail_url', '3': 4, '4': 1, '5': 9, '10': 'detailUrl'},
    {'1': 'package', '3': 5, '4': 1, '5': 9, '10': 'package'},
    {'1': 'downloaded', '3': 6, '4': 3, '5': 9, '10': 'downloaded'},
    {
      '1': 'episodes',
      '3': 7,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'episodes',
      '17': true
    },
    {
      '1': 'headers',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'headers',
      '17': true
    },
  ],
  '8': [
    {'1': '_title'},
    {'1': '_cover'},
    {'1': '_desc'},
    {'1': '_episodes'},
    {'1': '_headers'},
  ],
};

/// Descriptor for `UpsertDetailRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List upsertDetailRequestDescriptor = $convert.base64Decode(
    'ChNVcHNlcnREZXRhaWxSZXF1ZXN0EhkKBXRpdGxlGAEgASgJSABSBXRpdGxliAEBEhkKBWNvdm'
    'VyGAIgASgJSAFSBWNvdmVyiAEBEhcKBGRlc2MYAyABKAlIAlIEZGVzY4gBARIdCgpkZXRhaWxf'
    'dXJsGAQgASgJUglkZXRhaWxVcmwSGAoHcGFja2FnZRgFIAEoCVIHcGFja2FnZRIeCgpkb3dubG'
    '9hZGVkGAYgAygJUgpkb3dubG9hZGVkEh8KCGVwaXNvZGVzGAcgASgJSANSCGVwaXNvZGVziAEB'
    'Eh0KB2hlYWRlcnMYCCABKAlIBFIHaGVhZGVyc4gBAUIICgZfdGl0bGVCCAoGX2NvdmVyQgcKBV'
    '9kZXNjQgsKCV9lcGlzb2Rlc0IKCghfaGVhZGVycw==');

@$core.Deprecated('Use upsertDetailResponseDescriptor instead')
const UpsertDetailResponse$json = {
  '1': 'UpsertDetailResponse',
  '2': [
    {
      '1': 'detail',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.miru.Detail',
      '10': 'detail'
    },
  ],
};

/// Descriptor for `UpsertDetailResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List upsertDetailResponseDescriptor = $convert.base64Decode(
    'ChRVcHNlcnREZXRhaWxSZXNwb25zZRIkCgZkZXRhaWwYASABKAsyDC5taXJ1LkRldGFpbFIGZG'
    'V0YWls');

@$core.Deprecated('Use getAllFavoriteRequestDescriptor instead')
const GetAllFavoriteRequest$json = {
  '1': 'GetAllFavoriteRequest',
};

/// Descriptor for `GetAllFavoriteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAllFavoriteRequestDescriptor =
    $convert.base64Decode('ChVHZXRBbGxGYXZvcml0ZVJlcXVlc3Q=');

@$core.Deprecated('Use getAllFavoriteResponseDescriptor instead')
const GetAllFavoriteResponse$json = {
  '1': 'GetAllFavoriteResponse',
  '2': [
    {
      '1': 'favorites',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.Favorite',
      '10': 'favorites'
    },
  ],
};

/// Descriptor for `GetAllFavoriteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAllFavoriteResponseDescriptor =
    $convert.base64Decode(
        'ChZHZXRBbGxGYXZvcml0ZVJlc3BvbnNlEiwKCWZhdm9yaXRlcxgBIAMoCzIOLm1pcnUuRmF2b3'
        'JpdGVSCWZhdm9yaXRlcw==');

@$core.Deprecated('Use getFavoriteByPackageAndUrlRequestDescriptor instead')
const GetFavoriteByPackageAndUrlRequest$json = {
  '1': 'GetFavoriteByPackageAndUrlRequest',
  '2': [
    {'1': 'package', '3': 1, '4': 1, '5': 9, '10': 'package'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `GetFavoriteByPackageAndUrlRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFavoriteByPackageAndUrlRequestDescriptor =
    $convert.base64Decode(
        'CiFHZXRGYXZvcml0ZUJ5UGFja2FnZUFuZFVybFJlcXVlc3QSGAoHcGFja2FnZRgBIAEoCVIHcG'
        'Fja2FnZRIQCgN1cmwYAiABKAlSA3VybA==');

@$core.Deprecated('Use getFavoriteByPackageAndUrlResponseDescriptor instead')
const GetFavoriteByPackageAndUrlResponse$json = {
  '1': 'GetFavoriteByPackageAndUrlResponse',
  '2': [
    {
      '1': 'favorite',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.miru.Favorite',
      '10': 'favorite'
    },
  ],
};

/// Descriptor for `GetFavoriteByPackageAndUrlResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFavoriteByPackageAndUrlResponseDescriptor =
    $convert.base64Decode(
        'CiJHZXRGYXZvcml0ZUJ5UGFja2FnZUFuZFVybFJlc3BvbnNlEioKCGZhdm9yaXRlGAEgASgLMg'
        '4ubWlydS5GYXZvcml0ZVIIZmF2b3JpdGU=');

@$core.Deprecated('Use putFavoriteByIndexRequestDescriptor instead')
const PutFavoriteByIndexRequest$json = {
  '1': 'PutFavoriteByIndexRequest',
  '2': [
    {
      '1': 'groups',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.FavoriteGroup',
      '10': 'groups'
    },
  ],
};

/// Descriptor for `PutFavoriteByIndexRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List putFavoriteByIndexRequestDescriptor =
    $convert.base64Decode(
        'ChlQdXRGYXZvcml0ZUJ5SW5kZXhSZXF1ZXN0EisKBmdyb3VwcxgBIAMoCzITLm1pcnUuRmF2b3'
        'JpdGVHcm91cFIGZ3JvdXBz');

@$core.Deprecated('Use putFavoriteByIndexResponseDescriptor instead')
const PutFavoriteByIndexResponse$json = {
  '1': 'PutFavoriteByIndexResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `PutFavoriteByIndexResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List putFavoriteByIndexResponseDescriptor =
    $convert.base64Decode(
        'ChpQdXRGYXZvcml0ZUJ5SW5kZXhSZXNwb25zZRIYCgdtZXNzYWdlGAEgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use putFavoriteRequestDescriptor instead')
const PutFavoriteRequest$json = {
  '1': 'PutFavoriteRequest',
  '2': [
    {'1': 'package', '3': 1, '4': 1, '5': 9, '10': 'package'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
    {'1': 'type', '3': 3, '4': 1, '5': 9, '10': 'type'},
    {'1': 'title', '3': 4, '4': 1, '5': 9, '10': 'title'},
    {'1': 'cover', '3': 5, '4': 1, '5': 9, '10': 'cover'},
  ],
};

/// Descriptor for `PutFavoriteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List putFavoriteRequestDescriptor = $convert.base64Decode(
    'ChJQdXRGYXZvcml0ZVJlcXVlc3QSGAoHcGFja2FnZRgBIAEoCVIHcGFja2FnZRIQCgN1cmwYAi'
    'ABKAlSA3VybBISCgR0eXBlGAMgASgJUgR0eXBlEhQKBXRpdGxlGAQgASgJUgV0aXRsZRIUCgVj'
    'b3ZlchgFIAEoCVIFY292ZXI=');

@$core.Deprecated('Use putFavoriteResponseDescriptor instead')
const PutFavoriteResponse$json = {
  '1': 'PutFavoriteResponse',
  '2': [
    {
      '1': 'favorite',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.miru.Favorite',
      '10': 'favorite'
    },
  ],
};

/// Descriptor for `PutFavoriteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List putFavoriteResponseDescriptor = $convert.base64Decode(
    'ChNQdXRGYXZvcml0ZVJlc3BvbnNlEioKCGZhdm9yaXRlGAEgASgLMg4ubWlydS5GYXZvcml0ZV'
    'IIZmF2b3JpdGU=');

@$core.Deprecated('Use deleteFavoriteRequestDescriptor instead')
const DeleteFavoriteRequest$json = {
  '1': 'DeleteFavoriteRequest',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'package', '3': 2, '4': 1, '5': 9, '10': 'package'},
  ],
};

/// Descriptor for `DeleteFavoriteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteFavoriteRequestDescriptor = $convert.base64Decode(
    'ChVEZWxldGVGYXZvcml0ZVJlcXVlc3QSEAoDdXJsGAEgASgJUgN1cmwSGAoHcGFja2FnZRgCIA'
    'EoCVIHcGFja2FnZQ==');

@$core.Deprecated('Use deleteFavoriteResponseDescriptor instead')
const DeleteFavoriteResponse$json = {
  '1': 'DeleteFavoriteResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `DeleteFavoriteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteFavoriteResponseDescriptor =
    $convert.base64Decode(
        'ChZEZWxldGVGYXZvcml0ZVJlc3BvbnNlEhgKB21lc3NhZ2UYASABKAlSB21lc3NhZ2U=');

@$core.Deprecated('Use getFavoriteGroupsByIdRequestDescriptor instead')
const GetFavoriteGroupsByIdRequest$json = {
  '1': 'GetFavoriteGroupsByIdRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
  ],
};

/// Descriptor for `GetFavoriteGroupsByIdRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFavoriteGroupsByIdRequestDescriptor =
    $convert.base64Decode(
        'ChxHZXRGYXZvcml0ZUdyb3Vwc0J5SWRSZXF1ZXN0Eg4KAmlkGAEgASgFUgJpZA==');

@$core.Deprecated('Use getFavoriteGroupsByIdResponseDescriptor instead')
const GetFavoriteGroupsByIdResponse$json = {
  '1': 'GetFavoriteGroupsByIdResponse',
  '2': [
    {
      '1': 'groups',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.FavoriteGroup',
      '10': 'groups'
    },
  ],
};

/// Descriptor for `GetFavoriteGroupsByIdResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFavoriteGroupsByIdResponseDescriptor =
    $convert.base64Decode(
        'Ch1HZXRGYXZvcml0ZUdyb3Vwc0J5SWRSZXNwb25zZRIrCgZncm91cHMYASADKAsyEy5taXJ1Lk'
        'Zhdm9yaXRlR3JvdXBSBmdyb3Vwcw==');

@$core.Deprecated('Use getAllFavoriteGroupRequestDescriptor instead')
const GetAllFavoriteGroupRequest$json = {
  '1': 'GetAllFavoriteGroupRequest',
};

/// Descriptor for `GetAllFavoriteGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAllFavoriteGroupRequestDescriptor =
    $convert.base64Decode('ChpHZXRBbGxGYXZvcml0ZUdyb3VwUmVxdWVzdA==');

@$core.Deprecated('Use getAllFavoriteGroupResponseDescriptor instead')
const GetAllFavoriteGroupResponse$json = {
  '1': 'GetAllFavoriteGroupResponse',
  '2': [
    {
      '1': 'groups',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.FavoriteGroup',
      '10': 'groups'
    },
  ],
};

/// Descriptor for `GetAllFavoriteGroupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAllFavoriteGroupResponseDescriptor =
    $convert.base64Decode(
        'ChtHZXRBbGxGYXZvcml0ZUdyb3VwUmVzcG9uc2USKwoGZ3JvdXBzGAEgAygLMhMubWlydS5GYX'
        'Zvcml0ZUdyb3VwUgZncm91cHM=');

@$core.Deprecated('Use putFavoriteGroupRequestDescriptor instead')
const PutFavoriteGroupRequest$json = {
  '1': 'PutFavoriteGroupRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'items', '3': 2, '4': 3, '5': 5, '10': 'items'},
  ],
};

/// Descriptor for `PutFavoriteGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List putFavoriteGroupRequestDescriptor =
    $convert.base64Decode(
        'ChdQdXRGYXZvcml0ZUdyb3VwUmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEhQKBWl0ZW1zGA'
        'IgAygFUgVpdGVtcw==');

@$core.Deprecated('Use putFavoriteGroupResponseDescriptor instead')
const PutFavoriteGroupResponse$json = {
  '1': 'PutFavoriteGroupResponse',
  '2': [
    {
      '1': 'group',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.miru.FavoriteGroup',
      '10': 'group'
    },
  ],
};

/// Descriptor for `PutFavoriteGroupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List putFavoriteGroupResponseDescriptor =
    $convert.base64Decode(
        'ChhQdXRGYXZvcml0ZUdyb3VwUmVzcG9uc2USKQoFZ3JvdXAYASABKAsyEy5taXJ1LkZhdm9yaX'
        'RlR3JvdXBSBWdyb3Vw');

@$core.Deprecated('Use renameFavoriteGroupRequestDescriptor instead')
const RenameFavoriteGroupRequest$json = {
  '1': 'RenameFavoriteGroupRequest',
  '2': [
    {'1': 'old_name', '3': 1, '4': 1, '5': 9, '10': 'oldName'},
    {'1': 'new_name', '3': 2, '4': 1, '5': 9, '10': 'newName'},
  ],
};

/// Descriptor for `RenameFavoriteGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List renameFavoriteGroupRequestDescriptor =
    $convert.base64Decode(
        'ChpSZW5hbWVGYXZvcml0ZUdyb3VwUmVxdWVzdBIZCghvbGRfbmFtZRgBIAEoCVIHb2xkTmFtZR'
        'IZCghuZXdfbmFtZRgCIAEoCVIHbmV3TmFtZQ==');

@$core.Deprecated('Use renameFavoriteGroupResponseDescriptor instead')
const RenameFavoriteGroupResponse$json = {
  '1': 'RenameFavoriteGroupResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `RenameFavoriteGroupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List renameFavoriteGroupResponseDescriptor =
    $convert.base64Decode(
        'ChtSZW5hbWVGYXZvcml0ZUdyb3VwUmVzcG9uc2USGAoHbWVzc2FnZRgBIAEoCVIHbWVzc2FnZQ'
        '==');

@$core.Deprecated('Use deleteFavoriteGroupRequestDescriptor instead')
const DeleteFavoriteGroupRequest$json = {
  '1': 'DeleteFavoriteGroupRequest',
  '2': [
    {'1': 'names', '3': 1, '4': 3, '5': 9, '10': 'names'},
  ],
};

/// Descriptor for `DeleteFavoriteGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteFavoriteGroupRequestDescriptor =
    $convert.base64Decode(
        'ChpEZWxldGVGYXZvcml0ZUdyb3VwUmVxdWVzdBIUCgVuYW1lcxgBIAMoCVIFbmFtZXM=');

@$core.Deprecated('Use deleteFavoriteGroupResponseDescriptor instead')
const DeleteFavoriteGroupResponse$json = {
  '1': 'DeleteFavoriteGroupResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `DeleteFavoriteGroupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteFavoriteGroupResponseDescriptor =
    $convert.base64Decode(
        'ChtEZWxldGVGYXZvcml0ZUdyb3VwUmVzcG9uc2USGAoHbWVzc2FnZRgBIAEoCVIHbWVzc2FnZQ'
        '==');

@$core.Deprecated('Use getFavoriteGroupsByFavoriteRequestDescriptor instead')
const GetFavoriteGroupsByFavoriteRequest$json = {
  '1': 'GetFavoriteGroupsByFavoriteRequest',
  '2': [
    {'1': 'package', '3': 1, '4': 1, '5': 9, '10': 'package'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `GetFavoriteGroupsByFavoriteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFavoriteGroupsByFavoriteRequestDescriptor =
    $convert.base64Decode(
        'CiJHZXRGYXZvcml0ZUdyb3Vwc0J5RmF2b3JpdGVSZXF1ZXN0EhgKB3BhY2thZ2UYASABKAlSB3'
        'BhY2thZ2USEAoDdXJsGAIgASgJUgN1cmw=');

@$core.Deprecated('Use getFavoriteGroupsByFavoriteResponseDescriptor instead')
const GetFavoriteGroupsByFavoriteResponse$json = {
  '1': 'GetFavoriteGroupsByFavoriteResponse',
  '2': [
    {
      '1': 'groups',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.FavoriteGroup',
      '10': 'groups'
    },
  ],
};

/// Descriptor for `GetFavoriteGroupsByFavoriteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFavoriteGroupsByFavoriteResponseDescriptor =
    $convert.base64Decode(
        'CiNHZXRGYXZvcml0ZUdyb3Vwc0J5RmF2b3JpdGVSZXNwb25zZRIrCgZncm91cHMYASADKAsyEy'
        '5taXJ1LkZhdm9yaXRlR3JvdXBSBmdyb3Vwcw==');

@$core.Deprecated('Use getHistoriesByTypeRequestDescriptor instead')
const GetHistoriesByTypeRequest$json = {
  '1': 'GetHistoriesByTypeRequest',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
  ],
};

/// Descriptor for `GetHistoriesByTypeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHistoriesByTypeRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXRIaXN0b3JpZXNCeVR5cGVSZXF1ZXN0EhIKBHR5cGUYASABKAlSBHR5cGU=');

@$core.Deprecated('Use getHistoriesByTypeResponseDescriptor instead')
const GetHistoriesByTypeResponse$json = {
  '1': 'GetHistoriesByTypeResponse',
  '2': [
    {
      '1': 'histories',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.History',
      '10': 'histories'
    },
  ],
};

/// Descriptor for `GetHistoriesByTypeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHistoriesByTypeResponseDescriptor =
    $convert.base64Decode(
        'ChpHZXRIaXN0b3JpZXNCeVR5cGVSZXNwb25zZRIrCgloaXN0b3JpZXMYASADKAsyDS5taXJ1Lk'
        'hpc3RvcnlSCWhpc3Rvcmllcw==');

@$core.Deprecated('Use getHistoryByPackageAndUrlRequestDescriptor instead')
const GetHistoryByPackageAndUrlRequest$json = {
  '1': 'GetHistoryByPackageAndUrlRequest',
  '2': [
    {'1': 'package', '3': 1, '4': 1, '5': 9, '10': 'package'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `GetHistoryByPackageAndUrlRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHistoryByPackageAndUrlRequestDescriptor =
    $convert.base64Decode(
        'CiBHZXRIaXN0b3J5QnlQYWNrYWdlQW5kVXJsUmVxdWVzdBIYCgdwYWNrYWdlGAEgASgJUgdwYW'
        'NrYWdlEhAKA3VybBgCIAEoCVIDdXJs');

@$core.Deprecated('Use getHistoryByPackageAndUrlResponseDescriptor instead')
const GetHistoryByPackageAndUrlResponse$json = {
  '1': 'GetHistoryByPackageAndUrlResponse',
  '2': [
    {
      '1': 'history',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.miru.History',
      '10': 'history'
    },
  ],
};

/// Descriptor for `GetHistoryByPackageAndUrlResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHistoryByPackageAndUrlResponseDescriptor =
    $convert.base64Decode(
        'CiFHZXRIaXN0b3J5QnlQYWNrYWdlQW5kVXJsUmVzcG9uc2USJwoHaGlzdG9yeRgBIAEoCzINLm'
        '1pcnUuSGlzdG9yeVIHaGlzdG9yeQ==');

@$core.Deprecated('Use putHistoryRequestDescriptor instead')
const PutHistoryRequest$json = {
  '1': 'PutHistoryRequest',
  '2': [
    {
      '1': 'history',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.miru.History',
      '10': 'history'
    },
  ],
};

/// Descriptor for `PutHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List putHistoryRequestDescriptor = $convert.base64Decode(
    'ChFQdXRIaXN0b3J5UmVxdWVzdBInCgdoaXN0b3J5GAEgASgLMg0ubWlydS5IaXN0b3J5UgdoaX'
    'N0b3J5');

@$core.Deprecated('Use putHistoryResponseDescriptor instead')
const PutHistoryResponse$json = {
  '1': 'PutHistoryResponse',
  '2': [
    {
      '1': 'history',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.miru.History',
      '10': 'history'
    },
  ],
};

/// Descriptor for `PutHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List putHistoryResponseDescriptor = $convert.base64Decode(
    'ChJQdXRIaXN0b3J5UmVzcG9uc2USJwoHaGlzdG9yeRgBIAEoCzINLm1pcnUuSGlzdG9yeVIHaG'
    'lzdG9yeQ==');

@$core
    .Deprecated('Use getHistoryByPackageAndDetailUrlRequestDescriptor instead')
const GetHistoryByPackageAndDetailUrlRequest$json = {
  '1': 'GetHistoryByPackageAndDetailUrlRequest',
  '2': [
    {'1': 'package', '3': 1, '4': 1, '5': 9, '10': 'package'},
    {'1': 'detail_url', '3': 2, '4': 1, '5': 9, '10': 'detailUrl'},
  ],
};

/// Descriptor for `GetHistoryByPackageAndDetailUrlRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHistoryByPackageAndDetailUrlRequestDescriptor =
    $convert.base64Decode(
        'CiZHZXRIaXN0b3J5QnlQYWNrYWdlQW5kRGV0YWlsVXJsUmVxdWVzdBIYCgdwYWNrYWdlGAEgAS'
        'gJUgdwYWNrYWdlEh0KCmRldGFpbF91cmwYAiABKAlSCWRldGFpbFVybA==');

@$core
    .Deprecated('Use getHistoryByPackageAndDetailUrlResponseDescriptor instead')
const GetHistoryByPackageAndDetailUrlResponse$json = {
  '1': 'GetHistoryByPackageAndDetailUrlResponse',
  '2': [
    {
      '1': 'history',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.History',
      '10': 'history'
    },
  ],
};

/// Descriptor for `GetHistoryByPackageAndDetailUrlResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHistoryByPackageAndDetailUrlResponseDescriptor =
    $convert.base64Decode(
        'CidHZXRIaXN0b3J5QnlQYWNrYWdlQW5kRGV0YWlsVXJsUmVzcG9uc2USJwoHaGlzdG9yeRgBIA'
        'MoCzINLm1pcnUuSGlzdG9yeVIHaGlzdG9yeQ==');

@$core.Deprecated('Use deleteHistoryByPackageAndUrlRequestDescriptor instead')
const DeleteHistoryByPackageAndUrlRequest$json = {
  '1': 'DeleteHistoryByPackageAndUrlRequest',
  '2': [
    {'1': 'package', '3': 1, '4': 1, '5': 9, '10': 'package'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `DeleteHistoryByPackageAndUrlRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteHistoryByPackageAndUrlRequestDescriptor =
    $convert.base64Decode(
        'CiNEZWxldGVIaXN0b3J5QnlQYWNrYWdlQW5kVXJsUmVxdWVzdBIYCgdwYWNrYWdlGAEgASgJUg'
        'dwYWNrYWdlEhAKA3VybBgCIAEoCVIDdXJs');

@$core.Deprecated('Use deleteHistoryByPackageAndUrlResponseDescriptor instead')
const DeleteHistoryByPackageAndUrlResponse$json = {
  '1': 'DeleteHistoryByPackageAndUrlResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `DeleteHistoryByPackageAndUrlResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteHistoryByPackageAndUrlResponseDescriptor =
    $convert.base64Decode(
        'CiREZWxldGVIaXN0b3J5QnlQYWNrYWdlQW5kVXJsUmVzcG9uc2USGAoHbWVzc2FnZRgBIAEoCV'
        'IHbWVzc2FnZQ==');

@$core.Deprecated('Use deleteAllHistoryRequestDescriptor instead')
const DeleteAllHistoryRequest$json = {
  '1': 'DeleteAllHistoryRequest',
};

/// Descriptor for `DeleteAllHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteAllHistoryRequestDescriptor =
    $convert.base64Decode('ChdEZWxldGVBbGxIaXN0b3J5UmVxdWVzdA==');

@$core.Deprecated('Use deleteAllHistoryResponseDescriptor instead')
const DeleteAllHistoryResponse$json = {
  '1': 'DeleteAllHistoryResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `DeleteAllHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteAllHistoryResponseDescriptor =
    $convert.base64Decode(
        'ChhEZWxldGVBbGxIaXN0b3J5UmVzcG9uc2USGAoHbWVzc2FnZRgBIAEoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use getHistorysFilteredRequestDescriptor instead')
const GetHistorysFilteredRequest$json = {
  '1': 'GetHistorysFilteredRequest',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'before_date', '3': 2, '4': 1, '5': 9, '10': 'beforeDate'},
  ],
};

/// Descriptor for `GetHistorysFilteredRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHistorysFilteredRequestDescriptor =
    $convert.base64Decode(
        'ChpHZXRIaXN0b3J5c0ZpbHRlcmVkUmVxdWVzdBISCgR0eXBlGAEgASgJUgR0eXBlEh8KC2JlZm'
        '9yZV9kYXRlGAIgASgJUgpiZWZvcmVEYXRl');

@$core.Deprecated('Use getHistorysFilteredResponseDescriptor instead')
const GetHistorysFilteredResponse$json = {
  '1': 'GetHistorysFilteredResponse',
  '2': [
    {
      '1': 'histories',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.History',
      '10': 'histories'
    },
  ],
};

/// Descriptor for `GetHistorysFilteredResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHistorysFilteredResponseDescriptor =
    $convert.base64Decode(
        'ChtHZXRIaXN0b3J5c0ZpbHRlcmVkUmVzcG9uc2USKwoJaGlzdG9yaWVzGAEgAygLMg0ubWlydS'
        '5IaXN0b3J5UgloaXN0b3JpZXM=');
