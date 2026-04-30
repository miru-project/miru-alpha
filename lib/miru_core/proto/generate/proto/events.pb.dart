// This is a generated file - do not edit.
//
// Generated from proto/events.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $1;
import 'db_model.pb.dart' as $2;

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
  devLogEvent,
  devNetworkEvent,
  notSet
}

class WatchEventsResponse extends $pb.GeneratedMessage {
  factory WatchEventsResponse({
    DownloadEvent? downloadEvent,
    ExtensionEvent? extensionEvent,
    HistoryEvent? historyEvent,
    DevLogEvent? devLogEvent,
    DevNetworkEvent? devNetworkEvent,
  }) {
    final result = create();
    if (downloadEvent != null) result.downloadEvent = downloadEvent;
    if (extensionEvent != null) result.extensionEvent = extensionEvent;
    if (historyEvent != null) result.historyEvent = historyEvent;
    if (devLogEvent != null) result.devLogEvent = devLogEvent;
    if (devNetworkEvent != null) result.devNetworkEvent = devNetworkEvent;
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
    4: WatchEventsResponse_Event.devLogEvent,
    5: WatchEventsResponse_Event.devNetworkEvent,
    0: WatchEventsResponse_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchEventsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5])
    ..aOM<DownloadEvent>(1, _omitFieldNames ? '' : 'downloadEvent',
        subBuilder: DownloadEvent.create)
    ..aOM<ExtensionEvent>(2, _omitFieldNames ? '' : 'extensionEvent',
        subBuilder: ExtensionEvent.create)
    ..aOM<HistoryEvent>(3, _omitFieldNames ? '' : 'historyEvent',
        subBuilder: HistoryEvent.create)
    ..aOM<DevLogEvent>(4, _omitFieldNames ? '' : 'devLogEvent',
        subBuilder: DevLogEvent.create)
    ..aOM<DevNetworkEvent>(5, _omitFieldNames ? '' : 'devNetworkEvent',
        subBuilder: DevNetworkEvent.create)
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
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  WatchEventsResponse_Event whichEvent() =>
      _WatchEventsResponse_EventByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
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

  @$pb.TagNumber(4)
  DevLogEvent get devLogEvent => $_getN(3);
  @$pb.TagNumber(4)
  set devLogEvent(DevLogEvent value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasDevLogEvent() => $_has(3);
  @$pb.TagNumber(4)
  void clearDevLogEvent() => $_clearField(4);
  @$pb.TagNumber(4)
  DevLogEvent ensureDevLogEvent() => $_ensure(3);

  @$pb.TagNumber(5)
  DevNetworkEvent get devNetworkEvent => $_getN(4);
  @$pb.TagNumber(5)
  set devNetworkEvent(DevNetworkEvent value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasDevNetworkEvent() => $_has(4);
  @$pb.TagNumber(5)
  void clearDevNetworkEvent() => $_clearField(5);
  @$pb.TagNumber(5)
  DevNetworkEvent ensureDevNetworkEvent() => $_ensure(4);
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
    $core.Iterable<$2.History>? history,
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
    ..pPM<$2.History>(1, _omitFieldNames ? '' : 'history',
        subBuilder: $2.History.create)
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
  $pb.PbList<$2.History> get history => $_getList(0);
}

class DevLogEvent extends $pb.GeneratedMessage {
  factory DevLogEvent({
    $core.String? package,
    $core.String? message,
    $core.String? level,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (package != null) result.package = package;
    if (message != null) result.message = message;
    if (level != null) result.level = level;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  DevLogEvent._();

  factory DevLogEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DevLogEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DevLogEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'package')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'level')
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DevLogEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DevLogEvent copyWith(void Function(DevLogEvent) updates) =>
      super.copyWith((message) => updates(message as DevLogEvent))
          as DevLogEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DevLogEvent create() => DevLogEvent._();
  @$core.override
  DevLogEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DevLogEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DevLogEvent>(create);
  static DevLogEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get package => $_getSZ(0);
  @$pb.TagNumber(1)
  set package($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPackage() => $_has(0);
  @$pb.TagNumber(1)
  void clearPackage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get level => $_getSZ(2);
  @$pb.TagNumber(3)
  set level($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLevel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLevel() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
}

class DevNetworkEvent extends $pb.GeneratedMessage {
  factory DevNetworkEvent({
    $core.String? package,
    $core.String? url,
    $core.String? method,
    $core.int? status,
    $fixnum.Int64? duration,
    $fixnum.Int64? timestamp,
    $core.String? requestHeaders,
    $core.String? requestBody,
    $core.String? responseHeaders,
    $core.String? responseBody,
  }) {
    final result = create();
    if (package != null) result.package = package;
    if (url != null) result.url = url;
    if (method != null) result.method = method;
    if (status != null) result.status = status;
    if (duration != null) result.duration = duration;
    if (timestamp != null) result.timestamp = timestamp;
    if (requestHeaders != null) result.requestHeaders = requestHeaders;
    if (requestBody != null) result.requestBody = requestBody;
    if (responseHeaders != null) result.responseHeaders = responseHeaders;
    if (responseBody != null) result.responseBody = responseBody;
    return result;
  }

  DevNetworkEvent._();

  factory DevNetworkEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DevNetworkEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DevNetworkEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'miru'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'package')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..aOS(3, _omitFieldNames ? '' : 'method')
    ..aI(4, _omitFieldNames ? '' : 'status')
    ..aInt64(5, _omitFieldNames ? '' : 'duration')
    ..aInt64(6, _omitFieldNames ? '' : 'timestamp')
    ..aOS(7, _omitFieldNames ? '' : 'requestHeaders')
    ..aOS(8, _omitFieldNames ? '' : 'requestBody')
    ..aOS(9, _omitFieldNames ? '' : 'responseHeaders')
    ..aOS(10, _omitFieldNames ? '' : 'responseBody')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DevNetworkEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DevNetworkEvent copyWith(void Function(DevNetworkEvent) updates) =>
      super.copyWith((message) => updates(message as DevNetworkEvent))
          as DevNetworkEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DevNetworkEvent create() => DevNetworkEvent._();
  @$core.override
  DevNetworkEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DevNetworkEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DevNetworkEvent>(create);
  static DevNetworkEvent? _defaultInstance;

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
  $core.String get method => $_getSZ(2);
  @$pb.TagNumber(3)
  set method($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMethod() => $_has(2);
  @$pb.TagNumber(3)
  void clearMethod() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get status => $_getIZ(3);
  @$pb.TagNumber(4)
  set status($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get duration => $_getI64(4);
  @$pb.TagNumber(5)
  set duration($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDuration() => $_has(4);
  @$pb.TagNumber(5)
  void clearDuration() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get timestamp => $_getI64(5);
  @$pb.TagNumber(6)
  set timestamp($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimestamp() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get requestHeaders => $_getSZ(6);
  @$pb.TagNumber(7)
  set requestHeaders($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRequestHeaders() => $_has(6);
  @$pb.TagNumber(7)
  void clearRequestHeaders() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get requestBody => $_getSZ(7);
  @$pb.TagNumber(8)
  set requestBody($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRequestBody() => $_has(7);
  @$pb.TagNumber(8)
  void clearRequestBody() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get responseHeaders => $_getSZ(8);
  @$pb.TagNumber(9)
  set responseHeaders($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasResponseHeaders() => $_has(8);
  @$pb.TagNumber(9)
  void clearResponseHeaders() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get responseBody => $_getSZ(9);
  @$pb.TagNumber(10)
  set responseBody($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasResponseBody() => $_has(9);
  @$pb.TagNumber(10)
  void clearResponseBody() => $_clearField(10);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
