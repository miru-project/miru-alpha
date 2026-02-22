// This is a generated file - do not edit.
//
// Generated from proto/extension_model.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use extensionListItemDescriptor instead')
const ExtensionListItem$json = {
  '1': 'ExtensionListItem',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
    {'1': 'cover', '3': 3, '4': 1, '5': 9, '10': 'cover'},
    {'1': 'update', '3': 4, '4': 1, '5': 9, '10': 'update'},
    {
      '1': 'headers',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.miru.ExtensionListItem.HeadersEntry',
      '10': 'headers'
    },
  ],
  '3': [ExtensionListItem_HeadersEntry$json],
};

@$core.Deprecated('Use extensionListItemDescriptor instead')
const ExtensionListItem_HeadersEntry$json = {
  '1': 'HeadersEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ExtensionListItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionListItemDescriptor = $convert.base64Decode(
    'ChFFeHRlbnNpb25MaXN0SXRlbRIUCgV0aXRsZRgBIAEoCVIFdGl0bGUSEAoDdXJsGAIgASgJUg'
    'N1cmwSFAoFY292ZXIYAyABKAlSBWNvdmVyEhYKBnVwZGF0ZRgEIAEoCVIGdXBkYXRlEj4KB2hl'
    'YWRlcnMYBSADKAsyJC5taXJ1LkV4dGVuc2lvbkxpc3RJdGVtLkhlYWRlcnNFbnRyeVIHaGVhZG'
    'Vycxo6CgxIZWFkZXJzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZh'
    'bHVlOgI4AQ==');

@$core.Deprecated('Use extensionFilterDescriptor instead')
const ExtensionFilter$json = {
  '1': 'ExtensionFilter',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {'1': 'min', '3': 2, '4': 1, '5': 5, '10': 'min'},
    {'1': 'max', '3': 3, '4': 1, '5': 5, '10': 'max'},
    {'1': 'default', '3': 4, '4': 1, '5': 9, '10': 'default'},
    {
      '1': 'options',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.miru.ExtensionFilter.OptionsEntry',
      '10': 'options'
    },
  ],
  '3': [ExtensionFilter_OptionsEntry$json],
};

@$core.Deprecated('Use extensionFilterDescriptor instead')
const ExtensionFilter_OptionsEntry$json = {
  '1': 'OptionsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ExtensionFilter`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionFilterDescriptor = $convert.base64Decode(
    'Cg9FeHRlbnNpb25GaWx0ZXISFAoFdGl0bGUYASABKAlSBXRpdGxlEhAKA21pbhgCIAEoBVIDbW'
    'luEhAKA21heBgDIAEoBVIDbWF4EhgKB2RlZmF1bHQYBCABKAlSB2RlZmF1bHQSPAoHb3B0aW9u'
    'cxgFIAMoCzIiLm1pcnUuRXh0ZW5zaW9uRmlsdGVyLk9wdGlvbnNFbnRyeVIHb3B0aW9ucxo6Cg'
    'xPcHRpb25zRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4'
    'AQ==');

@$core.Deprecated('Use extensionDetailDescriptor instead')
const ExtensionDetail$json = {
  '1': 'ExtensionDetail',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'title', '17': true},
    {'1': 'cover', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'cover', '17': true},
    {'1': 'desc', '3': 3, '4': 1, '5': 9, '9': 2, '10': 'desc', '17': true},
    {
      '1': 'episodes',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.miru.ExtensionEpisodeGroup',
      '10': 'episodes'
    },
    {
      '1': 'headers',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.miru.ExtensionDetail.HeadersEntry',
      '10': 'headers'
    },
  ],
  '3': [ExtensionDetail_HeadersEntry$json],
  '8': [
    {'1': '_title'},
    {'1': '_cover'},
    {'1': '_desc'},
  ],
};

@$core.Deprecated('Use extensionDetailDescriptor instead')
const ExtensionDetail_HeadersEntry$json = {
  '1': 'HeadersEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ExtensionDetail`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionDetailDescriptor = $convert.base64Decode(
    'Cg9FeHRlbnNpb25EZXRhaWwSGQoFdGl0bGUYASABKAlIAFIFdGl0bGWIAQESGQoFY292ZXIYAi'
    'ABKAlIAVIFY292ZXKIAQESFwoEZGVzYxgDIAEoCUgCUgRkZXNjiAEBEjcKCGVwaXNvZGVzGAQg'
    'AygLMhsubWlydS5FeHRlbnNpb25FcGlzb2RlR3JvdXBSCGVwaXNvZGVzEjwKB2hlYWRlcnMYBS'
    'ADKAsyIi5taXJ1LkV4dGVuc2lvbkRldGFpbC5IZWFkZXJzRW50cnlSB2hlYWRlcnMaOgoMSGVh'
    'ZGVyc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAFCCA'
    'oGX3RpdGxlQggKBl9jb3ZlckIHCgVfZGVzYw==');

