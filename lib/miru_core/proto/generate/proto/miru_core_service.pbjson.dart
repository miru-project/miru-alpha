// This is a generated file - do not edit.
//
// Generated from proto/miru_core_service.proto.

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
    {
      '1': 'history',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.miru.History',
      '10': 'history'
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
    'd0b3JyZW50GAMgASgLMhIubWlydS5Ub3JyZW50U3RhdHNSB3RvcnJlbnQSJwoHaGlzdG9yeRgE'
    'IAMoCzINLm1pcnUuSGlzdG9yeVIHaGlzdG9yeRpZChNEb3dubG9hZFN0YXR1c0VudHJ5EhAKA2'
    'tleRgBIAEoBVIDa2V5EiwKBXZhbHVlGAIgASgLMhYubWlydS5Eb3dubG9hZFByb2dyZXNzUgV2'
    'YWx1ZToCOAE=');
