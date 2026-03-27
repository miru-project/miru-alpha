// This is a generated file - do not edit.
//
// Generated from proto/extension_model.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ExtensionSettingType extends $pb.ProtobufEnum {
  static const ExtensionSettingType input =
      ExtensionSettingType._(0, _omitEnumNames ? '' : 'input');
  static const ExtensionSettingType radio =
      ExtensionSettingType._(1, _omitEnumNames ? '' : 'radio');
  static const ExtensionSettingType toggle =
      ExtensionSettingType._(2, _omitEnumNames ? '' : 'toggle');

  static const $core.List<ExtensionSettingType> values = <ExtensionSettingType>[
    input,
    radio,
    toggle,
  ];

  static final $core.List<ExtensionSettingType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ExtensionSettingType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ExtensionSettingType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