@$core.Deprecated('Use extensionEpisodeGroupDescriptor instead')
const ExtensionEpisodeGroup$json = {
  '1': 'ExtensionEpisodeGroup',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {
      '1': 'urls',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.miru.ExtensionEpisode',
      '10': 'urls'
    },
  ],
};

/// Descriptor for `ExtensionEpisodeGroup`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionEpisodeGroupDescriptor = $convert.base64Decode(
    'ChVFeHRlbnNpb25FcGlzb2RlR3JvdXASFAoFdGl0bGUYASABKAlSBXRpdGxlEioKBHVybHMYAi'
    'ADKAsyFi5taXJ1LkV4dGVuc2lvbkVwaXNvZGVSBHVybHM=');

@$core.Deprecated('Use extensionEpisodeDescriptor instead')
const ExtensionEpisode$json = {
  '1': 'ExtensionEpisode',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
    {'1': 'update', '3': 3, '4': 1, '5': 9, '10': 'update'},
    {
      '1': 'description',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'description',
      '17': true
    },
  ],
  '8': [
    {'1': '_description'},
  ],
};

/// Descriptor for `ExtensionEpisode`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionEpisodeDescriptor = $convert.base64Decode(
    'ChBFeHRlbnNpb25FcGlzb2RlEhIKBG5hbWUYASABKAlSBG5hbWUSEAoDdXJsGAIgASgJUgN1cm'
    'wSFgoGdXBkYXRlGAMgASgJUgZ1cGRhdGUSJQoLZGVzY3JpcHRpb24YBCABKAlIAFILZGVzY3Jp'
    'cHRpb26IAQFCDgoMX2Rlc2NyaXB0aW9u');

@$core.Deprecated('Use extensionBangumiWatchSubtitleDescriptor instead')
const ExtensionBangumiWatchSubtitle$json = {
  '1': 'ExtensionBangumiWatchSubtitle',
  '2': [
    {
      '1': 'language',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'language',
      '17': true
    },
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'url', '3': 3, '4': 1, '5': 9, '10': 'url'},
  ],
  '8': [
    {'1': '_language'},
  ],
};

/// Descriptor for `ExtensionBangumiWatchSubtitle`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionBangumiWatchSubtitleDescriptor =
    $convert.base64Decode(
        'Ch1FeHRlbnNpb25CYW5ndW1pV2F0Y2hTdWJ0aXRsZRIfCghsYW5ndWFnZRgBIAEoCUgAUghsYW'
        '5ndWFnZYgBARIUCgV0aXRsZRgCIAEoCVIFdGl0bGUSEAoDdXJsGAMgASgJUgN1cmxCCwoJX2xh'
        'bmd1YWdl');

@$core.Deprecated(
    'Use extensionBangumiWatchTorrentFileTreeFileDescriptor instead')
const ExtensionBangumiWatchTorrentFileTreeFile$json = {
  '1': 'ExtensionBangumiWatchTorrentFileTreeFile',
  '2': [
    {'1': 'length', '3': 1, '4': 1, '5': 3, '10': 'length'},
    {'1': 'piecesRoot', '3': 2, '4': 1, '5': 9, '10': 'piecesRoot'},
  ],
};

/// Descriptor for `ExtensionBangumiWatchTorrentFileTreeFile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionBangumiWatchTorrentFileTreeFileDescriptor =
    $convert.base64Decode(
        'CihFeHRlbnNpb25CYW5ndW1pV2F0Y2hUb3JyZW50RmlsZVRyZWVGaWxlEhYKBmxlbmd0aBgBIA'
        'EoA1IGbGVuZ3RoEh4KCnBpZWNlc1Jvb3QYAiABKAlSCnBpZWNlc1Jvb3Q=');

@$core.Deprecated('Use extensionBangumiWatchTorrentFileTreeDescriptor instead')
const ExtensionBangumiWatchTorrentFileTree$json = {
  '1': 'ExtensionBangumiWatchTorrentFileTree',
  '2': [
    {
      '1': 'file',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.miru.ExtensionBangumiWatchTorrentFileTreeFile',
      '10': 'file'
    },
    {
      '1': 'dir',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.miru.ExtensionBangumiWatchTorrentFileTree.DirEntry',
      '10': 'dir'
    },
  ],
  '3': [ExtensionBangumiWatchTorrentFileTree_DirEntry$json],
};

