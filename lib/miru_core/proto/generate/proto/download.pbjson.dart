// This is a generated file - do not edit.
//
// Generated from proto/download.proto.

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

@$core.Deprecated('Use downloadRequestDescriptor instead')
const DownloadRequest$json = {
  '1': 'DownloadRequest',
  '2': [
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'download_path', '3': 2, '4': 1, '5': 9, '10': 'downloadPath'},
    {
      '1': 'headers',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.miru.DownloadRequest.HeadersEntry',
      '10': 'headers'
    },
    {'1': 'media_type', '3': 4, '4': 1, '5': 9, '10': 'mediaType'},
    {'1': 'package', '3': 5, '4': 1, '5': 9, '10': 'package'},
    {'1': 'key', '3': 6, '4': 1, '5': 9, '10': 'key'},
    {'1': 'title', '3': 7, '4': 1, '5': 9, '10': 'title'},
    {'1': 'detail_url', '3': 8, '4': 1, '5': 9, '10': 'detailUrl'},
    {'1': 'watch_url', '3': 9, '4': 1, '5': 9, '10': 'watchUrl'},
  ],
  '3': [DownloadRequest_HeadersEntry$json],
};

@$core.Deprecated('Use downloadRequestDescriptor instead')
const DownloadRequest_HeadersEntry$json = {
  '1': 'HeadersEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `DownloadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadRequestDescriptor = $convert.base64Decode(
    'Cg9Eb3dubG9hZFJlcXVlc3QSEAoDdXJsGAEgASgJUgN1cmwSIwoNZG93bmxvYWRfcGF0aBgCIA'
    'EoCVIMZG93bmxvYWRQYXRoEjwKB2hlYWRlcnMYAyADKAsyIi5taXJ1LkRvd25sb2FkUmVxdWVz'
    'dC5IZWFkZXJzRW50cnlSB2hlYWRlcnMSHQoKbWVkaWFfdHlwZRgEIAEoCVIJbWVkaWFUeXBlEh'
    'gKB3BhY2thZ2UYBSABKAlSB3BhY2thZ2USEAoDa2V5GAYgASgJUgNrZXkSFAoFdGl0bGUYByAB'
    'KAlSBXRpdGxlEh0KCmRldGFpbF91cmwYCCABKAlSCWRldGFpbFVybBIbCgl3YXRjaF91cmwYCS'
    'ABKAlSCHdhdGNoVXJsGjoKDEhlYWRlcnNFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1'
    'ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use downloadResponseDescriptor instead')
const DownloadResponse$json = {
  '1': 'DownloadResponse',
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

/// Descriptor for `DownloadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadResponseDescriptor = $convert.base64Decode(
    'ChBEb3dubG9hZFJlc3BvbnNlEhcKB3Rhc2tfaWQYASABKAVSBnRhc2tJZBJCCg92YXJpYW50X3'
    'N1bW1hcnkYAiADKAsyGS5taXJ1LkF2YWlsYWJsZUhsc1ZhcmlhbnRSDnZhcmlhbnRTdW1tYXJ5'
    'EiUKDmlzX2Rvd25sb2FkaW5nGAMgASgIUg1pc0Rvd25sb2FkaW5n');

@$core.Deprecated('Use getAllDownloadsRequestDescriptor instead')
const GetAllDownloadsRequest$json = {
  '1': 'GetAllDownloadsRequest',
  '2': [
    {'1': 'page', '3': 1, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
  ],
};

/// Descriptor for `GetAllDownloadsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAllDownloadsRequestDescriptor =
    $convert.base64Decode(
        'ChZHZXRBbGxEb3dubG9hZHNSZXF1ZXN0EhIKBHBhZ2UYASABKAVSBHBhZ2USGwoJcGFnZV9zaX'
        'plGAIgASgFUghwYWdlU2l6ZQ==');

@$core.Deprecated('Use getAllDownloadsResponseDescriptor instead')
const GetAllDownloadsResponse$json = {
  '1': 'GetAllDownloadsResponse',
  '2': [
    {
      '1': 'downloads',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.Download',
      '10': 'downloads'
    },
  ],
};

/// Descriptor for `GetAllDownloadsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAllDownloadsResponseDescriptor =
    $convert.base64Decode(
        'ChdHZXRBbGxEb3dubG9hZHNSZXNwb25zZRIsCglkb3dubG9hZHMYASADKAsyDi5taXJ1LkRvd2'
        '5sb2FkUglkb3dubG9hZHM=');

@$core.Deprecated('Use deleteDownloadRequestDescriptor instead')
const DeleteDownloadRequest$json = {
  '1': 'DeleteDownloadRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
  ],
};

