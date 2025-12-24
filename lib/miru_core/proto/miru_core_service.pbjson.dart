// This is a generated file - do not edit.
//
// Generated from miru_core_service.proto.

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
    {'1': 'data', '3': 1, '4': 1, '5': 9, '10': 'data'},
  ],
};

/// Descriptor for `DetailResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detailResponseDescriptor =
    $convert.base64Decode('Cg5EZXRhaWxSZXNwb25zZRISCgRkYXRhGAEgASgJUgRkYXRh');

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
    {'1': 'data', '3': 1, '4': 1, '5': 9, '10': 'data'},
  ],
};

/// Descriptor for `WatchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchResponseDescriptor =
    $convert.base64Decode('Cg1XYXRjaFJlc3BvbnNlEhIKBGRhdGEYASABKAlSBGRhdGE=');

@$core.Deprecated('Use extensionListItemDescriptor instead')
const ExtensionListItem$json = {
  '1': 'ExtensionListItem',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
    {'1': 'cover', '3': 3, '4': 1, '5': 9, '10': 'cover'},
    {'1': 'update', '3': 4, '4': 1, '5': 9, '10': 'update'},
  ],
};

/// Descriptor for `ExtensionListItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionListItemDescriptor = $convert.base64Decode(
    'ChFFeHRlbnNpb25MaXN0SXRlbRIUCgV0aXRsZRgBIAEoCVIFdGl0bGUSEAoDdXJsGAIgASgJUg'
    'N1cmwSFAoFY292ZXIYAyABKAlSBWNvdmVyEhYKBnVwZGF0ZRgEIAEoCVIGdXBkYXRl');

@$core.Deprecated('Use helloMiruRequestDescriptor instead')
const HelloMiruRequest$json = {
  '1': 'HelloMiruRequest',
};

/// Descriptor for `HelloMiruRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List helloMiruRequestDescriptor =
    $convert.base64Decode('ChBIZWxsb01pcnVSZXF1ZXN0');

@$core.Deprecated('Use helloMiruResponseDescriptor instead')
const HelloMiruResponse$json = {
  '1': 'HelloMiruResponse',
  '2': [
    {
      '1': 'extensionMeta',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.ExtensionMeta',
      '10': 'extensionMeta'
    },
    {
      '1': 'downloadStatus',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.miru.HelloMiruResponse.DownloadStatusEntry',
      '10': 'downloadStatus'
    },
    {
      '1': 'torrent',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.miru.TorrentStats',
      '10': 'torrent'
    },
  ],
  '3': [HelloMiruResponse_DownloadStatusEntry$json],
};

