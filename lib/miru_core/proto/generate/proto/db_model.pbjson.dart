// This is a generated file - do not edit.
//
// Generated from proto/db_model.proto.

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

@$core.Deprecated('Use detailDescriptor instead')
const Detail$json = {
  '1': 'Detail',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'title', '17': true},
    {'1': 'cover', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'cover', '17': true},
    {'1': 'desc', '3': 4, '4': 1, '5': 9, '9': 2, '10': 'desc', '17': true},
    {'1': 'detail_url', '3': 5, '4': 1, '5': 9, '10': 'detailUrl'},
    {'1': 'package', '3': 6, '4': 1, '5': 9, '10': 'package'},
    {'1': 'downloaded', '3': 7, '4': 3, '5': 9, '10': 'downloaded'},
    {
      '1': 'episodes',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'episodes',
      '17': true
    },
    {
      '1': 'headers',
      '3': 9,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'headers',
      '17': true
    },
    {
      '1': 'track_ids',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.miru.Detail.TrackIdsEntry',
      '10': 'trackIds'
    },
    {
      '1': 'trackers',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.miru.Tracker',
      '10': 'trackers'
    },
  ],
  '3': [Detail_TrackIdsEntry$json],
  '8': [
    {'1': '_title'},
    {'1': '_cover'},
    {'1': '_desc'},
    {'1': '_episodes'},
    {'1': '_headers'},
  ],
};

@$core.Deprecated('Use detailDescriptor instead')
const Detail_TrackIdsEntry$json = {
  '1': 'TrackIdsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Detail`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detailDescriptor = $convert.base64Decode(
    'CgZEZXRhaWwSDgoCaWQYASABKAVSAmlkEhkKBXRpdGxlGAIgASgJSABSBXRpdGxliAEBEhkKBW'
    'NvdmVyGAMgASgJSAFSBWNvdmVyiAEBEhcKBGRlc2MYBCABKAlIAlIEZGVzY4gBARIdCgpkZXRh'
    'aWxfdXJsGAUgASgJUglkZXRhaWxVcmwSGAoHcGFja2FnZRgGIAEoCVIHcGFja2FnZRIeCgpkb3'
    'dubG9hZGVkGAcgAygJUgpkb3dubG9hZGVkEh8KCGVwaXNvZGVzGAggASgJSANSCGVwaXNvZGVz'
    'iAEBEh0KB2hlYWRlcnMYCSABKAlIBFIHaGVhZGVyc4gBARI3Cgl0cmFja19pZHMYCiADKAsyGi'
    '5taXJ1LkRldGFpbC5UcmFja0lkc0VudHJ5Ugh0cmFja0lkcxIpCgh0cmFja2VycxgLIAMoCzIN'
    'Lm1pcnUuVHJhY2tlclIIdHJhY2tlcnMaOwoNVHJhY2tJZHNFbnRyeRIQCgNrZXkYASABKAlSA2'
    'tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgBQggKBl90aXRsZUIICgZfY292ZXJCBwoFX2Rl'
    'c2NCCwoJX2VwaXNvZGVzQgoKCF9oZWFkZXJz');

@$core.Deprecated('Use trackerDescriptor instead')
const Tracker$json = {
  '1': 'Tracker',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'tracker_id', '3': 2, '4': 1, '5': 9, '10': 'trackerId'},
    {'1': 'provider', '3': 3, '4': 1, '5': 9, '10': 'provider'},
    {'1': 'status', '3': 4, '4': 1, '5': 9, '10': 'status'},
    {'1': 'score', '3': 5, '4': 1, '5': 5, '9': 0, '10': 'score', '17': true},
    {'1': 'progress', '3': 6, '4': 1, '5': 5, '10': 'progress'},
    {
      '1': 'start_date',
      '3': 7,
      '4': 1,
      '5': 3,
      '9': 1,
      '10': 'startDate',
      '17': true
    },
    {
      '1': 'finish_date',
      '3': 8,
      '4': 1,
      '5': 3,
      '9': 2,
      '10': 'finishDate',
      '17': true
    },
    {
      '1': 'total_progress',
      '3': 9,
      '4': 1,
      '5': 5,
      '9': 3,
      '10': 'totalProgress',
      '17': true
    },
  ],
  '8': [
    {'1': '_score'},
    {'1': '_start_date'},
    {'1': '_finish_date'},
    {'1': '_total_progress'},
  ],
};

/// Descriptor for `Tracker`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trackerDescriptor = $convert.base64Decode(
    'CgdUcmFja2VyEg4KAmlkGAEgASgFUgJpZBIdCgp0cmFja2VyX2lkGAIgASgJUgl0cmFja2VySW'
    'QSGgoIcHJvdmlkZXIYAyABKAlSCHByb3ZpZGVyEhYKBnN0YXR1cxgEIAEoCVIGc3RhdHVzEhkK'
    'BXNjb3JlGAUgASgFSABSBXNjb3JliAEBEhoKCHByb2dyZXNzGAYgASgFUghwcm9ncmVzcxIiCg'
    'pzdGFydF9kYXRlGAcgASgDSAFSCXN0YXJ0RGF0ZYgBARIkCgtmaW5pc2hfZGF0ZRgIIAEoA0gC'
    'UgpmaW5pc2hEYXRliAEBEioKDnRvdGFsX3Byb2dyZXNzGAkgASgFSANSDXRvdGFsUHJvZ3Jlc3'
    'OIAQFCCAoGX3Njb3JlQg0KC19zdGFydF9kYXRlQg4KDF9maW5pc2hfZGF0ZUIRCg9fdG90YWxf'
    'cHJvZ3Jlc3M=');