/// Descriptor for `DeleteDownloadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteDownloadRequestDescriptor = $convert
    .base64Decode('ChVEZWxldGVEb3dubG9hZFJlcXVlc3QSDgoCaWQYASABKAVSAmlk');

@$core.Deprecated('Use deleteDownloadResponseDescriptor instead')
const DeleteDownloadResponse$json = {
  '1': 'DeleteDownloadResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `DeleteDownloadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteDownloadResponseDescriptor =
    $convert.base64Decode(
        'ChZEZWxldGVEb3dubG9hZFJlc3BvbnNlEhgKB21lc3NhZ2UYASABKAlSB21lc3NhZ2U=');

@$core.Deprecated(
    'Use getDownloadsByPackageAndDetailUrlRequestDescriptor instead')
const GetDownloadsByPackageAndDetailUrlRequest$json = {
  '1': 'GetDownloadsByPackageAndDetailUrlRequest',
  '2': [
    {'1': 'package', '3': 1, '4': 1, '5': 9, '10': 'package'},
    {'1': 'detail_url', '3': 2, '4': 1, '5': 9, '10': 'detailUrl'},
  ],
};

/// Descriptor for `GetDownloadsByPackageAndDetailUrlRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDownloadsByPackageAndDetailUrlRequestDescriptor =
    $convert.base64Decode(
        'CihHZXREb3dubG9hZHNCeVBhY2thZ2VBbmREZXRhaWxVcmxSZXF1ZXN0EhgKB3BhY2thZ2UYAS'
        'ABKAlSB3BhY2thZ2USHQoKZGV0YWlsX3VybBgCIAEoCVIJZGV0YWlsVXJs');

@$core.Deprecated(
    'Use getDownloadsByPackageAndDetailUrlResponseDescriptor instead')
const GetDownloadsByPackageAndDetailUrlResponse$json = {
  '1': 'GetDownloadsByPackageAndDetailUrlResponse',
  '2': [
    {
      '1': 'downloads',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.Download',
      '10': 'downloads'
    },
  ],
};

/// Descriptor for `GetDownloadsByPackageAndDetailUrlResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List
    getDownloadsByPackageAndDetailUrlResponseDescriptor = $convert.base64Decode(
        'CilHZXREb3dubG9hZHNCeVBhY2thZ2VBbmREZXRhaWxVcmxSZXNwb25zZRIsCglkb3dubG9hZH'
        'MYASADKAsyDi5taXJ1LkRvd25sb2FkUglkb3dubG9hZHM=');

@$core.Deprecated(
    'Use getDownloadByPackageWatchUrlDetailUrlRequestDescriptor instead')
const GetDownloadByPackageWatchUrlDetailUrlRequest$json = {
  '1': 'GetDownloadByPackageWatchUrlDetailUrlRequest',
  '2': [
    {'1': 'package', '3': 1, '4': 1, '5': 9, '10': 'package'},
    {'1': 'watch_url', '3': 2, '4': 1, '5': 9, '10': 'watchUrl'},
    {'1': 'detail_url', '3': 3, '4': 1, '5': 9, '10': 'detailUrl'},
  ],
};

/// Descriptor for `GetDownloadByPackageWatchUrlDetailUrlRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List
    getDownloadByPackageWatchUrlDetailUrlRequestDescriptor =
    $convert.base64Decode(
        'CixHZXREb3dubG9hZEJ5UGFja2FnZVdhdGNoVXJsRGV0YWlsVXJsUmVxdWVzdBIYCgdwYWNrYW'
        'dlGAEgASgJUgdwYWNrYWdlEhsKCXdhdGNoX3VybBgCIAEoCVIId2F0Y2hVcmwSHQoKZGV0YWls'
        'X3VybBgDIAEoCVIJZGV0YWlsVXJs');

@$core.Deprecated(
    'Use getDownloadByPackageWatchUrlDetailUrlResponseDescriptor instead')
const GetDownloadByPackageWatchUrlDetailUrlResponse$json = {
  '1': 'GetDownloadByPackageWatchUrlDetailUrlResponse',
  '2': [
    {
      '1': 'download',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.miru.Download',
      '10': 'download'
    },
  ],
};

/// Descriptor for `GetDownloadByPackageWatchUrlDetailUrlResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List
    getDownloadByPackageWatchUrlDetailUrlResponseDescriptor =
    $convert.base64Decode(
        'Ci1HZXREb3dubG9hZEJ5UGFja2FnZVdhdGNoVXJsRGV0YWlsVXJsUmVzcG9uc2USKgoIZG93bm'
        'xvYWQYASABKAsyDi5taXJ1LkRvd25sb2FkUghkb3dubG9hZA==');

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
    {'1': 'url', '3': 1, '4': 1, '5': 9, '10': 'url'},
    {'1': 'package', '3': 2, '4': 1, '5': 9, '10': 'package'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
  ],
};

