// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Extension _$ExtensionFromJson(Map<String, dynamic> json) => Extension(
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

Map<String, dynamic> _$ExtensionToJson(Extension instance) => <String, dynamic>{
  'nsfw': instance.nsfw,
  'package': instance.package,
  'author': instance.author,
  'version': instance.version,
  'lang': instance.lang,
  'license': instance.license,
  'type': _$ExtensionTypeEnumMap[instance.type]!,
  'webSite': instance.webSite,
  'name': instance.name,
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

ExtensionLog _$ExtensionLogFromJson(Map<String, dynamic> json) => ExtensionLog(
  extension: Extension.fromJson(json['extension'] as Map<String, dynamic>),
  content: json['content'] as String,
  time: DateTime.parse(json['time'] as String),
  level: $enumDecode(_$ExtensionLogLevelEnumMap, json['level']),
);

Map<String, dynamic> _$ExtensionLogToJson(ExtensionLog instance) =>
    <String, dynamic>{
      'time': instance.time.toIso8601String(),
      'extension': instance.extension,
      'content': instance.content,
      'level': _$ExtensionLogLevelEnumMap[instance.level]!,
    };

const _$ExtensionLogLevelEnumMap = {
  ExtensionLogLevel.info: 'info',
  ExtensionLogLevel.error: 'error',
};

ExtensionNetworkLog _$ExtensionNetworkLogFromJson(Map<String, dynamic> json) =>
    ExtensionNetworkLog(
      extension: Extension.fromJson(json['extension'] as Map<String, dynamic>),
      url: json['url'] as String,
      method: json['method'] as String,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      responseBody: json['responseBody'] as String?,
      requestBody: json['requestBody'] as String?,
      requestHeaders: json['requestHeaders'] as Map<String, dynamic>?,
      responseHeaders: json['responseHeaders'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ExtensionNetworkLogToJson(
  ExtensionNetworkLog instance,
) => <String, dynamic>{
  'extension': instance.extension,
  'responseBody': instance.responseBody,
  'requestBody': instance.requestBody,
  'requestHeaders': instance.requestHeaders,
  'responseHeaders': instance.responseHeaders,
  'url': instance.url,
  'method': instance.method,
  'statusCode': instance.statusCode,
};

GithubExtension _$GithubExtensionFromJson(Map<String, dynamic> json) =>
    GithubExtension(
      name: json['name'] as String,
      description: json['description'] as String?,
      license: json['license'] as String,
      version: json['version'] as String,
      author: json['author'] as String,
      package: json['package'] as String,
      icon: json['icon'] as String?,
      type: json['type'] as String,
      language: json['lang'] as String,
      website: json['webSite'] as String,
      isNsfw: _boolFromString(json['nsfw']),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$GithubExtensionToJson(GithubExtension instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'license': instance.license,
      'version': instance.version,
      'author': instance.author,
      'icon': instance.icon,
      'type': instance.type,
      'lang': instance.language,
      'webSite': instance.website,
      'nsfw': instance.isNsfw,
      'package': instance.package,
      'tags': instance.tags,
    };

ExtensionRepo _$ExtensionRepoFromJson(Map<String, dynamic> json) =>
    ExtensionRepo(
      extensions: (json['extensions'] as List<dynamic>)
          .map((e) => GithubExtension.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$ExtensionRepoToJson(ExtensionRepo instance) =>
    <String, dynamic>{
      'extensions': instance.extensions,
      'name': instance.name,
      'url': instance.url,
    };

RepoConfig _$RepoConfigFromJson(Map<String, dynamic> json) => RepoConfig(
  link: json['link'] as String,
  name: json['name'] as String,
  id: (json['id'] as num).toInt(),
);

Map<String, dynamic> _$RepoConfigToJson(RepoConfig instance) =>
    <String, dynamic>{
      'link': instance.link,
      'name': instance.name,
      'id': instance.id,
    };
