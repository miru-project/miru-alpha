// This is a generated file - do not edit.
//
// Generated from proto/download.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Dow
class GetDownloadStatusRequest extends $pb.GeneratedMessage {
  factory GetDownloadStatusRequest() => create();

  GetDownloadStatusRequest._();

  factory GetDownloadStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDownloadStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDownloadStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadStatusRequest copyWith(
          void Function(GetDownloadStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetDownloadStatusRequest))
          as GetDownloadStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDownloadStatusRequest create() => GetDownloadStatusRequest._();
  @$core.override
  GetDownloadStatusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDownloadStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDownloadStatusRequest>(create);
  static GetDownloadStatusRequest? _defaultInstance;
}

class GetDownloadStatusResponse extends $pb.GeneratedMessage {
  factory GetDownloadStatusResponse({
    $core.Iterable<$core.MapEntry<$core.int, $1.DownloadProgress>>?
        downloadStatus,
  }) {
    final result = create();
    if (downloadStatus != null)
      result.downloadStatus.addEntries(downloadStatus);
    return result;
  }

  GetDownloadStatusResponse._();

  factory GetDownloadStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDownloadStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDownloadStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..m<$core.int, $1.DownloadProgress>(
        1, _omitFieldNames ? '' : 'downloadStatus',
        entryClassName: 'GetDownloadStatusResponse.DownloadStatusEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: $1.DownloadProgress.create,
        valueDefaultOrMaker: $1.DownloadProgress.getDefault,
        packageName: const $pb.PackageName('miru'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadStatusResponse copyWith(
          void Function(GetDownloadStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetDownloadStatusResponse))
          as GetDownloadStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDownloadStatusResponse create() => GetDownloadStatusResponse._();
  @$core.override
  GetDownloadStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDownloadStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDownloadStatusResponse>(create);
  static GetDownloadStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.int, $1.DownloadProgress> get downloadStatus => $_getMap(0);
}

class CancelDownloadRequest extends $pb.GeneratedMessage {
  factory CancelDownloadRequest({
    $core.int? taskId,
  }) {
    final result = create();
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  CancelDownloadRequest._();

  factory CancelDownloadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CancelDownloadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CancelDownloadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelDownloadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelDownloadRequest copyWith(
          void Function(CancelDownloadRequest) updates) =>
      super.copyWith((message) => updates(message as CancelDownloadRequest))
          as CancelDownloadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelDownloadRequest create() => CancelDownloadRequest._();
  @$core.override
  CancelDownloadRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CancelDownloadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelDownloadRequest>(create);
  static CancelDownloadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get taskId => $_getIZ(0);
  @$pb.TagNumber(1)
  set taskId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskId() => $_clearField(1);
}

class CancelDownloadResponse extends $pb.GeneratedMessage {
  factory CancelDownloadResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  CancelDownloadResponse._();

  factory CancelDownloadResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CancelDownloadResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CancelDownloadResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelDownloadResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelDownloadResponse copyWith(
          void Function(CancelDownloadResponse) updates) =>
      super.copyWith((message) => updates(message as CancelDownloadResponse))
          as CancelDownloadResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelDownloadResponse create() => CancelDownloadResponse._();
  @$core.override
  CancelDownloadResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CancelDownloadResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelDownloadResponse>(create);
  static CancelDownloadResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

class ResumeDownloadRequest extends $pb.GeneratedMessage {
  factory ResumeDownloadRequest({
    $core.int? taskId,
  }) {
    final result = create();
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  ResumeDownloadRequest._();

  factory ResumeDownloadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResumeDownloadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResumeDownloadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResumeDownloadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResumeDownloadRequest copyWith(
          void Function(ResumeDownloadRequest) updates) =>
      super.copyWith((message) => updates(message as ResumeDownloadRequest))
          as ResumeDownloadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResumeDownloadRequest create() => ResumeDownloadRequest._();
  @$core.override
  ResumeDownloadRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResumeDownloadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResumeDownloadRequest>(create);
  static ResumeDownloadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get taskId => $_getIZ(0);
  @$pb.TagNumber(1)
  set taskId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskId() => $_clearField(1);
}

class ResumeDownloadResponse extends $pb.GeneratedMessage {
  factory ResumeDownloadResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  ResumeDownloadResponse._();

  factory ResumeDownloadResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResumeDownloadResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResumeDownloadResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResumeDownloadResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResumeDownloadResponse copyWith(
          void Function(ResumeDownloadResponse) updates) =>
      super.copyWith((message) => updates(message as ResumeDownloadResponse))
          as ResumeDownloadResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResumeDownloadResponse create() => ResumeDownloadResponse._();
  @$core.override
  ResumeDownloadResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResumeDownloadResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResumeDownloadResponse>(create);
  static ResumeDownloadResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

class PauseDownloadRequest extends $pb.GeneratedMessage {
  factory PauseDownloadRequest({
    $core.int? taskId,
  }) {
    final result = create();
    if (taskId != null) result.taskId = taskId;
    return result;
  }

  PauseDownloadRequest._();

  factory PauseDownloadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PauseDownloadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PauseDownloadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'taskId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PauseDownloadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PauseDownloadRequest copyWith(void Function(PauseDownloadRequest) updates) =>
      super.copyWith((message) => updates(message as PauseDownloadRequest))
          as PauseDownloadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PauseDownloadRequest create() => PauseDownloadRequest._();
  @$core.override
  PauseDownloadRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PauseDownloadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PauseDownloadRequest>(create);
  static PauseDownloadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get taskId => $_getIZ(0);
  @$pb.TagNumber(1)
  set taskId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskId() => $_clearField(1);
}

class PauseDownloadResponse extends $pb.GeneratedMessage {
  factory PauseDownloadResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  PauseDownloadResponse._();

  factory PauseDownloadResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PauseDownloadResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PauseDownloadResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PauseDownloadResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PauseDownloadResponse copyWith(
          void Function(PauseDownloadResponse) updates) =>
      super.copyWith((message) => updates(message as PauseDownloadResponse))
          as PauseDownloadResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PauseDownloadResponse create() => PauseDownloadResponse._();
  @$core.override
  PauseDownloadResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PauseDownloadResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PauseDownloadResponse>(create);
  static PauseDownloadResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

class DownloadRequest extends $pb.GeneratedMessage {
  factory DownloadRequest({
    $core.String? url,
    $core.String? downloadPath,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? headers,
    $core.String? mediaType,
    $core.String? package,
    $core.String? key,
    $core.String? title,
    $core.String? detailUrl,
    $core.String? watchUrl,
  }) {
    final result = create();
    if (url != null) result.url = url;
    if (downloadPath != null) result.downloadPath = downloadPath;
    if (headers != null) result.headers.addEntries(headers);
    if (mediaType != null) result.mediaType = mediaType;
    if (package != null) result.package = package;
    if (key != null) result.key = key;
    if (title != null) result.title = title;
    if (detailUrl != null) result.detailUrl = detailUrl;
    if (watchUrl != null) result.watchUrl = watchUrl;
    return result;
  }

  DownloadRequest._();

  factory DownloadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DownloadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DownloadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOS(2, _omitFieldNames ? '' : 'downloadPath')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'headers',
        entryClassName: 'DownloadRequest.HeadersEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('miru'))
    ..aOS(4, _omitFieldNames ? '' : 'mediaType')
    ..aOS(5, _omitFieldNames ? '' : 'package')
    ..aOS(6, _omitFieldNames ? '' : 'key')
    ..aOS(7, _omitFieldNames ? '' : 'title')
    ..aOS(8, _omitFieldNames ? '' : 'detailUrl')
    ..aOS(9, _omitFieldNames ? '' : 'watchUrl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadRequest copyWith(void Function(DownloadRequest) updates) =>
      super.copyWith((message) => updates(message as DownloadRequest))
          as DownloadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadRequest create() => DownloadRequest._();
  @$core.override
  DownloadRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DownloadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DownloadRequest>(create);
  static DownloadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get downloadPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set downloadPath($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDownloadPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearDownloadPath() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.String> get headers => $_getMap(2);

  @$pb.TagNumber(4)
  $core.String get mediaType => $_getSZ(3);
  @$pb.TagNumber(4)
  set mediaType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMediaType() => $_has(3);
  @$pb.TagNumber(4)
  void clearMediaType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get package => $_getSZ(4);
  @$pb.TagNumber(5)
  set package($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPackage() => $_has(4);
  @$pb.TagNumber(5)
  void clearPackage() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get key => $_getSZ(5);
  @$pb.TagNumber(6)
  set key($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasKey() => $_has(5);
  @$pb.TagNumber(6)
  void clearKey() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get title => $_getSZ(6);
  @$pb.TagNumber(7)
  set title($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTitle() => $_has(6);
  @$pb.TagNumber(7)
  void clearTitle() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get detailUrl => $_getSZ(7);
  @$pb.TagNumber(8)
  set detailUrl($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDetailUrl() => $_has(7);
  @$pb.TagNumber(8)
  void clearDetailUrl() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get watchUrl => $_getSZ(8);
  @$pb.TagNumber(9)
  set watchUrl($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasWatchUrl() => $_has(8);
  @$pb.TagNumber(9)
  void clearWatchUrl() => $_clearField(9);
}

class DownloadResponse extends $pb.GeneratedMessage {
  factory DownloadResponse({
    $core.int? taskId,
    $core.Iterable<$1.AvailableHlsVariant>? variantSummary,
    $core.bool? isDownloading,
  }) {
    final result = create();
    if (taskId != null) result.taskId = taskId;
    if (variantSummary != null) result.variantSummary.addAll(variantSummary);
    if (isDownloading != null) result.isDownloading = isDownloading;
    return result;
  }

  DownloadResponse._();

  factory DownloadResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DownloadResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DownloadResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'taskId')
    ..pPM<$1.AvailableHlsVariant>(2, _omitFieldNames ? '' : 'variantSummary',
        subBuilder: $1.AvailableHlsVariant.create)
    ..aOB(3, _omitFieldNames ? '' : 'isDownloading')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadResponse copyWith(void Function(DownloadResponse) updates) =>
      super.copyWith((message) => updates(message as DownloadResponse))
          as DownloadResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadResponse create() => DownloadResponse._();
  @$core.override
  DownloadResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DownloadResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DownloadResponse>(create);
  static DownloadResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get taskId => $_getIZ(0);
  @$pb.TagNumber(1)
  set taskId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$1.AvailableHlsVariant> get variantSummary => $_getList(1);

  @$pb.TagNumber(3)
  $core.bool get isDownloading => $_getBF(2);
  @$pb.TagNumber(3)
  set isDownloading($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsDownloading() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsDownloading() => $_clearField(3);
}

class GetAllDownloadsRequest extends $pb.GeneratedMessage {
  factory GetAllDownloadsRequest({
    $core.int? page,
    $core.int? pageSize,
  }) {
    final result = create();
    if (page != null) result.page = page;
    if (pageSize != null) result.pageSize = pageSize;
    return result;
  }

  GetAllDownloadsRequest._();

  factory GetAllDownloadsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAllDownloadsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAllDownloadsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'page')
    ..aI(2, _omitFieldNames ? '' : 'pageSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllDownloadsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllDownloadsRequest copyWith(
          void Function(GetAllDownloadsRequest) updates) =>
      super.copyWith((message) => updates(message as GetAllDownloadsRequest))
          as GetAllDownloadsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAllDownloadsRequest create() => GetAllDownloadsRequest._();
  @$core.override
  GetAllDownloadsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAllDownloadsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAllDownloadsRequest>(create);
  static GetAllDownloadsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get page => $_getIZ(0);
  @$pb.TagNumber(1)
  set page($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPage() => $_has(0);
  @$pb.TagNumber(1)
  void clearPage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => $_clearField(2);
}

class GetAllDownloadsResponse extends $pb.GeneratedMessage {
  factory GetAllDownloadsResponse({
    $core.Iterable<$1.Download>? downloads,
  }) {
    final result = create();
    if (downloads != null) result.downloads.addAll(downloads);
    return result;
  }

  GetAllDownloadsResponse._();

  factory GetAllDownloadsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAllDownloadsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAllDownloadsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<$1.Download>(1, _omitFieldNames ? '' : 'downloads',
        subBuilder: $1.Download.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllDownloadsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllDownloadsResponse copyWith(
          void Function(GetAllDownloadsResponse) updates) =>
      super.copyWith((message) => updates(message as GetAllDownloadsResponse))
          as GetAllDownloadsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAllDownloadsResponse create() => GetAllDownloadsResponse._();
  @$core.override
  GetAllDownloadsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAllDownloadsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAllDownloadsResponse>(create);
  static GetAllDownloadsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.Download> get downloads => $_getList(0);
}

class DeleteDownloadRequest extends $pb.GeneratedMessage {
  factory DeleteDownloadRequest({
    $core.int? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteDownloadRequest._();

  factory DeleteDownloadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteDownloadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteDownloadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteDownloadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteDownloadRequest copyWith(
          void Function(DeleteDownloadRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteDownloadRequest))
          as DeleteDownloadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteDownloadRequest create() => DeleteDownloadRequest._();
  @$core.override
  DeleteDownloadRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteDownloadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteDownloadRequest>(create);
  static DeleteDownloadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DeleteDownloadResponse extends $pb.GeneratedMessage {
  factory DeleteDownloadResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  DeleteDownloadResponse._();

  factory DeleteDownloadResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteDownloadResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteDownloadResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteDownloadResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteDownloadResponse copyWith(
          void Function(DeleteDownloadResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteDownloadResponse))
          as DeleteDownloadResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteDownloadResponse create() => DeleteDownloadResponse._();
  @$core.override
  DeleteDownloadResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteDownloadResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteDownloadResponse>(create);
  static DeleteDownloadResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

class GetDownloadsByPackageAndDetailUrlRequest extends $pb.GeneratedMessage {
  factory GetDownloadsByPackageAndDetailUrlRequest({
    $core.String? package,
    $core.String? detailUrl,
  }) {
    final result = create();
    if (package != null) result.package = package;
    if (detailUrl != null) result.detailUrl = detailUrl;
    return result;
  }

  GetDownloadsByPackageAndDetailUrlRequest._();

  factory GetDownloadsByPackageAndDetailUrlRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDownloadsByPackageAndDetailUrlRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDownloadsByPackageAndDetailUrlRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'package')
    ..aOS(2, _omitFieldNames ? '' : 'detailUrl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadsByPackageAndDetailUrlRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadsByPackageAndDetailUrlRequest copyWith(
          void Function(GetDownloadsByPackageAndDetailUrlRequest) updates) =>
      super.copyWith((message) =>
              updates(message as GetDownloadsByPackageAndDetailUrlRequest))
          as GetDownloadsByPackageAndDetailUrlRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDownloadsByPackageAndDetailUrlRequest create() =>
      GetDownloadsByPackageAndDetailUrlRequest._();
  @$core.override
  GetDownloadsByPackageAndDetailUrlRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDownloadsByPackageAndDetailUrlRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          GetDownloadsByPackageAndDetailUrlRequest>(create);
  static GetDownloadsByPackageAndDetailUrlRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get package => $_getSZ(0);
  @$pb.TagNumber(1)
  set package($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPackage() => $_has(0);
  @$pb.TagNumber(1)
  void clearPackage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get detailUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set detailUrl($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDetailUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearDetailUrl() => $_clearField(2);
}

class GetDownloadsByPackageAndDetailUrlResponse extends $pb.GeneratedMessage {
  factory GetDownloadsByPackageAndDetailUrlResponse({
    $core.Iterable<$1.Download>? downloads,
  }) {
    final result = create();
    if (downloads != null) result.downloads.addAll(downloads);
    return result;
  }

  GetDownloadsByPackageAndDetailUrlResponse._();

  factory GetDownloadsByPackageAndDetailUrlResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDownloadsByPackageAndDetailUrlResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDownloadsByPackageAndDetailUrlResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<$1.Download>(1, _omitFieldNames ? '' : 'downloads',
        subBuilder: $1.Download.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadsByPackageAndDetailUrlResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadsByPackageAndDetailUrlResponse copyWith(
          void Function(GetDownloadsByPackageAndDetailUrlResponse) updates) =>
      super.copyWith((message) =>
              updates(message as GetDownloadsByPackageAndDetailUrlResponse))
          as GetDownloadsByPackageAndDetailUrlResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDownloadsByPackageAndDetailUrlResponse create() =>
      GetDownloadsByPackageAndDetailUrlResponse._();
  @$core.override
  GetDownloadsByPackageAndDetailUrlResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDownloadsByPackageAndDetailUrlResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          GetDownloadsByPackageAndDetailUrlResponse>(create);
  static GetDownloadsByPackageAndDetailUrlResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.Download> get downloads => $_getList(0);
}

class GetDownloadByPackageWatchUrlDetailUrlRequest
    extends $pb.GeneratedMessage {
  factory GetDownloadByPackageWatchUrlDetailUrlRequest({
    $core.String? package,
    $core.String? watchUrl,
    $core.String? detailUrl,
  }) {
    final result = create();
    if (package != null) result.package = package;
    if (watchUrl != null) result.watchUrl = watchUrl;
    if (detailUrl != null) result.detailUrl = detailUrl;
    return result;
  }

  GetDownloadByPackageWatchUrlDetailUrlRequest._();

  factory GetDownloadByPackageWatchUrlDetailUrlRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDownloadByPackageWatchUrlDetailUrlRequest.fromJson(
          $core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDownloadByPackageWatchUrlDetailUrlRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'package')
    ..aOS(2, _omitFieldNames ? '' : 'watchUrl')
    ..aOS(3, _omitFieldNames ? '' : 'detailUrl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadByPackageWatchUrlDetailUrlRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadByPackageWatchUrlDetailUrlRequest copyWith(
          void Function(GetDownloadByPackageWatchUrlDetailUrlRequest)
              updates) =>
      super.copyWith((message) =>
              updates(message as GetDownloadByPackageWatchUrlDetailUrlRequest))
          as GetDownloadByPackageWatchUrlDetailUrlRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDownloadByPackageWatchUrlDetailUrlRequest create() =>
      GetDownloadByPackageWatchUrlDetailUrlRequest._();
  @$core.override
  GetDownloadByPackageWatchUrlDetailUrlRequest createEmptyInstance() =>
      create();
  @$core.pragma('dart2js:noInline')
  static GetDownloadByPackageWatchUrlDetailUrlRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          GetDownloadByPackageWatchUrlDetailUrlRequest>(create);
  static GetDownloadByPackageWatchUrlDetailUrlRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get package => $_getSZ(0);
  @$pb.TagNumber(1)
  set package($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPackage() => $_has(0);
  @$pb.TagNumber(1)
  void clearPackage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get watchUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set watchUrl($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWatchUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearWatchUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get detailUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set detailUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDetailUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearDetailUrl() => $_clearField(3);
}

class GetDownloadByPackageWatchUrlDetailUrlResponse
    extends $pb.GeneratedMessage {
  factory GetDownloadByPackageWatchUrlDetailUrlResponse({
    $1.Download? download,
  }) {
    final result = create();
    if (download != null) result.download = download;
    return result;
  }

  GetDownloadByPackageWatchUrlDetailUrlResponse._();

  factory GetDownloadByPackageWatchUrlDetailUrlResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDownloadByPackageWatchUrlDetailUrlResponse.fromJson(
          $core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDownloadByPackageWatchUrlDetailUrlResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOM<$1.Download>(1, _omitFieldNames ? '' : 'download',
        subBuilder: $1.Download.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadByPackageWatchUrlDetailUrlResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadByPackageWatchUrlDetailUrlResponse copyWith(
          void Function(GetDownloadByPackageWatchUrlDetailUrlResponse)
              updates) =>
      super.copyWith((message) =>
              updates(message as GetDownloadByPackageWatchUrlDetailUrlResponse))
          as GetDownloadByPackageWatchUrlDetailUrlResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDownloadByPackageWatchUrlDetailUrlResponse create() =>
      GetDownloadByPackageWatchUrlDetailUrlResponse._();
  @$core.override
  GetDownloadByPackageWatchUrlDetailUrlResponse createEmptyInstance() =>
      create();
  @$core.pragma('dart2js:noInline')
  static GetDownloadByPackageWatchUrlDetailUrlResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          GetDownloadByPackageWatchUrlDetailUrlResponse>(create);
  static GetDownloadByPackageWatchUrlDetailUrlResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Download get download => $_getN(0);
  @$pb.TagNumber(1)
  set download($1.Download value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDownload() => $_has(0);
  @$pb.TagNumber(1)
  void clearDownload() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Download ensureDownload() => $_ensure(0);
}

/// Torrent
class ListTorrentRequest extends $pb.GeneratedMessage {
  factory ListTorrentRequest() => create();

  ListTorrentRequest._();

  factory ListTorrentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTorrentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTorrentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTorrentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTorrentRequest copyWith(void Function(ListTorrentRequest) updates) =>
      super.copyWith((message) => updates(message as ListTorrentRequest))
          as ListTorrentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTorrentRequest create() => ListTorrentRequest._();
  @$core.override
  ListTorrentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTorrentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTorrentRequest>(create);
  static ListTorrentRequest? _defaultInstance;
}

class ListTorrentResponse extends $pb.GeneratedMessage {
  factory ListTorrentResponse({
    $core.Iterable<$1.TorrentResult>? torrents,
  }) {
    final result = create();
    if (torrents != null) result.torrents.addAll(torrents);
    return result;
  }

  ListTorrentResponse._();

  factory ListTorrentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTorrentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTorrentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<$1.TorrentResult>(1, _omitFieldNames ? '' : 'torrents',
        subBuilder: $1.TorrentResult.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTorrentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTorrentResponse copyWith(void Function(ListTorrentResponse) updates) =>
      super.copyWith((message) => updates(message as ListTorrentResponse))
          as ListTorrentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTorrentResponse create() => ListTorrentResponse._();
  @$core.override
  ListTorrentResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTorrentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTorrentResponse>(create);
  static ListTorrentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.TorrentResult> get torrents => $_getList(0);
}

class AddTorrentRequest extends $pb.GeneratedMessage {
  factory AddTorrentRequest({
    $core.String? url,
    $core.String? package,
    $core.String? title,
  }) {
    final result = create();
    if (url != null) result.url = url;
    if (package != null) result.package = package;
    if (title != null) result.title = title;
    return result;
  }

  AddTorrentRequest._();

  factory AddTorrentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddTorrentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddTorrentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOS(2, _omitFieldNames ? '' : 'package')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddTorrentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddTorrentRequest copyWith(void Function(AddTorrentRequest) updates) =>
      super.copyWith((message) => updates(message as AddTorrentRequest))
          as AddTorrentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddTorrentRequest create() => AddTorrentRequest._();
  @$core.override
  AddTorrentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddTorrentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddTorrentRequest>(create);
  static AddTorrentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get package => $_getSZ(1);
  @$pb.TagNumber(2)
  set package($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPackage() => $_has(1);
  @$pb.TagNumber(2)
  void clearPackage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);
}

class AddTorrentResponse extends $pb.GeneratedMessage {
  factory AddTorrentResponse({
    $core.String? infoHash,
    $core.String? detailJson,
    $core.Iterable<$core.String>? files,
  }) {
    final result = create();
    if (infoHash != null) result.infoHash = infoHash;
    if (detailJson != null) result.detailJson = detailJson;
    if (files != null) result.files.addAll(files);
    return result;
  }

  AddTorrentResponse._();

  factory AddTorrentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddTorrentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddTorrentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'infoHash')
    ..aOS(2, _omitFieldNames ? '' : 'detailJson')
    ..pPS(3, _omitFieldNames ? '' : 'files')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddTorrentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddTorrentResponse copyWith(void Function(AddTorrentResponse) updates) =>
      super.copyWith((message) => updates(message as AddTorrentResponse))
          as AddTorrentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddTorrentResponse create() => AddTorrentResponse._();
  @$core.override
  AddTorrentResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddTorrentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddTorrentResponse>(create);
  static AddTorrentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get infoHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set infoHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInfoHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearInfoHash() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get detailJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set detailJson($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDetailJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearDetailJson() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get files => $_getList(2);
}

class DeleteTorrentRequest extends $pb.GeneratedMessage {
  factory DeleteTorrentRequest({
    $core.String? infoHash,
  }) {
    final result = create();
    if (infoHash != null) result.infoHash = infoHash;
    return result;
  }

  DeleteTorrentRequest._();

  factory DeleteTorrentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteTorrentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteTorrentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'infoHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTorrentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTorrentRequest copyWith(void Function(DeleteTorrentRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteTorrentRequest))
          as DeleteTorrentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteTorrentRequest create() => DeleteTorrentRequest._();
  @$core.override
  DeleteTorrentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteTorrentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteTorrentRequest>(create);
  static DeleteTorrentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get infoHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set infoHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInfoHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearInfoHash() => $_clearField(1);
}

class DeleteTorrentResponse extends $pb.GeneratedMessage {
  factory DeleteTorrentResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  DeleteTorrentResponse._();

  factory DeleteTorrentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteTorrentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteTorrentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTorrentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTorrentResponse copyWith(
          void Function(DeleteTorrentResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteTorrentResponse))
          as DeleteTorrentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteTorrentResponse create() => DeleteTorrentResponse._();
  @$core.override
  DeleteTorrentResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteTorrentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteTorrentResponse>(create);
  static DeleteTorrentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

class AddMagnetRequest extends $pb.GeneratedMessage {
  factory AddMagnetRequest({
    $core.String? url,
    $core.String? package,
    $core.String? title,
  }) {
    final result = create();
    if (url != null) result.url = url;
    if (package != null) result.package = package;
    if (title != null) result.title = title;
    return result;
  }

  AddMagnetRequest._();

  factory AddMagnetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddMagnetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddMagnetRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOS(2, _omitFieldNames ? '' : 'package')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMagnetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMagnetRequest copyWith(void Function(AddMagnetRequest) updates) =>
      super.copyWith((message) => updates(message as AddMagnetRequest))
          as AddMagnetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddMagnetRequest create() => AddMagnetRequest._();
  @$core.override
  AddMagnetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddMagnetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddMagnetRequest>(create);
  static AddMagnetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get package => $_getSZ(1);
  @$pb.TagNumber(2)
  set package($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPackage() => $_has(1);
  @$pb.TagNumber(2)
  void clearPackage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);
}

class AddMagnetResponse extends $pb.GeneratedMessage {
  factory AddMagnetResponse({
    $core.String? infoHash,
    $core.String? detailJson,
    $core.Iterable<$core.String>? files,
  }) {
    final result = create();
    if (infoHash != null) result.infoHash = infoHash;
    if (detailJson != null) result.detailJson = detailJson;
    if (files != null) result.files.addAll(files);
    return result;
  }

  AddMagnetResponse._();

  factory AddMagnetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddMagnetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddMagnetResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'infoHash')
    ..aOS(2, _omitFieldNames ? '' : 'detailJson')
    ..pPS(3, _omitFieldNames ? '' : 'files')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMagnetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMagnetResponse copyWith(void Function(AddMagnetResponse) updates) =>
      super.copyWith((message) => updates(message as AddMagnetResponse))
          as AddMagnetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddMagnetResponse create() => AddMagnetResponse._();
  @$core.override
  AddMagnetResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddMagnetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddMagnetResponse>(create);
  static AddMagnetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get infoHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set infoHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInfoHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearInfoHash() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get detailJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set detailJson($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDetailJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearDetailJson() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get files => $_getList(2);
}

class UpdateDownloadStatusRequest extends $pb.GeneratedMessage {
  factory UpdateDownloadStatusRequest({
    $core.int? taskId,
    $core.String? status,
    $core.String? savePath,
  }) {
    final result = create();
    if (taskId != null) result.taskId = taskId;
    if (status != null) result.status = status;
    if (savePath != null) result.savePath = savePath;
    return result;
  }

  UpdateDownloadStatusRequest._();

  factory UpdateDownloadStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateDownloadStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateDownloadStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'taskId')
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..aOS(3, _omitFieldNames ? '' : 'savePath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateDownloadStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateDownloadStatusRequest copyWith(
          void Function(UpdateDownloadStatusRequest) updates) =>
      super.copyWith(
              (message) => updates(message as UpdateDownloadStatusRequest))
          as UpdateDownloadStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateDownloadStatusRequest create() =>
      UpdateDownloadStatusRequest._();
  @$core.override
  UpdateDownloadStatusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateDownloadStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateDownloadStatusRequest>(create);
  static UpdateDownloadStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get taskId => $_getIZ(0);
  @$pb.TagNumber(1)
  set taskId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get savePath => $_getSZ(2);
  @$pb.TagNumber(3)
  set savePath($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSavePath() => $_has(2);
  @$pb.TagNumber(3)
  void clearSavePath() => $_clearField(3);
}

class UpdateDownloadStatusResponse extends $pb.GeneratedMessage {
  factory UpdateDownloadStatusResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  UpdateDownloadStatusResponse._();

  factory UpdateDownloadStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateDownloadStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateDownloadStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateDownloadStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateDownloadStatusResponse copyWith(
          void Function(UpdateDownloadStatusResponse) updates) =>
      super.copyWith(
              (message) => updates(message as UpdateDownloadStatusResponse))
          as UpdateDownloadStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateDownloadStatusResponse create() =>
      UpdateDownloadStatusResponse._();
  @$core.override
  UpdateDownloadStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateDownloadStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateDownloadStatusResponse>(create);
  static UpdateDownloadStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
