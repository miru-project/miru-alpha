import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/utils/theme/theme.dart';
import 'package:moon_design/moon_design.dart';
import '../utils/index.dart';
import 'package:moon_design/src/theme/tab_bar/tab_bar_theme.dart';

final applicationControllerProvider =
    StateNotifierProvider<ApplicationController, ApplicationState>(
  (ref) => ApplicationController(),
);

class ApplicationState {
  final String themeText;
  final AccentColors accentColor;
  final ThemeData themeData;
  ApplicationState({
    required this.themeText,
    required this.accentColor,
    required this.themeData,
  });

  ApplicationState copyWith({
    String? themeText,
    AccentColors? accentColor,
    ThemeData? themeData,
  }) {
    return ApplicationState(
      themeData: themeData ?? this.themeData,
      themeText: themeText ?? this.themeText,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

class ApplicationController extends StateNotifier<ApplicationState> {
  ApplicationController()
      : super(ApplicationState(
          themeData: ThemeData.dark(),
          themeText: MiruStorage.getSettingSync(SettingKey.theme, String),
          accentColor: ThemeUtils.settingToAccentColor[
              MiruStorage.getSettingSync(SettingKey.accentColor, String)]!,
        )) {
    _init();
  }

  static const _themeList = [
    'system',
    'dark',
    'light',
    'black',
  ];

  List<String> get themeList => _themeList;

  final _lightToken = MoonTokens.light.copyWith(
    typography: MoonTypography.typography.copyWith(
      heading: MoonTypography.typography.heading
          .apply(fontFamily: "HarmonyOS_Sans_SC"),
    ),
  );

  final _darkToken = MoonTokens.dark.copyWith(
    typography: MoonTypography.typography.copyWith(
      heading: MoonTypography.typography.heading
          .apply(fontFamily: "HarmonyOS_Sans_SC"),
    ),
  );

  void _init() {
    // final theme = MiruStorage.getSettingSync(SettingKey.theme, String);
    // final accentColor = ThemeUtils.settingToAccentColor[
    //     MiruStorage.getSettingSync(SettingKey.accentColor, String)]!;

    state = state.copyWith(
        themeData: currentThemeData(state.themeText, state.accentColor));
  }

  currentThemeData(String themeText, AccentColors accentColor) {
    switch (themeText) {
      case "light":
        final color = ThemeUtils.accentToMoonColorBright[accentColor]!;
        return ThemeData.light().copyWith(
          extensions: <ThemeExtension<dynamic>>[
            MoonTheme(
              tokens: _lightToken,
              tabBarTheme: MoonTabBarTheme(tokens: _lightToken).copyWith(
                  colors: MoonTabBarTheme(tokens: _lightToken).colors.copyWith(
                      selectedPillTabColor: color,
                      selectedTextColor: color.computeLuminance() < .5
                          ? MoonColors.light.goku
                          : MoonColors.light.bulma)),
              switchTheme: MoonSwitchTheme(tokens: _lightToken).copyWith(
                  colors: MoonSwitchTheme(tokens: _lightToken)
                      .colors
                      .copyWith(activeTrackColor: color)),
              segmentedControlTheme:
                  MoonSegmentedControlTheme(tokens: _lightToken).copyWith(
                      colors: MoonSegmentedControlTheme(tokens: _lightToken)
                          .colors
                          .copyWith(
                              backgroundColor: color,
                              textColor: color.computeLuminance() < .5
                                  ? MoonColors.light.goku
                                  : MoonColors.light.bulma)),
            ),
          ],
        );
      default:
        final color = ThemeUtils.accentToMoonColorDark[accentColor]!;
        return ThemeData.dark().copyWith(
          extensions: <ThemeExtension<dynamic>>[
            MoonTheme(
                tokens: _darkToken,
                segmentedControlTheme:
                    MoonSegmentedControlTheme(tokens: _lightToken).copyWith(
                        colors: MoonSegmentedControlTheme(tokens: _lightToken)
                            .colors
                            .copyWith(
                                backgroundColor: color,
                                textColor: color.computeLuminance() < .3
                                    ? MoonColors.light.goku
                                    : MoonColors.light.bulma)),
                switchTheme: MoonSwitchTheme(tokens: _darkToken).copyWith(
                    colors: MoonSwitchTheme(tokens: _darkToken)
                        .colors
                        .copyWith(activeTrackColor: color)),
                chipTheme: MoonChipTheme(tokens: _darkToken).copyWith(
                    colors: MoonChipTheme(tokens: _darkToken).colors.copyWith(
                        activeBackgroundColor: color,
                        activeColor: color.computeLuminance() < .3
                            ? MoonColors.light.goku
                            : MoonColors.light.bulma)),
                tabBarTheme: MoonTabBarTheme(tokens: _darkToken).copyWith(
                    colors: MoonTabBarTheme(tokens: _darkToken).colors.copyWith(
                          selectedPillTabColor: color,
                          indicatorColor: color,
                          selectedTextColor: color,
                        ))),
          ],
        );
    }
  }

  ThemeMode get theme {
    switch (state.themeText) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      case "black":
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void changeAccentColor(String color) {
    MiruStorage.setSettingSync(SettingKey.accentColor, color);
    final accentColor = ThemeUtils.settingToAccentColor[color]!;
    state = state.copyWith(
        accentColor: accentColor,
        themeData: currentThemeData(state.themeText, accentColor));
  }

  void changeTheme(String mode) {
    MiruStorage.setSettingSync(SettingKey.theme, mode);
    state = state.copyWith(
        themeText: mode, themeData: currentThemeData(mode, state.accentColor));
  }
}