@$core.Deprecated('Use helloMiruResponseDescriptor instead')
const HelloMiruResponse_DownloadStatusEntry$json = {
  '1': 'DownloadStatusEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.miru.DownloadProgress',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `HelloMiruResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List helloMiruResponseDescriptor = $convert.base64Decode(
    'ChFIZWxsb01pcnVSZXNwb25zZRI5Cg1leHRlbnNpb25NZXRhGAEgAygLMhMubWlydS5FeHRlbn'
    'Npb25NZXRhUg1leHRlbnNpb25NZXRhElMKDmRvd25sb2FkU3RhdHVzGAIgAygLMisubWlydS5I'
    'ZWxsb01pcnVSZXNwb25zZS5Eb3dubG9hZFN0YXR1c0VudHJ5Ug5kb3dubG9hZFN0YXR1cxIsCg'
    'd0b3JyZW50GAMgASgLMhIubWlydS5Ub3JyZW50U3RhdHNSB3RvcnJlbnQaWQoTRG93bmxvYWRT'
    'dGF0dXNFbnRyeRIQCgNrZXkYASABKAVSA2tleRIsCgV2YWx1ZRgCIAEoCzIWLm1pcnUuRG93bm'
    'xvYWRQcm9ncmVzc1IFdmFsdWU6AjgB');

@$core.Deprecated('Use extensionMetaDescriptor instead')
const ExtensionMeta$json = {
  '1': 'ExtensionMeta',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'version', '3': 2, '4': 1, '5': 9, '10': 'version'},
    {'1': 'author', '3': 3, '4': 1, '5': 9, '10': 'author'},
    {'1': 'license', '3': 4, '4': 1, '5': 9, '10': 'license'},
    {'1': 'lang', '3': 5, '4': 1, '5': 9, '10': 'lang'},
    {'1': 'icon', '3': 6, '4': 1, '5': 9, '10': 'icon'},
    {'1': 'package', '3': 7, '4': 1, '5': 9, '10': 'package'},
    {'1': 'webSite', '3': 8, '4': 1, '5': 9, '10': 'webSite'},
    {'1': 'description', '3': 9, '4': 1, '5': 9, '10': 'description'},
    {'1': 'tags', '3': 10, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'api', '3': 11, '4': 1, '5': 9, '10': 'api'},
    {'1': 'error', '3': 12, '4': 1, '5': 9, '10': 'error'},
    {'1': 'type', '3': 13, '4': 1, '5': 9, '10': 'type'},
  ],
};

/// Descriptor for `ExtensionMeta`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionMetaDescriptor = $convert.base64Decode(
    'Cg1FeHRlbnNpb25NZXRhEhIKBG5hbWUYASABKAlSBG5hbWUSGAoHdmVyc2lvbhgCIAEoCVIHdm'
    'Vyc2lvbhIWCgZhdXRob3IYAyABKAlSBmF1dGhvchIYCgdsaWNlbnNlGAQgASgJUgdsaWNlbnNl'
    'EhIKBGxhbmcYBSABKAlSBGxhbmcSEgoEaWNvbhgGIAEoCVIEaWNvbhIYCgdwYWNrYWdlGAcgAS'
    'gJUgdwYWNrYWdlEhgKB3dlYlNpdGUYCCABKAlSB3dlYlNpdGUSIAoLZGVzY3JpcHRpb24YCSAB'
    'KAlSC2Rlc2NyaXB0aW9uEhIKBHRhZ3MYCiADKAlSBHRhZ3MSEAoDYXBpGAsgASgJUgNhcGkSFA'
    'oFZXJyb3IYDCABKAlSBWVycm9yEhIKBHR5cGUYDSABKAlSBHR5cGU=');

@$core.Deprecated('Use downloadProgressDescriptor instead')
const DownloadProgress$json = {
  '1': 'DownloadProgress',
  '2': [
    {'1': 'progress', '3': 1, '4': 1, '5': 5, '10': 'progress'},
    {'1': 'names', '3': 2, '4': 3, '5': 9, '10': 'names'},
    {'1': 'total', '3': 3, '4': 1, '5': 5, '10': 'total'},
    {'1': 'status', '3': 4, '4': 1, '5': 9, '10': 'status'},
    {'1': 'media_type', '3': 5, '4': 1, '5': 9, '10': 'mediaType'},
    {
      '1': 'current_downloading',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'currentDownloading'
    },
    {'1': 'task_id', '3': 7, '4': 1, '5': 5, '10': 'taskId'},
  ],
};

/// Descriptor for `DownloadProgress`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadProgressDescriptor = $convert.base64Decode(
    'ChBEb3dubG9hZFByb2dyZXNzEhoKCHByb2dyZXNzGAEgASgFUghwcm9ncmVzcxIUCgVuYW1lcx'
    'gCIAMoCVIFbmFtZXMSFAoFdG90YWwYAyABKAVSBXRvdGFsEhYKBnN0YXR1cxgEIAEoCVIGc3Rh'
    'dHVzEh0KCm1lZGlhX3R5cGUYBSABKAlSCW1lZGlhVHlwZRIvChNjdXJyZW50X2Rvd25sb2FkaW'
    '5nGAYgASgJUhJjdXJyZW50RG93bmxvYWRpbmcSFwoHdGFza19pZBgHIAEoBVIGdGFza0lk');

@$core.Deprecated('Use torrentStatsDescriptor instead')
const TorrentStats$json = {
  '1': 'TorrentStats',
  '2': [
    {'1': 'total_down', '3': 1, '4': 1, '5': 3, '10': 'totalDown'},
    {'1': 'total_up', '3': 2, '4': 1, '5': 3, '10': 'totalUp'},
  ],
};

/// Descriptor for `TorrentStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List torrentStatsDescriptor = $convert.base64Decode(
    'CgxUb3JyZW50U3RhdHMSHQoKdG90YWxfZG93bhgBIAEoA1IJdG90YWxEb3duEhkKCHRvdGFsX3'
    'VwGAIgASgDUgd0b3RhbFVw');

@$core.Deprecated('Use getAppSettingRequestDescriptor instead')
const GetAppSettingRequest$json = {
  '1': 'GetAppSettingRequest',
};

/// Descriptor for `GetAppSettingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAppSettingRequestDescriptor =
    $convert.base64Decode('ChRHZXRBcHBTZXR0aW5nUmVxdWVzdA==');

@$core.Deprecated('Use getAppSettingResponseDescriptor instead')
const GetAppSettingResponse$json = {
  '1': 'GetAppSettingResponse',
  '2': [
    {
      '1': 'settings',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.AppSetting',
      '10': 'settings'
    },
  ],
};

/// Descriptor for `GetAppSettingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAppSettingResponseDescriptor = $convert.base64Decode(
    'ChVHZXRBcHBTZXR0aW5nUmVzcG9uc2USLAoIc2V0dGluZ3MYASADKAsyEC5taXJ1LkFwcFNldH'
    'RpbmdSCHNldHRpbmdz');

