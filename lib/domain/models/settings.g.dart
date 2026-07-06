// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DomainAppSettings _$DomainAppSettingsFromJson(Map<String, dynamic> json) =>
    _DomainAppSettings(
      theme: json['theme'] as String? ?? 'system',
      accentColor: (json['accentColor'] as num?)?.toInt() ?? 0xFF2196F3,
      language: json['language'] as String? ?? 'en',
      isMobileTitleOnTop: json['isMobileTitleOnTop'] as bool? ?? false,
      tmdbApiKey: json['tmdbApiKey'] as String? ?? '',
      proxy: json['proxy'] as String? ?? '',
      proxyPort: json['proxyPort'] as String? ?? '',
      enableProxy: json['enableProxy'] as bool? ?? false,
      hardwareAcceleration: json['hardwareAcceleration'] as bool? ?? true,
      subtitleFontSize: (json['subtitleFontSize'] as num?)?.toDouble() ?? 16,
      subtitleColor: json['subtitleColor'] as String? ?? '',
      playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
      autoPlayNext: json['autoPlayNext'] as bool? ?? true,
      mangaReadMode:
          $enumDecodeNullable(_$MangaReadModeEnumMap, json['mangaReadMode']) ??
          MangaReadMode.standard,
      novelReadMode:
          $enumDecodeNullable(_$NovelReadModeEnumMap, json['novelReadMode']) ??
          NovelReadMode.standard,
      novelFontSize: (json['novelFontSize'] as num?)?.toDouble() ?? 16,
      novelTheme: json['novelTheme'] as String? ?? '',
      enableTTS: json['enableTTS'] as bool? ?? true,
      devMode: json['devMode'] as bool? ?? false,
      enableDevLog: json['enableDevLog'] as bool? ?? false,
      enableDevNetwork: json['enableDevNetwork'] as bool? ?? false,
      anilistToken: json['anilistToken'] as String? ?? '',
      autoSyncTracking: json['autoSyncTracking'] as bool? ?? true,
      downloadConcurrent: (json['downloadConcurrent'] as num?)?.toInt() ?? 3,
      downloadPath: json['downloadPath'] as String? ?? '',
      autoDownload: json['autoDownload'] as bool? ?? true,
      showContinueWatching: json['showContinueWatching'] as bool? ?? true,
      showHistory: json['showHistory'] as bool? ?? true,
      showFavorites: json['showFavorites'] as bool? ?? true,
    );

Map<String, dynamic> _$DomainAppSettingsToJson(_DomainAppSettings instance) =>
    <String, dynamic>{
      'theme': instance.theme,
      'accentColor': instance.accentColor,
      'language': instance.language,
      'isMobileTitleOnTop': instance.isMobileTitleOnTop,
      'tmdbApiKey': instance.tmdbApiKey,
      'proxy': instance.proxy,
      'proxyPort': instance.proxyPort,
      'enableProxy': instance.enableProxy,
      'hardwareAcceleration': instance.hardwareAcceleration,
      'subtitleFontSize': instance.subtitleFontSize,
      'subtitleColor': instance.subtitleColor,
      'playbackSpeed': instance.playbackSpeed,
      'autoPlayNext': instance.autoPlayNext,
      'mangaReadMode': _$MangaReadModeEnumMap[instance.mangaReadMode]!,
      'novelReadMode': _$NovelReadModeEnumMap[instance.novelReadMode]!,
      'novelFontSize': instance.novelFontSize,
      'novelTheme': instance.novelTheme,
      'enableTTS': instance.enableTTS,
      'devMode': instance.devMode,
      'enableDevLog': instance.enableDevLog,
      'enableDevNetwork': instance.enableDevNetwork,
      'anilistToken': instance.anilistToken,
      'autoSyncTracking': instance.autoSyncTracking,
      'downloadConcurrent': instance.downloadConcurrent,
      'downloadPath': instance.downloadPath,
      'autoDownload': instance.autoDownload,
      'showContinueWatching': instance.showContinueWatching,
      'showHistory': instance.showHistory,
      'showFavorites': instance.showFavorites,
    };

const _$MangaReadModeEnumMap = {
  MangaReadMode.standard: 'standard',
  MangaReadMode.rightToLeft: 'rightToLeft',
  MangaReadMode.webToon: 'webToon',
};

const _$NovelReadModeEnumMap = {
  NovelReadMode.standard: 'standard',
  NovelReadMode.rightToLeft: 'rightToLeft',
  NovelReadMode.webToon: 'webToon',
  NovelReadMode.rightToLeftFlip: 'rightToLeftFlip',
  NovelReadMode.standardFlip: 'standardFlip',
};

_DomainSettingItem _$DomainSettingItemFromJson(Map<String, dynamic> json) =>
    _DomainSettingItem(
      key: json['key'] as String,
      value: json['value'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$DomainSettingItemToJson(_DomainSettingItem instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
      'type': instance.type,
      'description': instance.description,
    };
