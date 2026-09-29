// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DomainDetail _$DomainDetailFromJson(Map<String, dynamic> json) =>
    _DomainDetail(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      cover: json['cover'] as String?,
      desc: json['desc'] as String?,
      episodes: (json['episodes'] as List<dynamic>?)
          ?.map((e) => DomainEpisodeGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      downloaded:
          (json['downloaded'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      detailUrl: json['detailUrl'] as String,
      package: json['package'] as String,
    );

Map<String, dynamic> _$DomainDetailToJson(_DomainDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'cover': instance.cover,
      'desc': instance.desc,
      'episodes': instance.episodes,
      'headers': instance.headers,
      'downloaded': instance.downloaded,
      'detailUrl': instance.detailUrl,
      'package': instance.package,
    };

_DomainEpisodeGroup _$DomainEpisodeGroupFromJson(Map<String, dynamic> json) =>
    _DomainEpisodeGroup(
      name: json['name'] as String?,
      episodes: (json['episodes'] as List<dynamic>)
          .map((e) => DomainEpisode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DomainEpisodeGroupToJson(_DomainEpisodeGroup instance) =>
    <String, dynamic>{'name': instance.name, 'episodes': instance.episodes};

_DomainEpisode _$DomainEpisodeFromJson(Map<String, dynamic> json) =>
    _DomainEpisode(name: json['name'] as String?, url: json['url'] as String);

Map<String, dynamic> _$DomainEpisodeToJson(_DomainEpisode instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};