@$core.Deprecated('Use setAppSettingRequestDescriptor instead')
const SetAppSettingRequest$json = {
  '1': 'SetAppSettingRequest',
  '2': [
    {
      '1': 'settings',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.AppSetting',
      '10': 'settings'
    },
  ],
};

/// Descriptor for `SetAppSettingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setAppSettingRequestDescriptor = $convert.base64Decode(
    'ChRTZXRBcHBTZXR0aW5nUmVxdWVzdBIsCghzZXR0aW5ncxgBIAMoCzIQLm1pcnUuQXBwU2V0dG'
    'luZ1IIc2V0dGluZ3M=');

@$core.Deprecated('Use setAppSettingResponseDescriptor instead')
const SetAppSettingResponse$json = {
  '1': 'SetAppSettingResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `SetAppSettingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setAppSettingResponseDescriptor =
    $convert.base64Decode(
        'ChVTZXRBcHBTZXR0aW5nUmVzcG9uc2USGAoHbWVzc2FnZRgBIAEoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use appSettingDescriptor instead')
const AppSetting$json = {
  '1': 'AppSetting',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `AppSetting`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List appSettingDescriptor = $convert.base64Decode(
    'CgpBcHBTZXR0aW5nEhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZQ==');

@$core.Deprecated('Use favoriteDescriptor instead')
const Favorite$json = {
  '1': 'Favorite',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'package', '3': 2, '4': 1, '5': 9, '10': 'package'},
    {'1': 'url', '3': 3, '4': 1, '5': 9, '10': 'url'},
    {'1': 'type', '3': 4, '4': 1, '5': 9, '10': 'type'},
    {'1': 'title', '3': 5, '4': 1, '5': 9, '10': 'title'},
    {'1': 'cover', '3': 6, '4': 1, '5': 9, '10': 'cover'},
    {'1': 'date', '3': 7, '4': 1, '5': 9, '10': 'date'},
  ],
};

