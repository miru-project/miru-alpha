import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

@freezed
abstract class DomainAppSettings with _$DomainAppSettings {
  const factory DomainAppSettings({
    @Default('system') String theme,
    @Default(0xFF2196F3) int accentColor,
    @Default('en') String language,
    @Default(false) bool isMobileTitleOnTop,
    @Default('') String tmdbApiKey,
    @Default('') String proxy,
    @Default('') String proxyPort,
    @Default(false) bool enableProxy,
    @Default(true) bool hardwareAcceleration,
    @Default(16) double subtitleFontSize,
    @Default('') String subtitleColor,
    @Default(1.0) double playbackSpeed,
    @Default(true) bool autoPlayNext,
    @Default(MangaReadMode.standard) MangaReadMode mangaReadMode,
    @Default(NovelReadMode.standard) NovelReadMode novelReadMode,
    @Default(16) double novelFontSize,
    @Default('') String novelTheme,
    @Default(true) bool enableTTS,
    @Default(false) bool devMode,
    @Default(false) bool enableDevLog,
    @Default(false) bool enableDevNetwork,
    @Default('') String anilistToken,
    @Default(true) bool autoSyncTracking,
    @Default(3) int downloadConcurrent,
    @Default('') String downloadPath,
    @Default(true) bool autoDownload,
    @Default(true) bool showContinueWatching,
    @Default(true) bool showHistory,
    @Default(true) bool showFavorites,
  }) = _DomainAppSettings;

  factory DomainAppSettings.fromJson(Map<String, dynamic> json) =>
      _$DomainAppSettingsFromJson(json);
}

enum MangaReadMode { standard, rightToLeft, webToon }

enum NovelReadMode {
  standard,
  rightToLeft,
  webToon,
  rightToLeftFlip,
  standardFlip,
}

@freezed
abstract class DomainSettingItem with _$DomainSettingItem {
  const factory DomainSettingItem({
    required String key,
    required String value,
    required String type,
    String? description,
  }) = _DomainSettingItem;

  factory DomainSettingItem.fromJson(Map<String, dynamic> json) =>
      _$DomainSettingItemFromJson(json);
}
