// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DomainSearchFilter _$DomainSearchFilterFromJson(Map<String, dynamic> json) =>
    _DomainSearchFilter(
      lang: json['lang'] as String?,
      type: json['type'] as String?,
      installedOnly: json['installedOnly'] as bool? ?? false,
      notInstalledOnly: json['notInstalledOnly'] as bool? ?? false,
    );

Map<String, dynamic> _$DomainSearchFilterToJson(_DomainSearchFilter instance) =>
    <String, dynamic>{
      'lang': instance.lang,
      'type': instance.type,
      'installedOnly': instance.installedOnly,
      'notInstalledOnly': instance.notInstalledOnly,
    };

_DomainSearchState _$DomainSearchStateFromJson(Map<String, dynamic> json) =>
    _DomainSearchState(
      extensions: json['extensions'] as List<dynamic>,
      query: json['query'] as String,
      selectedLang: json['selectedLang'] as String?,
      selectedType: json['selectedType'] as String?,
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$DomainSearchStateToJson(_DomainSearchState instance) =>
    <String, dynamic>{
      'extensions': instance.extensions,
      'query': instance.query,
      'selectedLang': instance.selectedLang,
      'selectedType': instance.selectedType,
      'isLoading': instance.isLoading,
      'error': instance.error,
    };