/// Descriptor for `Favorite`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List favoriteDescriptor = $convert.base64Decode(
    'CghGYXZvcml0ZRIOCgJpZBgBIAEoBVICaWQSGAoHcGFja2FnZRgCIAEoCVIHcGFja2FnZRIQCg'
    'N1cmwYAyABKAlSA3VybBISCgR0eXBlGAQgASgJUgR0eXBlEhQKBXRpdGxlGAUgASgJUgV0aXRs'
    'ZRIUCgVjb3ZlchgGIAEoCVIFY292ZXISEgoEZGF0ZRgHIAEoCVIEZGF0ZQ==');

@$core.Deprecated('Use favoriteGroupDescriptor instead')
const FavoriteGroup$json = {
  '1': 'FavoriteGroup',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'date', '3': 3, '4': 1, '5': 9, '10': 'date'},
    {
      '1': 'favorites',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.miru.Favorite',
      '10': 'favorites'
    },
  ],
};

/// Descriptor for `FavoriteGroup`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List favoriteGroupDescriptor = $convert.base64Decode(
    'Cg1GYXZvcml0ZUdyb3VwEg4KAmlkGAEgASgFUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEhIKBG'
    'RhdGUYAyABKAlSBGRhdGUSLAoJZmF2b3JpdGVzGAQgAygLMg4ubWlydS5GYXZvcml0ZVIJZmF2'
    'b3JpdGVz');

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

@$core.Deprecated('Use historyDescriptor instead')
const History$json = {
  '1': 'History',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'package', '3': 2, '4': 1, '5': 9, '10': 'package'},
    {'1': 'url', '3': 3, '4': 1, '5': 9, '10': 'url'},
    {'1': 'cover', '3': 4, '4': 1, '5': 9, '10': 'cover'},
    {'1': 'type', '3': 5, '4': 1, '5': 9, '10': 'type'},
    {'1': 'episode_group_id', '3': 6, '4': 1, '5': 5, '10': 'episodeGroupId'},
    {'1': 'episode_id', '3': 7, '4': 1, '5': 5, '10': 'episodeId'},
    {'1': 'title', '3': 8, '4': 1, '5': 9, '10': 'title'},
    {'1': 'episode_title', '3': 9, '4': 1, '5': 9, '10': 'episodeTitle'},
    {'1': 'progress', '3': 10, '4': 1, '5': 5, '10': 'progress'},
    {'1': 'total_progress', '3': 11, '4': 1, '5': 5, '10': 'totalProgress'},
    {'1': 'date', '3': 12, '4': 1, '5': 9, '10': 'date'},
    {'1': 'detail_url', '3': 13, '4': 1, '5': 9, '10': 'detailUrl'},
  ],
};

/// Descriptor for `History`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List historyDescriptor = $convert.base64Decode(
    'CgdIaXN0b3J5Eg4KAmlkGAEgASgFUgJpZBIYCgdwYWNrYWdlGAIgASgJUgdwYWNrYWdlEhAKA3'
    'VybBgDIAEoCVIDdXJsEhQKBWNvdmVyGAQgASgJUgVjb3ZlchISCgR0eXBlGAUgASgJUgR0eXBl'
    'EigKEGVwaXNvZGVfZ3JvdXBfaWQYBiABKAVSDmVwaXNvZGVHcm91cElkEh0KCmVwaXNvZGVfaW'
    'QYByABKAVSCWVwaXNvZGVJZBIUCgV0aXRsZRgIIAEoCVIFdGl0bGUSIwoNZXBpc29kZV90aXRs'
    'ZRgJIAEoCVIMZXBpc29kZVRpdGxlEhoKCHByb2dyZXNzGAogASgFUghwcm9ncmVzcxIlCg50b3'
    'RhbF9wcm9ncmVzcxgLIAEoBVINdG90YWxQcm9ncmVzcxISCgRkYXRlGAwgASgJUgRkYXRlEh0K'
    'CmRldGFpbF91cmwYDSABKAlSCWRldGFpbFVybA==');

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

@$core.Deprecated('Use getDownloadStatusRequestDescriptor instead')
const GetDownloadStatusRequest$json = {
  '1': 'GetDownloadStatusRequest',
};