@$core.Deprecated('Use extensionBangumiWatchTorrentFileTreeDescriptor instead')
const ExtensionBangumiWatchTorrentFileTree_DirEntry$json = {
  '1': 'DirEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.miru.ExtensionBangumiWatchTorrentFileTree',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `ExtensionBangumiWatchTorrentFileTree`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionBangumiWatchTorrentFileTreeDescriptor = $convert.base64Decode(
    'CiRFeHRlbnNpb25CYW5ndW1pV2F0Y2hUb3JyZW50RmlsZVRyZWUSQgoEZmlsZRgBIAEoCzIuLm'
    '1pcnUuRXh0ZW5zaW9uQmFuZ3VtaVdhdGNoVG9ycmVudEZpbGVUcmVlRmlsZVIEZmlsZRJFCgNk'
    'aXIYAiADKAsyMy5taXJ1LkV4dGVuc2lvbkJhbmd1bWlXYXRjaFRvcnJlbnRGaWxlVHJlZS5EaX'
    'JFbnRyeVIDZGlyGmIKCERpckVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EkAKBXZhbHVlGAIgASgL'
    'MioubWlydS5FeHRlbnNpb25CYW5ndW1pV2F0Y2hUb3JyZW50RmlsZVRyZWVSBXZhbHVlOgI4AQ'
    '==');

@$core.Deprecated('Use extensionBangumiWatchTorrentDetailDescriptor instead')
const ExtensionBangumiWatchTorrentDetail$json = {
  '1': 'ExtensionBangumiWatchTorrentDetail',
  '2': [
    {
      '1': 'pieceLength',
      '3': 1,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'pieceLength',
      '17': true
    },
    {'1': 'pieces', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'pieces', '17': true},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '9': 2, '10': 'name', '17': true},
    {
      '1': 'nameUtf8',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'nameUtf8',
      '17': true
    },
    {'1': 'length', '3': 5, '4': 1, '5': 3, '9': 4, '10': 'length', '17': true},
    {'1': 'source', '3': 6, '4': 1, '5': 9, '9': 5, '10': 'source', '17': true},
    {
      '1': 'metaVersion',
      '3': 7,
      '4': 1,
      '5': 5,
      '9': 6,
      '10': 'metaVersion',
      '17': true
    },
    {
      '1': 'fileTree',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.miru.ExtensionBangumiWatchTorrentFileTree',
      '10': 'fileTree'
    },
  ],
  '8': [
    {'1': '_pieceLength'},
    {'1': '_pieces'},
    {'1': '_name'},
    {'1': '_nameUtf8'},
    {'1': '_length'},
    {'1': '_source'},
    {'1': '_metaVersion'},
  ],
};

/// Descriptor for `ExtensionBangumiWatchTorrentDetail`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionBangumiWatchTorrentDetailDescriptor = $convert.base64Decode(
    'CiJFeHRlbnNpb25CYW5ndW1pV2F0Y2hUb3JyZW50RGV0YWlsEiUKC3BpZWNlTGVuZ3RoGAEgAS'
    'gFSABSC3BpZWNlTGVuZ3RoiAEBEhsKBnBpZWNlcxgCIAEoCUgBUgZwaWVjZXOIAQESFwoEbmFt'
    'ZRgDIAEoCUgCUgRuYW1liAEBEh8KCG5hbWVVdGY4GAQgASgJSANSCG5hbWVVdGY4iAEBEhsKBm'
    'xlbmd0aBgFIAEoA0gEUgZsZW5ndGiIAQESGwoGc291cmNlGAYgASgJSAVSBnNvdXJjZYgBARIl'
    'CgttZXRhVmVyc2lvbhgHIAEoBUgGUgttZXRhVmVyc2lvbogBARJGCghmaWxlVHJlZRgIIAEoCz'
    'IqLm1pcnUuRXh0ZW5zaW9uQmFuZ3VtaVdhdGNoVG9ycmVudEZpbGVUcmVlUghmaWxlVHJlZUIO'
    'CgxfcGllY2VMZW5ndGhCCQoHX3BpZWNlc0IHCgVfbmFtZUILCglfbmFtZVV0ZjhCCQoHX2xlbm'
    'd0aEIJCgdfc291cmNlQg4KDF9tZXRhVmVyc2lvbg==');

@$core.Deprecated('Use extensionBangumiWatchTorrentDescriptor instead')
const ExtensionBangumiWatchTorrent$json = {
  '1': 'ExtensionBangumiWatchTorrent',
  '2': [
    {'1': 'infoHash', '3': 1, '4': 1, '5': 9, '10': 'infoHash'},
    {
      '1': 'detail',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.miru.ExtensionBangumiWatchTorrentDetail',
      '10': 'detail'
    },
    {'1': 'files', '3': 3, '4': 3, '5': 9, '10': 'files'},
  ],
};

