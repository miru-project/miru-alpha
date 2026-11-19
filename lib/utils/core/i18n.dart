import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:miru_alpha/utils/setting_dir_index.dart';
import 'package:miru_alpha/utils/router/router_util.dart';

final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

class I18nUtils {
  static final flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
      useCountryCode: false,
      fallbackFile: 'en',
      basePath: 'assets/i18n',
      forcedLocale: Locale(
        MiruSettings.getSettingSync<String>(SettingKey.language),
      ),
      decodeStrategies: [JsonDecodeStrategy()],
    ),
  );

  // 获取当前语言
  static Locale? get currentLanguage =>
      FlutterI18n.currentLocale(RouterUtil.rootNavigatorKey.currentContext!);

  // 切换语言
  static Future changeLanguage(String locale) async {
    final context = RouterUtil.rootNavigatorKey.currentState?.overlay?.context;
    if (context == null) return;
    await FlutterI18n.refresh(context, Locale(locale));
  }
}

/// English strings resolved without a [FlutterI18n] ancestor.
///
/// The app itself always has the delegate above, so this path is only taken by
/// contexts that deliberately have no [Localizations] at all — the widgetbook
/// catalog builds its own `MaterialApp` inside the widgetbook package and
/// cannot register the app's delegates. Without it every catalog use-case
/// renders `settings.update.title` instead of a sentence, which makes the
/// catalog useless for judging copy.
///
/// English is the only language loaded: a catalog is read by whoever is
/// designing the surface, and the app's own language switch has no bearing on
/// it.
abstract final class I18nStatic {
  static Map<String, String> _english = const {};
  static bool _ready = false;

  /// Loads `en.json` once, before the first frame.
  ///
  /// Two candidate paths because the same source file is reachable under
  /// different URIs depending on which app is running: the catalog depends on
  /// miru_alpha as a package (so its assets land under `packages/miru_alpha`),
  /// while the app itself serves them from the bundle root.
  static Future<void> warmUp() async {
    if (_ready) return;
    for (final path in const [
      'packages/miru_alpha/assets/i18n/en.json',
      'assets/i18n/en.json',
    ]) {
      try {
        final decoded = jsonDecode(await rootBundle.loadString(path));
        if (decoded is Map<String, dynamic>) {
          _english = _flatten(decoded);
          _ready = true;
          return;
        }
      } catch (_) {
        // Try the next candidate; a catalog with no English at all still
        // renders the keys, which is what it did before this existed.
      }
    }
  }

  /// Turns the nested JSON object into the dotted keys `flutter_i18n` exposes
  /// (`{"settings":{"update":{"title":"…"}}}` → `settings.update.title`).
  static Map<String, String> _flatten(
    Map<String, dynamic> json, [
    String prefix = '',
  ]) {
    final out = <String, String>{};
    json.forEach((key, value) {
      final full = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map) {
        out.addAll(_flatten(value.cast<String, dynamic>(), full));
      } else {
        out[full] = value.toString();
      }
    });
    return out;
  }

  /// Resolves [key] against the loaded English table, substituting `{param}`
  /// placeholders the way `flutter_i18n`'s `translationParams` does.
  ///
  /// An unknown key resolves to itself — the same behaviour as the delegate,
  /// and what makes a missing translation visible instead of blank.
  static String translate(String key, [Map<String, String>? params]) {
    final template = _english[key];
    if (template == null) return key;
    if (params == null || params.isEmpty) return template;
    var out = template;
    params.forEach((name, value) {
      out = out.replaceAll('{$name}', value);
    });
    return out;
  }

  /// Whether [warmUp] found a table. False means keys render verbatim.
  static bool get isReady => _ready;
}

extension I18nString on String {
  String get i18n {
    final context = RouterUtil.rootNavigatorKey.currentContext;
    if (context == null) return I18nStatic.translate(this);
    return FlutterI18n.translate(context, this);
  }

  String fill(Map<String, String> params) {
    final context = RouterUtil.rootNavigatorKey.currentContext;
    if (context == null) return I18nStatic.translate(this, params);
    return FlutterI18n.translate(context, this, translationParams: params);
  }
}