/// Descriptor for `GetDownloadStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDownloadStatusRequestDescriptor =
    $convert.base64Decode('ChhHZXREb3dubG9hZFN0YXR1c1JlcXVlc3Q=');

@$core.Deprecated('Use getDownloadStatusResponseDescriptor instead')
const GetDownloadStatusResponse$json = {
  '1': 'GetDownloadStatusResponse',
  '2': [
    {
      '1': 'download_status',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.GetDownloadStatusResponse.DownloadStatusEntry',
      '10': 'downloadStatus'
    },
  ],
  '3': [GetDownloadStatusResponse_DownloadStatusEntry$json],
};

@$core.Deprecated('Use getDownloadStatusResponseDescriptor instead')
const GetDownloadStatusResponse_DownloadStatusEntry$json = {
  '1': 'DownloadStatusEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.miru.DownloadProgress',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `GetDownloadStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDownloadStatusResponseDescriptor = $convert.base64Decode(
    'ChlHZXREb3dubG9hZFN0YXR1c1Jlc3BvbnNlElwKD2Rvd25sb2FkX3N0YXR1cxgBIAMoCzIzLm'
    '1pcnUuR2V0RG93bmxvYWRTdGF0dXNSZXNwb25zZS5Eb3dubG9hZFN0YXR1c0VudHJ5Ug5kb3du'
    'bG9hZFN0YXR1cxpZChNEb3dubG9hZFN0YXR1c0VudHJ5EhAKA2tleRgBIAEoBVIDa2V5EiwKBX'
    'ZhbHVlGAIgASgLMhYubWlydS5Eb3dubG9hZFByb2dyZXNzUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use cancelDownloadRequestDescriptor instead')
const CancelDownloadRequest$json = {
  '1': 'CancelDownloadRequest',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 5, '10': 'taskId'},
  ],
};

/// Descriptor for `CancelDownloadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelDownloadRequestDescriptor =
    $convert.base64Decode(
        'ChVDYW5jZWxEb3dubG9hZFJlcXVlc3QSFwoHdGFza19pZBgBIAEoBVIGdGFza0lk');

@$core.Deprecated('Use cancelDownloadResponseDescriptor instead')
const CancelDownloadResponse$json = {
  '1': 'CancelDownloadResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `CancelDownloadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelDownloadResponseDescriptor =
    $convert.base64Decode(
        'ChZDYW5jZWxEb3dubG9hZFJlc3BvbnNlEhgKB21lc3NhZ2UYASABKAlSB21lc3NhZ2U=');

@$core.Deprecated('Use resumeDownloadRequestDescriptor instead')
const ResumeDownloadRequest$json = {
  '1': 'ResumeDownloadRequest',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 5, '10': 'taskId'},
  ],
};

/// Descriptor for `ResumeDownloadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resumeDownloadRequestDescriptor =
    $convert.base64Decode(
        'ChVSZXN1bWVEb3dubG9hZFJlcXVlc3QSFwoHdGFza19pZBgBIAEoBVIGdGFza0lk');

@$core.Deprecated('Use resumeDownloadResponseDescriptor instead')
const ResumeDownloadResponse$json = {
  '1': 'ResumeDownloadResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `ResumeDownloadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resumeDownloadResponseDescriptor =
    $convert.base64Decode(
        'ChZSZXN1bWVEb3dubG9hZFJlc3BvbnNlEhgKB21lc3NhZ2UYASABKAlSB21lc3NhZ2U=');

@$core.Deprecated('Use pauseDownloadRequestDescriptor instead')
const PauseDownloadRequest$json = {
  '1': 'PauseDownloadRequest',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 5, '10': 'taskId'},
  ],
};

/// Descriptor for `PauseDownloadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pauseDownloadRequestDescriptor =
    $convert.base64Decode(
        'ChRQYXVzZURvd25sb2FkUmVxdWVzdBIXCgd0YXNrX2lkGAEgASgFUgZ0YXNrSWQ=');

