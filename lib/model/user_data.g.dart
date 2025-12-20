// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

History _$HistoryFromJson(Map<String, dynamic> json) => History(
  id: json['id'] == null ? 0 : _parseInt(json['id']),
  package: json['package'] as String,
  url: json['url'] as String,
  cover: json['cover'] as String?,
  type: json['type'] as String,
  episodeGroupId: (json['episodeGroupId'] as num).toInt(),
  episodeId: (json['episodeId'] as num).toInt(),
  title: json['title'] as String,
  episodeTitle: json['episodeTitle'] as String,
  progress: (json['progress'] as num).toInt(),
  totalProgress: (json['totalProgress'] as num).toInt(),
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$HistoryToJson(History instance) => <String, dynamic>{
  'id': instance.id,
  'package': instance.package,
  'url': instance.url,
  'cover': instance.cover,
  'type': instance.type,
  'episodeGroupId': instance.episodeGroupId,
  'episodeId': instance.episodeId,
  'title': instance.title,
  'episodeTitle': instance.episodeTitle,
  'progress': instance.progress,
  'totalProgress': instance.totalProgress,
  'date': instance.date.toIso8601String(),
};

Favorite _$FavoriteFromJson(Map<String, dynamic> json) => Favorite(
  id: json['id'] == null ? 0 : _parseInt(json['id']),
  package: json['package'] as String,
  url: json['url'] as String,
  type: json['type'] as String,
  title: json['title'] as String,
  cover: json['cover'] as String?,
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$FavoriteToJson(Favorite instance) => <String, dynamic>{
  'id': instance.id,
  'package': instance.package,
  'url': instance.url,
  'type': instance.type,
  'title': instance.title,
  'cover': instance.cover,
  'date': instance.date.toIso8601String(),
};

FavoriateGroup _$FavoriateGroupFromJson(Map<String, dynamic> json) =>
    FavoriateGroup(
      id: json['id'] == null ? 0 : _parseInt(json['id']),
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      favorites:
          (json['favorites'] as List<dynamic>?)
              ?.map((e) => Favorite.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$FavoriateGroupToJson(FavoriateGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'favorites': instance.favorites,
      'date': instance.date.toIso8601String(),
    };
