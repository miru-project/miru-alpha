import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import './miru_directory.dart';
import '../model/index.dart';

class MiruStorage {
  static late final Isar database;
  // static late final Box settings;
  static const int _lastDatabaseVersion = 2;
  static late String _path;
  static late IsarCollection<AppSetting> _settings;
  static final _settingCache = <String, int>{};
  static ensureInitialized() async {
    _path = MiruDirectory.getDirectory;

    // 初始化数据库
    database = await Isar.open(
      [
        FavoriteSchema,
        HistorySchema,
        ExtensionSettingSchema,
        MangaSettingSchema,
        MiruDetailSchema,
        TMDBSchema,
        AppSettingSchema,
      ],
      directory: _path,
    );
    _settings = database.collection<AppSetting>();
    // 初始化设置
    await _initSettings();
    // 数据库升级
    // await performMigrationIfNeeded();
  }

  static performMigrationIfNeeded() async {
    final currentVersion = await getDatabaseVersion();
    debugPrint(currentVersion.toString());
    switch (currentVersion) {
      case 1:
        await migrateV1ToV2();
        break;
      case 2:
        return;
      default:
        throw Exception('Unknown version: $currentVersion');
    }

    // 更新到最新版本
  }

  static migrateV1ToV2() async {
    // 获取所有的 TMDB 数据
    final tmdbList = await database.tMDBs.where().findAll();
    database.writeTxn(() async {
      // 给所有的 TMDB 数据添加 mediaType 字段
      for (final tmdb in tmdbList) {
        final tmdbdetail = TMDBDetail.fromJson(jsonDecode(tmdb.data));
        tmdb.mediaType = tmdbdetail.mediaType;
        await database.tMDBs.put(tmdb);
      }
    });

    // 修改所有 miruDetail 的 tmdbId 字段为本地的 TMDB id
    final miruList = await database.miruDetails.where().findAll();
    database.writeTxn(() async {
      for (final miru in miruList) {
        final tmdb = await database.tMDBs
            .where()
            .filter()
            .tmdbIDEqualTo(miru.tmdbID!)
            .findFirst();
        if (tmdb != null) {
          miru.tmdbID = tmdb.id;
          await database.miruDetails.put(miru);
        }
      }
    });
  }

  // 获取数据库版本
  static Future<int> getDatabaseVersion() async {
    // 先获取数据库版本
    final version = await getSetting(SettingKey.databaseVersion, int);
    // 如果没有版本号，并且没有数据库文件说明是第一次使用，返回最新的数据库版本
    if (version == null) {
      final path = MiruDirectory.getDirectory;
      final dbPath = p.join(path, 'default.isar');
      if (File(dbPath).existsSync()) {
        return 1;
      }
      // 设置数据库版本并返回最新版本
      await setSetting(SettingKey.databaseVersion, _lastDatabaseVersion);
      return _lastDatabaseVersion;
    }
    // 如果有版本号，返回版本号
    return version;
  }

  static final Map<String, dynamic> _defaultSettings = {
    SettingKey.miruRepoUrl: "https://miru-repo.0n0.dev",
    SettingKey.tmdbKey: "",
    SettingKey.autoCheckUpdate: true,
    SettingKey.language: 'en',
    SettingKey.novelFontSize: 18.0,
    SettingKey.theme: 'system',
    SettingKey.enableNSFW: false,
    SettingKey.videoPlayer: 'built-in',
    SettingKey.listMode: "grid",
    SettingKey.keyI: 10.0,
    SettingKey.keyJ: -10.0,
    SettingKey.arrowLeft: -2.0,
    SettingKey.arrowRight: 2.0,
    SettingKey.readingMode: "standard",
    SettingKey.aniListToken: '',
    SettingKey.aniListUserId: '',
    SettingKey.autoTracking: true,
    SettingKey.windowSize: "1280,720",
    SettingKey.androidWebviewUA:
        "Mozilla/5.0 (Linux; Android 13; Android) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.43 Mobile Safari/537.36",
    SettingKey.windowsWebviewUA:
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0",
    SettingKey.proxy: '',
    SettingKey.proxyType: 'DIRECT',
    SettingKey.saveLog: true,
    SettingKey.subtitleFontSize: 46.0,
    SettingKey.subtitleFontColor: Colors.white.value,
    SettingKey.subtitleFontWeight: 'bold',
    SettingKey.subtitleBackgroundColor: Colors.black.value,
    SettingKey.subtitleBackgroundOpacity: 0.5,
    SettingKey.subtitleTextAlign: TextAlign.center.index,
  };
  static _initSettings() async {
    await database.writeTxn(() async {
      for (final entry in _defaultSettings.entries) {
        final result =
            await _settings.filter().keyEqualTo(entry.key).findFirst();
        if (result == null) {
          await _settings.putByKey(AppSetting()
            ..key = entry.key
            ..value = entry.value.toString());
        }
      }
    });
  }

  static setSetting(String key, dynamic value) async {
    await database.writeTxn(() async {
      await _settings.put(AppSetting()
        ..key = key
        ..value = value.toString());
    });
  }

  static setSettingSync(String key, String value) {
    if (_settingCache[key] != null) {
      database.writeTxnSync(() {
        _settings.putByKeySync(AppSetting()
          ..id = _settingCache[key]!
          ..key = key
          ..value = value.toString());
      });
    }
  }

  static getSetting(String key, Type type) async {
    AppSetting? val;
    await database.writeTxn(() async {
      val = await _settings.getByKey(key);
    });
    if (val == null) {
      throw Exception('Setting $key not found');
    }
    _settingCache[key] = val!.id;
    return convertStringToObj(val!.value, type);
  }

  static getSettingSync(String key, Type type) {
    AppSetting? val;
    database.writeTxnSync(() {
      val = _settings.getByKeySync(key);
    });
    if (val == null) {
      throw Exception('Setting $key not found');
    }
    _settingCache[key] = val!.id;
    return convertStringToObj(val!.value, type);
  }

  static String getUASetting() {
    if (Platform.isAndroid) {
      return getSettingSync(SettingKey.androidWebviewUA, String);
    }
    return getSettingSync(SettingKey.windowsWebviewUA, String);
  }

  static setUASetting(String value) async {
    if (Platform.isAndroid) {
      setSetting(SettingKey.androidWebviewUA, value);
    } else {
      setSetting(SettingKey.windowsWebviewUA, value);
    }
  }

  static convertStringToObj(String value, Type type) {
    switch (type) {
      case const (bool):
        return value == 'true';
      case const (double):
        return double.parse(value);
      case const (int):
        return int.parse(value);
      case const (String):
        return value;
      case const (Color):
        return Color(int.parse(value));
      default:
        throw Exception('Unknown type');
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
}
