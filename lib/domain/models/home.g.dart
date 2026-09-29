// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DomainHomeState _$DomainHomeStateFromJson(Map<String, dynamic> json) =>
    _DomainHomeState(
      selectedTab:
          $enumDecodeNullable(_$HomeTabEnumMap, json['selectedTab']) ??
          HomeTab.library,
      libraryExtensions: (json['libraryExtensions'] as List<dynamic>)
          .map((e) => DomainExtensionMeta.fromJson(e as Map<String, dynamic>))
          .toList(),
      historyItems: (json['historyItems'] as List<dynamic>)
          .map((e) => DomainHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      favoriteGroups: (json['favoriteGroups'] as List<dynamic>)
          .map((e) => DomainFavoriteGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      favorites: (json['favorites'] as List<dynamic>)
          .map((e) => DomainFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeDownloads: (json['activeDownloads'] as List<dynamic>)
          .map((e) => DomainDownload.fromJson(e as Map<String, dynamic>))
          .toList(),
      finishedDownloads: (json['finishedDownloads'] as List<dynamic>)
          .map((e) => DomainDownload.fromJson(e as Map<String, dynamic>))
          .toList(),
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$DomainHomeStateToJson(_DomainHomeState instance) =>
    <String, dynamic>{
      'selectedTab': _$HomeTabEnumMap[instance.selectedTab]!,
      'libraryExtensions': instance.libraryExtensions,
      'historyItems': instance.historyItems,
      'favoriteGroups': instance.favoriteGroups,
      'favorites': instance.favorites,
      'activeDownloads': instance.activeDownloads,
      'finishedDownloads': instance.finishedDownloads,
      'isLoading': instance.isLoading,
      'error': instance.error,
    };

const _$HomeTabEnumMap = {
  HomeTab.library: 'library',
  HomeTab.history: 'history',
  HomeTab.favorite: 'favorite',
  HomeTab.download: 'download',
};

_DomainLibrarySection _$DomainLibrarySectionFromJson(
  Map<String, dynamic> json,
) => _DomainLibrarySection(
  extensions: (json['extensions'] as List<dynamic>)
      .map((e) => DomainExtensionMeta.fromJson(e as Map<String, dynamic>))
      .toList(),
  pinnedPackages: (json['pinnedPackages'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  query: json['query'] as String?,
);

Map<String, dynamic> _$DomainLibrarySectionToJson(
  _DomainLibrarySection instance,
) => <String, dynamic>{
  'extensions': instance.extensions,
  'pinnedPackages': instance.pinnedPackages,
  'query': instance.query,
};
