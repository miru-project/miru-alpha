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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class ExtensionListItem extends $pb.GeneratedMessage {
  factory ExtensionListItem({
    $core.String? title,
    $core.String? url,
    $core.String? cover,
    $core.String? update,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? headers,
  }) {
    final result = create();
    if (title != null) result.title = title;
    if (url != null) result.url = url;
    if (cover != null) result.cover = cover;
    if (update != null) result.update = update;
    if (headers != null) result.headers.addEntries(headers);
    return result;
  }

  ExtensionListItem._();

  factory ExtensionListItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExtensionListItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExtensionListItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..aOS(3, _omitFieldNames ? '' : 'cover')
    ..aOS(4, _omitFieldNames ? '' : 'update')
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'headers',
        entryClassName: 'ExtensionListItem.HeadersEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('miru'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionListItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionListItem copyWith(void Function(ExtensionListItem) updates) =>
      super.copyWith((message) => updates(message as ExtensionListItem))
          as ExtensionListItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExtensionListItem create() => ExtensionListItem._();
  @$core.override
  ExtensionListItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExtensionListItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExtensionListItem>(create);
  static ExtensionListItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get cover => $_getSZ(2);
  @$pb.TagNumber(3)
  set cover($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCover() => $_has(2);
  @$pb.TagNumber(3)
  void clearCover() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get update => $_getSZ(3);
  @$pb.TagNumber(4)
  set update($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUpdate() => $_has(3);
  @$pb.TagNumber(4)
  void clearUpdate() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $core.String> get headers => $_getMap(4);
}

class ExtensionFilter extends $pb.GeneratedMessage {
  factory ExtensionFilter({
    $core.String? title,
    $core.int? min,
    $core.int? max,
    $core.String? default_4,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? options,
  }) {
    final result = create();
    if (title != null) result.title = title;
    if (min != null) result.min = min;
    if (max != null) result.max = max;
    if (default_4 != null) result.default_4 = default_4;
    if (options != null) result.options.addEntries(options);
    return result;
  }

  ExtensionFilter._();

  factory ExtensionFilter.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExtensionFilter.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExtensionFilter',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aI(2, _omitFieldNames ? '' : 'min')
    ..aI(3, _omitFieldNames ? '' : 'max')
    ..aOS(4, _omitFieldNames ? '' : 'default')
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'options',
        entryClassName: 'ExtensionFilter.OptionsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('miru'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionFilter clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionFilter copyWith(void Function(ExtensionFilter) updates) =>
      super.copyWith((message) => updates(message as ExtensionFilter))
          as ExtensionFilter;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExtensionFilter create() => ExtensionFilter._();
  @$core.override
  ExtensionFilter createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExtensionFilter getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExtensionFilter>(create);
  static ExtensionFilter? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get min => $_getIZ(1);
  @$pb.TagNumber(2)
  set min($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMin() => $_has(1);
  @$pb.TagNumber(2)
  void clearMin() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get max => $_getIZ(2);
  @$pb.TagNumber(3)
  set max($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMax() => $_has(2);
  @$pb.TagNumber(3)
  void clearMax() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get default_4 => $_getSZ(3);
  @$pb.TagNumber(4)
  set default_4($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDefault_4() => $_has(3);
  @$pb.TagNumber(4)
  void clearDefault_4() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $core.String> get options => $_getMap(4);
}

class ExtensionDetail extends $pb.GeneratedMessage {
  factory ExtensionDetail({
    $core.String? title,
    $core.String? cover,
    $core.String? desc,
    $core.Iterable<ExtensionEpisodeGroup>? episodes,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? headers,
  }) {
    final result = create();
    if (title != null) result.title = title;
    if (cover != null) result.cover = cover;
    if (desc != null) result.desc = desc;
    if (episodes != null) result.episodes.addAll(episodes);
    if (headers != null) result.headers.addEntries(headers);
    return result;
  }

  ExtensionDetail._();

  factory ExtensionDetail.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExtensionDetail.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExtensionDetail',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'cover')
    ..aOS(3, _omitFieldNames ? '' : 'desc')
    ..pPM<ExtensionEpisodeGroup>(4, _omitFieldNames ? '' : 'episodes',
        subBuilder: ExtensionEpisodeGroup.create)
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'headers',
        entryClassName: 'ExtensionDetail.HeadersEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('miru'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionDetail clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionDetail copyWith(void Function(ExtensionDetail) updates) =>
      super.copyWith((message) => updates(message as ExtensionDetail))
          as ExtensionDetail;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExtensionDetail create() => ExtensionDetail._();
  @$core.override
  ExtensionDetail createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExtensionDetail getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExtensionDetail>(create);
  static ExtensionDetail? _defaultInstance;

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
  $pb.PbList<ExtensionEpisodeGroup> get episodes => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $core.String> get headers => $_getMap(4);
}

class ExtensionEpisodeGroup extends $pb.GeneratedMessage {
  factory ExtensionEpisodeGroup({
    $core.String? title,
    $core.Iterable<ExtensionEpisode>? urls,
  }) {
    final result = create();
    if (title != null) result.title = title;
    if (urls != null) result.urls.addAll(urls);
    return result;
  }

  ExtensionEpisodeGroup._();

  factory ExtensionEpisodeGroup.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExtensionEpisodeGroup.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExtensionEpisodeGroup',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..pPM<ExtensionEpisode>(2, _omitFieldNames ? '' : 'urls',
        subBuilder: ExtensionEpisode.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionEpisodeGroup clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionEpisodeGroup copyWith(
          void Function(ExtensionEpisodeGroup) updates) =>
      super.copyWith((message) => updates(message as ExtensionEpisodeGroup))
          as ExtensionEpisodeGroup;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExtensionEpisodeGroup create() => ExtensionEpisodeGroup._();
  @$core.override
  ExtensionEpisodeGroup createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExtensionEpisodeGroup getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExtensionEpisodeGroup>(create);
  static ExtensionEpisodeGroup? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<ExtensionEpisode> get urls => $_getList(1);
}

class ExtensionEpisode extends $pb.GeneratedMessage {
  factory ExtensionEpisode({
    $core.String? name,
    $core.String? url,
    $core.String? update,
    $core.String? description,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (url != null) result.url = url;
    if (update != null) result.update = update;
    if (description != null) result.description = description;
    return result;
  }

  ExtensionEpisode._();

  factory ExtensionEpisode.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExtensionEpisode.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExtensionEpisode',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..aOS(3, _omitFieldNames ? '' : 'update')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionEpisode clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionEpisode copyWith(void Function(ExtensionEpisode) updates) =>
      super.copyWith((message) => updates(message as ExtensionEpisode))
          as ExtensionEpisode;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExtensionEpisode create() => ExtensionEpisode._();
  @$core.override
  ExtensionEpisode createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExtensionEpisode getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExtensionEpisode>(create);
  static ExtensionEpisode? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get update => $_getSZ(2);
  @$pb.TagNumber(3)
  set update($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUpdate() => $_has(2);
  @$pb.TagNumber(3)
  void clearUpdate() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);
}

class ExtensionBangumiWatchSubtitle extends $pb.GeneratedMessage {
  factory ExtensionBangumiWatchSubtitle({
    $core.String? language,
    $core.String? title,
    $core.String? url,
  }) {
    final result = create();
    if (language != null) result.language = language;
    if (title != null) result.title = title;
    if (url != null) result.url = url;
    return result;
  }

  ExtensionBangumiWatchSubtitle._();

  factory ExtensionBangumiWatchSubtitle.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExtensionBangumiWatchSubtitle.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExtensionBangumiWatchSubtitle',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'language')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionBangumiWatchSubtitle clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionBangumiWatchSubtitle copyWith(
          void Function(ExtensionBangumiWatchSubtitle) updates) =>
      super.copyWith(
              (message) => updates(message as ExtensionBangumiWatchSubtitle))
          as ExtensionBangumiWatchSubtitle;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExtensionBangumiWatchSubtitle create() =>
      ExtensionBangumiWatchSubtitle._();
  @$core.override
  ExtensionBangumiWatchSubtitle createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExtensionBangumiWatchSubtitle getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExtensionBangumiWatchSubtitle>(create);
  static ExtensionBangumiWatchSubtitle? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get language => $_getSZ(0);
  @$pb.TagNumber(1)
  set language($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLanguage() => $_has(0);
  @$pb.TagNumber(1)
  void clearLanguage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => $_clearField(3);
}

class ExtensionBangumiWatchTorrentFileTreeFile extends $pb.GeneratedMessage {
  factory ExtensionBangumiWatchTorrentFileTreeFile({
    $fixnum.Int64? length,
    $core.String? piecesRoot,
  }) {
    final result = create();
    if (length != null) result.length = length;
    if (piecesRoot != null) result.piecesRoot = piecesRoot;
    return result;
  }

  ExtensionBangumiWatchTorrentFileTreeFile._();

  factory ExtensionBangumiWatchTorrentFileTreeFile.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExtensionBangumiWatchTorrentFileTreeFile.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExtensionBangumiWatchTorrentFileTreeFile',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'length')
    ..aOS(2, _omitFieldNames ? '' : 'piecesRoot', protoName: 'piecesRoot')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionBangumiWatchTorrentFileTreeFile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionBangumiWatchTorrentFileTreeFile copyWith(
          void Function(ExtensionBangumiWatchTorrentFileTreeFile) updates) =>
      super.copyWith((message) =>
              updates(message as ExtensionBangumiWatchTorrentFileTreeFile))
          as ExtensionBangumiWatchTorrentFileTreeFile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExtensionBangumiWatchTorrentFileTreeFile create() =>
      ExtensionBangumiWatchTorrentFileTreeFile._();
  @$core.override
  ExtensionBangumiWatchTorrentFileTreeFile createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExtensionBangumiWatchTorrentFileTreeFile getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          ExtensionBangumiWatchTorrentFileTreeFile>(create);
  static ExtensionBangumiWatchTorrentFileTreeFile? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get length => $_getI64(0);
  @$pb.TagNumber(1)
  set length($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLength() => $_has(0);
  @$pb.TagNumber(1)
  void clearLength() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get piecesRoot => $_getSZ(1);
  @$pb.TagNumber(2)
  set piecesRoot($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPiecesRoot() => $_has(1);
  @$pb.TagNumber(2)
  void clearPiecesRoot() => $_clearField(2);
}

class ExtensionBangumiWatchTorrentFileTree extends $pb.GeneratedMessage {
  factory ExtensionBangumiWatchTorrentFileTree({
    ExtensionBangumiWatchTorrentFileTreeFile? file,
    $core.Iterable<
            $core.MapEntry<$core.String, ExtensionBangumiWatchTorrentFileTree>>?
        dir,
  }) {
    final result = create();
    if (file != null) result.file = file;
    if (dir != null) result.dir.addEntries(dir);
    return result;
  }

  ExtensionBangumiWatchTorrentFileTree._();

  factory ExtensionBangumiWatchTorrentFileTree.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExtensionBangumiWatchTorrentFileTree.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExtensionBangumiWatchTorrentFileTree',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOM<ExtensionBangumiWatchTorrentFileTreeFile>(
        1, _omitFieldNames ? '' : 'file',
        subBuilder: ExtensionBangumiWatchTorrentFileTreeFile.create)
    ..m<$core.String, ExtensionBangumiWatchTorrentFileTree>(
        2, _omitFieldNames ? '' : 'dir',
        entryClassName: 'ExtensionBangumiWatchTorrentFileTree.DirEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: ExtensionBangumiWatchTorrentFileTree.create,
        valueDefaultOrMaker: ExtensionBangumiWatchTorrentFileTree.getDefault,
        packageName: const $pb.PackageName('miru'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionBangumiWatchTorrentFileTree clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionBangumiWatchTorrentFileTree copyWith(
          void Function(ExtensionBangumiWatchTorrentFileTree) updates) =>
      super.copyWith((message) =>
              updates(message as ExtensionBangumiWatchTorrentFileTree))
          as ExtensionBangumiWatchTorrentFileTree;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExtensionBangumiWatchTorrentFileTree create() =>
      ExtensionBangumiWatchTorrentFileTree._();
  @$core.override
  ExtensionBangumiWatchTorrentFileTree createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExtensionBangumiWatchTorrentFileTree getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          ExtensionBangumiWatchTorrentFileTree>(create);
  static ExtensionBangumiWatchTorrentFileTree? _defaultInstance;

  @$pb.TagNumber(1)
  ExtensionBangumiWatchTorrentFileTreeFile get file => $_getN(0);
  @$pb.TagNumber(1)
  set file(ExtensionBangumiWatchTorrentFileTreeFile value) =>
      $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearFile() => $_clearField(1);
  @$pb.TagNumber(1)
  ExtensionBangumiWatchTorrentFileTreeFile ensureFile() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, ExtensionBangumiWatchTorrentFileTree> get dir =>
      $_getMap(1);
}

class ExtensionBangumiWatchTorrentDetail extends $pb.GeneratedMessage {
  factory ExtensionBangumiWatchTorrentDetail({
    $core.int? pieceLength,
    $core.String? pieces,
    $core.String? name,
    $core.String? nameUtf8,
    $fixnum.Int64? length,
    $core.String? source,
    $core.int? metaVersion,
    ExtensionBangumiWatchTorrentFileTree? fileTree,
  }) {
    final result = create();
    if (pieceLength != null) result.pieceLength = pieceLength;
    if (pieces != null) result.pieces = pieces;
    if (name != null) result.name = name;
    if (nameUtf8 != null) result.nameUtf8 = nameUtf8;
    if (length != null) result.length = length;
    if (source != null) result.source = source;
    if (metaVersion != null) result.metaVersion = metaVersion;
    if (fileTree != null) result.fileTree = fileTree;
    return result;
  }

  ExtensionBangumiWatchTorrentDetail._();

  factory ExtensionBangumiWatchTorrentDetail.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExtensionBangumiWatchTorrentDetail.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExtensionBangumiWatchTorrentDetail',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pieceLength', protoName: 'pieceLength')
    ..aOS(2, _omitFieldNames ? '' : 'pieces')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'nameUtf8', protoName: 'nameUtf8')
    ..aInt64(5, _omitFieldNames ? '' : 'length')
    ..aOS(6, _omitFieldNames ? '' : 'source')
    ..aI(7, _omitFieldNames ? '' : 'metaVersion', protoName: 'metaVersion')
    ..aOM<ExtensionBangumiWatchTorrentFileTree>(
        8, _omitFieldNames ? '' : 'fileTree',
        protoName: 'fileTree',
        subBuilder: ExtensionBangumiWatchTorrentFileTree.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionBangumiWatchTorrentDetail clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionBangumiWatchTorrentDetail copyWith(
          void Function(ExtensionBangumiWatchTorrentDetail) updates) =>
      super.copyWith((message) =>
              updates(message as ExtensionBangumiWatchTorrentDetail))
          as ExtensionBangumiWatchTorrentDetail;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExtensionBangumiWatchTorrentDetail create() =>
      ExtensionBangumiWatchTorrentDetail._();
  @$core.override
  ExtensionBangumiWatchTorrentDetail createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExtensionBangumiWatchTorrentDetail getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExtensionBangumiWatchTorrentDetail>(
          create);
  static ExtensionBangumiWatchTorrentDetail? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pieceLength => $_getIZ(0);
  @$pb.TagNumber(1)
  set pieceLength($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPieceLength() => $_has(0);
  @$pb.TagNumber(1)
  void clearPieceLength() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pieces => $_getSZ(1);
  @$pb.TagNumber(2)
  set pieces($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPieces() => $_has(1);
  @$pb.TagNumber(2)
  void clearPieces() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get nameUtf8 => $_getSZ(3);
  @$pb.TagNumber(4)
  set nameUtf8($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNameUtf8() => $_has(3);
  @$pb.TagNumber(4)
  void clearNameUtf8() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get length => $_getI64(4);
  @$pb.TagNumber(5)
  set length($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLength() => $_has(4);
  @$pb.TagNumber(5)
  void clearLength() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get source => $_getSZ(5);
  @$pb.TagNumber(6)
  set source($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSource() => $_has(5);
  @$pb.TagNumber(6)
  void clearSource() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get metaVersion => $_getIZ(6);
  @$pb.TagNumber(7)
  set metaVersion($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMetaVersion() => $_has(6);
  @$pb.TagNumber(7)
  void clearMetaVersion() => $_clearField(7);

  @$pb.TagNumber(8)
  ExtensionBangumiWatchTorrentFileTree get fileTree => $_getN(7);
  @$pb.TagNumber(8)
  set fileTree(ExtensionBangumiWatchTorrentFileTree value) =>
      $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasFileTree() => $_has(7);
  @$pb.TagNumber(8)
  void clearFileTree() => $_clearField(8);
  @$pb.TagNumber(8)
  ExtensionBangumiWatchTorrentFileTree ensureFileTree() => $_ensure(7);
}

class ExtensionBangumiWatchTorrent extends $pb.GeneratedMessage {
  factory ExtensionBangumiWatchTorrent({
    $core.String? infoHash,
    ExtensionBangumiWatchTorrentDetail? detail,
    $core.Iterable<$core.String>? files,
  }) {
    final result = create();
    if (infoHash != null) result.infoHash = infoHash;
    if (detail != null) result.detail = detail;
    if (files != null) result.files.addAll(files);
    return result;
  }

  ExtensionBangumiWatchTorrent._();

  factory ExtensionBangumiWatchTorrent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExtensionBangumiWatchTorrent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExtensionBangumiWatchTorrent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'infoHash', protoName: 'infoHash')
    ..aOM<ExtensionBangumiWatchTorrentDetail>(
        2, _omitFieldNames ? '' : 'detail',
        subBuilder: ExtensionBangumiWatchTorrentDetail.create)
    ..pPS(3, _omitFieldNames ? '' : 'files')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionBangumiWatchTorrent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionBangumiWatchTorrent copyWith(
          void Function(ExtensionBangumiWatchTorrent) updates) =>
      super.copyWith(
              (message) => updates(message as ExtensionBangumiWatchTorrent))
          as ExtensionBangumiWatchTorrent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExtensionBangumiWatchTorrent create() =>
      ExtensionBangumiWatchTorrent._();
  @$core.override
  ExtensionBangumiWatchTorrent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExtensionBangumiWatchTorrent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExtensionBangumiWatchTorrent>(create);
  static ExtensionBangumiWatchTorrent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get infoHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set infoHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInfoHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearInfoHash() => $_clearField(1);

  @$pb.TagNumber(2)
  ExtensionBangumiWatchTorrentDetail get detail => $_getN(1);
  @$pb.TagNumber(2)
  set detail(ExtensionBangumiWatchTorrentDetail value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDetail() => $_has(1);
  @$pb.TagNumber(2)
  void clearDetail() => $_clearField(2);
  @$pb.TagNumber(2)
  ExtensionBangumiWatchTorrentDetail ensureDetail() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get files => $_getList(2);
}

class ExtensionBangumiWatch extends $pb.GeneratedMessage {
  factory ExtensionBangumiWatch({
    $core.String? type,
    $core.String? url,
    $core.Iterable<ExtensionBangumiWatchSubtitle>? subtitles,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? headers,
    $core.String? audioTrack,
    ExtensionBangumiWatchTorrent? torrent,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (url != null) result.url = url;
    if (subtitles != null) result.subtitles.addAll(subtitles);
    if (headers != null) result.headers.addEntries(headers);
    if (audioTrack != null) result.audioTrack = audioTrack;
    if (torrent != null) result.torrent = torrent;
    return result;
  }

  ExtensionBangumiWatch._();

  factory ExtensionBangumiWatch.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExtensionBangumiWatch.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExtensionBangumiWatch',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..pPM<ExtensionBangumiWatchSubtitle>(3, _omitFieldNames ? '' : 'subtitles',
        subBuilder: ExtensionBangumiWatchSubtitle.create)
    ..m<$core.String, $core.String>(4, _omitFieldNames ? '' : 'headers',
        entryClassName: 'ExtensionBangumiWatch.HeadersEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('miru'))
    ..aOS(5, _omitFieldNames ? '' : 'audioTrack', protoName: 'audioTrack')
    ..aOM<ExtensionBangumiWatchTorrent>(6, _omitFieldNames ? '' : 'torrent',
        subBuilder: ExtensionBangumiWatchTorrent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionBangumiWatch clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionBangumiWatch copyWith(
          void Function(ExtensionBangumiWatch) updates) =>
      super.copyWith((message) => updates(message as ExtensionBangumiWatch))
          as ExtensionBangumiWatch;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExtensionBangumiWatch create() => ExtensionBangumiWatch._();
  @$core.override
  ExtensionBangumiWatch createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExtensionBangumiWatch getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExtensionBangumiWatch>(create);
  static ExtensionBangumiWatch? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<ExtensionBangumiWatchSubtitle> get subtitles => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, $core.String> get headers => $_getMap(3);

  @$pb.TagNumber(5)
  $core.String get audioTrack => $_getSZ(4);
  @$pb.TagNumber(5)
  set audioTrack($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAudioTrack() => $_has(4);
  @$pb.TagNumber(5)
  void clearAudioTrack() => $_clearField(5);

  @$pb.TagNumber(6)
  ExtensionBangumiWatchTorrent get torrent => $_getN(5);
  @$pb.TagNumber(6)
  set torrent(ExtensionBangumiWatchTorrent value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasTorrent() => $_has(5);
  @$pb.TagNumber(6)
  void clearTorrent() => $_clearField(6);
  @$pb.TagNumber(6)
  ExtensionBangumiWatchTorrent ensureTorrent() => $_ensure(5);
}

class ExtensionMangaWatch extends $pb.GeneratedMessage {
  factory ExtensionMangaWatch({
    $core.Iterable<$core.String>? urls,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? headers,
  }) {
    final result = create();
    if (urls != null) result.urls.addAll(urls);
    if (headers != null) result.headers.addEntries(headers);
    return result;
  }

  ExtensionMangaWatch._();

  factory ExtensionMangaWatch.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExtensionMangaWatch.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExtensionMangaWatch',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'urls')
    ..m<$core.String, $core.String>(2, _omitFieldNames ? '' : 'headers',
        entryClassName: 'ExtensionMangaWatch.HeadersEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('miru'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionMangaWatch clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionMangaWatch copyWith(void Function(ExtensionMangaWatch) updates) =>
      super.copyWith((message) => updates(message as ExtensionMangaWatch))
          as ExtensionMangaWatch;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExtensionMangaWatch create() => ExtensionMangaWatch._();
  @$core.override
  ExtensionMangaWatch createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExtensionMangaWatch getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExtensionMangaWatch>(create);
  static ExtensionMangaWatch? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get urls => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, $core.String> get headers => $_getMap(1);
}

class ExtensionFikushonWatch extends $pb.GeneratedMessage {
  factory ExtensionFikushonWatch({
    $core.Iterable<$core.String>? content,
    $core.String? title,
    $core.String? subtitle,
  }) {
    final result = create();
    if (content != null) result.content.addAll(content);
    if (title != null) result.title = title;
    if (subtitle != null) result.subtitle = subtitle;
    return result;
  }

  ExtensionFikushonWatch._();

  factory ExtensionFikushonWatch.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExtensionFikushonWatch.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExtensionFikushonWatch',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'content')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'subtitle')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionFikushonWatch clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionFikushonWatch copyWith(
          void Function(ExtensionFikushonWatch) updates) =>
      super.copyWith((message) => updates(message as ExtensionFikushonWatch))
          as ExtensionFikushonWatch;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExtensionFikushonWatch create() => ExtensionFikushonWatch._();
  @$core.override
  ExtensionFikushonWatch createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExtensionFikushonWatch getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExtensionFikushonWatch>(create);
  static ExtensionFikushonWatch? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get content => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get subtitle => $_getSZ(2);
  @$pb.TagNumber(3)
  set subtitle($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSubtitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearSubtitle() => $_clearField(3);
}

class GithubExtension extends $pb.GeneratedMessage {
  factory GithubExtension({
    $core.String? name,
    $core.String? description,
    $core.String? license,
    $core.String? version,
    $core.String? author,
    $core.String? icon,
    $core.String? type,
    $core.String? lang,
    $core.String? webSite,
    $core.bool? nsfw,
    $core.String? package,
    $core.Iterable<$core.String>? tags,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (license != null) result.license = license;
    if (version != null) result.version = version;
    if (author != null) result.author = author;
    if (icon != null) result.icon = icon;
    if (type != null) result.type = type;
    if (lang != null) result.lang = lang;
    if (webSite != null) result.webSite = webSite;
    if (nsfw != null) result.nsfw = nsfw;
    if (package != null) result.package = package;
    if (tags != null) result.tags.addAll(tags);
    return result;
  }

  GithubExtension._();

  factory GithubExtension.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GithubExtension.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GithubExtension',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aOS(3, _omitFieldNames ? '' : 'license')
    ..aOS(4, _omitFieldNames ? '' : 'version')
    ..aOS(5, _omitFieldNames ? '' : 'author')
    ..aOS(6, _omitFieldNames ? '' : 'icon')
    ..aOS(7, _omitFieldNames ? '' : 'type')
    ..aOS(8, _omitFieldNames ? '' : 'lang')
    ..aOS(9, _omitFieldNames ? '' : 'webSite', protoName: 'webSite')
    ..aOB(10, _omitFieldNames ? '' : 'nsfw')
    ..aOS(11, _omitFieldNames ? '' : 'package')
    ..pPS(12, _omitFieldNames ? '' : 'tags')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GithubExtension clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GithubExtension copyWith(void Function(GithubExtension) updates) =>
      super.copyWith((message) => updates(message as GithubExtension))
          as GithubExtension;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GithubExtension create() => GithubExtension._();
  @$core.override
  GithubExtension createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GithubExtension getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GithubExtension>(create);
  static GithubExtension? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get license => $_getSZ(2);
  @$pb.TagNumber(3)
  set license($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLicense() => $_has(2);
  @$pb.TagNumber(3)
  void clearLicense() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get version => $_getSZ(3);
  @$pb.TagNumber(4)
  set version($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get author => $_getSZ(4);
  @$pb.TagNumber(5)
  set author($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAuthor() => $_has(4);
  @$pb.TagNumber(5)
  void clearAuthor() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get icon => $_getSZ(5);
  @$pb.TagNumber(6)
  set icon($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIcon() => $_has(5);
  @$pb.TagNumber(6)
  void clearIcon() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get type => $_getSZ(6);
  @$pb.TagNumber(7)
  set type($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasType() => $_has(6);
  @$pb.TagNumber(7)
  void clearType() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get lang => $_getSZ(7);
  @$pb.TagNumber(8)
  set lang($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLang() => $_has(7);
  @$pb.TagNumber(8)
  void clearLang() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get webSite => $_getSZ(8);
  @$pb.TagNumber(9)
  set webSite($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasWebSite() => $_has(8);
  @$pb.TagNumber(9)
  void clearWebSite() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get nsfw => $_getBF(9);
  @$pb.TagNumber(10)
  set nsfw($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNsfw() => $_has(9);
  @$pb.TagNumber(10)
  void clearNsfw() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get package => $_getSZ(10);
  @$pb.TagNumber(11)
  set package($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPackage() => $_has(10);
  @$pb.TagNumber(11)
  void clearPackage() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<$core.String> get tags => $_getList(11);
}

class ExtensionRepo extends $pb.GeneratedMessage {
  factory ExtensionRepo({
    $core.Iterable<GithubExtension>? extensions,
    $core.String? name,
    $core.String? url,
  }) {
    final result = create();
    if (extensions != null) result.extensions.addAll(extensions);
    if (name != null) result.name = name;
    if (url != null) result.url = url;
    return result;
  }

  ExtensionRepo._();

  factory ExtensionRepo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExtensionRepo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExtensionRepo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<GithubExtension>(1, _omitFieldNames ? '' : 'extensions',
        subBuilder: GithubExtension.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionRepo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionRepo copyWith(void Function(ExtensionRepo) updates) =>
      super.copyWith((message) => updates(message as ExtensionRepo))
          as ExtensionRepo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExtensionRepo create() => ExtensionRepo._();
  @$core.override
  ExtensionRepo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExtensionRepo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExtensionRepo>(create);
  static ExtensionRepo? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GithubExtension> get extensions => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => $_clearField(3);
}

class RepoConfig extends $pb.GeneratedMessage {
  factory RepoConfig({
    $core.String? link,
    $core.String? name,
    $core.int? id,
  }) {
    final result = create();
    if (link != null) result.link = link;
    if (name != null) result.name = name;
    if (id != null) result.id = id;
    return result;
  }

  RepoConfig._();

  factory RepoConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RepoConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RepoConfig',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'link')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aI(3, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepoConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RepoConfig copyWith(void Function(RepoConfig) updates) =>
      super.copyWith((message) => updates(message as RepoConfig)) as RepoConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RepoConfig create() => RepoConfig._();
  @$core.override
  RepoConfig createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RepoConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RepoConfig>(create);
  static RepoConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get link => $_getSZ(0);
  @$pb.TagNumber(1)
  set link($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLink() => $_has(0);
  @$pb.TagNumber(1)
  void clearLink() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get id => $_getIZ(2);
  @$pb.TagNumber(3)
  set id($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
