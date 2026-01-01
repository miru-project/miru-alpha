// This is a generated file - do not edit.
//
// Generated from proto/db.proto.

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

/// DB - Detail
class GetDetailRequest extends $pb.GeneratedMessage {
  factory GetDetailRequest({
    $core.String? package,
    $core.String? detailUrl,
  }) {
    final result = create();
    if (package != null) result.package = package;
    if (detailUrl != null) result.detailUrl = detailUrl;
    return result;
  }

  GetDetailRequest._();

  factory GetDetailRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDetailRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDetailRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'package')
    ..aOS(2, _omitFieldNames ? '' : 'detailUrl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDetailRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDetailRequest copyWith(void Function(GetDetailRequest) updates) =>
      super.copyWith((message) => updates(message as GetDetailRequest))
          as GetDetailRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDetailRequest create() => GetDetailRequest._();
  @$core.override
  GetDetailRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDetailRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDetailRequest>(create);
  static GetDetailRequest? _defaultInstance;

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

class GetDetailResponse extends $pb.GeneratedMessage {
  factory GetDetailResponse({
    $1.Detail? detail,
  }) {
    final result = create();
    if (detail != null) result.detail = detail;
    return result;
  }

  GetDetailResponse._();

  factory GetDetailResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDetailResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDetailResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOM<$1.Detail>(1, _omitFieldNames ? '' : 'detail',
        subBuilder: $1.Detail.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDetailResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDetailResponse copyWith(void Function(GetDetailResponse) updates) =>
      super.copyWith((message) => updates(message as GetDetailResponse))
          as GetDetailResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDetailResponse create() => GetDetailResponse._();
  @$core.override
  GetDetailResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDetailResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDetailResponse>(create);
  static GetDetailResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Detail get detail => $_getN(0);
  @$pb.TagNumber(1)
  set detail($1.Detail value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDetail() => $_has(0);
  @$pb.TagNumber(1)
  void clearDetail() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Detail ensureDetail() => $_ensure(0);
}

class UpsertDetailRequest extends $pb.GeneratedMessage {
  factory UpsertDetailRequest({
    $core.String? title,
    $core.String? cover,
    $core.String? desc,
    $core.String? detailUrl,
    $core.String? package,
    $core.Iterable<$core.String>? downloaded,
    $core.String? episodes,
    $core.String? headers,
  }) {
    final result = create();
    if (title != null) result.title = title;
    if (cover != null) result.cover = cover;
    if (desc != null) result.desc = desc;
    if (detailUrl != null) result.detailUrl = detailUrl;
    if (package != null) result.package = package;
    if (downloaded != null) result.downloaded.addAll(downloaded);
    if (episodes != null) result.episodes = episodes;
    if (headers != null) result.headers = headers;
    return result;
  }

  UpsertDetailRequest._();

  factory UpsertDetailRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpsertDetailRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpsertDetailRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'cover')
    ..aOS(3, _omitFieldNames ? '' : 'desc')
    ..aOS(4, _omitFieldNames ? '' : 'detailUrl')
    ..aOS(5, _omitFieldNames ? '' : 'package')
    ..pPS(6, _omitFieldNames ? '' : 'downloaded')
    ..aOS(7, _omitFieldNames ? '' : 'episodes')
    ..aOS(8, _omitFieldNames ? '' : 'headers')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpsertDetailRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpsertDetailRequest copyWith(void Function(UpsertDetailRequest) updates) =>
      super.copyWith((message) => updates(message as UpsertDetailRequest))
          as UpsertDetailRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpsertDetailRequest create() => UpsertDetailRequest._();
  @$core.override
  UpsertDetailRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpsertDetailRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpsertDetailRequest>(create);
  static UpsertDetailRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cover => $_getSZ(1);
  @$pb.TagNumber(2)
  set cover($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCover() => $_has(1);
  @$pb.TagNumber(2)
  void clearCover() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get desc => $_getSZ(2);
  @$pb.TagNumber(3)
  set desc($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDesc() => $_has(2);
  @$pb.TagNumber(3)
  void clearDesc() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get detailUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set detailUrl($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDetailUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearDetailUrl() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get package => $_getSZ(4);
  @$pb.TagNumber(5)
  set package($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPackage() => $_has(4);
  @$pb.TagNumber(5)
  void clearPackage() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get downloaded => $_getList(5);

  @$pb.TagNumber(7)
  $core.String get episodes => $_getSZ(6);
  @$pb.TagNumber(7)
  set episodes($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEpisodes() => $_has(6);
  @$pb.TagNumber(7)
  void clearEpisodes() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get headers => $_getSZ(7);
  @$pb.TagNumber(8)
  set headers($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasHeaders() => $_has(7);
  @$pb.TagNumber(8)
  void clearHeaders() => $_clearField(8);
}

class UpsertDetailResponse extends $pb.GeneratedMessage {
  factory UpsertDetailResponse({
    $1.Detail? detail,
  }) {
    final result = create();
    if (detail != null) result.detail = detail;
    return result;
  }

  UpsertDetailResponse._();

  factory UpsertDetailResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpsertDetailResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpsertDetailResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOM<$1.Detail>(1, _omitFieldNames ? '' : 'detail',
        subBuilder: $1.Detail.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpsertDetailResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpsertDetailResponse copyWith(void Function(UpsertDetailResponse) updates) =>
      super.copyWith((message) => updates(message as UpsertDetailResponse))
          as UpsertDetailResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpsertDetailResponse create() => UpsertDetailResponse._();
  @$core.override
  UpsertDetailResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpsertDetailResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpsertDetailResponse>(create);
  static UpsertDetailResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Detail get detail => $_getN(0);
  @$pb.TagNumber(1)
  set detail($1.Detail value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDetail() => $_has(0);
  @$pb.TagNumber(1)
  void clearDetail() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Detail ensureDetail() => $_ensure(0);
}

/// DB - Favorite
class GetAllFavoriteRequest extends $pb.GeneratedMessage {
  factory GetAllFavoriteRequest() => create();

  GetAllFavoriteRequest._();

  factory GetAllFavoriteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAllFavoriteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAllFavoriteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllFavoriteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllFavoriteRequest copyWith(
          void Function(GetAllFavoriteRequest) updates) =>
      super.copyWith((message) => updates(message as GetAllFavoriteRequest))
          as GetAllFavoriteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAllFavoriteRequest create() => GetAllFavoriteRequest._();
  @$core.override
  GetAllFavoriteRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAllFavoriteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAllFavoriteRequest>(create);
  static GetAllFavoriteRequest? _defaultInstance;
}

class GetAllFavoriteResponse extends $pb.GeneratedMessage {
  factory GetAllFavoriteResponse({
    $core.Iterable<$1.Favorite>? favorites,
  }) {
    final result = create();
    if (favorites != null) result.favorites.addAll(favorites);
    return result;
  }

  GetAllFavoriteResponse._();

  factory GetAllFavoriteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAllFavoriteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAllFavoriteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<$1.Favorite>(1, _omitFieldNames ? '' : 'favorites',
        subBuilder: $1.Favorite.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllFavoriteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllFavoriteResponse copyWith(
          void Function(GetAllFavoriteResponse) updates) =>
      super.copyWith((message) => updates(message as GetAllFavoriteResponse))
          as GetAllFavoriteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAllFavoriteResponse create() => GetAllFavoriteResponse._();
  @$core.override
  GetAllFavoriteResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAllFavoriteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAllFavoriteResponse>(create);
  static GetAllFavoriteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.Favorite> get favorites => $_getList(0);
}

class GetFavoriteByPackageAndUrlRequest extends $pb.GeneratedMessage {
  factory GetFavoriteByPackageAndUrlRequest({
    $core.String? package,
    $core.String? url,
  }) {
    final result = create();
    if (package != null) result.package = package;
    if (url != null) result.url = url;
    return result;
  }

  GetFavoriteByPackageAndUrlRequest._();

  factory GetFavoriteByPackageAndUrlRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFavoriteByPackageAndUrlRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFavoriteByPackageAndUrlRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'package')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFavoriteByPackageAndUrlRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFavoriteByPackageAndUrlRequest copyWith(
          void Function(GetFavoriteByPackageAndUrlRequest) updates) =>
      super.copyWith((message) =>
              updates(message as GetFavoriteByPackageAndUrlRequest))
          as GetFavoriteByPackageAndUrlRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFavoriteByPackageAndUrlRequest create() =>
      GetFavoriteByPackageAndUrlRequest._();
  @$core.override
  GetFavoriteByPackageAndUrlRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFavoriteByPackageAndUrlRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFavoriteByPackageAndUrlRequest>(
          create);
  static GetFavoriteByPackageAndUrlRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get package => $_getSZ(0);
  @$pb.TagNumber(1)
  set package($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPackage() => $_has(0);
  @$pb.TagNumber(1)
  void clearPackage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);
}

class GetFavoriteByPackageAndUrlResponse extends $pb.GeneratedMessage {
  factory GetFavoriteByPackageAndUrlResponse({
    $1.Favorite? favorite,
  }) {
    final result = create();
    if (favorite != null) result.favorite = favorite;
    return result;
  }

  GetFavoriteByPackageAndUrlResponse._();

  factory GetFavoriteByPackageAndUrlResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFavoriteByPackageAndUrlResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFavoriteByPackageAndUrlResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOM<$1.Favorite>(1, _omitFieldNames ? '' : 'favorite',
        subBuilder: $1.Favorite.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFavoriteByPackageAndUrlResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFavoriteByPackageAndUrlResponse copyWith(
          void Function(GetFavoriteByPackageAndUrlResponse) updates) =>
      super.copyWith((message) =>
              updates(message as GetFavoriteByPackageAndUrlResponse))
          as GetFavoriteByPackageAndUrlResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFavoriteByPackageAndUrlResponse create() =>
      GetFavoriteByPackageAndUrlResponse._();
  @$core.override
  GetFavoriteByPackageAndUrlResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFavoriteByPackageAndUrlResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFavoriteByPackageAndUrlResponse>(
          create);
  static GetFavoriteByPackageAndUrlResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Favorite get favorite => $_getN(0);
  @$pb.TagNumber(1)
  set favorite($1.Favorite value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFavorite() => $_has(0);
  @$pb.TagNumber(1)
  void clearFavorite() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Favorite ensureFavorite() => $_ensure(0);
}

class PutFavoriteByIndexRequest extends $pb.GeneratedMessage {
  factory PutFavoriteByIndexRequest({
    $core.Iterable<$1.FavoriteGroup>? groups,
  }) {
    final result = create();
    if (groups != null) result.groups.addAll(groups);
    return result;
  }

  PutFavoriteByIndexRequest._();

  factory PutFavoriteByIndexRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PutFavoriteByIndexRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PutFavoriteByIndexRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<$1.FavoriteGroup>(1, _omitFieldNames ? '' : 'groups',
        subBuilder: $1.FavoriteGroup.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutFavoriteByIndexRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutFavoriteByIndexRequest copyWith(
          void Function(PutFavoriteByIndexRequest) updates) =>
      super.copyWith((message) => updates(message as PutFavoriteByIndexRequest))
          as PutFavoriteByIndexRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PutFavoriteByIndexRequest create() => PutFavoriteByIndexRequest._();
  @$core.override
  PutFavoriteByIndexRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PutFavoriteByIndexRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PutFavoriteByIndexRequest>(create);
  static PutFavoriteByIndexRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.FavoriteGroup> get groups => $_getList(0);
}

class PutFavoriteByIndexResponse extends $pb.GeneratedMessage {
  factory PutFavoriteByIndexResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  PutFavoriteByIndexResponse._();

  factory PutFavoriteByIndexResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PutFavoriteByIndexResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PutFavoriteByIndexResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutFavoriteByIndexResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutFavoriteByIndexResponse copyWith(
          void Function(PutFavoriteByIndexResponse) updates) =>
      super.copyWith(
              (message) => updates(message as PutFavoriteByIndexResponse))
          as PutFavoriteByIndexResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PutFavoriteByIndexResponse create() => PutFavoriteByIndexResponse._();
  @$core.override
  PutFavoriteByIndexResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PutFavoriteByIndexResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PutFavoriteByIndexResponse>(create);
  static PutFavoriteByIndexResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

class PutFavoriteRequest extends $pb.GeneratedMessage {
  factory PutFavoriteRequest({
    $core.String? package,
    $core.String? url,
    $core.String? type,
    $core.String? title,
    $core.String? cover,
  }) {
    final result = create();
    if (package != null) result.package = package;
    if (url != null) result.url = url;
    if (type != null) result.type = type;
    if (title != null) result.title = title;
    if (cover != null) result.cover = cover;
    return result;
  }

  PutFavoriteRequest._();

  factory PutFavoriteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PutFavoriteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PutFavoriteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'package')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..aOS(3, _omitFieldNames ? '' : 'type')
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aOS(5, _omitFieldNames ? '' : 'cover')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutFavoriteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutFavoriteRequest copyWith(void Function(PutFavoriteRequest) updates) =>
      super.copyWith((message) => updates(message as PutFavoriteRequest))
          as PutFavoriteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PutFavoriteRequest create() => PutFavoriteRequest._();
  @$core.override
  PutFavoriteRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PutFavoriteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PutFavoriteRequest>(create);
  static PutFavoriteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get package => $_getSZ(0);
  @$pb.TagNumber(1)
  set package($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPackage() => $_has(0);
  @$pb.TagNumber(1)
  void clearPackage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get type => $_getSZ(2);
  @$pb.TagNumber(3)
  set type($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get title => $_getSZ(3);
  @$pb.TagNumber(4)
  set title($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearTitle() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get cover => $_getSZ(4);
  @$pb.TagNumber(5)
  set cover($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCover() => $_has(4);
  @$pb.TagNumber(5)
  void clearCover() => $_clearField(5);
}

class PutFavoriteResponse extends $pb.GeneratedMessage {
  factory PutFavoriteResponse({
    $1.Favorite? favorite,
  }) {
    final result = create();
    if (favorite != null) result.favorite = favorite;
    return result;
  }

  PutFavoriteResponse._();

  factory PutFavoriteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PutFavoriteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PutFavoriteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOM<$1.Favorite>(1, _omitFieldNames ? '' : 'favorite',
        subBuilder: $1.Favorite.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutFavoriteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutFavoriteResponse copyWith(void Function(PutFavoriteResponse) updates) =>
      super.copyWith((message) => updates(message as PutFavoriteResponse))
          as PutFavoriteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PutFavoriteResponse create() => PutFavoriteResponse._();
  @$core.override
  PutFavoriteResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PutFavoriteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PutFavoriteResponse>(create);
  static PutFavoriteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Favorite get favorite => $_getN(0);
  @$pb.TagNumber(1)
  set favorite($1.Favorite value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFavorite() => $_has(0);
  @$pb.TagNumber(1)
  void clearFavorite() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Favorite ensureFavorite() => $_ensure(0);
}

class DeleteFavoriteRequest extends $pb.GeneratedMessage {
  factory DeleteFavoriteRequest({
    $core.String? url,
    $core.String? package,
  }) {
    final result = create();
    if (url != null) result.url = url;
    if (package != null) result.package = package;
    return result;
  }

  DeleteFavoriteRequest._();

  factory DeleteFavoriteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteFavoriteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteFavoriteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOS(2, _omitFieldNames ? '' : 'package')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFavoriteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFavoriteRequest copyWith(
          void Function(DeleteFavoriteRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteFavoriteRequest))
          as DeleteFavoriteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteFavoriteRequest create() => DeleteFavoriteRequest._();
  @$core.override
  DeleteFavoriteRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteFavoriteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteFavoriteRequest>(create);
  static DeleteFavoriteRequest? _defaultInstance;

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
}

class DeleteFavoriteResponse extends $pb.GeneratedMessage {
  factory DeleteFavoriteResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  DeleteFavoriteResponse._();

  factory DeleteFavoriteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteFavoriteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteFavoriteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFavoriteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFavoriteResponse copyWith(
          void Function(DeleteFavoriteResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteFavoriteResponse))
          as DeleteFavoriteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteFavoriteResponse create() => DeleteFavoriteResponse._();
  @$core.override
  DeleteFavoriteResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteFavoriteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteFavoriteResponse>(create);
  static DeleteFavoriteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

/// Favorite Groups
class GetFavoriteGroupsByIdRequest extends $pb.GeneratedMessage {
  factory GetFavoriteGroupsByIdRequest({
    $core.int? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetFavoriteGroupsByIdRequest._();

  factory GetFavoriteGroupsByIdRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFavoriteGroupsByIdRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFavoriteGroupsByIdRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFavoriteGroupsByIdRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFavoriteGroupsByIdRequest copyWith(
          void Function(GetFavoriteGroupsByIdRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetFavoriteGroupsByIdRequest))
          as GetFavoriteGroupsByIdRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFavoriteGroupsByIdRequest create() =>
      GetFavoriteGroupsByIdRequest._();
  @$core.override
  GetFavoriteGroupsByIdRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFavoriteGroupsByIdRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFavoriteGroupsByIdRequest>(create);
  static GetFavoriteGroupsByIdRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetFavoriteGroupsByIdResponse extends $pb.GeneratedMessage {
  factory GetFavoriteGroupsByIdResponse({
    $core.Iterable<$1.FavoriteGroup>? groups,
  }) {
    final result = create();
    if (groups != null) result.groups.addAll(groups);
    return result;
  }

  GetFavoriteGroupsByIdResponse._();

  factory GetFavoriteGroupsByIdResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFavoriteGroupsByIdResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFavoriteGroupsByIdResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<$1.FavoriteGroup>(1, _omitFieldNames ? '' : 'groups',
        subBuilder: $1.FavoriteGroup.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFavoriteGroupsByIdResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFavoriteGroupsByIdResponse copyWith(
          void Function(GetFavoriteGroupsByIdResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetFavoriteGroupsByIdResponse))
          as GetFavoriteGroupsByIdResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFavoriteGroupsByIdResponse create() =>
      GetFavoriteGroupsByIdResponse._();
  @$core.override
  GetFavoriteGroupsByIdResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFavoriteGroupsByIdResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFavoriteGroupsByIdResponse>(create);
  static GetFavoriteGroupsByIdResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.FavoriteGroup> get groups => $_getList(0);
}

class GetAllFavoriteGroupRequest extends $pb.GeneratedMessage {
  factory GetAllFavoriteGroupRequest() => create();

  GetAllFavoriteGroupRequest._();

  factory GetAllFavoriteGroupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAllFavoriteGroupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAllFavoriteGroupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllFavoriteGroupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllFavoriteGroupRequest copyWith(
          void Function(GetAllFavoriteGroupRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetAllFavoriteGroupRequest))
          as GetAllFavoriteGroupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAllFavoriteGroupRequest create() => GetAllFavoriteGroupRequest._();
  @$core.override
  GetAllFavoriteGroupRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAllFavoriteGroupRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAllFavoriteGroupRequest>(create);
  static GetAllFavoriteGroupRequest? _defaultInstance;
}

class GetAllFavoriteGroupResponse extends $pb.GeneratedMessage {
  factory GetAllFavoriteGroupResponse({
    $core.Iterable<$1.FavoriteGroup>? groups,
  }) {
    final result = create();
    if (groups != null) result.groups.addAll(groups);
    return result;
  }

  GetAllFavoriteGroupResponse._();

  factory GetAllFavoriteGroupResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAllFavoriteGroupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAllFavoriteGroupResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<$1.FavoriteGroup>(1, _omitFieldNames ? '' : 'groups',
        subBuilder: $1.FavoriteGroup.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllFavoriteGroupResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAllFavoriteGroupResponse copyWith(
          void Function(GetAllFavoriteGroupResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetAllFavoriteGroupResponse))
          as GetAllFavoriteGroupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAllFavoriteGroupResponse create() =>
      GetAllFavoriteGroupResponse._();
  @$core.override
  GetAllFavoriteGroupResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAllFavoriteGroupResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAllFavoriteGroupResponse>(create);
  static GetAllFavoriteGroupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.FavoriteGroup> get groups => $_getList(0);
}

class PutFavoriteGroupRequest extends $pb.GeneratedMessage {
  factory PutFavoriteGroupRequest({
    $core.String? name,
    $core.Iterable<$core.int>? items,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (items != null) result.items.addAll(items);
    return result;
  }

  PutFavoriteGroupRequest._();

  factory PutFavoriteGroupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PutFavoriteGroupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PutFavoriteGroupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..p<$core.int>(2, _omitFieldNames ? '' : 'items', $pb.PbFieldType.K3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutFavoriteGroupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutFavoriteGroupRequest copyWith(
          void Function(PutFavoriteGroupRequest) updates) =>
      super.copyWith((message) => updates(message as PutFavoriteGroupRequest))
          as PutFavoriteGroupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PutFavoriteGroupRequest create() => PutFavoriteGroupRequest._();
  @$core.override
  PutFavoriteGroupRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PutFavoriteGroupRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PutFavoriteGroupRequest>(create);
  static PutFavoriteGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.int> get items => $_getList(1);
}

class PutFavoriteGroupResponse extends $pb.GeneratedMessage {
  factory PutFavoriteGroupResponse({
    $1.FavoriteGroup? group,
  }) {
    final result = create();
    if (group != null) result.group = group;
    return result;
  }

  PutFavoriteGroupResponse._();

  factory PutFavoriteGroupResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PutFavoriteGroupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PutFavoriteGroupResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOM<$1.FavoriteGroup>(1, _omitFieldNames ? '' : 'group',
        subBuilder: $1.FavoriteGroup.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutFavoriteGroupResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutFavoriteGroupResponse copyWith(
          void Function(PutFavoriteGroupResponse) updates) =>
      super.copyWith((message) => updates(message as PutFavoriteGroupResponse))
          as PutFavoriteGroupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PutFavoriteGroupResponse create() => PutFavoriteGroupResponse._();
  @$core.override
  PutFavoriteGroupResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PutFavoriteGroupResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PutFavoriteGroupResponse>(create);
  static PutFavoriteGroupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.FavoriteGroup get group => $_getN(0);
  @$pb.TagNumber(1)
  set group($1.FavoriteGroup value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.FavoriteGroup ensureGroup() => $_ensure(0);
}

class RenameFavoriteGroupRequest extends $pb.GeneratedMessage {
  factory RenameFavoriteGroupRequest({
    $core.String? oldName,
    $core.String? newName,
  }) {
    final result = create();
    if (oldName != null) result.oldName = oldName;
    if (newName != null) result.newName = newName;
    return result;
  }

  RenameFavoriteGroupRequest._();

  factory RenameFavoriteGroupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RenameFavoriteGroupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RenameFavoriteGroupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'oldName')
    ..aOS(2, _omitFieldNames ? '' : 'newName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RenameFavoriteGroupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RenameFavoriteGroupRequest copyWith(
          void Function(RenameFavoriteGroupRequest) updates) =>
      super.copyWith(
              (message) => updates(message as RenameFavoriteGroupRequest))
          as RenameFavoriteGroupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RenameFavoriteGroupRequest create() => RenameFavoriteGroupRequest._();
  @$core.override
  RenameFavoriteGroupRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RenameFavoriteGroupRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RenameFavoriteGroupRequest>(create);
  static RenameFavoriteGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get oldName => $_getSZ(0);
  @$pb.TagNumber(1)
  set oldName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOldName() => $_has(0);
  @$pb.TagNumber(1)
  void clearOldName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get newName => $_getSZ(1);
  @$pb.TagNumber(2)
  set newName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNewName() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewName() => $_clearField(2);
}

class RenameFavoriteGroupResponse extends $pb.GeneratedMessage {
  factory RenameFavoriteGroupResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  RenameFavoriteGroupResponse._();

  factory RenameFavoriteGroupResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RenameFavoriteGroupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RenameFavoriteGroupResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RenameFavoriteGroupResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RenameFavoriteGroupResponse copyWith(
          void Function(RenameFavoriteGroupResponse) updates) =>
      super.copyWith(
              (message) => updates(message as RenameFavoriteGroupResponse))
          as RenameFavoriteGroupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RenameFavoriteGroupResponse create() =>
      RenameFavoriteGroupResponse._();
  @$core.override
  RenameFavoriteGroupResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RenameFavoriteGroupResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RenameFavoriteGroupResponse>(create);
  static RenameFavoriteGroupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

class DeleteFavoriteGroupRequest extends $pb.GeneratedMessage {
  factory DeleteFavoriteGroupRequest({
    $core.Iterable<$core.String>? names,
  }) {
    final result = create();
    if (names != null) result.names.addAll(names);
    return result;
  }

  DeleteFavoriteGroupRequest._();

  factory DeleteFavoriteGroupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteFavoriteGroupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteFavoriteGroupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'names')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFavoriteGroupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFavoriteGroupRequest copyWith(
          void Function(DeleteFavoriteGroupRequest) updates) =>
      super.copyWith(
              (message) => updates(message as DeleteFavoriteGroupRequest))
          as DeleteFavoriteGroupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteFavoriteGroupRequest create() => DeleteFavoriteGroupRequest._();
  @$core.override
  DeleteFavoriteGroupRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteFavoriteGroupRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteFavoriteGroupRequest>(create);
  static DeleteFavoriteGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get names => $_getList(0);
}

class DeleteFavoriteGroupResponse extends $pb.GeneratedMessage {
  factory DeleteFavoriteGroupResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  DeleteFavoriteGroupResponse._();

  factory DeleteFavoriteGroupResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteFavoriteGroupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteFavoriteGroupResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFavoriteGroupResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFavoriteGroupResponse copyWith(
          void Function(DeleteFavoriteGroupResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DeleteFavoriteGroupResponse))
          as DeleteFavoriteGroupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteFavoriteGroupResponse create() =>
      DeleteFavoriteGroupResponse._();
  @$core.override
  DeleteFavoriteGroupResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteFavoriteGroupResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteFavoriteGroupResponse>(create);
  static DeleteFavoriteGroupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

class GetFavoriteGroupsByFavoriteRequest extends $pb.GeneratedMessage {
  factory GetFavoriteGroupsByFavoriteRequest({
    $core.String? package,
    $core.String? url,
  }) {
    final result = create();
    if (package != null) result.package = package;
    if (url != null) result.url = url;
    return result;
  }

  GetFavoriteGroupsByFavoriteRequest._();

  factory GetFavoriteGroupsByFavoriteRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFavoriteGroupsByFavoriteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFavoriteGroupsByFavoriteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'package')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFavoriteGroupsByFavoriteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFavoriteGroupsByFavoriteRequest copyWith(
          void Function(GetFavoriteGroupsByFavoriteRequest) updates) =>
      super.copyWith((message) =>
              updates(message as GetFavoriteGroupsByFavoriteRequest))
          as GetFavoriteGroupsByFavoriteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFavoriteGroupsByFavoriteRequest create() =>
      GetFavoriteGroupsByFavoriteRequest._();
  @$core.override
  GetFavoriteGroupsByFavoriteRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFavoriteGroupsByFavoriteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFavoriteGroupsByFavoriteRequest>(
          create);
  static GetFavoriteGroupsByFavoriteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get package => $_getSZ(0);
  @$pb.TagNumber(1)
  set package($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPackage() => $_has(0);
  @$pb.TagNumber(1)
  void clearPackage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);
}

class GetFavoriteGroupsByFavoriteResponse extends $pb.GeneratedMessage {
  factory GetFavoriteGroupsByFavoriteResponse({
    $core.Iterable<$1.FavoriteGroup>? groups,
  }) {
    final result = create();
    if (groups != null) result.groups.addAll(groups);
    return result;
  }

  GetFavoriteGroupsByFavoriteResponse._();

  factory GetFavoriteGroupsByFavoriteResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFavoriteGroupsByFavoriteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFavoriteGroupsByFavoriteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<$1.FavoriteGroup>(1, _omitFieldNames ? '' : 'groups',
        subBuilder: $1.FavoriteGroup.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFavoriteGroupsByFavoriteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFavoriteGroupsByFavoriteResponse copyWith(
          void Function(GetFavoriteGroupsByFavoriteResponse) updates) =>
      super.copyWith((message) =>
              updates(message as GetFavoriteGroupsByFavoriteResponse))
          as GetFavoriteGroupsByFavoriteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFavoriteGroupsByFavoriteResponse create() =>
      GetFavoriteGroupsByFavoriteResponse._();
  @$core.override
  GetFavoriteGroupsByFavoriteResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFavoriteGroupsByFavoriteResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          GetFavoriteGroupsByFavoriteResponse>(create);
  static GetFavoriteGroupsByFavoriteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.FavoriteGroup> get groups => $_getList(0);
}

/// History
class GetHistoriesByTypeRequest extends $pb.GeneratedMessage {
  factory GetHistoriesByTypeRequest({
    $core.String? type,
  }) {
    final result = create();
    if (type != null) result.type = type;
    return result;
  }

  GetHistoriesByTypeRequest._();

  factory GetHistoriesByTypeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHistoriesByTypeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHistoriesByTypeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistoriesByTypeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistoriesByTypeRequest copyWith(
          void Function(GetHistoriesByTypeRequest) updates) =>
      super.copyWith((message) => updates(message as GetHistoriesByTypeRequest))
          as GetHistoriesByTypeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHistoriesByTypeRequest create() => GetHistoriesByTypeRequest._();
  @$core.override
  GetHistoriesByTypeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHistoriesByTypeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHistoriesByTypeRequest>(create);
  static GetHistoriesByTypeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);
}

class GetHistoriesByTypeResponse extends $pb.GeneratedMessage {
  factory GetHistoriesByTypeResponse({
    $core.Iterable<$1.History>? histories,
  }) {
    final result = create();
    if (histories != null) result.histories.addAll(histories);
    return result;
  }

  GetHistoriesByTypeResponse._();

  factory GetHistoriesByTypeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHistoriesByTypeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHistoriesByTypeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<$1.History>(1, _omitFieldNames ? '' : 'histories',
        subBuilder: $1.History.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistoriesByTypeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistoriesByTypeResponse copyWith(
          void Function(GetHistoriesByTypeResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetHistoriesByTypeResponse))
          as GetHistoriesByTypeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHistoriesByTypeResponse create() => GetHistoriesByTypeResponse._();
  @$core.override
  GetHistoriesByTypeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHistoriesByTypeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHistoriesByTypeResponse>(create);
  static GetHistoriesByTypeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.History> get histories => $_getList(0);
}

class GetHistoryByPackageAndUrlRequest extends $pb.GeneratedMessage {
  factory GetHistoryByPackageAndUrlRequest({
    $core.String? package,
    $core.String? url,
  }) {
    final result = create();
    if (package != null) result.package = package;
    if (url != null) result.url = url;
    return result;
  }

  GetHistoryByPackageAndUrlRequest._();

  factory GetHistoryByPackageAndUrlRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHistoryByPackageAndUrlRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHistoryByPackageAndUrlRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'package')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistoryByPackageAndUrlRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistoryByPackageAndUrlRequest copyWith(
          void Function(GetHistoryByPackageAndUrlRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetHistoryByPackageAndUrlRequest))
          as GetHistoryByPackageAndUrlRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHistoryByPackageAndUrlRequest create() =>
      GetHistoryByPackageAndUrlRequest._();
  @$core.override
  GetHistoryByPackageAndUrlRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHistoryByPackageAndUrlRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHistoryByPackageAndUrlRequest>(
          create);
  static GetHistoryByPackageAndUrlRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get package => $_getSZ(0);
  @$pb.TagNumber(1)
  set package($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPackage() => $_has(0);
  @$pb.TagNumber(1)
  void clearPackage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);
}

class GetHistoryByPackageAndUrlResponse extends $pb.GeneratedMessage {
  factory GetHistoryByPackageAndUrlResponse({
    $1.History? history,
  }) {
    final result = create();
    if (history != null) result.history = history;
    return result;
  }

  GetHistoryByPackageAndUrlResponse._();

  factory GetHistoryByPackageAndUrlResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHistoryByPackageAndUrlResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHistoryByPackageAndUrlResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOM<$1.History>(1, _omitFieldNames ? '' : 'history',
        subBuilder: $1.History.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistoryByPackageAndUrlResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistoryByPackageAndUrlResponse copyWith(
          void Function(GetHistoryByPackageAndUrlResponse) updates) =>
      super.copyWith((message) =>
              updates(message as GetHistoryByPackageAndUrlResponse))
          as GetHistoryByPackageAndUrlResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHistoryByPackageAndUrlResponse create() =>
      GetHistoryByPackageAndUrlResponse._();
  @$core.override
  GetHistoryByPackageAndUrlResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHistoryByPackageAndUrlResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHistoryByPackageAndUrlResponse>(
          create);
  static GetHistoryByPackageAndUrlResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.History get history => $_getN(0);
  @$pb.TagNumber(1)
  set history($1.History value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHistory() => $_has(0);
  @$pb.TagNumber(1)
  void clearHistory() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.History ensureHistory() => $_ensure(0);
}

class PutHistoryRequest extends $pb.GeneratedMessage {
  factory PutHistoryRequest({
    $1.History? history,
  }) {
    final result = create();
    if (history != null) result.history = history;
    return result;
  }

  PutHistoryRequest._();

  factory PutHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PutHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PutHistoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOM<$1.History>(1, _omitFieldNames ? '' : 'history',
        subBuilder: $1.History.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutHistoryRequest copyWith(void Function(PutHistoryRequest) updates) =>
      super.copyWith((message) => updates(message as PutHistoryRequest))
          as PutHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PutHistoryRequest create() => PutHistoryRequest._();
  @$core.override
  PutHistoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PutHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PutHistoryRequest>(create);
  static PutHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $1.History get history => $_getN(0);
  @$pb.TagNumber(1)
  set history($1.History value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHistory() => $_has(0);
  @$pb.TagNumber(1)
  void clearHistory() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.History ensureHistory() => $_ensure(0);
}

class PutHistoryResponse extends $pb.GeneratedMessage {
  factory PutHistoryResponse({
    $1.History? history,
  }) {
    final result = create();
    if (history != null) result.history = history;
    return result;
  }

  PutHistoryResponse._();

  factory PutHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PutHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PutHistoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOM<$1.History>(1, _omitFieldNames ? '' : 'history',
        subBuilder: $1.History.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutHistoryResponse copyWith(void Function(PutHistoryResponse) updates) =>
      super.copyWith((message) => updates(message as PutHistoryResponse))
          as PutHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PutHistoryResponse create() => PutHistoryResponse._();
  @$core.override
  PutHistoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PutHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PutHistoryResponse>(create);
  static PutHistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.History get history => $_getN(0);
  @$pb.TagNumber(1)
  set history($1.History value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHistory() => $_has(0);
  @$pb.TagNumber(1)
  void clearHistory() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.History ensureHistory() => $_ensure(0);
}

class DeleteHistoryByPackageAndUrlRequest extends $pb.GeneratedMessage {
  factory DeleteHistoryByPackageAndUrlRequest({
    $core.String? package,
    $core.String? url,
  }) {
    final result = create();
    if (package != null) result.package = package;
    if (url != null) result.url = url;
    return result;
  }

  DeleteHistoryByPackageAndUrlRequest._();

  factory DeleteHistoryByPackageAndUrlRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteHistoryByPackageAndUrlRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteHistoryByPackageAndUrlRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'package')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteHistoryByPackageAndUrlRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteHistoryByPackageAndUrlRequest copyWith(
          void Function(DeleteHistoryByPackageAndUrlRequest) updates) =>
      super.copyWith((message) =>
              updates(message as DeleteHistoryByPackageAndUrlRequest))
          as DeleteHistoryByPackageAndUrlRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteHistoryByPackageAndUrlRequest create() =>
      DeleteHistoryByPackageAndUrlRequest._();
  @$core.override
  DeleteHistoryByPackageAndUrlRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteHistoryByPackageAndUrlRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          DeleteHistoryByPackageAndUrlRequest>(create);
  static DeleteHistoryByPackageAndUrlRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get package => $_getSZ(0);
  @$pb.TagNumber(1)
  set package($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPackage() => $_has(0);
  @$pb.TagNumber(1)
  void clearPackage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);
}

class DeleteHistoryByPackageAndUrlResponse extends $pb.GeneratedMessage {
  factory DeleteHistoryByPackageAndUrlResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  DeleteHistoryByPackageAndUrlResponse._();

  factory DeleteHistoryByPackageAndUrlResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteHistoryByPackageAndUrlResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteHistoryByPackageAndUrlResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteHistoryByPackageAndUrlResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteHistoryByPackageAndUrlResponse copyWith(
          void Function(DeleteHistoryByPackageAndUrlResponse) updates) =>
      super.copyWith((message) =>
              updates(message as DeleteHistoryByPackageAndUrlResponse))
          as DeleteHistoryByPackageAndUrlResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteHistoryByPackageAndUrlResponse create() =>
      DeleteHistoryByPackageAndUrlResponse._();
  @$core.override
  DeleteHistoryByPackageAndUrlResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteHistoryByPackageAndUrlResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          DeleteHistoryByPackageAndUrlResponse>(create);
  static DeleteHistoryByPackageAndUrlResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

class DeleteAllHistoryRequest extends $pb.GeneratedMessage {
  factory DeleteAllHistoryRequest() => create();

  DeleteAllHistoryRequest._();

  factory DeleteAllHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteAllHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteAllHistoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAllHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAllHistoryRequest copyWith(
          void Function(DeleteAllHistoryRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteAllHistoryRequest))
          as DeleteAllHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteAllHistoryRequest create() => DeleteAllHistoryRequest._();
  @$core.override
  DeleteAllHistoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteAllHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteAllHistoryRequest>(create);
  static DeleteAllHistoryRequest? _defaultInstance;
}

class DeleteAllHistoryResponse extends $pb.GeneratedMessage {
  factory DeleteAllHistoryResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  DeleteAllHistoryResponse._();

  factory DeleteAllHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteAllHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteAllHistoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAllHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAllHistoryResponse copyWith(
          void Function(DeleteAllHistoryResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteAllHistoryResponse))
          as DeleteAllHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteAllHistoryResponse create() => DeleteAllHistoryResponse._();
  @$core.override
  DeleteAllHistoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteAllHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteAllHistoryResponse>(create);
  static DeleteAllHistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

class GetHistorysFilteredRequest extends $pb.GeneratedMessage {
  factory GetHistorysFilteredRequest({
    $core.String? type,
    $core.String? beforeDate,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (beforeDate != null) result.beforeDate = beforeDate;
    return result;
  }

  GetHistorysFilteredRequest._();

  factory GetHistorysFilteredRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHistorysFilteredRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHistorysFilteredRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'beforeDate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistorysFilteredRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistorysFilteredRequest copyWith(
          void Function(GetHistorysFilteredRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetHistorysFilteredRequest))
          as GetHistorysFilteredRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHistorysFilteredRequest create() => GetHistorysFilteredRequest._();
  @$core.override
  GetHistorysFilteredRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHistorysFilteredRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHistorysFilteredRequest>(create);
  static GetHistorysFilteredRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get beforeDate => $_getSZ(1);
  @$pb.TagNumber(2)
  set beforeDate($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBeforeDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearBeforeDate() => $_clearField(2);
}

class GetHistorysFilteredResponse extends $pb.GeneratedMessage {
  factory GetHistorysFilteredResponse({
    $core.Iterable<$1.History>? histories,
  }) {
    final result = create();
    if (histories != null) result.histories.addAll(histories);
    return result;
  }

  GetHistorysFilteredResponse._();

  factory GetHistorysFilteredResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHistorysFilteredResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHistorysFilteredResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<$1.History>(1, _omitFieldNames ? '' : 'histories',
        subBuilder: $1.History.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistorysFilteredResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistorysFilteredResponse copyWith(
          void Function(GetHistorysFilteredResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetHistorysFilteredResponse))
          as GetHistorysFilteredResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHistorysFilteredResponse create() =>
      GetHistorysFilteredResponse._();
  @$core.override
  GetHistorysFilteredResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHistorysFilteredResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHistorysFilteredResponse>(create);
  static GetHistorysFilteredResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.History> get histories => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
