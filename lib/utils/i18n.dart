import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:miru_app_new/utils/index.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class I18nUtils {
  static final flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
      useCountryCode: false,
      fallbackFile: 'en',
      basePath: 'assets/i18n',
      forcedLocale: Locale(
        MiruStorage.getSettingSync(SettingKey.language, String),
      ),
      decodeStrategies: [JsonDecodeStrategy()],
    ),
  );

  // 获取当前语言
  static Locale? get currentLanguage =>
      FlutterI18n.currentLocale(navigatorKey.currentContext!);

  // 切换语言
  static Future changeLanguage(String locale) async {
    await FlutterI18n.refresh(navigatorKey.currentContext!, Locale(locale));
  }
}

extension I18nString on String {
  String get i18n => FlutterI18n.translate(navigatorKey.currentContext!, this);
}
