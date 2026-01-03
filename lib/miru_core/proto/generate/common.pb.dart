// This is a generated file - do not edit.
//
// Generated from common.proto.

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

class ExtensionMeta extends $pb.GeneratedMessage {
  factory ExtensionMeta({
    $core.String? name,
    $core.String? version,
    $core.String? author,
    $core.String? license,
    $core.String? lang,
    $core.String? icon,
    $core.String? package,
    $core.String? webSite,
    $core.String? description,
    $core.Iterable<$core.String>? tags,
    $core.String? api,
    $core.String? error,
    $core.String? type,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (version != null) result.version = version;
    if (author != null) result.author = author;
    if (license != null) result.license = license;
    if (lang != null) result.lang = lang;
    if (icon != null) result.icon = icon;
    if (package != null) result.package = package;
    if (webSite != null) result.webSite = webSite;
    if (description != null) result.description = description;
    if (tags != null) result.tags.addAll(tags);
    if (api != null) result.api = api;
    if (error != null) result.error = error;
    if (type != null) result.type = type;
    return result;
  }

  ExtensionMeta._();

  factory ExtensionMeta.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExtensionMeta.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExtensionMeta',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'version')
    ..aOS(3, _omitFieldNames ? '' : 'author')
    ..aOS(4, _omitFieldNames ? '' : 'license')
    ..aOS(5, _omitFieldNames ? '' : 'lang')
    ..aOS(6, _omitFieldNames ? '' : 'icon')
    ..aOS(7, _omitFieldNames ? '' : 'package')
    ..aOS(8, _omitFieldNames ? '' : 'webSite', protoName: 'webSite')
    ..aOS(9, _omitFieldNames ? '' : 'description')
    ..pPS(10, _omitFieldNames ? '' : 'tags')
    ..aOS(11, _omitFieldNames ? '' : 'api')
    ..aOS(12, _omitFieldNames ? '' : 'error')
    ..aOS(13, _omitFieldNames ? '' : 'type')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionMeta clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionMeta copyWith(void Function(ExtensionMeta) updates) =>
      super.copyWith((message) => updates(message as ExtensionMeta))
          as ExtensionMeta;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExtensionMeta create() => ExtensionMeta._();
  @$core.override
  ExtensionMeta createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExtensionMeta getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExtensionMeta>(create);
  static ExtensionMeta? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get version => $_getSZ(1);
  @$pb.TagNumber(2)
  set version($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get author => $_getSZ(2);
  @$pb.TagNumber(3)
  set author($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAuthor() => $_has(2);
  @$pb.TagNumber(3)
  void clearAuthor() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get license => $_getSZ(3);
  @$pb.TagNumber(4)
  set license($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLicense() => $_has(3);
  @$pb.TagNumber(4)
  void clearLicense() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get lang => $_getSZ(4);
  @$pb.TagNumber(5)
  set lang($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLang() => $_has(4);
  @$pb.TagNumber(5)
  void clearLang() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get icon => $_getSZ(5);
  @$pb.TagNumber(6)
  set icon($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIcon() => $_has(5);
  @$pb.TagNumber(6)
  void clearIcon() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get package => $_getSZ(6);
  @$pb.TagNumber(7)
  set package($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPackage() => $_has(6);
  @$pb.TagNumber(7)
  void clearPackage() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get webSite => $_getSZ(7);
  @$pb.TagNumber(8)
  set webSite($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasWebSite() => $_has(7);
  @$pb.TagNumber(8)
  void clearWebSite() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get description => $_getSZ(8);
  @$pb.TagNumber(9)
  set description($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDescription() => $_has(8);
  @$pb.TagNumber(9)
  void clearDescription() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get tags => $_getList(9);

  @$pb.TagNumber(11)
  $core.String get api => $_getSZ(10);
  @$pb.TagNumber(11)
  set api($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasApi() => $_has(10);
  @$pb.TagNumber(11)
  void clearApi() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get error => $_getSZ(11);
  @$pb.TagNumber(12)
  set error($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasError() => $_has(11);
  @$pb.TagNumber(12)
  void clearError() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get type => $_getSZ(12);
  @$pb.TagNumber(13)
  set type($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasType() => $_has(12);
  @$pb.TagNumber(13)
  void clearType() => $_clearField(13);
}

class DownloadProgress extends $pb.GeneratedMessage {
  factory DownloadProgress({
    $core.int? progress,
    $core.Iterable<$core.String>? names,
    $core.int? total,
    $core.String? status,
    $core.String? mediaType,
    $core.String? currentDownloading,
    $core.int? taskId,
    $core.String? title,
    $core.String? package,
    $core.String? key,
  }) {
    final result = create();
    if (progress != null) result.progress = progress;
    if (names != null) result.names.addAll(names);
    if (total != null) result.total = total;
    if (status != null) result.status = status;
    if (mediaType != null) result.mediaType = mediaType;
    if (currentDownloading != null)
      result.currentDownloading = currentDownloading;
    if (taskId != null) result.taskId = taskId;
    if (title != null) result.title = title;
    if (package != null) result.package = package;
    if (key != null) result.key = key;
    return result;
  }

  DownloadProgress._();

  factory DownloadProgress.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DownloadProgress.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DownloadProgress',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'progress')
    ..pPS(2, _omitFieldNames ? '' : 'names')
    ..aI(3, _omitFieldNames ? '' : 'total')
    ..aOS(4, _omitFieldNames ? '' : 'status')
    ..aOS(5, _omitFieldNames ? '' : 'mediaType')
    ..aOS(6, _omitFieldNames ? '' : 'currentDownloading')
    ..aI(7, _omitFieldNames ? '' : 'taskId')
    ..aOS(8, _omitFieldNames ? '' : 'title')
    ..aOS(9, _omitFieldNames ? '' : 'package')
    ..aOS(10, _omitFieldNames ? '' : 'key')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadProgress clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadProgress copyWith(void Function(DownloadProgress) updates) =>
      super.copyWith((message) => updates(message as DownloadProgress))
          as DownloadProgress;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadProgress create() => DownloadProgress._();
  @$core.override
  DownloadProgress createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DownloadProgress getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DownloadProgress>(create);
  static DownloadProgress? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get progress => $_getIZ(0);
  @$pb.TagNumber(1)
  set progress($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProgress() => $_has(0);
  @$pb.TagNumber(1)
  void clearProgress() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get names => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get total => $_getIZ(2);
  @$pb.TagNumber(3)
  set total($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotal() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotal() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get status => $_getSZ(3);
  @$pb.TagNumber(4)
  set status($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get mediaType => $_getSZ(4);
  @$pb.TagNumber(5)
  set mediaType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMediaType() => $_has(4);
  @$pb.TagNumber(5)
  void clearMediaType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get currentDownloading => $_getSZ(5);
  @$pb.TagNumber(6)
  set currentDownloading($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCurrentDownloading() => $_has(5);
  @$pb.TagNumber(6)
  void clearCurrentDownloading() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get taskId => $_getIZ(6);
  @$pb.TagNumber(7)
  set taskId($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTaskId() => $_has(6);
  @$pb.TagNumber(7)
  void clearTaskId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get title => $_getSZ(7);
  @$pb.TagNumber(8)
  set title($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTitle() => $_has(7);
  @$pb.TagNumber(8)
  void clearTitle() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get package => $_getSZ(8);
  @$pb.TagNumber(9)
  set package($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPackage() => $_has(8);
  @$pb.TagNumber(9)
  void clearPackage() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get key => $_getSZ(9);
  @$pb.TagNumber(10)
  set key($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasKey() => $_has(9);
  @$pb.TagNumber(10)
  void clearKey() => $_clearField(10);
}

class TorrentStats extends $pb.GeneratedMessage {
  factory TorrentStats({
    $fixnum.Int64? totalDown,
    $fixnum.Int64? totalUp,
  }) {
    final result = create();
    if (totalDown != null) result.totalDown = totalDown;
    if (totalUp != null) result.totalUp = totalUp;
    return result;
  }

  TorrentStats._();

  factory TorrentStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TorrentStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TorrentStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'totalDown')
    ..aInt64(2, _omitFieldNames ? '' : 'totalUp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TorrentStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TorrentStats copyWith(void Function(TorrentStats) updates) =>
      super.copyWith((message) => updates(message as TorrentStats))
          as TorrentStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TorrentStats create() => TorrentStats._();
  @$core.override
  TorrentStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TorrentStats getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TorrentStats>(create);
  static TorrentStats? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get totalDown => $_getI64(0);
  @$pb.TagNumber(1)
  set totalDown($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotalDown() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalDown() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalUp => $_getI64(1);
  @$pb.TagNumber(2)
  set totalUp($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalUp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalUp() => $_clearField(2);
}

class ExtensionListItem extends $pb.GeneratedMessage {
  factory ExtensionListItem({
    $core.String? title,
    $core.String? url,
    $core.String? cover,
    $core.String? update,
  }) {
    final result = create();
    if (title != null) result.title = title;
    if (url != null) result.url = url;
    if (cover != null) result.cover = cover;
    if (update != null) result.update = update;
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
}

class AvailableHlsVariant extends $pb.GeneratedMessage {
  factory AvailableHlsVariant({
    $core.String? resolution,
    $core.String? url,
    $core.String? codec,
  }) {
    final result = create();
    if (resolution != null) result.resolution = resolution;
    if (url != null) result.url = url;
    if (codec != null) result.codec = codec;
    return result;
  }

  AvailableHlsVariant._();

  factory AvailableHlsVariant.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AvailableHlsVariant.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AvailableHlsVariant',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'resolution')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..aOS(3, _omitFieldNames ? '' : 'codec')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AvailableHlsVariant clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AvailableHlsVariant copyWith(void Function(AvailableHlsVariant) updates) =>
      super.copyWith((message) => updates(message as AvailableHlsVariant))
          as AvailableHlsVariant;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AvailableHlsVariant create() => AvailableHlsVariant._();
  @$core.override
  AvailableHlsVariant createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AvailableHlsVariant getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AvailableHlsVariant>(create);
  static AvailableHlsVariant? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get resolution => $_getSZ(0);
  @$pb.TagNumber(1)
  set resolution($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasResolution() => $_has(0);
  @$pb.TagNumber(1)
  void clearResolution() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get codec => $_getSZ(2);
  @$pb.TagNumber(3)
  set codec($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCodec() => $_has(2);
  @$pb.TagNumber(3)
  void clearCodec() => $_clearField(3);
}

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

/// Download
class Download extends $pb.GeneratedMessage {
  factory Download({
    $core.int? id,
    $core.Iterable<$core.String>? url,
    $core.String? headers,
    $core.String? package,
    $core.Iterable<$core.int>? progress,
    $core.String? key,
    $core.String? title,
    $core.String? mediaType,
    $core.String? status,
    $core.String? savePath,
    $core.String? date,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (url != null) result.url.addAll(url);
    if (headers != null) result.headers = headers;
    if (package != null) result.package = package;
    if (progress != null) result.progress.addAll(progress);
    if (key != null) result.key = key;
    if (title != null) result.title = title;
    if (mediaType != null) result.mediaType = mediaType;
    if (status != null) result.status = status;
    if (savePath != null) result.savePath = savePath;
    if (date != null) result.date = date;
    return result;
  }

  Download._();

  factory Download.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Download.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Download',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..pPS(2, _omitFieldNames ? '' : 'url')
    ..aOS(3, _omitFieldNames ? '' : 'headers')
    ..aOS(4, _omitFieldNames ? '' : 'package')
    ..p<$core.int>(5, _omitFieldNames ? '' : 'progress', $pb.PbFieldType.K3)
    ..aOS(6, _omitFieldNames ? '' : 'key')
    ..aOS(7, _omitFieldNames ? '' : 'title')
    ..aOS(8, _omitFieldNames ? '' : 'mediaType')
    ..aOS(9, _omitFieldNames ? '' : 'status')
    ..aOS(10, _omitFieldNames ? '' : 'savePath')
    ..aOS(11, _omitFieldNames ? '' : 'date')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Download clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Download copyWith(void Function(Download) updates) =>
      super.copyWith((message) => updates(message as Download)) as Download;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Download create() => Download._();
  @$core.override
  Download createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Download getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Download>(create);
  static Download? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get url => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get headers => $_getSZ(2);
  @$pb.TagNumber(3)
  set headers($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeaders() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeaders() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get package => $_getSZ(3);
  @$pb.TagNumber(4)
  set package($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPackage() => $_has(3);
  @$pb.TagNumber(4)
  void clearPackage() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.int> get progress => $_getList(4);

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
  $core.String get mediaType => $_getSZ(7);
  @$pb.TagNumber(8)
  set mediaType($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMediaType() => $_has(7);
  @$pb.TagNumber(8)
  void clearMediaType() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get status => $_getSZ(8);
  @$pb.TagNumber(9)
  set status($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatus() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get savePath => $_getSZ(9);
  @$pb.TagNumber(10)
  set savePath($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasSavePath() => $_has(9);
  @$pb.TagNumber(10)
  void clearSavePath() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get date => $_getSZ(10);
  @$pb.TagNumber(11)
  set date($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasDate() => $_has(10);
  @$pb.TagNumber(11)
  void clearDate() => $_clearField(11);
}

/// Torrent
class TorrentResult extends $pb.GeneratedMessage {
  factory TorrentResult({
    $core.String? infoHash,
    $core.String? name,
    $core.Iterable<$core.String>? files,
  }) {
    final result = create();
    if (infoHash != null) result.infoHash = infoHash;
    if (name != null) result.name = name;
    if (files != null) result.files.addAll(files);
    return result;
  }

  TorrentResult._();

  factory TorrentResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TorrentResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TorrentResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'infoHash')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..pPS(3, _omitFieldNames ? '' : 'files')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TorrentResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TorrentResult copyWith(void Function(TorrentResult) updates) =>
      super.copyWith((message) => updates(message as TorrentResult))
          as TorrentResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TorrentResult create() => TorrentResult._();
  @$core.override
  TorrentResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TorrentResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TorrentResult>(create);
  static TorrentResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get infoHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set infoHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInfoHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearInfoHash() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get files => $_getList(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
