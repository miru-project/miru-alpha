// This is a generated file - do not edit.
//
// Generated from proto/events.proto.

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

@$core.Deprecated('Use watchEventsRequestDescriptor instead')
const WatchEventsRequest$json = {
  '1': 'WatchEventsRequest',
};

/// Descriptor for `WatchEventsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchEventsRequestDescriptor =
    $convert.base64Decode('ChJXYXRjaEV2ZW50c1JlcXVlc3Q=');

@$core.Deprecated('Use watchEventsResponseDescriptor instead')
const WatchEventsResponse$json = {
  '1': 'WatchEventsResponse',
  '2': [
    {
      '1': 'download_event',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.miru.DownloadEvent',
      '9': 0,
      '10': 'downloadEvent'
    },
    {
      '1': 'extension_event',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.miru.ExtensionEvent',
      '9': 0,
      '10': 'extensionEvent'
    },
    {
      '1': 'history_event',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.miru.HistoryEvent',
      '9': 0,
      '10': 'historyEvent'
    },
    {
      '1': 'dev_log_event',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.miru.DevLogEvent',
      '9': 0,
      '10': 'devLogEvent'
    },
    {
      '1': 'dev_network_event',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.miru.DevNetworkEvent',
      '9': 0,
      '10': 'devNetworkEvent'
    },
  ],
  '8': [
    {'1': 'event'},
  ],
};

/// Descriptor for `WatchEventsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchEventsResponseDescriptor = $convert.base64Decode(
    'ChNXYXRjaEV2ZW50c1Jlc3BvbnNlEjwKDmRvd25sb2FkX2V2ZW50GAEgASgLMhMubWlydS5Eb3'
    'dubG9hZEV2ZW50SABSDWRvd25sb2FkRXZlbnQSPwoPZXh0ZW5zaW9uX2V2ZW50GAIgASgLMhQu'
    'bWlydS5FeHRlbnNpb25FdmVudEgAUg5leHRlbnNpb25FdmVudBI5Cg1oaXN0b3J5X2V2ZW50GA'
    'MgASgLMhIubWlydS5IaXN0b3J5RXZlbnRIAFIMaGlzdG9yeUV2ZW50EjcKDWRldl9sb2dfZXZl'
    'bnQYBCABKAsyES5taXJ1LkRldkxvZ0V2ZW50SABSC2RldkxvZ0V2ZW50EkMKEWRldl9uZXR3b3'
    'JrX2V2ZW50GAUgASgLMhUubWlydS5EZXZOZXR3b3JrRXZlbnRIAFIPZGV2TmV0d29ya0V2ZW50'
    'QgcKBWV2ZW50');

@$core.Deprecated('Use downloadEventDescriptor instead')
const DownloadEvent$json = {
  '1': 'DownloadEvent',
  '2': [
    {
      '1': 'download_status',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.DownloadEvent.DownloadStatusEntry',
      '10': 'downloadStatus'
    },
  ],
  '3': [DownloadEvent_DownloadStatusEntry$json],
};

@$core.Deprecated('Use downloadEventDescriptor instead')
const DownloadEvent_DownloadStatusEntry$json = {
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

/// Descriptor for `DownloadEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadEventDescriptor = $convert.base64Decode(
    'Cg1Eb3dubG9hZEV2ZW50ElAKD2Rvd25sb2FkX3N0YXR1cxgBIAMoCzInLm1pcnUuRG93bmxvYW'
    'RFdmVudC5Eb3dubG9hZFN0YXR1c0VudHJ5Ug5kb3dubG9hZFN0YXR1cxpZChNEb3dubG9hZFN0'
    'YXR1c0VudHJ5EhAKA2tleRgBIAEoBVIDa2V5EiwKBXZhbHVlGAIgASgLMhYubWlydS5Eb3dubG'
    '9hZFByb2dyZXNzUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use extensionEventDescriptor instead')
