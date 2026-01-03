// This is a generated file - do not edit.
//
// Generated from events.proto.

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

enum WatchEventsResponse_Event {
  downloadEvent,
  extensionEvent,
  historyEvent,
  notSet
}

class WatchEventsResponse extends $pb.GeneratedMessage {
  factory WatchEventsResponse({
    DownloadEvent? downloadEvent,
    ExtensionEvent? extensionEvent,
    HistoryEvent? historyEvent,
  }) {
    final result = create();
    if (downloadEvent != null) result.downloadEvent = downloadEvent;
    if (extensionEvent != null) result.extensionEvent = extensionEvent;
    if (historyEvent != null) result.historyEvent = historyEvent;
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
    3: WatchEventsResponse_Event.historyEvent,
    0: WatchEventsResponse_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchEventsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<DownloadEvent>(1, _omitFieldNames ? '' : 'downloadEvent',
        subBuilder: DownloadEvent.create)
    ..aOM<ExtensionEvent>(2, _omitFieldNames ? '' : 'extensionEvent',
        subBuilder: ExtensionEvent.create)
    ..aOM<HistoryEvent>(3, _omitFieldNames ? '' : 'historyEvent',
        subBuilder: HistoryEvent.create)
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
  @$pb.TagNumber(3)
  WatchEventsResponse_Event whichEvent() =>
      _WatchEventsResponse_EventByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
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

  @$pb.TagNumber(3)
  HistoryEvent get historyEvent => $_getN(2);
  @$pb.TagNumber(3)
  set historyEvent(HistoryEvent value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasHistoryEvent() => $_has(2);
  @$pb.TagNumber(3)
  void clearHistoryEvent() => $_clearField(3);
  @$pb.TagNumber(3)
  HistoryEvent ensureHistoryEvent() => $_ensure(2);
}

class DownloadEvent extends $pb.GeneratedMessage {
  factory DownloadEvent({
    $core.Iterable<$core.MapEntry<$core.int, $1.DownloadProgress>>?
        downloadStatus,
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
    ..m<$core.int, $1.DownloadProgress>(
        1, _omitFieldNames ? '' : 'downloadStatus',
        entryClassName: 'DownloadEvent.DownloadStatusEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: $1.DownloadProgress.create,
        valueDefaultOrMaker: $1.DownloadProgress.getDefault,
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
  $pb.PbMap<$core.int, $1.DownloadProgress> get downloadStatus => $_getMap(0);
}

class ExtensionEvent extends $pb.GeneratedMessage {
  factory ExtensionEvent({
    $core.Iterable<$1.ExtensionMeta>? extensionMeta,
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
    ..pPM<$1.ExtensionMeta>(1, _omitFieldNames ? '' : 'extensionMeta',
        subBuilder: $1.ExtensionMeta.create)
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
  $pb.PbList<$1.ExtensionMeta> get extensionMeta => $_getList(0);
}

class HistoryEvent extends $pb.GeneratedMessage {
  factory HistoryEvent({
    $core.Iterable<$1.History>? history,
  }) {
    final result = create();
    if (history != null) result.history.addAll(history);
    return result;
  }

  HistoryEvent._();

  factory HistoryEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HistoryEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HistoryEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..pPM<$1.History>(1, _omitFieldNames ? '' : 'history',
        subBuilder: $1.History.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HistoryEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HistoryEvent copyWith(void Function(HistoryEvent) updates) =>
      super.copyWith((message) => updates(message as HistoryEvent))
          as HistoryEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HistoryEvent create() => HistoryEvent._();
  @$core.override
  HistoryEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HistoryEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HistoryEvent>(create);
  static HistoryEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.History> get history => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
