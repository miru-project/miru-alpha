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
    {'1': 'title', '3': 8, '4': 1, '5': 9, '10': 'title'},
    {'1': 'package', '3': 9, '4': 1, '5': 9, '10': 'package'},
    {'1': 'key', '3': 10, '4': 1, '5': 9, '10': 'key'},
  ],
};

/// Descriptor for `DownloadProgress`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadProgressDescriptor = $convert.base64Decode(
    'ChBEb3dubG9hZFByb2dyZXNzEhoKCHByb2dyZXNzGAEgASgFUghwcm9ncmVzcxIUCgVuYW1lcx'
    'gCIAMoCVIFbmFtZXMSFAoFdG90YWwYAyABKAVSBXRvdGFsEhYKBnN0YXR1cxgEIAEoCVIGc3Rh'
    'dHVzEh0KCm1lZGlhX3R5cGUYBSABKAlSCW1lZGlhVHlwZRIvChNjdXJyZW50X2Rvd25sb2FkaW'
    '5nGAYgASgJUhJjdXJyZW50RG93bmxvYWRpbmcSFwoHdGFza19pZBgHIAEoBVIGdGFza0lkEhQK'
    'BXRpdGxlGAggASgJUgV0aXRsZRIYCgdwYWNrYWdlGAkgASgJUgdwYWNrYWdlEhAKA2tleRgKIA'
    'EoCVIDa2V5');

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
    {'1': 'media_type', '3': 8, '4': 1, '5': 9, '10': 'mediaType'},
    {'1': 'status', '3': 9, '4': 1, '5': 9, '10': 'status'},
    {'1': 'save_path', '3': 10, '4': 1, '5': 9, '10': 'savePath'},
    {'1': 'date', '3': 11, '4': 1, '5': 9, '10': 'date'},
    {'1': 'download_url', '3': 12, '4': 1, '5': 9, '10': 'downloadUrl'},
    {'1': 'detail_url', '3': 13, '4': 1, '5': 9, '10': 'detailUrl'},
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
    'IDa2V5EhQKBXRpdGxlGAcgASgJUgV0aXRsZRIdCgptZWRpYV90eXBlGAggASgJUgltZWRpYVR5'
    'cGUSFgoGc3RhdHVzGAkgASgJUgZzdGF0dXMSGwoJc2F2ZV9wYXRoGAogASgJUghzYXZlUGF0aB'
    'ISCgRkYXRlGAsgASgJUgRkYXRlEiEKDGRvd25sb2FkX3VybBgMIAEoCVILZG93bmxvYWRVcmwS'
    'HQoKZGV0YWlsX3VybBgNIAEoCVIJZGV0YWlsVXJsGjoKDEhlYWRlcnNFbnRyeRIQCgNrZXkYAS'
    'ABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

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
