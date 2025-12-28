// This is a generated file - do not edit.
//
// Generated from miru_core_service.proto.

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

class WatchEventsRequest extends $pb.GeneratedMessage {
  factory WatchEventsRequest() => create();

  WatchEventsRequest._();

  factory WatchEventsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WatchEventsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchEventsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchEventsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchEventsRequest copyWith(void Function(WatchEventsRequest) updates) =>
      super.copyWith((message) => updates(message as WatchEventsRequest))
          as WatchEventsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WatchEventsRequest create() => WatchEventsRequest._();
  @$core.override
  WatchEventsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WatchEventsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchEventsRequest>(create);
  static WatchEventsRequest? _defaultInstance;
}

enum WatchEventsResponse_Event { downloadEvent, extensionEvent, notSet }

class WatchEventsResponse extends $pb.GeneratedMessage {
  factory WatchEventsResponse({
    DownloadEvent? downloadEvent,
    ExtensionEvent? extensionEvent,
  }) {
    final result = create();
    if (downloadEvent != null) result.downloadEvent = downloadEvent;
    if (extensionEvent != null) result.extensionEvent = extensionEvent;
    return result;
  }

  WatchEventsResponse._();

  factory WatchEventsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WatchEventsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, WatchEventsResponse_Event>
      _WatchEventsResponse_EventByTag = {
    1: WatchEventsResponse_Event.downloadEvent,
    2: WatchEventsResponse_Event.extensionEvent,
    0: WatchEventsResponse_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchEventsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<DownloadEvent>(1, _omitFieldNames ? '' : 'downloadEvent',
        subBuilder: DownloadEvent.create)
    ..aOM<ExtensionEvent>(2, _omitFieldNames ? '' : 'extensionEvent',
        subBuilder: ExtensionEvent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchEventsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchEventsResponse copyWith(void Function(WatchEventsResponse) updates) =>
      super.copyWith((message) => updates(message as WatchEventsResponse))
          as WatchEventsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WatchEventsResponse create() => WatchEventsResponse._();
  @$core.override
  WatchEventsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WatchEventsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchEventsResponse>(create);
  static WatchEventsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  WatchEventsResponse_Event whichEvent() =>
      _WatchEventsResponse_EventByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearEvent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  DownloadEvent get downloadEvent => $_getN(0);
  @$pb.TagNumber(1)
  set downloadEvent(DownloadEvent value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDownloadEvent() => $_has(0);
  @$pb.TagNumber(1)
  void clearDownloadEvent() => $_clearField(1);
  @$pb.TagNumber(1)
  DownloadEvent ensureDownloadEvent() => $_ensure(0);

  @$pb.TagNumber(2)
  ExtensionEvent get extensionEvent => $_getN(1);
  @$pb.TagNumber(2)
  set extensionEvent(ExtensionEvent value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasExtensionEvent() => $_has(1);
  @$pb.TagNumber(2)
  void clearExtensionEvent() => $_clearField(2);
  @$pb.TagNumber(2)
  ExtensionEvent ensureExtensionEvent() => $_ensure(1);
}

class DownloadEvent extends $pb.GeneratedMessage {
  factory DownloadEvent({
    $core.Iterable<$core.MapEntry<$core.int, DownloadProgress>>? downloadStatus,
  }) {
    final result = create();
    if (downloadStatus != null)
      result.downloadStatus.addEntries(downloadStatus);
    return result;
  }

  DownloadEvent._();

  factory DownloadEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DownloadEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DownloadEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..m<$core.int, DownloadProgress>(1, _omitFieldNames ? '' : 'downloadStatus',
        entryClassName: 'DownloadEvent.DownloadStatusEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: DownloadProgress.create,
        valueDefaultOrMaker: DownloadProgress.getDefault,
        packageName: const $pb.PackageName('miru'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadEvent copyWith(void Function(DownloadEvent) updates) =>
      super.copyWith((message) => updates(message as DownloadEvent))
          as DownloadEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadEvent create() => DownloadEvent._();
  @$core.override
  DownloadEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DownloadEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DownloadEvent>(create);
  static DownloadEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.int, DownloadProgress> get downloadStatus => $_getMap(0);
}

class ExtensionEvent extends $pb.GeneratedMessage {
  factory ExtensionEvent({
    $core.Iterable<ExtensionMeta>? extensionMeta,
  }) {
    final result = create();
    if (extensionMeta != null) result.extensionMeta.addAll(extensionMeta);
    return result;
  }

  ExtensionEvent._();

  factory ExtensionEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExtensionEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExtensionEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<ExtensionMeta>(1, _omitFieldNames ? '' : 'extensionMeta',
        subBuilder: ExtensionMeta.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExtensionEvent copyWith(void Function(ExtensionEvent) updates) =>
      super.copyWith((message) => updates(message as ExtensionEvent))
          as ExtensionEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExtensionEvent create() => ExtensionEvent._();
  @$core.override
  ExtensionEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExtensionEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExtensionEvent>(create);
  static ExtensionEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ExtensionMeta> get extensionMeta => $_getList(0);
}

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

class SearchResponse extends $pb.GeneratedMessage {
  factory SearchResponse({
    $core.Iterable<ExtensionListItem>? items,
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
    ..pPM<ExtensionListItem>(1, _omitFieldNames ? '' : 'items',
        subBuilder: ExtensionListItem.create)
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
  $pb.PbList<ExtensionListItem> get items => $_getList(0);
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
    $core.Iterable<ExtensionListItem>? items,
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
    ..pPM<ExtensionListItem>(1, _omitFieldNames ? '' : 'items',
        subBuilder: ExtensionListItem.create)
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
  $pb.PbList<ExtensionListItem> get items => $_getList(0);
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
    $core.String? data,
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
    ..aOS(1, _omitFieldNames ? '' : 'data')
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
  $core.String get data => $_getSZ(0);
  @$pb.TagNumber(1)
  set data($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
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

class WatchResponse extends $pb.GeneratedMessage {
  factory WatchResponse({
    $core.String? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  WatchResponse._();

  factory WatchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WatchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'data')
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
  $core.String get data => $_getSZ(0);
  @$pb.TagNumber(1)
  set data($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
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

class HelloMiruRequest extends $pb.GeneratedMessage {
  factory HelloMiruRequest() => create();

  HelloMiruRequest._();

  factory HelloMiruRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HelloMiruRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HelloMiruRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HelloMiruRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HelloMiruRequest copyWith(void Function(HelloMiruRequest) updates) =>
      super.copyWith((message) => updates(message as HelloMiruRequest))
          as HelloMiruRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HelloMiruRequest create() => HelloMiruRequest._();
  @$core.override
  HelloMiruRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HelloMiruRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HelloMiruRequest>(create);
  static HelloMiruRequest? _defaultInstance;
}

class HelloMiruResponse extends $pb.GeneratedMessage {
  factory HelloMiruResponse({
    $core.Iterable<ExtensionMeta>? extensionMeta,
    $core.Iterable<$core.MapEntry<$core.int, DownloadProgress>>? downloadStatus,
    TorrentStats? torrent,
  }) {
    final result = create();
    if (extensionMeta != null) result.extensionMeta.addAll(extensionMeta);
    if (downloadStatus != null)
      result.downloadStatus.addEntries(downloadStatus);
    if (torrent != null) result.torrent = torrent;
    return result;
  }

  HelloMiruResponse._();

  factory HelloMiruResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HelloMiruResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HelloMiruResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<ExtensionMeta>(1, _omitFieldNames ? '' : 'extensionMeta',
        protoName: 'extensionMeta', subBuilder: ExtensionMeta.create)
    ..m<$core.int, DownloadProgress>(2, _omitFieldNames ? '' : 'downloadStatus',
        protoName: 'downloadStatus',
        entryClassName: 'HelloMiruResponse.DownloadStatusEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: DownloadProgress.create,
        valueDefaultOrMaker: DownloadProgress.getDefault,
        packageName: const $pb.PackageName('miru'))
    ..aOM<TorrentStats>(3, _omitFieldNames ? '' : 'torrent',
        subBuilder: TorrentStats.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HelloMiruResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HelloMiruResponse copyWith(void Function(HelloMiruResponse) updates) =>
      super.copyWith((message) => updates(message as HelloMiruResponse))
          as HelloMiruResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HelloMiruResponse create() => HelloMiruResponse._();
  @$core.override
  HelloMiruResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HelloMiruResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HelloMiruResponse>(create);
  static HelloMiruResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ExtensionMeta> get extensionMeta => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.int, DownloadProgress> get downloadStatus => $_getMap(1);

  @$pb.TagNumber(3)
  TorrentStats get torrent => $_getN(2);
  @$pb.TagNumber(3)
  set torrent(TorrentStats value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTorrent() => $_has(2);
  @$pb.TagNumber(3)
  void clearTorrent() => $_clearField(3);
  @$pb.TagNumber(3)
  TorrentStats ensureTorrent() => $_ensure(2);
}

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

  /// Add detailed stats later if needed, starting with basic counts or empty for
  /// now Since torrent.ClientStats is complex, we might just return summary
  /// stats
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
    $core.Iterable<Favorite>? favorites,
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
    ..pPM<Favorite>(1, _omitFieldNames ? '' : 'favorites',
        subBuilder: Favorite.create)
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
  $pb.PbList<Favorite> get favorites => $_getList(0);
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
    Favorite? favorite,
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
    ..aOM<Favorite>(1, _omitFieldNames ? '' : 'favorite',
        subBuilder: Favorite.create)
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
  Favorite get favorite => $_getN(0);
  @$pb.TagNumber(1)
  set favorite(Favorite value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFavorite() => $_has(0);
  @$pb.TagNumber(1)
  void clearFavorite() => $_clearField(1);
  @$pb.TagNumber(1)
  Favorite ensureFavorite() => $_ensure(0);
}

class PutFavoriteByIndexRequest extends $pb.GeneratedMessage {
  factory PutFavoriteByIndexRequest({
    $core.Iterable<FavoriteGroup>? groups,
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
    ..pPM<FavoriteGroup>(1, _omitFieldNames ? '' : 'groups',
        subBuilder: FavoriteGroup.create)
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
  $pb.PbList<FavoriteGroup> get groups => $_getList(0);
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
    Favorite? favorite,
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
    ..aOM<Favorite>(1, _omitFieldNames ? '' : 'favorite',
        subBuilder: Favorite.create)
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
  Favorite get favorite => $_getN(0);
  @$pb.TagNumber(1)
  set favorite(Favorite value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFavorite() => $_has(0);
  @$pb.TagNumber(1)
  void clearFavorite() => $_clearField(1);
  @$pb.TagNumber(1)
  Favorite ensureFavorite() => $_ensure(0);
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
    $core.Iterable<FavoriteGroup>? groups,
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
    ..pPM<FavoriteGroup>(1, _omitFieldNames ? '' : 'groups',
        subBuilder: FavoriteGroup.create)
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
  $pb.PbList<FavoriteGroup> get groups => $_getList(0);
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
    $core.Iterable<FavoriteGroup>? groups,
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
    ..pPM<FavoriteGroup>(1, _omitFieldNames ? '' : 'groups',
        subBuilder: FavoriteGroup.create)
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
  $pb.PbList<FavoriteGroup> get groups => $_getList(0);
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
    FavoriteGroup? group,
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
    ..aOM<FavoriteGroup>(1, _omitFieldNames ? '' : 'group',
        subBuilder: FavoriteGroup.create)
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
  FavoriteGroup get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(FavoriteGroup value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => $_clearField(1);
  @$pb.TagNumber(1)
  FavoriteGroup ensureGroup() => $_ensure(0);
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
    $core.Iterable<FavoriteGroup>? groups,
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
    ..pPM<FavoriteGroup>(1, _omitFieldNames ? '' : 'groups',
        subBuilder: FavoriteGroup.create)
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
  $pb.PbList<FavoriteGroup> get groups => $_getList(0);
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
    $core.Iterable<History>? histories,
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
    ..pPM<History>(1, _omitFieldNames ? '' : 'histories',
        subBuilder: History.create)
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
  $pb.PbList<History> get histories => $_getList(0);
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
    History? history,
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
    ..aOM<History>(1, _omitFieldNames ? '' : 'history',
        subBuilder: History.create)
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
  History get history => $_getN(0);
  @$pb.TagNumber(1)
  set history(History value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHistory() => $_has(0);
  @$pb.TagNumber(1)
  void clearHistory() => $_clearField(1);
  @$pb.TagNumber(1)
  History ensureHistory() => $_ensure(0);
}

class PutHistoryRequest extends $pb.GeneratedMessage {
  factory PutHistoryRequest({
    History? history,
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
    ..aOM<History>(1, _omitFieldNames ? '' : 'history',
        subBuilder: History.create)
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
  History get history => $_getN(0);
  @$pb.TagNumber(1)
  set history(History value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHistory() => $_has(0);
  @$pb.TagNumber(1)
  void clearHistory() => $_clearField(1);
  @$pb.TagNumber(1)
  History ensureHistory() => $_ensure(0);
}

class PutHistoryResponse extends $pb.GeneratedMessage {
  factory PutHistoryResponse({
    History? history,
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
    ..aOM<History>(1, _omitFieldNames ? '' : 'history',
        subBuilder: History.create)
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
  History get history => $_getN(0);
  @$pb.TagNumber(1)
  set history(History value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHistory() => $_has(0);
  @$pb.TagNumber(1)
  void clearHistory() => $_clearField(1);
  @$pb.TagNumber(1)
  History ensureHistory() => $_ensure(0);
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
    $core.Iterable<History>? histories,
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
    ..pPM<History>(1, _omitFieldNames ? '' : 'histories',
        subBuilder: History.create)
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
  $pb.PbList<History> get histories => $_getList(0);
}

/// Download
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
    $core.Iterable<$core.MapEntry<$core.int, DownloadProgress>>? downloadStatus,
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
    ..m<$core.int, DownloadProgress>(1, _omitFieldNames ? '' : 'downloadStatus',
        entryClassName: 'GetDownloadStatusResponse.DownloadStatusEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: DownloadProgress.create,
        valueDefaultOrMaker: DownloadProgress.getDefault,
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
  $pb.PbMap<$core.int, DownloadProgress> get downloadStatus => $_getMap(0);
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

class DownloadBangumiRequest extends $pb.GeneratedMessage {
  factory DownloadBangumiRequest({
    $core.String? url,
    $core.String? downloadPath,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? header,
    $core.bool? isHls,
    $core.String? package,
    $core.String? key,
    $core.String? title,
  }) {
    final result = create();
    if (url != null) result.url = url;
    if (downloadPath != null) result.downloadPath = downloadPath;
    if (header != null) result.header.addEntries(header);
    if (isHls != null) result.isHls = isHls;
    if (package != null) result.package = package;
    if (key != null) result.key = key;
    if (title != null) result.title = title;
    return result;
  }

  DownloadBangumiRequest._();

  factory DownloadBangumiRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DownloadBangumiRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DownloadBangumiRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOS(2, _omitFieldNames ? '' : 'downloadPath')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'header',
        entryClassName: 'DownloadBangumiRequest.HeaderEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('miru'))
    ..aOB(4, _omitFieldNames ? '' : 'isHls')
    ..aOS(5, _omitFieldNames ? '' : 'package')
    ..aOS(6, _omitFieldNames ? '' : 'key')
    ..aOS(7, _omitFieldNames ? '' : 'title')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadBangumiRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadBangumiRequest copyWith(
          void Function(DownloadBangumiRequest) updates) =>
      super.copyWith((message) => updates(message as DownloadBangumiRequest))
          as DownloadBangumiRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadBangumiRequest create() => DownloadBangumiRequest._();
  @$core.override
  DownloadBangumiRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DownloadBangumiRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DownloadBangumiRequest>(create);
  static DownloadBangumiRequest? _defaultInstance;

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
  $pb.PbMap<$core.String, $core.String> get header => $_getMap(2);

  @$pb.TagNumber(4)
  $core.bool get isHls => $_getBF(3);
  @$pb.TagNumber(4)
  set isHls($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsHls() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsHls() => $_clearField(4);

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
}

class DownloadBangumiResponse extends $pb.GeneratedMessage {
  factory DownloadBangumiResponse({
    $core.int? taskId,
    $core.Iterable<AvailableHlsVariant>? variantSummary,
    $core.bool? isDownloading,
  }) {
    final result = create();
    if (taskId != null) result.taskId = taskId;
    if (variantSummary != null) result.variantSummary.addAll(variantSummary);
    if (isDownloading != null) result.isDownloading = isDownloading;
    return result;
  }

  DownloadBangumiResponse._();

  factory DownloadBangumiResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DownloadBangumiResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DownloadBangumiResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'taskId')
    ..pPM<AvailableHlsVariant>(2, _omitFieldNames ? '' : 'variantSummary',
        subBuilder: AvailableHlsVariant.create)
    ..aOB(3, _omitFieldNames ? '' : 'isDownloading')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadBangumiResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadBangumiResponse copyWith(
          void Function(DownloadBangumiResponse) updates) =>
      super.copyWith((message) => updates(message as DownloadBangumiResponse))
          as DownloadBangumiResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadBangumiResponse create() => DownloadBangumiResponse._();
  @$core.override
  DownloadBangumiResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DownloadBangumiResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DownloadBangumiResponse>(create);
  static DownloadBangumiResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get taskId => $_getIZ(0);
  @$pb.TagNumber(1)
  set taskId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<AvailableHlsVariant> get variantSummary => $_getList(1);

  @$pb.TagNumber(3)
  $core.bool get isDownloading => $_getBF(2);
  @$pb.TagNumber(3)
  set isDownloading($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsDownloading() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsDownloading() => $_clearField(3);
}

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

class GetAllDownloadsRequest extends $pb.GeneratedMessage {
  factory GetAllDownloadsRequest() => create();

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
}

class GetAllDownloadsResponse extends $pb.GeneratedMessage {
  factory GetAllDownloadsResponse({
    $core.Iterable<Download>? downloads,
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
    ..pPM<Download>(1, _omitFieldNames ? '' : 'downloads',
        subBuilder: Download.create)
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
  $pb.PbList<Download> get downloads => $_getList(0);
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
    $core.Iterable<TorrentResult>? torrents,
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
    ..pPM<TorrentResult>(1, _omitFieldNames ? '' : 'torrents',
        subBuilder: TorrentResult.create)
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
  $pb.PbList<TorrentResult> get torrents => $_getList(0);
}

class AddTorrentRequest extends $pb.GeneratedMessage {
  factory AddTorrentRequest({
    $core.List<$core.int>? torrent,
    $core.String? package,
    $core.String? title,
  }) {
    final result = create();
    if (torrent != null) result.torrent = torrent;
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
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'torrent', $pb.PbFieldType.OY)
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
  $core.List<$core.int> get torrent => $_getN(0);
  @$pb.TagNumber(1)
  set torrent($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTorrent() => $_has(0);
  @$pb.TagNumber(1)
  void clearTorrent() => $_clearField(1);

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

/// Repo
class GetReposRequest extends $pb.GeneratedMessage {
  factory GetReposRequest() => create();

  GetReposRequest._();

  factory GetReposRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetReposRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetReposRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReposRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReposRequest copyWith(void Function(GetReposRequest) updates) =>
      super.copyWith((message) => updates(message as GetReposRequest))
          as GetReposRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetReposRequest create() => GetReposRequest._();
  @$core.override
  GetReposRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetReposRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetReposRequest>(create);
  static GetReposRequest? _defaultInstance;
}

class GetReposResponse extends $pb.GeneratedMessage {
  factory GetReposResponse({
    $core.String? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  GetReposResponse._();

  factory GetReposResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetReposResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetReposResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'data')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReposResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReposResponse copyWith(void Function(GetReposResponse) updates) =>
      super.copyWith((message) => updates(message as GetReposResponse))
          as GetReposResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetReposResponse create() => GetReposResponse._();
  @$core.override
  GetReposResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetReposResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetReposResponse>(create);
  static GetReposResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get data => $_getSZ(0);
  @$pb.TagNumber(1)
  set data($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
}

class SetRepoRequest extends $pb.GeneratedMessage {
  factory SetRepoRequest({
    $core.String? repoUrl,
    $core.String? name,
  }) {
    final result = create();
    if (repoUrl != null) result.repoUrl = repoUrl;
    if (name != null) result.name = name;
    return result;
  }

  SetRepoRequest._();

  factory SetRepoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetRepoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetRepoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'repoUrl')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetRepoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetRepoRequest copyWith(void Function(SetRepoRequest) updates) =>
      super.copyWith((message) => updates(message as SetRepoRequest))
          as SetRepoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetRepoRequest create() => SetRepoRequest._();
  @$core.override
  SetRepoRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetRepoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetRepoRequest>(create);
  static SetRepoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get repoUrl => $_getSZ(0);
  @$pb.TagNumber(1)
  set repoUrl($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRepoUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearRepoUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);
}

class SetRepoResponse extends $pb.GeneratedMessage {
  factory SetRepoResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  SetRepoResponse._();

  factory SetRepoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetRepoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetRepoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetRepoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetRepoResponse copyWith(void Function(SetRepoResponse) updates) =>
      super.copyWith((message) => updates(message as SetRepoResponse))
          as SetRepoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetRepoResponse create() => SetRepoResponse._();
  @$core.override
  SetRepoResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetRepoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetRepoResponse>(create);
  static SetRepoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

class DeleteRepoRequest extends $pb.GeneratedMessage {
  factory DeleteRepoRequest({
    $core.String? repoUrl,
  }) {
    final result = create();
    if (repoUrl != null) result.repoUrl = repoUrl;
    return result;
  }

  DeleteRepoRequest._();

  factory DeleteRepoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteRepoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteRepoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'repoUrl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteRepoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteRepoRequest copyWith(void Function(DeleteRepoRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteRepoRequest))
          as DeleteRepoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteRepoRequest create() => DeleteRepoRequest._();
  @$core.override
  DeleteRepoRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteRepoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteRepoRequest>(create);
  static DeleteRepoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get repoUrl => $_getSZ(0);
  @$pb.TagNumber(1)
  set repoUrl($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRepoUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearRepoUrl() => $_clearField(1);
}

class DeleteRepoResponse extends $pb.GeneratedMessage {
  factory DeleteRepoResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  DeleteRepoResponse._();

  factory DeleteRepoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteRepoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteRepoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteRepoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteRepoResponse copyWith(void Function(DeleteRepoResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteRepoResponse))
          as DeleteRepoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteRepoResponse create() => DeleteRepoResponse._();
  @$core.override
  DeleteRepoResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteRepoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteRepoResponse>(create);
  static DeleteRepoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
}

class FetchRepoListRequest extends $pb.GeneratedMessage {
  factory FetchRepoListRequest() => create();

  FetchRepoListRequest._();

  factory FetchRepoListRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FetchRepoListRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FetchRepoListRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FetchRepoListRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FetchRepoListRequest copyWith(void Function(FetchRepoListRequest) updates) =>
      super.copyWith((message) => updates(message as FetchRepoListRequest))
          as FetchRepoListRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FetchRepoListRequest create() => FetchRepoListRequest._();
  @$core.override
  FetchRepoListRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FetchRepoListRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FetchRepoListRequest>(create);
  static FetchRepoListRequest? _defaultInstance;
}

class FetchRepoListResponse extends $pb.GeneratedMessage {
  factory FetchRepoListResponse({
    $core.String? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  FetchRepoListResponse._();

  factory FetchRepoListResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FetchRepoListResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FetchRepoListResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'data')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FetchRepoListResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FetchRepoListResponse copyWith(
          void Function(FetchRepoListResponse) updates) =>
      super.copyWith((message) => updates(message as FetchRepoListResponse))
          as FetchRepoListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FetchRepoListResponse create() => FetchRepoListResponse._();
  @$core.override
  FetchRepoListResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FetchRepoListResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FetchRepoListResponse>(create);
  static FetchRepoListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get data => $_getSZ(0);
  @$pb.TagNumber(1)
  set data($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
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

/// Network
class SetCookieRequest extends $pb.GeneratedMessage {
  factory SetCookieRequest({
    $core.String? cookie,
    $core.String? url,
  }) {
    final result = create();
    if (cookie != null) result.cookie = cookie;
    if (url != null) result.url = url;
    return result;
  }

  SetCookieRequest._();

  factory SetCookieRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetCookieRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetCookieRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cookie')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCookieRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCookieRequest copyWith(void Function(SetCookieRequest) updates) =>
      super.copyWith((message) => updates(message as SetCookieRequest))
          as SetCookieRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetCookieRequest create() => SetCookieRequest._();
  @$core.override
  SetCookieRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetCookieRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetCookieRequest>(create);
  static SetCookieRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cookie => $_getSZ(0);
  @$pb.TagNumber(1)
  set cookie($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCookie() => $_has(0);
  @$pb.TagNumber(1)
  void clearCookie() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);
}

class SetCookieResponse extends $pb.GeneratedMessage {
  factory SetCookieResponse({
    $core.String? message,
  }) {
    final result = create();
    if (message != null) result.message = message;
    return result;
  }

  SetCookieResponse._();

  factory SetCookieResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetCookieResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetCookieResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCookieResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCookieResponse copyWith(void Function(SetCookieResponse) updates) =>
      super.copyWith((message) => updates(message as SetCookieResponse))
          as SetCookieResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetCookieResponse create() => SetCookieResponse._();
  @$core.override
  SetCookieResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetCookieResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetCookieResponse>(create);
  static SetCookieResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);
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
    Detail? detail,
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
    ..aOM<Detail>(1, _omitFieldNames ? '' : 'detail', subBuilder: Detail.create)
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
  Detail get detail => $_getN(0);
  @$pb.TagNumber(1)
  set detail(Detail value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDetail() => $_has(0);
  @$pb.TagNumber(1)
  void clearDetail() => $_clearField(1);
  @$pb.TagNumber(1)
  Detail ensureDetail() => $_ensure(0);
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
    Detail? detail,
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
    ..aOM<Detail>(1, _omitFieldNames ? '' : 'detail', subBuilder: Detail.create)
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
  Detail get detail => $_getN(0);
  @$pb.TagNumber(1)
  set detail(Detail value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDetail() => $_has(0);
  @$pb.TagNumber(1)
  void clearDetail() => $_clearField(1);
  @$pb.TagNumber(1)
  Detail ensureDetail() => $_ensure(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