@$core.Deprecated('Use favoriteDescriptor instead')
const Favorite$json = {
  '1': 'Favorite',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'package', '3': 2, '4': 1, '5': 9, '10': 'package'},
    {'1': 'url', '3': 3, '4': 1, '5': 9, '10': 'url'},
    {'1': 'type', '3': 4, '4': 1, '5': 9, '10': 'type'},
    {'1': 'title', '3': 5, '4': 1, '5': 9, '10': 'title'},
    {'1': 'cover', '3': 6, '4': 1, '5': 9, '10': 'cover'},
    {'1': 'date', '3': 7, '4': 1, '5': 9, '10': 'date'},
  ],
};

/// Descriptor for `Favorite`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List favoriteDescriptor = $convert.base64Decode(
    'CghGYXZvcml0ZRIOCgJpZBgBIAEoBVICaWQSGAoHcGFja2FnZRgCIAEoCVIHcGFja2FnZRIQCg'
    'N1cmwYAyABKAlSA3VybBISCgR0eXBlGAQgASgJUgR0eXBlEhQKBXRpdGxlGAUgASgJUgV0aXRs'
    'ZRIUCgVjb3ZlchgGIAEoCVIFY292ZXISEgoEZGF0ZRgHIAEoCVIEZGF0ZQ==');

@$core.Deprecated('Use favoriteGroupDescriptor instead')
const FavoriteGroup$json = {
  '1': 'FavoriteGroup',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'date', '3': 3, '4': 1, '5': 9, '10': 'date'},
    {
      '1': 'favorites',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.miru.Favorite',
      '10': 'favorites'
    },
  ],
};

/// Descriptor for `FavoriteGroup`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List favoriteGroupDescriptor = $convert.base64Decode(
    'Cg1GYXZvcml0ZUdyb3VwEg4KAmlkGAEgASgFUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEhIKBG'
    'RhdGUYAyABKAlSBGRhdGUSLAoJZmF2b3JpdGVzGAQgAygLMg4ubWlydS5GYXZvcml0ZVIJZmF2'
    'b3JpdGVz');

@$core.Deprecated('Use historyDescriptor instead')
const History$json = {
  '1': 'History',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'package', '3': 2, '4': 1, '5': 9, '10': 'package'},
    {'1': 'url', '3': 3, '4': 1, '5': 9, '10': 'url'},
    {'1': 'cover', '3': 4, '4': 1, '5': 9, '10': 'cover'},
    {'1': 'type', '3': 5, '4': 1, '5': 9, '10': 'type'},
    {'1': 'episode_group_id', '3': 6, '4': 1, '5': 5, '10': 'episodeGroupId'},
    {'1': 'episode_id', '3': 7, '4': 1, '5': 5, '10': 'episodeId'},
    {'1': 'title', '3': 8, '4': 1, '5': 9, '10': 'title'},
    {'1': 'episode_title', '3': 9, '4': 1, '5': 9, '10': 'episodeTitle'},
    {'1': 'progress', '3': 10, '4': 1, '5': 5, '10': 'progress'},
    {'1': 'total_progress', '3': 11, '4': 1, '5': 5, '10': 'totalProgress'},
    {'1': 'date', '3': 12, '4': 1, '5': 9, '10': 'date'},
    {'1': 'detail_url', '3': 13, '4': 1, '5': 9, '10': 'detailUrl'},
  ],
};

/// Descriptor for `History`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List historyDescriptor = $convert.base64Decode(
    'CgdIaXN0b3J5Eg4KAmlkGAEgASgFUgJpZBIYCgdwYWNrYWdlGAIgASgJUgdwYWNrYWdlEhAKA3'
    'VybBgDIAEoCVIDdXJsEhQKBWNvdmVyGAQgASgJUgVjb3ZlchISCgR0eXBlGAUgASgJUgR0eXBl'
    'EigKEGVwaXNvZGVfZ3JvdXBfaWQYBiABKAVSDmVwaXNvZGVHcm91cElkEh0KCmVwaXNvZGVfaW'
    'QYByABKAVSCWVwaXNvZGVJZBIUCgV0aXRsZRgIIAEoCVIFdGl0bGUSIwoNZXBpc29kZV90aXRs'
    'ZRgJIAEoCVIMZXBpc29kZVRpdGxlEhoKCHByb2dyZXNzGAogASgFUghwcm9ncmVzcxIlCg50b3'
    'RhbF9wcm9ncmVzcxgLIAEoBVINdG90YWxQcm9ncmVzcxISCgRkYXRlGAwgASgJUgRkYXRlEh0K'
    'CmRldGFpbF91cmwYDSABKAlSCWRldGFpbFVybA==');

@$core.Deprecated('Use trackDescriptor instead')
const Track$json = {
  '1': 'Track',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'tracking_id', '3': 2, '4': 1, '5': 9, '10': 'trackingId'},
    {'1': 'data', '3': 3, '4': 1, '5': 9, '10': 'data'},
    {'1': 'media_type', '3': 4, '4': 1, '5': 9, '10': 'mediaType'},
    {'1': 'provider', '3': 5, '4': 1, '5': 9, '10': 'provider'},
  ],
};

/// Descriptor for `Track`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trackDescriptor = $convert.base64Decode(
    'CgVUcmFjaxIOCgJpZBgBIAEoBVICaWQSHwoLdHJhY2tpbmdfaWQYAiABKAlSCnRyYWNraW5nSW'
    'QSEgoEZGF0YRgDIAEoCVIEZGF0YRIdCgptZWRpYV90eXBlGAQgASgJUgltZWRpYVR5cGUSGgoI'
    'cHJvdmlkZXIYBSABKAlSCHByb3ZpZGVy');
