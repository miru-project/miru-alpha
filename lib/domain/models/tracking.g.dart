// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DomainTrackingAccount _$DomainTrackingAccountFromJson(
  Map<String, dynamic> json,
) => _DomainTrackingAccount(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  avatar: json['avatar'] as String?,
  provider: $enumDecode(_$TrackingProviderEnumMap, json['provider']),
);

Map<String, dynamic> _$DomainTrackingAccountToJson(
  _DomainTrackingAccount instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatar': instance.avatar,
  'provider': _$TrackingProviderEnumMap[instance.provider]!,
};

const _$TrackingProviderEnumMap = {
  TrackingProvider.anilist: 'anilist',
  TrackingProvider.tmdb: 'tmdb',
};

_DomainTrackingProgress _$DomainTrackingProgressFromJson(
  Map<String, dynamic> json,
) => _DomainTrackingProgress(
  id: (json['id'] as num).toInt(),
  mediaId: (json['mediaId'] as num).toInt(),
  status: json['status'] as String,
  progress: (json['progress'] as num).toInt(),
  score: (json['score'] as num?)?.toDouble(),
  mediaType: json['mediaType'] as String?,
  title: json['title'] as String?,
  cover: json['cover'] as String?,
);

Map<String, dynamic> _$DomainTrackingProgressToJson(
  _DomainTrackingProgress instance,
) => <String, dynamic>{
  'id': instance.id,
  'mediaId': instance.mediaId,
  'status': instance.status,
  'progress': instance.progress,
  'score': instance.score,
  'mediaType': instance.mediaType,
  'title': instance.title,
  'cover': instance.cover,
};

_DomainTMDBTrack _$DomainTMDBTrackFromJson(Map<String, dynamic> json) =>
    _DomainTMDBTrack(
      id: (json['id'] as num).toInt(),
      mediaId: (json['mediaId'] as num).toInt(),
      mediaType: json['mediaType'] as String,
      title: json['title'] as String,
      cover: json['cover'] as String?,
      overview: json['overview'] as String?,
      status: json['status'] as String?,
      runtime: (json['runtime'] as num?)?.toInt(),
      genres: (json['genres'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DomainTMDBTrackToJson(_DomainTMDBTrack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mediaId': instance.mediaId,
      'mediaType': instance.mediaType,
      'title': instance.title,
      'cover': instance.cover,
      'overview': instance.overview,
      'status': instance.status,
      'runtime': instance.runtime,
      'genres': instance.genres,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_DomainTMDBCast _$DomainTMDBCastFromJson(Map<String, dynamic> json) =>
    _DomainTMDBCast(
      name: json['name'] as String,
      character: json['character'] as String,
      profilePath: json['profilePath'] as String?,
    );

Map<String, dynamic> _$DomainTMDBCastToJson(_DomainTMDBCast instance) =>
    <String, dynamic>{
      'name': instance.name,
      'character': instance.character,
      'profilePath': instance.profilePath,
    };
