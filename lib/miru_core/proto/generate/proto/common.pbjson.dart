// This is a generated file - do not edit.
//
// Generated from proto/common.proto.

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

@$core.Deprecated('Use downloadStatusDescriptor instead')
const DownloadStatus$json = {
  '1': 'DownloadStatus',
  '2': [
    {'1': 'DOWNLOADING', '2': 0},
    {'1': 'PAUSED', '2': 1},
    {'1': 'COMPLETED', '2': 2},
    {'1': 'FAILED', '2': 3},
    {'1': 'CANCELLED', '2': 4},
    {'1': 'QUEUED', '2': 5},
    {'1': 'CONVERTING', '2': 6},
  ],
};

/// Descriptor for `DownloadStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List downloadStatusDescriptor = $convert.base64Decode(
    'Cg5Eb3dubG9hZFN0YXR1cxIPCgtET1dOTE9BRElORxAAEgoKBlBBVVNFRBABEg0KCUNPTVBMRV'
    'RFRBACEgoKBkZBSUxFRBADEg0KCUNBTkNFTExFRBAEEgoKBlFVRVVFRBAFEg4KCkNPTlZFUlRJ'
    'TkcQBg==');

@$core.Deprecated('Use downloadActionDescriptor instead')
const DownloadAction$json = {
  '1': 'DownloadAction',
  '2': [
    {'1': 'PAUSE', '2': 0},
    {'1': 'RESUME', '2': 1},
    {'1': 'CANCEL', '2': 2},
  ],
};

/// Descriptor for `DownloadAction`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List downloadActionDescriptor = $convert.base64Decode(
    'Cg5Eb3dubG9hZEFjdGlvbhIJCgVQQVVTRRAAEgoKBlJFU1VNRRABEgoKBkNBTkNFTBAC');

@$core.Deprecated('Use downloadCategoryDescriptor instead')
const DownloadCategory$json = {
  '1': 'DownloadCategory',
  '2': [
    {'1': 'unspecified', '2': 0},
    {'1': 'video', '2': 1},
    {'1': 'manga', '2': 2},
    {'1': 'novel', '2': 3},
  ],
};

/// Descriptor for `DownloadCategory`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List downloadCategoryDescriptor = $convert.base64Decode(
    'ChBEb3dubG9hZENhdGVnb3J5Eg8KC3Vuc3BlY2lmaWVkEAASCQoFdmlkZW8QARIJCgVtYW5nYR'
    'ACEgkKBW5vdmVsEAM=');

@$core.Deprecated('Use downloadMediaTypeDescriptor instead')
const DownloadMediaType$json = {
  '1': 'DownloadMediaType',
  '2': [
    {'1': 'media_type_unspecified', '2': 0},
    {'1': 'hls', '2': 1},
    {'1': 'mp4', '2': 2},
    {'1': 'torrent', '2': 3},
    {'1': 'magnet', '2': 4},
  ],
};

/// Descriptor for `DownloadMediaType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List downloadMediaTypeDescriptor = $convert.base64Decode(
    'ChFEb3dubG9hZE1lZGlhVHlwZRIaChZtZWRpYV90eXBlX3Vuc3BlY2lmaWVkEAASBwoDaGxzEA'
    'ESBwoDbXA0EAISCwoHdG9ycmVudBADEgoKBm1hZ25ldBAE');

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
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.miru.DownloadStatus',
      '10': 'status'
    },
    {
      '1': 'media_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.miru.DownloadMediaType',
      '10': 'mediaType'
    },
    {
      '1': 'current_downloading',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'currentDownloading'
    },
    {'1': 'task_id', '3': 7, '4': 1, '5': 5, '10': 'taskId'},
    {'1': 'title', '3': 8, '4': 1, '5': 9, '10': 'title'},
    {'1': 'package', '3': 9, '4': 1, '5': 9, '10': 'package'},
    {'1': 'key', '3': 10, '4': 1, '5': 9, '10': 'key'},
    {'1': 'priority', '3': 11, '4': 1, '5': 5, '10': 'priority'},
    {'1': 'url', '3': 12, '4': 1, '5': 9, '10': 'url'},
    {'1': 'error', '3': 13, '4': 1, '5': 9, '10': 'error'},
    {
      '1': 'category',
      '3': 14,
      '4': 1,
      '5': 14,
      '6': '.miru.DownloadCategory',
      '10': 'category'
    },
  ],
};

