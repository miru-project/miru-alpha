// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extension.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DomainExtension _$DomainExtensionFromJson(Map<String, dynamic> json) =>
    _DomainExtension(
      package: json['package'] as String,
      author: json['author'] as String,
      version: json['version'] as String,
      lang: json['lang'] as String,
      license: json['license'] as String,
      type: $enumDecode(_$ExtensionTypeEnumMap, json['type']),
      webSite: json['webSite'] as String,
      name: json['name'] as String,
      nsfw: json['nsfw'] as bool? ?? false,
      icon: json['icon'] as String?,
      url: json['url'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$DomainExtensionToJson(_DomainExtension instance) =>
    <String, dynamic>{
      'package': instance.package,
      'author': instance.author,
      'version': instance.version,
      'lang': instance.lang,
      'license': instance.license,
      'type': _$ExtensionTypeEnumMap[instance.type]!,
      'webSite': instance.webSite,
      'name': instance.name,
      'nsfw': instance.nsfw,
      'icon': instance.icon,
      'url': instance.url,
      'description': instance.description,
    };

const _$ExtensionTypeEnumMap = {
  ExtensionType.manga: 'manga',
  ExtensionType.bangumi: 'bangumi',
  ExtensionType.fikushon: 'fikushon',
  ExtensionType.all: 'all',
};

_DomainExtensionMeta _$DomainExtensionMetaFromJson(Map<String, dynamic> json) =>
    _DomainExtensionMeta(
      name: json['name'] as String? ?? '',
      version: json['version'] as String? ?? '',
      author: json['author'] as String? ?? '',
      license: json['license'] as String? ?? '',
      lang: json['lang'] as String? ?? '',
      icon: json['icon'] as String?,
      packageName: json['packageName'] as String? ?? '',
      webSite: json['webSite'] as String? ?? '',
      description: json['description'] as String?,
      tags: json['tags'] as List<dynamic>? ?? const [],
      api: json['api'] as String? ?? '',
      type: $enumDecode(_$ExtensionTypeEnumMap, json['type']),
      error: json['error'] as String?,
      nsfw: json['nsfw'] as bool? ?? false,
    );

Map<String, dynamic> _$DomainExtensionMetaToJson(
  _DomainExtensionMeta instance,
) => <String, dynamic>{
  'name': instance.name,
  'version': instance.version,
  'author': instance.author,
  'license': instance.license,
  'lang': instance.lang,
  'icon': instance.icon,
  'packageName': instance.packageName,
  'webSite': instance.webSite,
  'description': instance.description,
  'tags': instance.tags,
  'api': instance.api,
  'type': _$ExtensionTypeEnumMap[instance.type]!,
  'error': instance.error,
  'nsfw': instance.nsfw,
};

_DomainExtensionRepo _$DomainExtensionRepoFromJson(Map<String, dynamic> json) =>
    _DomainExtensionRepo(
      name: json['name'] as String,
      url: json['url'] as String,
      extensions:
          (json['extensions'] as List<dynamic>?)
              ?.map(
                (e) => DomainExtensionMeta.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DomainExtensionRepoToJson(
  _DomainExtensionRepo instance,
) => <String, dynamic>{
  'name': instance.name,
  'url': instance.url,
  'extensions': instance.extensions,
};
