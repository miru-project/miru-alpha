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

/// Content category used for storage grouping of downloads. The enum value
/// names are lower-case and match the stored ent column strings (unspecified /
/// video / manga / novel), so the wire string form can be passed through to the
/// database without any mapping conversion.
class DownloadCategory extends $pb.ProtobufEnum {
  /// Unspecified / unknown category.
  static const DownloadCategory unspecified =
      DownloadCategory._(0, _omitEnumNames ? '' : 'unspecified');

  /// Video content (e.g. bangumi).
  static const DownloadCategory video =
      DownloadCategory._(1, _omitEnumNames ? '' : 'video');

  /// Manga / comic content.
  static const DownloadCategory manga =
      DownloadCategory._(2, _omitEnumNames ? '' : 'manga');

  /// Text novel / fiction content (fikushon).
  static const DownloadCategory novel =
      DownloadCategory._(3, _omitEnumNames ? '' : 'novel');

  static const $core.List<DownloadCategory> values = <DownloadCategory>[
    unspecified,
    video,
    manga,
    novel,
  ];

  static final $core.List<DownloadCategory?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static DownloadCategory? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DownloadCategory._(super.value, super.name);
}

/// Transport/media type of a download. The enum value names are lower-case and
/// match the stored ent column strings (unspecified / hls / mp4 / torrent /
/// magnet), so the wire string form can be passed through to the database
/// without any mapping conversion.
class DownloadMediaType extends $pb.ProtobufEnum {
  /// Unspecified / unknown media type. Backend will infer it from the URL.
  static const DownloadMediaType media_type_unspecified =
      DownloadMediaType._(0, _omitEnumNames ? '' : 'media_type_unspecified');

  /// HTTP Live Streaming (m3u8).
  static const DownloadMediaType hls =
      DownloadMediaType._(1, _omitEnumNames ? '' : 'hls');

  /// Direct MP4 (or other single-file) download.
  static const DownloadMediaType mp4 =
      DownloadMediaType._(2, _omitEnumNames ? '' : 'mp4');

  /// Torrent file (single file from the torrent).
  static const DownloadMediaType torrent =
      DownloadMediaType._(3, _omitEnumNames ? '' : 'torrent');

  /// Magnet link (single file from the torrent).
  static const DownloadMediaType magnet =
      DownloadMediaType._(4, _omitEnumNames ? '' : 'magnet');

  static const $core.List<DownloadMediaType> values = <DownloadMediaType>[
    media_type_unspecified,
    hls,
    mp4,
    torrent,
    magnet,
  ];

  static final $core.List<DownloadMediaType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static DownloadMediaType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DownloadMediaType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
