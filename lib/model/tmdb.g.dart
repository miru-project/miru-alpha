// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TMDBDetail _$TMDBDetailFromJson(Map<String, dynamic> json) => TMDBDetail(
      id: (json['id'] as num).toInt(),
      mediaType: json['mediaType'] as String,
      title: json['title'] as String,
      cover: json['cover'] as String,
      backdrop: json['backdrop'] as String?,
      genres:
          (json['genres'] as List<dynamic>).map((e) => e as String).toList(),
      languages:
          (json['languages'] as List<dynamic>).map((e) => e as String).toList(),
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      overview: json['overview'] as String?,
      status: json['status'] as String,
      casts: (json['casts'] as List<dynamic>)
          .map((e) => TMDBCast.fromJson(e as Map<String, dynamic>))
          .toList(),
      releaseDate: json['releaseDate'] as String,
      runtime: (json['runtime'] as num).toInt(),
      originalTitle: json['originalTitle'] as String,
    );

Map<String, dynamic> _$TMDBDetailToJson(TMDBDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mediaType': instance.mediaType,
      'title': instance.title,
      'cover': instance.cover,
      'backdrop': instance.backdrop,
      'genres': instance.genres,
      'languages': instance.languages,
      'images': instance.images,
      'overview': instance.overview,
      'status': instance.status,
      'casts': instance.casts,
      'releaseDate': instance.releaseDate,
      'runtime': instance.runtime,
      'originalTitle': instance.originalTitle,
    };

TMDBCast _$TMDBCastFromJson(Map<String, dynamic> json) => TMDBCast(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      profilePath: json['profilePath'] as String?,
      character: json['character'] as String,
    );

Map<String, dynamic> _$TMDBCastToJson(TMDBCast instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'profilePath': instance.profilePath,
      'character': instance.character,
    };
