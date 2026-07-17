import 'package:miru_alpha/data/services/settings_service.dart';
import 'package:miru_alpha/domain/models/settings.dart';

class SettingsRepository {
  final SettingsService _settingsService;

  SettingsRepository(this._settingsService);

  Future<DomainAppSettings> getAppSettings() async {
    final settings = await _settingsService.getAllSettings();
    return DomainAppSettings(
      theme: settings['theme'] ?? 'system',
      baseColor: settings['baseColor'] ?? 'zinc',
      accentColor: int.tryParse(settings['accentColor'] ?? '') ?? 0xFF2196F3,
      language: settings['language'] ?? 'en',
      isMobileTitleOnTop: settings['isMobileTitleOnTop'] == 'true',
      tmdbApiKey: settings['tmdbApiKey'] ?? '',
      proxy: settings['proxy'] ?? '',
      proxyPort: settings['proxyPort'] ?? '',
      enableProxy: settings['enableProxy'] == 'true',
      hardwareAcceleration: settings['hardwareAcceleration'] != 'false',
      subtitleFontSize:
          double.tryParse(settings['subtitleFontSize'] ?? '') ?? 16,
      subtitleColor: settings['subtitleColor'] ?? '',
      playbackSpeed: double.tryParse(settings['playbackSpeed'] ?? '') ?? 1.0,
      autoPlayNext: settings['autoPlayNext'] != 'false',
      mangaReadMode: _parseMangaReadMode(settings['mangaReadMode']),
      novelReadMode: _parseNovelReadMode(settings['novelReadMode']),
      novelFontSize: double.tryParse(settings['novelFontSize'] ?? '') ?? 16,
      novelTheme: settings['novelTheme'] ?? '',
      enableTTS: settings['enableTTS'] == 'true',
      devMode: settings['devMode'] == 'true',
      enableDevLog: settings['enableDevLog'] == 'true',
      enableDevNetwork: settings['enableDevNetwork'] == 'true',
      anilistToken: settings['anilistToken'] ?? '',
      autoSyncTracking: settings['autoSyncTracking'] != 'false',
      downloadConcurrent:
          int.tryParse(settings['downloadConcurrent'] ?? '') ?? 3,
      downloadPath: settings['downloadPath'] ?? '',
      autoDownload: settings['autoDownload'] != 'false',
      showContinueWatching: settings['showContinueWatching'] != 'false',
      showHistory: settings['showHistory'] != 'false',
      showFavorites: settings['showFavorites'] != 'false',
    );
  }

  Future<void> updateAppSettings(DomainAppSettings settings) async {
    final map = <String, String>{
      'theme': settings.theme,
      'baseColor': settings.baseColor,
      'accentColor': settings.accentColor.toString(),
      'language': settings.language,
      'isMobileTitleOnTop': settings.isMobileTitleOnTop.toString(),
      'tmdbApiKey': settings.tmdbApiKey,
      'proxy': settings.proxy,
      'proxyPort': settings.proxyPort,
      'enableProxy': settings.enableProxy.toString(),
      'hardwareAcceleration': settings.hardwareAcceleration.toString(),
      'subtitleFontSize': settings.subtitleFontSize.toString(),
      'subtitleColor': settings.subtitleColor,
      'playbackSpeed': settings.playbackSpeed.toString(),
      'autoPlayNext': settings.autoPlayNext.toString(),
      'mangaReadMode': settings.mangaReadMode.name,
      'novelReadMode': settings.novelReadMode.name,
      'novelFontSize': settings.novelFontSize.toString(),
      'novelTheme': settings.novelTheme,
      'enableTTS': settings.enableTTS.toString(),
      'devMode': settings.devMode.toString(),
      'enableDevLog': settings.enableDevLog.toString(),
      'enableDevNetwork': settings.enableDevNetwork.toString(),
      'anilistToken': settings.anilistToken,
      'autoSyncTracking': settings.autoSyncTracking.toString(),
      'downloadConcurrent': settings.downloadConcurrent.toString(),
      'downloadPath': settings.downloadPath,
      'autoDownload': settings.autoDownload.toString(),
      'showContinueWatching': settings.showContinueWatching.toString(),
      'showHistory': settings.showHistory.toString(),
      'showFavorites': settings.showFavorites.toString(),
    };

    for (final entry in map.entries) {
      await _settingsService.setSetting(entry.key, entry.value);
    }
  }

  Future<String?> getSetting(String key) async {
    return await _settingsService.getSetting(key);
  }

  Future<void> setSetting(String key, String value) async {
    await _settingsService.setSetting(key, value);
  }

  MangaReadMode _parseMangaReadMode(String? value) {
    if (value == null) return MangaReadMode.standard;
    return MangaReadMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MangaReadMode.standard,
    );
  }

  NovelReadMode _parseNovelReadMode(String? value) {
    if (value == null) return NovelReadMode.standard;
    return NovelReadMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NovelReadMode.standard,
    );
  }
}
