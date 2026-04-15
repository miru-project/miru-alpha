// This is a generated file - do not edit.
//
// Generated from proto/extension.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'extension_model.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class SearchRequest extends $pb.GeneratedMessage {
  factory SearchRequest({
    $core.String? pkg,
    $core.String? kw,
    $core.int? page,
    $core.String? filter,
  }) {
    final result = create();
    if (pkg != null) result.pkg = pkg;
    if (kw != null) result.kw = kw;
    if (page != null) result.page = page;
    if (filter != null) result.filter = filter;
    return result;
  }

  SearchRequest._();

  factory SearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pkg')
    ..aOS(2, _omitFieldNames ? '' : 'kw')
    ..aI(3, _omitFieldNames ? '' : 'page')
    ..aOS(4, _omitFieldNames ? '' : 'filter')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchRequest copyWith(void Function(SearchRequest) updates) =>
      super.copyWith((message) => updates(message as SearchRequest))
          as SearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchRequest create() => SearchRequest._();
  @$core.override
  SearchRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchRequest>(create);
  static SearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pkg => $_getSZ(0);
  @$pb.TagNumber(1)
  set pkg($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPkg() => $_has(0);
  @$pb.TagNumber(1)
  void clearPkg() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get kw => $_getSZ(1);
  @$pb.TagNumber(2)
  set kw($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKw() => $_has(1);
  @$pb.TagNumber(2)
  void clearKw() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get page => $_getIZ(2);
  @$pb.TagNumber(3)
  set page($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPage() => $_has(2);
  @$pb.TagNumber(3)
  void clearPage() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get filter => $_getSZ(3);
  @$pb.TagNumber(4)
  set filter($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFilter() => $_has(3);
  @$pb.TagNumber(4)
  void clearFilter() => $_clearField(4);
}

class CreateFilterRequest extends $pb.GeneratedMessage {
  factory CreateFilterRequest({
    $core.String? pkg,
    $core.String? filter,
  }) {
    final result = create();
    if (pkg != null) result.pkg = pkg;
    if (filter != null) result.filter = filter;
    return result;
  }

  CreateFilterRequest._();

  factory CreateFilterRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateFilterRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateFilterRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pkg')
    ..aOS(2, _omitFieldNames ? '' : 'filter')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFilterRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFilterRequest copyWith(void Function(CreateFilterRequest) updates) =>
      super.copyWith((message) => updates(message as CreateFilterRequest))
          as CreateFilterRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateFilterRequest create() => CreateFilterRequest._();
  @$core.override
  CreateFilterRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateFilterRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateFilterRequest>(create);
  static CreateFilterRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pkg => $_getSZ(0);
  @$pb.TagNumber(1)
  set pkg($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPkg() => $_has(0);
  @$pb.TagNumber(1)
  void clearPkg() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get filter => $_getSZ(1);
  @$pb.TagNumber(2)
  set filter($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFilter() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilter() => $_clearField(2);
}

class CreateFilterResponse extends $pb.GeneratedMessage {
  factory CreateFilterResponse({
    $core.Iterable<$core.MapEntry<$core.String, $1.ExtensionFilter>>? filters,
  }) {
    final result = create();
    if (filters != null) result.filters.addEntries(filters);
    return result;
  }

  CreateFilterResponse._();

  factory CreateFilterResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateFilterResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateFilterResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..m<$core.String, $1.ExtensionFilter>(1, _omitFieldNames ? '' : 'filters',
        entryClassName: 'CreateFilterResponse.FiltersEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: $1.ExtensionFilter.create,
        valueDefaultOrMaker: $1.ExtensionFilter.getDefault,
        packageName: const $pb.PackageName('miru'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFilterResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFilterResponse copyWith(void Function(CreateFilterResponse) updates) =>
      super.copyWith((message) => updates(message as CreateFilterResponse))
          as CreateFilterResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateFilterResponse create() => CreateFilterResponse._();
  @$core.override
  CreateFilterResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateFilterResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateFilterResponse>(create);
  static CreateFilterResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, $1.ExtensionFilter> get filters => $_getMap(0);
}

class SearchResponse extends $pb.GeneratedMessage {
  factory SearchResponse({
    $core.Iterable<$1.ExtensionListItem>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  SearchResponse._();

  factory SearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<$1.ExtensionListItem>(1, _omitFieldNames ? '' : 'items',
        subBuilder: $1.ExtensionListItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchResponse copyWith(void Function(SearchResponse) updates) =>
      super.copyWith((message) => updates(message as SearchResponse))
          as SearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchResponse create() => SearchResponse._();
  @$core.override
  SearchResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchResponse>(create);
  static SearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.ExtensionListItem> get items => $_getList(0);
}

class LatestRequest extends $pb.GeneratedMessage {
  factory LatestRequest({
    $core.String? pkg,
    $core.int? page,
  }) {
    final result = create();
    if (pkg != null) result.pkg = pkg;
    if (page != null) result.page = page;
    return result;
  }

  LatestRequest._();

  factory LatestRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LatestRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LatestRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pkg')
    ..aI(2, _omitFieldNames ? '' : 'page')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LatestRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LatestRequest copyWith(void Function(LatestRequest) updates) =>
      super.copyWith((message) => updates(message as LatestRequest))
          as LatestRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LatestRequest create() => LatestRequest._();
  @$core.override
  LatestRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LatestRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LatestRequest>(create);
  static LatestRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pkg => $_getSZ(0);
  @$pb.TagNumber(1)
  set pkg($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPkg() => $_has(0);
  @$pb.TagNumber(1)
  void clearPkg() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get page => $_getIZ(1);
  @$pb.TagNumber(2)
  set page($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearPage() => $_clearField(2);
}

class LatestResponse extends $pb.GeneratedMessage {
  factory LatestResponse({
    $core.Iterable<$1.ExtensionListItem>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  LatestResponse._();

  factory LatestResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LatestResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LatestResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<$1.ExtensionListItem>(1, _omitFieldNames ? '' : 'items',
        subBuilder: $1.ExtensionListItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LatestResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LatestResponse copyWith(void Function(LatestResponse) updates) =>
      super.copyWith((message) => updates(message as LatestResponse))
          as LatestResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LatestResponse create() => LatestResponse._();
  @$core.override
  LatestResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LatestResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LatestResponse>(create);
  static LatestResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.ExtensionListItem> get items => $_getList(0);
}

class DetailRequest extends $pb.GeneratedMessage {
  factory DetailRequest({
    $core.String? pkg,
    $core.String? url,
  }) {
    final result = create();
    if (pkg != null) result.pkg = pkg;
    if (url != null) result.url = url;
    return result;
  }

  DetailRequest._();

  factory DetailRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetailRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetailRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pkg')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetailRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetailRequest copyWith(void Function(DetailRequest) updates) =>
      super.copyWith((message) => updates(message as DetailRequest))
          as DetailRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetailRequest create() => DetailRequest._();
  @$core.override
  DetailRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetailRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetailRequest>(create);
  static DetailRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pkg => $_getSZ(0);
  @$pb.TagNumber(1)
  set pkg($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPkg() => $_has(0);
  @$pb.TagNumber(1)
  void clearPkg() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);
}

class DetailResponse extends $pb.GeneratedMessage {
  factory DetailResponse({
    $1.ExtensionDetail? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  DetailResponse._();

  factory DetailResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetailResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetailResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOM<$1.ExtensionDetail>(1, _omitFieldNames ? '' : 'data',
        subBuilder: $1.ExtensionDetail.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetailResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetailResponse copyWith(void Function(DetailResponse) updates) =>
      super.copyWith((message) => updates(message as DetailResponse))
          as DetailResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetailResponse create() => DetailResponse._();
  @$core.override
  DetailResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetailResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetailResponse>(create);
  static DetailResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ExtensionDetail get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($1.ExtensionDetail value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.ExtensionDetail ensureData() => $_ensure(0);
}

class WatchRequest extends $pb.GeneratedMessage {
  factory WatchRequest({
    $core.String? pkg,
    $core.String? url,
  }) {
    final result = create();
    if (pkg != null) result.pkg = pkg;
    if (url != null) result.url = url;
    return result;
  }

  WatchRequest._();

  factory WatchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WatchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pkg')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchRequest copyWith(void Function(WatchRequest) updates) =>
      super.copyWith((message) => updates(message as WatchRequest))
          as WatchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WatchRequest create() => WatchRequest._();
  @$core.override
  WatchRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WatchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchRequest>(create);
  static WatchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pkg => $_getSZ(0);
  @$pb.TagNumber(1)
  set pkg($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPkg() => $_has(0);
  @$pb.TagNumber(1)
  void clearPkg() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);
}

class MirrorRequest extends $pb.GeneratedMessage {
  factory MirrorRequest({
    $core.String? pkg,
    $core.String? url,
  }) {
    final result = create();
    if (pkg != null) result.pkg = pkg;
    if (url != null) result.url = url;
    return result;
  }

  MirrorRequest._();

  factory MirrorRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MirrorRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MirrorRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pkg')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MirrorRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MirrorRequest copyWith(void Function(MirrorRequest) updates) =>
      super.copyWith((message) => updates(message as MirrorRequest))
          as MirrorRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MirrorRequest create() => MirrorRequest._();
  @$core.override
  MirrorRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MirrorRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MirrorRequest>(create);
  static MirrorRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pkg => $_getSZ(0);
  @$pb.TagNumber(1)
  set pkg($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPkg() => $_has(0);
  @$pb.TagNumber(1)
  void clearPkg() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);
}

enum MirrorResponse_Data { bangumi, manga, fikushon, raw, notSet }

class MirrorResponse extends $pb.GeneratedMessage {
  factory MirrorResponse({
    $1.ExtensionBangumiWatch? bangumi,
    $1.ExtensionMangaWatch? manga,
    $1.ExtensionFikushonWatch? fikushon,
    $core.String? raw,
  }) {
    final result = create();
    if (bangumi != null) result.bangumi = bangumi;
    if (manga != null) result.manga = manga;
    if (fikushon != null) result.fikushon = fikushon;
    if (raw != null) result.raw = raw;
    return result;
  }

  MirrorResponse._();

  factory MirrorResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MirrorResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, MirrorResponse_Data>
      _MirrorResponse_DataByTag = {
    1: MirrorResponse_Data.bangumi,
    2: MirrorResponse_Data.manga,
    3: MirrorResponse_Data.fikushon,
    4: MirrorResponse_Data.raw,
    0: MirrorResponse_Data.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MirrorResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4])
    ..aOM<$1.ExtensionBangumiWatch>(1, _omitFieldNames ? '' : 'bangumi',
        subBuilder: $1.ExtensionBangumiWatch.create)
    ..aOM<$1.ExtensionMangaWatch>(2, _omitFieldNames ? '' : 'manga',
        subBuilder: $1.ExtensionMangaWatch.create)
    ..aOM<$1.ExtensionFikushonWatch>(3, _omitFieldNames ? '' : 'fikushon',
        subBuilder: $1.ExtensionFikushonWatch.create)
    ..aOS(4, _omitFieldNames ? '' : 'raw')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MirrorResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MirrorResponse copyWith(void Function(MirrorResponse) updates) =>
      super.copyWith((message) => updates(message as MirrorResponse))
          as MirrorResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MirrorResponse create() => MirrorResponse._();
  @$core.override
  MirrorResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MirrorResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MirrorResponse>(create);
  static MirrorResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  MirrorResponse_Data whichData() =>
      _MirrorResponse_DataByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  void clearData() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $1.ExtensionBangumiWatch get bangumi => $_getN(0);
  @$pb.TagNumber(1)
  set bangumi($1.ExtensionBangumiWatch value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBangumi() => $_has(0);
  @$pb.TagNumber(1)
  void clearBangumi() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.ExtensionBangumiWatch ensureBangumi() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ExtensionMangaWatch get manga => $_getN(1);
  @$pb.TagNumber(2)
  set manga($1.ExtensionMangaWatch value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasManga() => $_has(1);
  @$pb.TagNumber(2)
  void clearManga() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ExtensionMangaWatch ensureManga() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.ExtensionFikushonWatch get fikushon => $_getN(2);
  @$pb.TagNumber(3)
  set fikushon($1.ExtensionFikushonWatch value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasFikushon() => $_has(2);
  @$pb.TagNumber(3)
  void clearFikushon() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.ExtensionFikushonWatch ensureFikushon() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get raw => $_getSZ(3);
  @$pb.TagNumber(4)
  set raw($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRaw() => $_has(3);
  @$pb.TagNumber(4)
  void clearRaw() => $_clearField(4);
}

enum WatchResponse_Data { bangumi, manga, fikushon, watch, raw, notSet }

class WatchResponse extends $pb.GeneratedMessage {
  factory WatchResponse({
    $1.ExtensionBangumiWatch? bangumi,
    $1.ExtensionMangaWatch? manga,
    $1.ExtensionFikushonWatch? fikushon,
    $1.ExtensionWatch? watch,
    $core.String? raw,
  }) {
    final result = create();
    if (bangumi != null) result.bangumi = bangumi;
    if (manga != null) result.manga = manga;
    if (fikushon != null) result.fikushon = fikushon;
    if (watch != null) result.watch = watch;
    if (raw != null) result.raw = raw;
    return result;
  }

  WatchResponse._();

  factory WatchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WatchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, WatchResponse_Data>
      _WatchResponse_DataByTag = {
    1: WatchResponse_Data.bangumi,
    2: WatchResponse_Data.manga,
    3: WatchResponse_Data.fikushon,
    4: WatchResponse_Data.watch,
    5: WatchResponse_Data.raw,
    0: WatchResponse_Data.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5])
    ..aOM<$1.ExtensionBangumiWatch>(1, _omitFieldNames ? '' : 'bangumi',
        subBuilder: $1.ExtensionBangumiWatch.create)
    ..aOM<$1.ExtensionMangaWatch>(2, _omitFieldNames ? '' : 'manga',
        subBuilder: $1.ExtensionMangaWatch.create)
    ..aOM<$1.ExtensionFikushonWatch>(3, _omitFieldNames ? '' : 'fikushon',
        subBuilder: $1.ExtensionFikushonWatch.create)
    ..aOM<$1.ExtensionWatch>(4, _omitFieldNames ? '' : 'watch',
        subBuilder: $1.ExtensionWatch.create)
    ..aOS(5, _omitFieldNames ? '' : 'raw')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchResponse copyWith(void Function(WatchResponse) updates) =>
      super.copyWith((message) => updates(message as WatchResponse))
          as WatchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WatchResponse create() => WatchResponse._();
  @$core.override
  WatchResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WatchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchResponse>(create);
  static WatchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  WatchResponse_Data whichData() => _WatchResponse_DataByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  void clearData() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $1.ExtensionBangumiWatch get bangumi => $_getN(0);
  @$pb.TagNumber(1)
  set bangumi($1.ExtensionBangumiWatch value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBangumi() => $_has(0);
  @$pb.TagNumber(1)
  void clearBangumi() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.ExtensionBangumiWatch ensureBangumi() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ExtensionMangaWatch get manga => $_getN(1);
  @$pb.TagNumber(2)
  set manga($1.ExtensionMangaWatch value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasManga() => $_has(1);
  @$pb.TagNumber(2)
  void clearManga() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ExtensionMangaWatch ensureManga() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.ExtensionFikushonWatch get fikushon => $_getN(2);
  @$pb.TagNumber(3)
  set fikushon($1.ExtensionFikushonWatch value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasFikushon() => $_has(2);
  @$pb.TagNumber(3)
  void clearFikushon() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.ExtensionFikushonWatch ensureFikushon() => $_ensure(2);

  @$pb.TagNumber(4)
  $1.ExtensionWatch get watch => $_getN(3);
  @$pb.TagNumber(4)
  set watch($1.ExtensionWatch value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasWatch() => $_has(3);
  @$pb.TagNumber(4)
  void clearWatch() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.ExtensionWatch ensureWatch() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.String get raw => $_getSZ(4);
  @$pb.TagNumber(5)
  set raw($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRaw() => $_has(4);
  @$pb.TagNumber(5)
  void clearRaw() => $_clearField(5);
}

/// Extension Management
class DownloadExtensionRequest extends $pb.GeneratedMessage {
  factory DownloadExtensionRequest({
    $core.String? repoUrl,
    $core.String? pkg,
  }) {
    final result = create();
    if (repoUrl != null) result.repoUrl = repoUrl;
    if (pkg != null) result.pkg = pkg;
    return result;
  }

  DownloadExtensionRequest._();

  factory DownloadExtensionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DownloadExtensionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DownloadExtensionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'repoUrl')
    ..aOS(2, _omitFieldNames ? '' : 'pkg')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadExtensionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadExtensionRequest copyWith(
          void Function(DownloadExtensionRequest) updates) =>
      super.copyWith((message) => updates(message as DownloadExtensionRequest))
          as DownloadExtensionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadExtensionRequest create() => DownloadExtensionRequest._();
  @$core.override
  DownloadExtensionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DownloadExtensionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DownloadExtensionRequest>(create);
  static DownloadExtensionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get repoUrl => $_getSZ(0);
  @$pb.TagNumber(1)
  set repoUrl($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRepoUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearRepoUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pkg => $_getSZ(1);
  @$pb.TagNumber(2)
  set pkg($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPkg() => $_has(1);
  @$pb.TagNumber(2)
  void clearPkg() => $_clearField(2);
}

class DownloadExtensionResponse extends $pb.GeneratedMessage {
  factory DownloadExtensionResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  DownloadExtensionResponse._();

  factory DownloadExtensionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DownloadExtensionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DownloadExtensionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadExtensionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadExtensionResponse copyWith(
          void Function(DownloadExtensionResponse) updates) =>
      super.copyWith((message) => updates(message as DownloadExtensionResponse))
          as DownloadExtensionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadExtensionResponse create() => DownloadExtensionResponse._();
  @$core.override
  DownloadExtensionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DownloadExtensionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DownloadExtensionResponse>(create);
  static DownloadExtensionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

class RemoveExtensionRequest extends $pb.GeneratedMessage {
  factory RemoveExtensionRequest({
    $core.String? pkg,
  }) {
    final result = create();
    if (pkg != null) result.pkg = pkg;
    return result;
  }

  RemoveExtensionRequest._();

  factory RemoveExtensionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveExtensionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveExtensionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(2, _omitFieldNames ? '' : 'pkg')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveExtensionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveExtensionRequest copyWith(
          void Function(RemoveExtensionRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveExtensionRequest))
          as RemoveExtensionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveExtensionRequest create() => RemoveExtensionRequest._();
  @$core.override
  RemoveExtensionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveExtensionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveExtensionRequest>(create);
  static RemoveExtensionRequest? _defaultInstance;

  @$pb.TagNumber(2)
  $core.String get pkg => $_getSZ(0);
  @$pb.TagNumber(2)
  set pkg($core.String value) => $_setString(0, value);
  @$pb.TagNumber(2)
  $core.bool hasPkg() => $_has(0);
  @$pb.TagNumber(2)
  void clearPkg() => $_clearField(2);
}

class RemoveExtensionResponse extends $pb.GeneratedMessage {
  factory RemoveExtensionResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  RemoveExtensionResponse._();

  factory RemoveExtensionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveExtensionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveExtensionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveExtensionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveExtensionResponse copyWith(
          void Function(RemoveExtensionResponse) updates) =>
      super.copyWith((message) => updates(message as RemoveExtensionResponse))
          as RemoveExtensionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveExtensionResponse create() => RemoveExtensionResponse._();
  @$core.override
  RemoveExtensionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveExtensionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveExtensionResponse>(create);
  static RemoveExtensionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

class GetExtensionSettingsRequest extends $pb.GeneratedMessage {
  factory GetExtensionSettingsRequest({
    $core.String? pkg,
  }) {
    final result = create();
    if (pkg != null) result.pkg = pkg;
    return result;
  }

  GetExtensionSettingsRequest._();

  factory GetExtensionSettingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetExtensionSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetExtensionSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pkg')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetExtensionSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetExtensionSettingsRequest copyWith(
          void Function(GetExtensionSettingsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetExtensionSettingsRequest))
          as GetExtensionSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetExtensionSettingsRequest create() =>
      GetExtensionSettingsRequest._();
  @$core.override
  GetExtensionSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetExtensionSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetExtensionSettingsRequest>(create);
  static GetExtensionSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pkg => $_getSZ(0);
  @$pb.TagNumber(1)
  set pkg($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPkg() => $_has(0);
  @$pb.TagNumber(1)
  void clearPkg() => $_clearField(1);
}

class GetExtensionSettingsResponse extends $pb.GeneratedMessage {
  factory GetExtensionSettingsResponse({
    $core.Iterable<$1.ExtensionSetting>? settings,
  }) {
    final result = create();
    if (settings != null) result.settings.addAll(settings);
    return result;
  }

  GetExtensionSettingsResponse._();

  factory GetExtensionSettingsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetExtensionSettingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetExtensionSettingsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<$1.ExtensionSetting>(1, _omitFieldNames ? '' : 'settings',
        subBuilder: $1.ExtensionSetting.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetExtensionSettingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetExtensionSettingsResponse copyWith(
          void Function(GetExtensionSettingsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetExtensionSettingsResponse))
          as GetExtensionSettingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetExtensionSettingsResponse create() =>
      GetExtensionSettingsResponse._();
  @$core.override
  GetExtensionSettingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetExtensionSettingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetExtensionSettingsResponse>(create);
  static GetExtensionSettingsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.ExtensionSetting> get settings => $_getList(0);
}

class SaveExtensionSettingsRequest extends $pb.GeneratedMessage {
  factory SaveExtensionSettingsRequest({
    $core.String? pkg,
    $core.Iterable<$1.ExtensionSetting>? settings,
  }) {
    final result = create();
    if (pkg != null) result.pkg = pkg;
    if (settings != null) result.settings.addAll(settings);
    return result;
  }

  SaveExtensionSettingsRequest._();

  factory SaveExtensionSettingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SaveExtensionSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SaveExtensionSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pkg')
    ..pPM<$1.ExtensionSetting>(2, _omitFieldNames ? '' : 'settings',
        subBuilder: $1.ExtensionSetting.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveExtensionSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveExtensionSettingsRequest copyWith(
          void Function(SaveExtensionSettingsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SaveExtensionSettingsRequest))
          as SaveExtensionSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SaveExtensionSettingsRequest create() =>
      SaveExtensionSettingsRequest._();
  @$core.override
  SaveExtensionSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SaveExtensionSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SaveExtensionSettingsRequest>(create);
  static SaveExtensionSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pkg => $_getSZ(0);
  @$pb.TagNumber(1)
  set pkg($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPkg() => $_has(0);
  @$pb.TagNumber(1)
  void clearPkg() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$1.ExtensionSetting> get settings => $_getList(1);
}

class SaveExtensionSettingsResponse extends $pb.GeneratedMessage {
  factory SaveExtensionSettingsResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  SaveExtensionSettingsResponse._();

  factory SaveExtensionSettingsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SaveExtensionSettingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SaveExtensionSettingsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveExtensionSettingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveExtensionSettingsResponse copyWith(
          void Function(SaveExtensionSettingsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SaveExtensionSettingsResponse))
          as SaveExtensionSettingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SaveExtensionSettingsResponse create() =>
      SaveExtensionSettingsResponse._();
  @$core.override
  SaveExtensionSettingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SaveExtensionSettingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SaveExtensionSettingsResponse>(create);
  static SaveExtensionSettingsResponse? _defaultInstance;

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
