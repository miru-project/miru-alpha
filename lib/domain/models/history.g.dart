// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DomainHistoryItem _$DomainHistoryItemFromJson(Map<String, dynamic> json) =>
    _DomainHistoryItem(
      id: json['id'] as String,
      package: json['package'] as String,
      detailUrl: json['detailUrl'] as String,
      title: json['title'] as String,
      cover: json['cover'] as String?,
      episodeIndex: (json['episodeIndex'] as num).toInt(),
      episodeTitle: json['episodeTitle'] as String?,
      watchedDuration: (json['watchedDuration'] as num).toInt(),
      totalDuration: (json['totalDuration'] as num).toInt(),
      progress: (json['progress'] as num).toDouble(),
      watchedAt: DateTime.parse(json['watchedAt'] as String),
      lastPosition: json['lastPosition'] as String?,
    );

Map<String, dynamic> _$DomainHistoryItemToJson(_DomainHistoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'package': instance.package,
      'detailUrl': instance.detailUrl,
      'title': instance.title,
      'cover': instance.cover,
      'episodeIndex': instance.episodeIndex,
      'episodeTitle': instance.episodeTitle,
      'watchedDuration': instance.watchedDuration,
      'totalDuration': instance.totalDuration,
      'progress': instance.progress,
      'watchedAt': instance.watchedAt.toIso8601String(),
      'lastPosition': instance.lastPosition,
    };
