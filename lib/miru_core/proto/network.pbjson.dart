// This is a generated file - do not edit.
//
// Generated from proto/network.proto.

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
