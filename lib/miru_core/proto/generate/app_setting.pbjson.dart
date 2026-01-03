// This is a generated file - do not edit.
//
// Generated from app_setting.proto.

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
