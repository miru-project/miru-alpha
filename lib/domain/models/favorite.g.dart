// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DomainFavorite _$DomainFavoriteFromJson(Map<String, dynamic> json) =>
    _DomainFavorite(
      id: json['id'] as String,
      package: json['package'] as String,
      detailUrl: json['detailUrl'] as String,
      title: json['title'] as String,
      cover: json['cover'] as String?,
      type: json['type'] as String,
      groupId: json['groupId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$DomainFavoriteToJson(_DomainFavorite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'package': instance.package,
      'detailUrl': instance.detailUrl,
      'title': instance.title,
      'cover': instance.cover,
      'type': instance.type,
      'groupId': instance.groupId,
      'createdAt': instance.createdAt.toIso8601String(),
      'description': instance.description,
    };

_DomainFavoriteGroup _$DomainFavoriteGroupFromJson(Map<String, dynamic> json) =>
    _DomainFavoriteGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      order: (json['order'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$DomainFavoriteGroupToJson(
  _DomainFavoriteGroup instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'order': instance.order,
  'createdAt': instance.createdAt.toIso8601String(),
  'icon': instance.icon,
};