/// Descriptor for `ExtensionBangumiWatchTorrent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionBangumiWatchTorrentDescriptor =
    $convert.base64Decode(
        'ChxFeHRlbnNpb25CYW5ndW1pV2F0Y2hUb3JyZW50EhoKCGluZm9IYXNoGAEgASgJUghpbmZvSG'
        'FzaBJACgZkZXRhaWwYAiABKAsyKC5taXJ1LkV4dGVuc2lvbkJhbmd1bWlXYXRjaFRvcnJlbnRE'
        'ZXRhaWxSBmRldGFpbBIUCgVmaWxlcxgDIAMoCVIFZmlsZXM=');

@$core.Deprecated('Use extensionBangumiWatchDescriptor instead')
const ExtensionBangumiWatch$json = {
  '1': 'ExtensionBangumiWatch',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
    {
      '1': 'subtitles',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.miru.ExtensionBangumiWatchSubtitle',
      '10': 'subtitles'
    },
    {
      '1': 'headers',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.miru.ExtensionBangumiWatch.HeadersEntry',
      '10': 'headers'
    },
    {
      '1': 'audioTrack',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'audioTrack',
      '17': true
    },
    {
      '1': 'torrent',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.miru.ExtensionBangumiWatchTorrent',
      '10': 'torrent'
    },
  ],
  '3': [ExtensionBangumiWatch_HeadersEntry$json],
  '8': [
    {'1': '_audioTrack'},
  ],
};

@$core.Deprecated('Use extensionBangumiWatchDescriptor instead')
const ExtensionBangumiWatch_HeadersEntry$json = {
  '1': 'HeadersEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ExtensionBangumiWatch`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionBangumiWatchDescriptor = $convert.base64Decode(
    'ChVFeHRlbnNpb25CYW5ndW1pV2F0Y2gSEgoEdHlwZRgBIAEoCVIEdHlwZRIQCgN1cmwYAiABKA'
    'lSA3VybBJBCglzdWJ0aXRsZXMYAyADKAsyIy5taXJ1LkV4dGVuc2lvbkJhbmd1bWlXYXRjaFN1'
    'YnRpdGxlUglzdWJ0aXRsZXMSQgoHaGVhZGVycxgEIAMoCzIoLm1pcnUuRXh0ZW5zaW9uQmFuZ3'
    'VtaVdhdGNoLkhlYWRlcnNFbnRyeVIHaGVhZGVycxIjCgphdWRpb1RyYWNrGAUgASgJSABSCmF1'
    'ZGlvVHJhY2uIAQESPAoHdG9ycmVudBgGIAEoCzIiLm1pcnUuRXh0ZW5zaW9uQmFuZ3VtaVdhdG'
    'NoVG9ycmVudFIHdG9ycmVudBo6CgxIZWFkZXJzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoF'
    'dmFsdWUYAiABKAlSBXZhbHVlOgI4AUINCgtfYXVkaW9UcmFjaw==');

@$core.Deprecated('Use extensionMangaWatchDescriptor instead')
const ExtensionMangaWatch$json = {
  '1': 'ExtensionMangaWatch',
  '2': [
    {'1': 'urls', '3': 1, '4': 3, '5': 9, '10': 'urls'},
    {
      '1': 'headers',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.miru.ExtensionMangaWatch.HeadersEntry',
      '10': 'headers'
    },
  ],
  '3': [ExtensionMangaWatch_HeadersEntry$json],
};

@$core.Deprecated('Use extensionMangaWatchDescriptor instead')
const ExtensionMangaWatch_HeadersEntry$json = {
  '1': 'HeadersEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ExtensionMangaWatch`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionMangaWatchDescriptor = $convert.base64Decode(
    'ChNFeHRlbnNpb25NYW5nYVdhdGNoEhIKBHVybHMYASADKAlSBHVybHMSQAoHaGVhZGVycxgCIA'
    'MoCzImLm1pcnUuRXh0ZW5zaW9uTWFuZ2FXYXRjaC5IZWFkZXJzRW50cnlSB2hlYWRlcnMaOgoM'
    'SGVhZGVyc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOA'
    'E=');