/// Descriptor for `AddTorrentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addTorrentRequestDescriptor = $convert.base64Decode(
    'ChFBZGRUb3JyZW50UmVxdWVzdBIQCgN1cmwYASABKAlSA3VybBIYCgdwYWNrYWdlGAIgASgJUg'
    'dwYWNrYWdlEhQKBXRpdGxlGAMgASgJUgV0aXRsZQ==');

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
    {'1': 'package', '3': 2, '4': 1, '5': 9, '10': 'package'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
  ],
};

/// Descriptor for `AddMagnetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addMagnetRequestDescriptor = $convert.base64Decode(
    'ChBBZGRNYWduZXRSZXF1ZXN0EhAKA3VybBgBIAEoCVIDdXJsEhgKB3BhY2thZ2UYAiABKAlSB3'
    'BhY2thZ2USFAoFdGl0bGUYAyABKAlSBXRpdGxl');

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

@$core.Deprecated('Use updateDownloadStatusRequestDescriptor instead')
const UpdateDownloadStatusRequest$json = {
  '1': 'UpdateDownloadStatusRequest',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 5, '10': 'taskId'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
    {
      '1': 'save_path',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'savePath',
      '17': true
    },
  ],
  '8': [
    {'1': '_save_path'},
  ],
};

/// Descriptor for `UpdateDownloadStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateDownloadStatusRequestDescriptor =
    $convert.base64Decode(
        'ChtVcGRhdGVEb3dubG9hZFN0YXR1c1JlcXVlc3QSFwoHdGFza19pZBgBIAEoBVIGdGFza0lkEh'
        'YKBnN0YXR1cxgCIAEoCVIGc3RhdHVzEiAKCXNhdmVfcGF0aBgDIAEoCUgAUghzYXZlUGF0aIgB'
        'AUIMCgpfc2F2ZV9wYXRo');

@$core.Deprecated('Use updateDownloadStatusResponseDescriptor instead')
const UpdateDownloadStatusResponse$json = {
  '1': 'UpdateDownloadStatusResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `UpdateDownloadStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateDownloadStatusResponseDescriptor =
    $convert.base64Decode(
        'ChxVcGRhdGVEb3dubG9hZFN0YXR1c1Jlc3BvbnNlEhgKB21lc3NhZ2UYASABKAlSB21lc3NhZ2'
        'U=');