@$core.Deprecated('Use pauseDownloadResponseDescriptor instead')
const PauseDownloadResponse$json = {
  '1': 'PauseDownloadResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `PauseDownloadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pauseDownloadResponseDescriptor =
    $convert.base64Decode(
        'ChVQYXVzZURvd25sb2FkUmVzcG9uc2USGAoHbWVzc2FnZRgBIAEoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use downloadBangumiRequestDescriptor instead')
const DownloadBangumiRequest$json = {
  '1': 'DownloadBangumiRequest',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'download_path', '3': 2, '4': 1, '5': 9, '10': 'downloadPath'},
    {
      '1': 'header',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.miru.DownloadBangumiRequest.HeaderEntry',
      '10': 'header'
    },
    {'1': 'is_hls', '3': 4, '4': 1, '5': 8, '10': 'isHls'},
  ],
  '3': [DownloadBangumiRequest_HeaderEntry$json],
};

@$core.Deprecated('Use downloadBangumiRequestDescriptor instead')
const DownloadBangumiRequest_HeaderEntry$json = {
  '1': 'HeaderEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `DownloadBangumiRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadBangumiRequestDescriptor = $convert.base64Decode(
    'ChZEb3dubG9hZEJhbmd1bWlSZXF1ZXN0EhAKA3VybBgBIAEoCVIDdXJsEiMKDWRvd25sb2FkX3'
    'BhdGgYAiABKAlSDGRvd25sb2FkUGF0aBJACgZoZWFkZXIYAyADKAsyKC5taXJ1LkRvd25sb2Fk'
    'QmFuZ3VtaVJlcXVlc3QuSGVhZGVyRW50cnlSBmhlYWRlchIVCgZpc19obHMYBCABKAhSBWlzSG'
    'xzGjkKC0hlYWRlckVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1'
    'ZToCOAE=');

@$core.Deprecated('Use downloadBangumiResponseDescriptor instead')
const DownloadBangumiResponse$json = {
  '1': 'DownloadBangumiResponse',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 5, '10': 'taskId'},
    {
      '1': 'variant_summary',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.miru.AvailableHlsVariant',
      '10': 'variantSummary'
    },
    {'1': 'is_downloading', '3': 3, '4': 1, '5': 8, '10': 'isDownloading'},
  ],
};

/// Descriptor for `DownloadBangumiResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadBangumiResponseDescriptor = $convert.base64Decode(
    'ChdEb3dubG9hZEJhbmd1bWlSZXNwb25zZRIXCgd0YXNrX2lkGAEgASgFUgZ0YXNrSWQSQgoPdm'
    'FyaWFudF9zdW1tYXJ5GAIgAygLMhkubWlydS5BdmFpbGFibGVIbHNWYXJpYW50Ug52YXJpYW50'
    'U3VtbWFyeRIlCg5pc19kb3dubG9hZGluZxgDIAEoCFINaXNEb3dubG9hZGluZw==');

@$core.Deprecated('Use availableHlsVariantDescriptor instead')
const AvailableHlsVariant$json = {
  '1': 'AvailableHlsVariant',
  '2': [
    {'1': 'resolution', '3': 1, '4': 1, '5': 9, '10': 'resolution'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
    {'1': 'codec', '3': 3, '4': 1, '5': 9, '10': 'codec'},
  ],
};

/// Descriptor for `AvailableHlsVariant`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List availableHlsVariantDescriptor = $convert.base64Decode(
    'ChNBdmFpbGFibGVIbHNWYXJpYW50Eh4KCnJlc29sdXRpb24YASABKAlSCnJlc29sdXRpb24SEA'
    'oDdXJsGAIgASgJUgN1cmwSFAoFY29kZWMYAyABKAlSBWNvZGVj');

@$core.Deprecated('Use torrentResultDescriptor instead')
const TorrentResult$json = {
  '1': 'TorrentResult',
  '2': [
    {'1': 'info_hash', '3': 1, '4': 1, '5': 9, '10': 'infoHash'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'files', '3': 3, '4': 3, '5': 9, '10': 'files'},
  ],
};

