// This is a generated file - do not edit.
//
// Generated from proto/common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class DownloadStatus extends $pb.ProtobufEnum {
  static const DownloadStatus DOWNLOADING =
      DownloadStatus._(0, _omitEnumNames ? '' : 'DOWNLOADING');
  static const DownloadStatus PAUSED =
      DownloadStatus._(1, _omitEnumNames ? '' : 'PAUSED');
  static const DownloadStatus COMPLETED =
      DownloadStatus._(2, _omitEnumNames ? '' : 'COMPLETED');
  static const DownloadStatus FAILED =
      DownloadStatus._(3, _omitEnumNames ? '' : 'FAILED');
  static const DownloadStatus CANCELLED =
      DownloadStatus._(4, _omitEnumNames ? '' : 'CANCELLED');
  static const DownloadStatus QUEUED =
      DownloadStatus._(5, _omitEnumNames ? '' : 'QUEUED');
  static const DownloadStatus CONVERTING =
      DownloadStatus._(6, _omitEnumNames ? '' : 'CONVERTING');

  static const $core.List<DownloadStatus> values = <DownloadStatus>[
    DOWNLOADING,
    PAUSED,
    COMPLETED,
    FAILED,
    CANCELLED,
    QUEUED,
    CONVERTING,
  ];

  static final $core.List<DownloadStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static DownloadStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DownloadStatus._(super.value, super.name);
}

class DownloadAction extends $pb.ProtobufEnum {
  static const DownloadAction PAUSE =
      DownloadAction._(0, _omitEnumNames ? '' : 'PAUSE');
  static const DownloadAction RESUME =
      DownloadAction._(1, _omitEnumNames ? '' : 'RESUME');
  static const DownloadAction CANCEL =
      DownloadAction._(2, _omitEnumNames ? '' : 'CANCEL');

  static const $core.List<DownloadAction> values = <DownloadAction>[
    PAUSE,
    RESUME,
    CANCEL,
  ];

  static final $core.List<DownloadAction?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static DownloadAction? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DownloadAction._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