/// Descriptor for `DownloadProgress`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadProgressDescriptor = $convert.base64Decode(
    'ChBEb3dubG9hZFByb2dyZXNzEhoKCHByb2dyZXNzGAEgASgFUghwcm9ncmVzcxIUCgVuYW1lcx'
    'gCIAMoCVIFbmFtZXMSFAoFdG90YWwYAyABKAVSBXRvdGFsEiwKBnN0YXR1cxgEIAEoDjIULm1p'
    'cnUuRG93bmxvYWRTdGF0dXNSBnN0YXR1cxI2CgptZWRpYV90eXBlGAUgASgOMhcubWlydS5Eb3'
    'dubG9hZE1lZGlhVHlwZVIJbWVkaWFUeXBlEi8KE2N1cnJlbnRfZG93bmxvYWRpbmcYBiABKAlS'
    'EmN1cnJlbnREb3dubG9hZGluZxIXCgd0YXNrX2lkGAcgASgFUgZ0YXNrSWQSFAoFdGl0bGUYCC'
    'ABKAlSBXRpdGxlEhgKB3BhY2thZ2UYCSABKAlSB3BhY2thZ2USEAoDa2V5GAogASgJUgNrZXkS'
    'GgoIcHJpb3JpdHkYCyABKAVSCHByaW9yaXR5EhAKA3VybBgMIAEoCVIDdXJsEhQKBWVycm9yGA'
    '0gASgJUgVlcnJvchIyCghjYXRlZ29yeRgOIAEoDjIWLm1pcnUuRG93bmxvYWRDYXRlZ29yeVII'
    'Y2F0ZWdvcnk=');

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

@$core.Deprecated('Use downloadDescriptor instead')
const Download$json = {
  '1': 'Download',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'url', '3': 2, '4': 3, '5': 9, '10': 'url'},
    {
      '1': 'headers',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.miru.Download.HeadersEntry',
      '10': 'headers'
    },
    {'1': 'package', '3': 4, '4': 1, '5': 9, '10': 'package'},
    {'1': 'progress', '3': 5, '4': 3, '5': 5, '10': 'progress'},
    {'1': 'key', '3': 6, '4': 1, '5': 9, '10': 'key'},
    {'1': 'title', '3': 7, '4': 1, '5': 9, '10': 'title'},
    {
      '1': 'media_type',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.miru.DownloadMediaType',
      '10': 'mediaType'
    },
    {
      '1': 'status',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.miru.DownloadStatus',
      '10': 'status'
    },
    {'1': 'save_path', '3': 10, '4': 1, '5': 9, '10': 'savePath'},
    {'1': 'date', '3': 11, '4': 1, '5': 9, '10': 'date'},
    {'1': 'download_url', '3': 12, '4': 1, '5': 9, '10': 'downloadUrl'},
    {'1': 'detail_url', '3': 13, '4': 1, '5': 9, '10': 'detailUrl'},
    {'1': 'priority', '3': 14, '4': 1, '5': 5, '10': 'priority'},
    {
      '1': 'category',
      '3': 15,
      '4': 1,
      '5': 14,
      '6': '.miru.DownloadCategory',
      '10': 'category'
    },
  ],
  '3': [Download_HeadersEntry$json],
};

@$core.Deprecated('Use downloadDescriptor instead')
const Download_HeadersEntry$json = {
  '1': 'HeadersEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Download`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadDescriptor = $convert.base64Decode(
    'CghEb3dubG9hZBIOCgJpZBgBIAEoBVICaWQSEAoDdXJsGAIgAygJUgN1cmwSNQoHaGVhZGVycx'
    'gDIAMoCzIbLm1pcnUuRG93bmxvYWQuSGVhZGVyc0VudHJ5UgdoZWFkZXJzEhgKB3BhY2thZ2UY'
    'BCABKAlSB3BhY2thZ2USGgoIcHJvZ3Jlc3MYBSADKAVSCHByb2dyZXNzEhAKA2tleRgGIAEoCV'
    'IDa2V5EhQKBXRpdGxlGAcgASgJUgV0aXRsZRI2CgptZWRpYV90eXBlGAggASgOMhcubWlydS5E'
    'b3dubG9hZE1lZGlhVHlwZVIJbWVkaWFUeXBlEiwKBnN0YXR1cxgJIAEoDjIULm1pcnUuRG93bm'
    'xvYWRTdGF0dXNSBnN0YXR1cxIbCglzYXZlX3BhdGgYCiABKAlSCHNhdmVQYXRoEhIKBGRhdGUY'
    'CyABKAlSBGRhdGUSIQoMZG93bmxvYWRfdXJsGAwgASgJUgtkb3dubG9hZFVybBIdCgpkZXRhaW'
    'xfdXJsGA0gASgJUglkZXRhaWxVcmwSGgoIcHJpb3JpdHkYDiABKAVSCHByaW9yaXR5EjIKCGNh'
    'dGVnb3J5GA8gASgOMhYubWlydS5Eb3dubG9hZENhdGVnb3J5UghjYXRlZ29yeRo6CgxIZWFkZX'
    'JzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

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