@$core.Deprecated('Use extensionFikushonWatchDescriptor instead')
const ExtensionFikushonWatch$json = {
  '1': 'ExtensionFikushonWatch',
  '2': [
    {'1': 'content', '3': 1, '4': 3, '5': 9, '10': 'content'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {
      '1': 'subtitle',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'subtitle',
      '17': true
    },
  ],
  '8': [
    {'1': '_subtitle'},
  ],
};

/// Descriptor for `ExtensionFikushonWatch`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionFikushonWatchDescriptor = $convert.base64Decode(
    'ChZFeHRlbnNpb25GaWt1c2hvbldhdGNoEhgKB2NvbnRlbnQYASADKAlSB2NvbnRlbnQSFAoFdG'
    'l0bGUYAiABKAlSBXRpdGxlEh8KCHN1YnRpdGxlGAMgASgJSABSCHN1YnRpdGxliAEBQgsKCV9z'
    'dWJ0aXRsZQ==');

@$core.Deprecated('Use githubExtensionDescriptor instead')
const GithubExtension$json = {
  '1': 'GithubExtension',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'description',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'description',
      '17': true
    },
    {'1': 'license', '3': 3, '4': 1, '5': 9, '10': 'license'},
    {'1': 'version', '3': 4, '4': 1, '5': 9, '10': 'version'},
    {'1': 'author', '3': 5, '4': 1, '5': 9, '10': 'author'},
    {'1': 'icon', '3': 6, '4': 1, '5': 9, '9': 1, '10': 'icon', '17': true},
    {'1': 'type', '3': 7, '4': 1, '5': 9, '10': 'type'},
    {'1': 'lang', '3': 8, '4': 1, '5': 9, '10': 'lang'},
    {'1': 'webSite', '3': 9, '4': 1, '5': 9, '10': 'webSite'},
    {'1': 'nsfw', '3': 10, '4': 1, '5': 8, '10': 'nsfw'},
    {'1': 'package', '3': 11, '4': 1, '5': 9, '10': 'package'},
    {'1': 'tags', '3': 12, '4': 3, '5': 9, '10': 'tags'},
  ],
  '8': [
    {'1': '_description'},
    {'1': '_icon'},
  ],
};

/// Descriptor for `GithubExtension`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List githubExtensionDescriptor = $convert.base64Decode(
    'Cg9HaXRodWJFeHRlbnNpb24SEgoEbmFtZRgBIAEoCVIEbmFtZRIlCgtkZXNjcmlwdGlvbhgCIA'
    'EoCUgAUgtkZXNjcmlwdGlvbogBARIYCgdsaWNlbnNlGAMgASgJUgdsaWNlbnNlEhgKB3ZlcnNp'
    'b24YBCABKAlSB3ZlcnNpb24SFgoGYXV0aG9yGAUgASgJUgZhdXRob3ISFwoEaWNvbhgGIAEoCU'
    'gBUgRpY29uiAEBEhIKBHR5cGUYByABKAlSBHR5cGUSEgoEbGFuZxgIIAEoCVIEbGFuZxIYCgd3'
    'ZWJTaXRlGAkgASgJUgd3ZWJTaXRlEhIKBG5zZncYCiABKAhSBG5zZncSGAoHcGFja2FnZRgLIA'
    'EoCVIHcGFja2FnZRISCgR0YWdzGAwgAygJUgR0YWdzQg4KDF9kZXNjcmlwdGlvbkIHCgVfaWNv'
    'bg==');

@$core.Deprecated('Use extensionRepoDescriptor instead')
const ExtensionRepo$json = {
  '1': 'ExtensionRepo',
  '2': [
    {
      '1': 'extensions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.miru.GithubExtension',
      '10': 'extensions'
    },
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'url', '3': 3, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `ExtensionRepo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List extensionRepoDescriptor = $convert.base64Decode(
    'Cg1FeHRlbnNpb25SZXBvEjUKCmV4dGVuc2lvbnMYASADKAsyFS5taXJ1LkdpdGh1YkV4dGVuc2'
    'lvblIKZXh0ZW5zaW9ucxISCgRuYW1lGAIgASgJUgRuYW1lEhAKA3VybBgDIAEoCVIDdXJs');

@$core.Deprecated('Use repoConfigDescriptor instead')
const RepoConfig$json = {
  '1': 'RepoConfig',
  '2': [
    {'1': 'link', '3': 1, '4': 1, '5': 9, '10': 'link'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'id', '3': 3, '4': 1, '5': 5, '10': 'id'},
  ],
};

/// Descriptor for `RepoConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List repoConfigDescriptor = $convert.base64Decode(
    'CgpSZXBvQ29uZmlnEhIKBGxpbmsYASABKAlSBGxpbmsSEgoEbmFtZRgCIAEoCVIEbmFtZRIOCg'
    'JpZBgDIAEoBVICaWQ=');