const ExtensionEvent$json = {
  '1': 'ExtensionEvent',
  '2': [
    {
      '1': 'extension_meta',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.ExtensionMeta',
      '10': 'extensionMeta'
    },
  ],
};

/// Descriptor for `ExtensionEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionEventDescriptor = $convert.base64Decode(
    'Cg5FeHRlbnNpb25FdmVudBI6Cg5leHRlbnNpb25fbWV0YRgBIAMoCzITLm1pcnUuRXh0ZW5zaW'
    '9uTWV0YVINZXh0ZW5zaW9uTWV0YQ==');

@$core.Deprecated('Use historyEventDescriptor instead')
const HistoryEvent$json = {
  '1': 'HistoryEvent',
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

/// Descriptor for `HistoryEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List historyEventDescriptor = $convert.base64Decode(
    'CgxIaXN0b3J5RXZlbnQSJwoHaGlzdG9yeRgBIAMoCzINLm1pcnUuSGlzdG9yeVIHaGlzdG9yeQ'
    '==');

@$core.Deprecated('Use devLogEventDescriptor instead')
const DevLogEvent$json = {
  '1': 'DevLogEvent',
  '2': [
    {'1': 'package', '3': 1, '4': 1, '5': 9, '10': 'package'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'level', '3': 3, '4': 1, '5': 9, '10': 'level'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `DevLogEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List devLogEventDescriptor = $convert.base64Decode(
    'CgtEZXZMb2dFdmVudBIYCgdwYWNrYWdlGAEgASgJUgdwYWNrYWdlEhgKB21lc3NhZ2UYAiABKA'
    'lSB21lc3NhZ2USFAoFbGV2ZWwYAyABKAlSBWxldmVsEhwKCXRpbWVzdGFtcBgEIAEoA1IJdGlt'
    'ZXN0YW1w');

@$core.Deprecated('Use devNetworkEventDescriptor instead')
const DevNetworkEvent$json = {
  '1': 'DevNetworkEvent',
  '2': [
    {'1': 'package', '3': 1, '4': 1, '5': 9, '10': 'package'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
    {'1': 'method', '3': 3, '4': 1, '5': 9, '10': 'method'},
    {'1': 'status', '3': 4, '4': 1, '5': 5, '10': 'status'},
    {'1': 'duration', '3': 5, '4': 1, '5': 3, '10': 'duration'},
    {'1': 'timestamp', '3': 6, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'request_headers', '3': 7, '4': 1, '5': 9, '10': 'requestHeaders'},
    {'1': 'request_body', '3': 8, '4': 1, '5': 9, '10': 'requestBody'},
    {'1': 'response_headers', '3': 9, '4': 1, '5': 9, '10': 'responseHeaders'},
    {'1': 'response_body', '3': 10, '4': 1, '5': 9, '10': 'responseBody'},
  ],
};

/// Descriptor for `DevNetworkEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List devNetworkEventDescriptor = $convert.base64Decode(
    'Cg9EZXZOZXR3b3JrRXZlbnQSGAoHcGFja2FnZRgBIAEoCVIHcGFja2FnZRIQCgN1cmwYAiABKA'
    'lSA3VybBIWCgZtZXRob2QYAyABKAlSBm1ldGhvZBIWCgZzdGF0dXMYBCABKAVSBnN0YXR1cxIa'
    'CghkdXJhdGlvbhgFIAEoA1IIZHVyYXRpb24SHAoJdGltZXN0YW1wGAYgASgDUgl0aW1lc3RhbX'
    'ASJwoPcmVxdWVzdF9oZWFkZXJzGAcgASgJUg5yZXF1ZXN0SGVhZGVycxIhCgxyZXF1ZXN0X2Jv'
    'ZHkYCCABKAlSC3JlcXVlc3RCb2R5EikKEHJlc3BvbnNlX2hlYWRlcnMYCSABKAlSD3Jlc3Bvbn'
    'NlSGVhZGVycxIjCg1yZXNwb25zZV9ib2R5GAogASgJUgxyZXNwb25zZUJvZHk=');
