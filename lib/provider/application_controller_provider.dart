import 'package:flutter/material.dart';
import 'package:forui/theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/utils/theme/theme.dart';
import '../utils/index.dart';

final applicationControllerProvider =
    NotifierProvider<ApplicationController, ApplicationState>(
      ApplicationController.new,
    );

class ApplicationState {
  final String themeText;
  final AccentColors accentColor;
  final FThemeData themeData;
  final ThemeMode themeMode;
  ApplicationState({
    required this.themeText,
    required this.accentColor,
    required this.themeData,
    required this.themeMode,
  });

  ApplicationState copyWith({
    String? themeText,
    AccentColors? accentColor,
    FThemeData? themeData,
    ThemeMode? themeMode,
  }) {
    return ApplicationState(
      themeData: themeData ?? this.themeData,
      themeText: themeText ?? this.themeText,
      accentColor: accentColor ?? this.accentColor,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class ApplicationController extends Notifier<ApplicationState> {
  @override
  ApplicationState build() {
    final themeText = MiruSettings.getSettingSync<String>(SettingKey.theme);
    final accentColor =
        ThemeUtils.settingToAccentColor[MiruSettings.getSettingSync<String>(
          SettingKey.accentColor,
        )] ??
        AccentColors.zinc;

    final themeData = currentThemeData(themeText, accentColor);

    return ApplicationState(
      themeText: themeText,
      accentColor: accentColor,
      themeData: themeData,
      themeMode: ThemeMode.system,
    );
  }

  FThemeData currentThemeData(String themeText, AccentColors accentColor) {
    // Pick Forui theme data by accent and brightness
    final isLight = themeText == 'light';
    FThemeData themeData;
    switch (accentColor) {
      case AccentColors.zinc:
        themeData = isLight ? FThemes.zinc.light : FThemes.zinc.dark;
        break;
      case AccentColors.slate:
        themeData = isLight ? FThemes.slate.light : FThemes.slate.dark;
        break;
      case AccentColors.red:
        themeData = isLight ? FThemes.red.light : FThemes.red.dark;
        break;
      case AccentColors.rose:
        themeData = isLight ? FThemes.rose.light : FThemes.rose.dark;
        break;
      case AccentColors.orange:
        themeData = isLight ? FThemes.orange.light : FThemes.orange.dark;
        break;
      case AccentColors.green:
        themeData = isLight ? FThemes.green.light : FThemes.green.dark;
        break;
      case AccentColors.blue:
        themeData = isLight ? FThemes.blue.light : FThemes.blue.dark;
        break;
      case AccentColors.yellow:
        themeData = isLight ? FThemes.yellow.light : FThemes.yellow.dark;
        break;
      case AccentColors.violet:
        themeData = isLight ? FThemes.violet.light : FThemes.violet.dark;
        break;
    }
    return themeData;
  }

  void changeAccentColor(String color) {
    MiruSettings.setSettingSync(SettingKey.accentColor, color);
    final accentColor =
        ThemeUtils.settingToAccentColor[color] ?? AccentColors.zinc;
    state = state.copyWith(
      accentColor: accentColor,
      themeData: currentThemeData(state.themeText, accentColor),
    );
  }

  void changeTheme(String mode) {
    MiruSettings.setSettingSync(SettingKey.theme, mode);
    final themeMode =
        (mode == 'system')
            ? ThemeMode.system
            : (mode == 'light')
            ? ThemeMode.light
            : ThemeMode.dark;
    state = state.copyWith(
      themeMode: themeMode,
      themeText: mode,
      themeData: currentThemeData(mode, state.accentColor),
    );
  }
}
