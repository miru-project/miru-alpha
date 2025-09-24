import 'dart:io';

import 'package:flutter/material.dart';
import 'package:miru_app_new/miru_core/network/network.dart';
import 'package:miru_app_new/utils/log.dart';

class MiruSettings {
  static Map<String, String> _settingsCache = {};
  static Future<void> getAllSetting() async {
    final jsResult = await CoreNetwork.requestJSON('appSetting');

    final Map<String, String> result = {};
    try {
      if (jsResult is List) {
        for (final item in jsResult) {
          if (item is Map) {
            final k = item['key']?.toString();
            final v = item['value']?.toString();
            if (k != null && v != null) {
              result[k] = v;
            }
          }
        }
      }
    } catch (e) {
      logger.info('Failed to parse app settings from /appSetting: $e');
    }
    _settingsCache = result;
    return;
  }

  // Update key and value in miru core by HTTP
  static Future<void> setSetting(String key, String value) async {
    try {
      await CoreNetwork.requestRaw(
        'appSetting',
        data: [
          {"key": key, "value": value},
        ],
        method: 'PUT',
      );
    } catch (e) {
      logger.info('Failed to set setting $key to $value: $e');
    }
  }

  static Future<void> ensureInitialized() async {
    await getAllSetting();
    await _initSettings();
    logger.info('Settings initialized');
  }

  static final Map<String, dynamic> _defaultSettings = {
    SettingKey.miruRepoUrl: "https://miru-repo.0n0.dev",
    SettingKey.tmdbKey: "",
    SettingKey.autoCheckUpdate: 'true',
    SettingKey.language: 'en',
    SettingKey.novelFontSize: "18.0",
    SettingKey.theme: 'system',
    SettingKey.enableNSFW: 'false',
    SettingKey.videoPlayer: 'built-in',
    SettingKey.listMode: "grid",
    SettingKey.keyI: "10.0",
    SettingKey.keyJ: "-10.0",
    SettingKey.arrowLeft: "-2.0",
    SettingKey.arrowRight: "2.0",
    SettingKey.readingMode: "standard",
    SettingKey.aniListToken: '',
    SettingKey.aniListUserId: '',
    SettingKey.autoTracking: 'true',
    SettingKey.windowSize: "1280,720",
    SettingKey.androidWebviewUA:
        "Mozilla/5.0 (Linux; Android 13; Android) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.43 Mobile Safari/537.36",
    SettingKey.windowsWebviewUA:
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0",
    SettingKey.proxy: '',
    SettingKey.proxyType: 'DIRECT',
    SettingKey.saveLog: 'true',
    SettingKey.subtitleFontSize: "46.0",
    SettingKey.subtitleFontColor: Colors.white.toARGB32().toString(),
    SettingKey.subtitleFontWeight: 'bold',
    SettingKey.subtitleBackgroundColor: Colors.black.toARGB32().toString(),
    SettingKey.subtitleBackgroundOpacity: "0.5",
    SettingKey.subtitleTextAlign: TextAlign.center.index.toString(),
    SettingKey.accentColor: "zinc",
    SettingKey.mobiletitleIsonTop: "false",
    SettingKey.btServerLink: "https://github.com/miru-project/bt-server",
    SettingKey.maxConnection: "3",
    SettingKey.pinnedExtension: {}.toString(),
  };
  static Future<void> _initSettings() async {
    for (final entry in _defaultSettings.entries) {
      if (_settingsCache[entry.key] == null) {
        _settingsCache[entry.key] = entry.value;
      }
    }
    logger.info('Settings initialized');
  }

  static void setSettingSync(String key, String value) {
    _settingsCache[key] = value;
    setSetting(key, value);
  }

  static T getSettingSync<T>(String key) {
    final value = _settingsCache[key];
    if (value == null) {
      throw Exception('Setting $key not found');
    }
    return convertStringToObj<T>(value);
  }

  static String getUASetting() {
    if (Platform.isAndroid) {
      return getSettingSync<String>(SettingKey.androidWebviewUA);
    }
    return getSettingSync<String>(SettingKey.windowsWebviewUA);
  }

  static Future<void> setUASetting(String value) async {
    if (Platform.isAndroid) {
      setSettingSync(SettingKey.androidWebviewUA, value);
    } else {
      setSettingSync(SettingKey.windowsWebviewUA, value);
    }
  }

  static T convertStringToObj<T>(String value) {
    final type = T;

    switch (type) {
      case const (bool):
        return (value == 'true') as T;
      case const (double):
        return double.parse(value) as T;
      case const (int):
        return int.parse(value) as T;
      case const (String):
        return value as T;
      case const (Color):
        return Color(int.parse(value)) as T;
      case const (List<String>):
        return value.split(',').map((e) => e.trim()).toList() as T;
      case const (Set<String>):
        final val = value.substring(1, value.length - 1);
        if (val.isEmpty) {
          return <String>{} as T;
        }
        return val.split(',').map((e) => e.trim()).toSet() as T;
      default:
        throw Exception('Unknown $T');
    }
  }
}

class SettingKey {
  static const theme = "Theme";
  static const miruRepoUrl = "MiruRepoUrl";
  static const tmdbKey = 'TMDBKey';
  static const autoCheckUpdate = 'AutoCheckUpdate';
  static const language = 'Language';
  static const novelFontSize = 'NovelFontSize';
  static const enableNSFW = 'EnableNSFW';
  static const videoPlayer = 'VideoPlayer';
  static const databaseVersion = 'DatabaseVersion';
  static const listMode = 'ListMode';
  static const keyI = 'KeyI';
  static const keyJ = 'KeyJ';
  static const arrowLeft = 'Arrowleft';
  static const arrowRight = 'Arrowright';
  static const readingMode = 'ReadingMode';
  static const aniListToken = 'AniListToken';
  static const aniListUserId = 'AniListUserId';
  static const autoTracking = 'AutoTracking';
  static const windowSize = 'WindowsSize';
  static const windowPosition = 'WindowsPosition';
  static const androidWebviewUA = "AndroidWebviewUA";
  static const windowsWebviewUA = "WindowsWebviewUA";
  static const proxy = "Proxy";
  static const proxyType = "ProxyType";
  static const saveLog = "SaveLog";
  static const subtitleFontSize = "SubtitleFontSize";
  static const subtitleFontWeight = "SubtitleFontWeight";
  static const subtitleFontColor = "SubtitleFontColor";
  static const subtitleBackgroundColor = "SubtitleBackgroundColor";
  static const subtitleBackgroundOpacity = "SubtitleBackgroundOpacity";
  static const subtitleTextAlign = "SubtitleTextAlign";
  static const subtitleLastLanguageSelected = "SubtitleLastLanguageSelected";
  static const subtitleLastTitleSelected = "SubtitleLastTitleSelected";
  static const accentColor = "AccentColor";
  static const mobiletitleIsonTop = "MobileTitleIsOnTop";
  static const btServerLink = "BtServerLink";
  static const maxConnection = "MaxConnection";
  static const pinnedExtension = "PinnedExtension";
}
