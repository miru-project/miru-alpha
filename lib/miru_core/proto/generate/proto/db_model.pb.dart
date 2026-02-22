// This is a generated file - do not edit.
//
// Generated from proto/db_model.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// DB - Detail
class Detail extends $pb.GeneratedMessage {
  factory Detail({
    $core.int? id,
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
    if (id != null) result.id = id;
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

  Detail._();

  factory Detail.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Detail.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Detail',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'cover')
    ..aOS(4, _omitFieldNames ? '' : 'desc')
    ..aOS(5, _omitFieldNames ? '' : 'detailUrl')
    ..aOS(6, _omitFieldNames ? '' : 'package')
    ..pPS(7, _omitFieldNames ? '' : 'downloaded')
    ..aOS(8, _omitFieldNames ? '' : 'episodes')
    ..aOS(9, _omitFieldNames ? '' : 'headers')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Detail clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Detail copyWith(void Function(Detail) updates) =>
      super.copyWith((message) => updates(message as Detail)) as Detail;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Detail create() => Detail._();
  @$core.override
  Detail createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Detail getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Detail>(create);
  static Detail? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get cover => $_getSZ(2);
  @$pb.TagNumber(3)
  set cover($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCover() => $_has(2);
  @$pb.TagNumber(3)
  void clearCover() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get desc => $_getSZ(3);
  @$pb.TagNumber(4)
  set desc($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDesc() => $_has(3);
  @$pb.TagNumber(4)
  void clearDesc() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get detailUrl => $_getSZ(4);
  @$pb.TagNumber(5)
  set detailUrl($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDetailUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearDetailUrl() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get package => $_getSZ(5);
  @$pb.TagNumber(6)
  set package($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPackage() => $_has(5);
  @$pb.TagNumber(6)
  void clearPackage() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get downloaded => $_getList(6);

  /// JSON encoded strings for complex types to mirror frontend ExtensionDetail
  @$pb.TagNumber(8)
  $core.String get episodes => $_getSZ(7);
  @$pb.TagNumber(8)
  set episodes($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEpisodes() => $_has(7);
  @$pb.TagNumber(8)
  void clearEpisodes() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get headers => $_getSZ(8);
  @$pb.TagNumber(9)
  set headers($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasHeaders() => $_has(8);
  @$pb.TagNumber(9)
  void clearHeaders() => $_clearField(9);
}

/// DB - Favorite
class Favorite extends $pb.GeneratedMessage {
  factory Favorite({
    $core.int? id,
    $core.String? package,
    $core.String? url,
    $core.String? type,
    $core.String? title,
    $core.String? cover,
    $core.String? date,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (package != null) result.package = package;
    if (url != null) result.url = url;
    if (type != null) result.type = type;
    if (title != null) result.title = title;
    if (cover != null) result.cover = cover;
    if (date != null) result.date = date;
    return result;
  }

  Favorite._();

  factory Favorite.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Favorite.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Favorite',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'package')
    ..aOS(3, _omitFieldNames ? '' : 'url')
    ..aOS(4, _omitFieldNames ? '' : 'type')
    ..aOS(5, _omitFieldNames ? '' : 'title')
    ..aOS(6, _omitFieldNames ? '' : 'cover')
    ..aOS(7, _omitFieldNames ? '' : 'date')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Favorite clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Favorite copyWith(void Function(Favorite) updates) =>
      super.copyWith((message) => updates(message as Favorite)) as Favorite;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Favorite create() => Favorite._();
  @$core.override
  Favorite createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Favorite getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Favorite>(create);
  static Favorite? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get package => $_getSZ(1);
  @$pb.TagNumber(2)
  set package($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPackage() => $_has(1);
  @$pb.TagNumber(2)
  void clearPackage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get type => $_getSZ(3);
  @$pb.TagNumber(4)
  set type($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get title => $_getSZ(4);
  @$pb.TagNumber(5)
  set title($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTitle() => $_has(4);
  @$pb.TagNumber(5)
  void clearTitle() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get cover => $_getSZ(5);
  @$pb.TagNumber(6)
  set cover($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCover() => $_has(5);
  @$pb.TagNumber(6)
  void clearCover() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get date => $_getSZ(6);
  @$pb.TagNumber(7)
  set date($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearDate() => $_clearField(7);
}

class FavoriteGroup extends $pb.GeneratedMessage {
  factory FavoriteGroup({
    $core.int? id,
    $core.String? name,
    $core.String? date,
    $core.Iterable<Favorite>? favorites,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (date != null) result.date = date;
    if (favorites != null) result.favorites.addAll(favorites);
    return result;
  }

  FavoriteGroup._();

  factory FavoriteGroup.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FavoriteGroup.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FavoriteGroup',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'date')
    ..pPM<Favorite>(4, _omitFieldNames ? '' : 'favorites',
        subBuilder: Favorite.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FavoriteGroup clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FavoriteGroup copyWith(void Function(FavoriteGroup) updates) =>
      super.copyWith((message) => updates(message as FavoriteGroup))
          as FavoriteGroup;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FavoriteGroup create() => FavoriteGroup._();
  @$core.override
  FavoriteGroup createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FavoriteGroup getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FavoriteGroup>(create);
  static FavoriteGroup? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get date => $_getSZ(2);
  @$pb.TagNumber(3)
  set date($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearDate() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<Favorite> get favorites => $_getList(3);
}

/// History
class History extends $pb.GeneratedMessage {
  factory History({
    $core.int? id,
    $core.String? package,
    $core.String? url,
    $core.String? cover,
    $core.String? type,
    $core.int? episodeGroupId,
    $core.int? episodeId,
    $core.String? title,
    $core.String? episodeTitle,
    $core.int? progress,
    $core.int? totalProgress,
    $core.String? date,
    $core.String? detailUrl,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (package != null) result.package = package;
    if (url != null) result.url = url;
    if (cover != null) result.cover = cover;
    if (type != null) result.type = type;
    if (episodeGroupId != null) result.episodeGroupId = episodeGroupId;
    if (episodeId != null) result.episodeId = episodeId;
    if (title != null) result.title = title;
    if (episodeTitle != null) result.episodeTitle = episodeTitle;
    if (progress != null) result.progress = progress;
    if (totalProgress != null) result.totalProgress = totalProgress;
    if (date != null) result.date = date;
    if (detailUrl != null) result.detailUrl = detailUrl;
    return result;
  }

  History._();

  factory History.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory History.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'History',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'package')
    ..aOS(3, _omitFieldNames ? '' : 'url')
    ..aOS(4, _omitFieldNames ? '' : 'cover')
    ..aOS(5, _omitFieldNames ? '' : 'type')
    ..aI(6, _omitFieldNames ? '' : 'episodeGroupId')
    ..aI(7, _omitFieldNames ? '' : 'episodeId')
    ..aOS(8, _omitFieldNames ? '' : 'title')
    ..aOS(9, _omitFieldNames ? '' : 'episodeTitle')
    ..aI(10, _omitFieldNames ? '' : 'progress')
    ..aI(11, _omitFieldNames ? '' : 'totalProgress')
    ..aOS(12, _omitFieldNames ? '' : 'date')
    ..aOS(13, _omitFieldNames ? '' : 'detailUrl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  History clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  History copyWith(void Function(History) updates) =>
      super.copyWith((message) => updates(message as History)) as History;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static History create() => History._();
  @$core.override
  History createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static History getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<History>(create);
  static History? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get package => $_getSZ(1);
  @$pb.TagNumber(2)
  set package($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPackage() => $_has(1);
  @$pb.TagNumber(2)
  void clearPackage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get cover => $_getSZ(3);
  @$pb.TagNumber(4)
  set cover($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCover() => $_has(3);
  @$pb.TagNumber(4)
  void clearCover() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get type => $_getSZ(4);
  @$pb.TagNumber(5)
  set type($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasType() => $_has(4);
  @$pb.TagNumber(5)
  void clearType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get episodeGroupId => $_getIZ(5);
  @$pb.TagNumber(6)
  set episodeGroupId($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEpisodeGroupId() => $_has(5);
  @$pb.TagNumber(6)
  void clearEpisodeGroupId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get episodeId => $_getIZ(6);
  @$pb.TagNumber(7)
  set episodeId($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEpisodeId() => $_has(6);
  @$pb.TagNumber(7)
  void clearEpisodeId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get title => $_getSZ(7);
  @$pb.TagNumber(8)
  set title($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTitle() => $_has(7);
  @$pb.TagNumber(8)
  void clearTitle() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get episodeTitle => $_getSZ(8);
  @$pb.TagNumber(9)
  set episodeTitle($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasEpisodeTitle() => $_has(8);
  @$pb.TagNumber(9)
  void clearEpisodeTitle() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get progress => $_getIZ(9);
  @$pb.TagNumber(10)
  set progress($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasProgress() => $_has(9);
  @$pb.TagNumber(10)
  void clearProgress() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get totalProgress => $_getIZ(10);
  @$pb.TagNumber(11)
  set totalProgress($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasTotalProgress() => $_has(10);
  @$pb.TagNumber(11)
  void clearTotalProgress() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get date => $_getSZ(11);
  @$pb.TagNumber(12)
  set date($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasDate() => $_has(11);
  @$pb.TagNumber(12)
  void clearDate() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get detailUrl => $_getSZ(12);
  @$pb.TagNumber(13)
  set detailUrl($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasDetailUrl() => $_has(12);
  @$pb.TagNumber(13)
  void clearDetailUrl() => $_clearField(13);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
