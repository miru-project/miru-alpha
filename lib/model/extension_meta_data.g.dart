// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extension_meta_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExtensionMeta _$ExtensionMetaFromJson(Map<String, dynamic> json) =>
    ExtensionMeta(
      name: json['name'] as String? ?? '',
      version: json['version'] as String? ?? '',
      author: json['author'] as String? ?? '',
      license: json['license'] as String? ?? '',
      lang: json['lang'] as String? ?? '',
      icon: json['icon'] as String?,
      packageName: json['package'] as String? ?? '',
      webSite: json['webSite'] as String? ?? '',
      description: json['description'] as String?,
      tags: json['tags'] as List<dynamic>? ?? [],
      api: json['api'] as String? ?? '',
      type: _extensionTypeFromJson(json['type'] as String),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$ExtensionMetaToJson(ExtensionMeta instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'author': instance.author,
      'license': instance.license,
      'lang': instance.lang,
      'icon': instance.icon,
      'package': instance.packageName,
      'webSite': instance.webSite,
      'description': instance.description,
      'tags': instance.tags,
      'api': instance.api,
      'type': _$ExtensionTypeEnumMap[instance.type]!,
      'error': instance.error,
    };

const _$ExtensionTypeEnumMap = {
  ExtensionType.manga: 'manga',
  ExtensionType.bangumi: 'bangumi',
  ExtensionType.fikushon: 'fikushon',
  ExtensionType.unknown: 'unknown',
};
