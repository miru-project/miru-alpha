// This is a generated file - do not edit.
//
// Generated from proto/miru_core_service.proto.

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
    $core.Iterable<$1.ExtensionMeta>? extensionMeta,
    $core.Iterable<$core.MapEntry<$core.int, $1.DownloadProgress>>?
        downloadStatus,
    $1.TorrentStats? torrent,
    $core.Iterable<$1.History>? history,
  }) {
    final result = create();
    if (extensionMeta != null) result.extensionMeta.addAll(extensionMeta);
    if (downloadStatus != null)
      result.downloadStatus.addEntries(downloadStatus);
    if (torrent != null) result.torrent = torrent;
    if (history != null) result.history.addAll(history);
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
    ..pPM<$1.ExtensionMeta>(1, _omitFieldNames ? '' : 'extensionMeta',
        protoName: 'extensionMeta', subBuilder: $1.ExtensionMeta.create)
    ..m<$core.int, $1.DownloadProgress>(
        2, _omitFieldNames ? '' : 'downloadStatus',
        protoName: 'downloadStatus',
        entryClassName: 'HelloMiruResponse.DownloadStatusEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: $1.DownloadProgress.create,
        valueDefaultOrMaker: $1.DownloadProgress.getDefault,
        packageName: const $pb.PackageName('miru'))
    ..aOM<$1.TorrentStats>(3, _omitFieldNames ? '' : 'torrent',
        subBuilder: $1.TorrentStats.create)
    ..pPM<$1.History>(4, _omitFieldNames ? '' : 'history',
        subBuilder: $1.History.create)
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
  $pb.PbList<$1.ExtensionMeta> get extensionMeta => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.int, $1.DownloadProgress> get downloadStatus => $_getMap(1);

  @$pb.TagNumber(3)
  $1.TorrentStats get torrent => $_getN(2);
  @$pb.TagNumber(3)
  set torrent($1.TorrentStats value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTorrent() => $_has(2);
  @$pb.TagNumber(3)
  void clearTorrent() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.TorrentStats ensureTorrent() => $_ensure(2);

  @$pb.TagNumber(4)
  $pb.PbList<$1.History> get history => $_getList(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