/// Descriptor for `TorrentResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List torrentResultDescriptor = $convert.base64Decode(
    'Cg1Ub3JyZW50UmVzdWx0EhsKCWluZm9faGFzaBgBIAEoCVIIaW5mb0hhc2gSEgoEbmFtZRgCIA'
    'EoCVIEbmFtZRIUCgVmaWxlcxgDIAMoCVIFZmlsZXM=');

@$core.Deprecated('Use listTorrentRequestDescriptor instead')
const ListTorrentRequest$json = {
  '1': 'ListTorrentRequest',
};

/// Descriptor for `ListTorrentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTorrentRequestDescriptor =
    $convert.base64Decode('ChJMaXN0VG9ycmVudFJlcXVlc3Q=');

@$core.Deprecated('Use listTorrentResponseDescriptor instead')
const ListTorrentResponse$json = {
  '1': 'ListTorrentResponse',
  '2': [
    {
      '1': 'torrents',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.TorrentResult',
      '10': 'torrents'
    },
  ],
};

/// Descriptor for `ListTorrentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTorrentResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0VG9ycmVudFJlc3BvbnNlEi8KCHRvcnJlbnRzGAEgAygLMhMubWlydS5Ub3JyZW50Um'
    'VzdWx0Ugh0b3JyZW50cw==');

@$core.Deprecated('Use addTorrentRequestDescriptor instead')
const AddTorrentRequest$json = {
  '1': 'AddTorrentRequest',
  '2': [
    {'1': 'torrent', '3': 1, '4': 1, '5': 12, '10': 'torrent'},
  ],
};

/// Descriptor for `AddTorrentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addTorrentRequestDescriptor = $convert.base64Decode(
    'ChFBZGRUb3JyZW50UmVxdWVzdBIYCgd0b3JyZW50GAEgASgMUgd0b3JyZW50');

@$core.Deprecated('Use addTorrentResponseDescriptor instead')
const AddTorrentResponse$json = {
  '1': 'AddTorrentResponse',
  '2': [
    {'1': 'info_hash', '3': 1, '4': 1, '5': 9, '10': 'infoHash'},
    {'1': 'detail_json', '3': 2, '4': 1, '5': 9, '10': 'detailJson'},
    {'1': 'files', '3': 3, '4': 3, '5': 9, '10': 'files'},
  ],
};

/// Descriptor for `AddTorrentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addTorrentResponseDescriptor = $convert.base64Decode(
    'ChJBZGRUb3JyZW50UmVzcG9uc2USGwoJaW5mb19oYXNoGAEgASgJUghpbmZvSGFzaBIfCgtkZX'
    'RhaWxfanNvbhgCIAEoCVIKZGV0YWlsSnNvbhIUCgVmaWxlcxgDIAMoCVIFZmlsZXM=');

@$core.Deprecated('Use deleteTorrentRequestDescriptor instead')
const DeleteTorrentRequest$json = {
  '1': 'DeleteTorrentRequest',
  '2': [
    {'1': 'info_hash', '3': 1, '4': 1, '5': 9, '10': 'infoHash'},
  ],
};

/// Descriptor for `DeleteTorrentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteTorrentRequestDescriptor =
    $convert.base64Decode(
        'ChREZWxldGVUb3JyZW50UmVxdWVzdBIbCglpbmZvX2hhc2gYASABKAlSCGluZm9IYXNo');

