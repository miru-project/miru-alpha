// This is a generated file - do not edit.
//
// Generated from proto/app_setting.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class AppSetting extends $pb.GeneratedMessage {
  factory AppSetting({
    $core.String? key,
    $core.String? value,
  }) {
    final result = create();
    if (key != null) result.key = key;
    if (value != null) result.value = value;
    return result;
  }

  AppSetting._();

  factory AppSetting.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AppSetting.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AppSetting',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AppSetting clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AppSetting copyWith(void Function(AppSetting) updates) =>
      super.copyWith((message) => updates(message as AppSetting)) as AppSetting;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AppSetting create() => AppSetting._();
  @$core.override
  AppSetting createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AppSetting getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AppSetting>(create);
  static AppSetting? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

class GetAppSettingRequest extends $pb.GeneratedMessage {
  factory GetAppSettingRequest() => create();

  GetAppSettingRequest._();

  factory GetAppSettingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAppSettingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAppSettingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAppSettingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAppSettingRequest copyWith(void Function(GetAppSettingRequest) updates) =>
      super.copyWith((message) => updates(message as GetAppSettingRequest))
          as GetAppSettingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAppSettingRequest create() => GetAppSettingRequest._();
  @$core.override
  GetAppSettingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAppSettingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAppSettingRequest>(create);
  static GetAppSettingRequest? _defaultInstance;
}

class GetAppSettingResponse extends $pb.GeneratedMessage {
  factory GetAppSettingResponse({
    $core.Iterable<AppSetting>? settings,
  }) {
    final result = create();
    if (settings != null) result.settings.addAll(settings);
    return result;
  }

  GetAppSettingResponse._();

  factory GetAppSettingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAppSettingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAppSettingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<AppSetting>(1, _omitFieldNames ? '' : 'settings',
        subBuilder: AppSetting.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAppSettingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAppSettingResponse copyWith(
          void Function(GetAppSettingResponse) updates) =>
      super.copyWith((message) => updates(message as GetAppSettingResponse))
          as GetAppSettingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAppSettingResponse create() => GetAppSettingResponse._();
  @$core.override
  GetAppSettingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAppSettingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAppSettingResponse>(create);
  static GetAppSettingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AppSetting> get settings => $_getList(0);
}

class SetAppSettingRequest extends $pb.GeneratedMessage {
  factory SetAppSettingRequest({
    $core.Iterable<AppSetting>? settings,
  }) {
    final result = create();
    if (settings != null) result.settings.addAll(settings);
    return result;
  }

  SetAppSettingRequest._();

  factory SetAppSettingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetAppSettingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetAppSettingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<AppSetting>(1, _omitFieldNames ? '' : 'settings',
        subBuilder: AppSetting.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAppSettingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAppSettingRequest copyWith(void Function(SetAppSettingRequest) updates) =>
      super.copyWith((message) => updates(message as SetAppSettingRequest))
          as SetAppSettingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetAppSettingRequest create() => SetAppSettingRequest._();
  @$core.override
  SetAppSettingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetAppSettingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetAppSettingRequest>(create);
  static SetAppSettingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AppSetting> get settings => $_getList(0);
}

class SetAppSettingResponse extends $pb.GeneratedMessage {
  factory SetAppSettingResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  SetAppSettingResponse._();

  factory SetAppSettingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetAppSettingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetAppSettingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAppSettingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetAppSettingResponse copyWith(
          void Function(SetAppSettingResponse) updates) =>
      super.copyWith((message) => updates(message as SetAppSettingResponse))
          as SetAppSettingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetAppSettingResponse create() => SetAppSettingResponse._();
  @$core.override
  SetAppSettingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetAppSettingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetAppSettingResponse>(create);
  static SetAppSettingResponse? _defaultInstance;

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