@$core.Deprecated('Use deleteTorrentResponseDescriptor instead')
const DeleteTorrentResponse$json = {
  '1': 'DeleteTorrentResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `DeleteTorrentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteTorrentResponseDescriptor =
    $convert.base64Decode(
        'ChVEZWxldGVUb3JyZW50UmVzcG9uc2USGAoHbWVzc2FnZRgBIAEoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use addMagnetRequestDescriptor instead')
const AddMagnetRequest$json = {
  '1': 'AddMagnetRequest',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `AddMagnetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addMagnetRequestDescriptor =
    $convert.base64Decode('ChBBZGRNYWduZXRSZXF1ZXN0EhAKA3VybBgBIAEoCVIDdXJs');

@$core.Deprecated('Use addMagnetResponseDescriptor instead')
const AddMagnetResponse$json = {
  '1': 'AddMagnetResponse',
  '2': [
    {'1': 'info_hash', '3': 1, '4': 1, '5': 9, '10': 'infoHash'},
    {'1': 'detail_json', '3': 2, '4': 1, '5': 9, '10': 'detailJson'},
    {'1': 'files', '3': 3, '4': 3, '5': 9, '10': 'files'},
  ],
};

/// Descriptor for `AddMagnetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addMagnetResponseDescriptor = $convert.base64Decode(
    'ChFBZGRNYWduZXRSZXNwb25zZRIbCglpbmZvX2hhc2gYASABKAlSCGluZm9IYXNoEh8KC2RldG'
    'FpbF9qc29uGAIgASgJUgpkZXRhaWxKc29uEhQKBWZpbGVzGAMgAygJUgVmaWxlcw==');

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

@$core.Deprecated('Use setCookieRequestDescriptor instead')
const SetCookieRequest$json = {
  '1': 'SetCookieRequest',
  '2': [
    {'1': 'cookie', '3': 1, '4': 1, '5': 9, '10': 'cookie'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `SetCookieRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setCookieRequestDescriptor = $convert.base64Decode(
    'ChBTZXRDb29raWVSZXF1ZXN0EhYKBmNvb2tpZRgBIAEoCVIGY29va2llEhAKA3VybBgCIAEoCV'
    'IDdXJs');

@$core.Deprecated('Use setCookieResponseDescriptor instead')
const SetCookieResponse$json = {
  '1': 'SetCookieResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `SetCookieResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setCookieResponseDescriptor = $convert.base64Decode(
    'ChFTZXRDb29raWVSZXNwb25zZRIYCgdtZXNzYWdlGAEgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use detailDescriptor instead')
const Detail$json = {
  '1': 'Detail',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'title', '17': true},
    {'1': 'cover', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'cover', '17': true},
    {'1': 'desc', '3': 4, '4': 1, '5': 9, '9': 2, '10': 'desc', '17': true},
    {'1': 'detail_url', '3': 5, '4': 1, '5': 9, '10': 'detailUrl'},
    {'1': 'package', '3': 6, '4': 1, '5': 9, '10': 'package'},
    {'1': 'downloaded', '3': 7, '4': 3, '5': 9, '10': 'downloaded'},
    {
      '1': 'episodes',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'episodes',
      '17': true
    },
    {
      '1': 'headers',
      '3': 9,
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

/// Descriptor for `Detail`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detailDescriptor = $convert.base64Decode(
    'CgZEZXRhaWwSDgoCaWQYASABKAVSAmlkEhkKBXRpdGxlGAIgASgJSABSBXRpdGxliAEBEhkKBW'
    'NvdmVyGAMgASgJSAFSBWNvdmVyiAEBEhcKBGRlc2MYBCABKAlIAlIEZGVzY4gBARIdCgpkZXRh'
    'aWxfdXJsGAUgASgJUglkZXRhaWxVcmwSGAoHcGFja2FnZRgGIAEoCVIHcGFja2FnZRIeCgpkb3'
    'dubG9hZGVkGAcgAygJUgpkb3dubG9hZGVkEh8KCGVwaXNvZGVzGAggASgJSANSCGVwaXNvZGVz'
    'iAEBEh0KB2hlYWRlcnMYCSABKAlIBFIHaGVhZGVyc4gBAUIICgZfdGl0bGVCCAoGX2NvdmVyQg'
    'cKBV9kZXNjQgsKCV9lcGlzb2Rlc0IKCghfaGVhZGVycw==');

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
