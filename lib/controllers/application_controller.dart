import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/utils/theme/theme.dart';
import 'package:moon_design/moon_design.dart';
import '../utils/index.dart';

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
    : super(
        ApplicationState(
          themeData: ThemeData.dark(),
          themeText: MiruStorage.getSettingSync(SettingKey.theme, String),
          accentColor:
              ThemeUtils.settingToAccentColor[MiruStorage.getSettingSync(
                SettingKey.accentColor,
                String,
              )]!,
        ),
      ) {
    _init();
  }

  static const _themeList = ['system', 'dark', 'light', 'black'];

  List<String> get themeList => _themeList;

  final _lightToken = MoonTokens.light.copyWith(
    typography: MoonTypography.typography.copyWith(
      heading: MoonTypography.typography.heading.apply(
        fontFamily: "HarmonyOS_Sans",
      ),
      body: MoonTypography.typography.body.apply(fontFamily: "HarmonyOS_Sans"),
    ),
  );

  final _darkToken = MoonTokens.dark.copyWith(
    typography: MoonTypography.typography.copyWith(
      body: MoonTypography.typography.body.apply(fontFamily: "HarmonyOS_Sans"),
      heading: MoonTypography.typography.heading.apply(
        fontFamily: "HarmonyOS_Sans",
      ),
    ),
  );

  void _init() {
    state = state.copyWith(
      themeData: currentThemeData(state.themeText, state.accentColor),
    );
  }

  ThemeData currentThemeData(String themeText, AccentColors accentColor) {
    late MoonTokens token;
    late final Color color;
    late final Color textColor;
    // late final Color selectedTextColor;
    // late final Color selectSegmentColor;
    late ThemeData themeData;
    if (themeText == "light") {
      token = _lightToken;
      color = ThemeUtils.accentToMoonColorBright[accentColor]!;
      textColor =
          color.computeLuminance() < .3
              ? MoonColors.light.goku
              : MoonColors.light.bulma;
      // selectedTextColor = color.computeLuminance() < .5
      //     ? MoonColors.light.goku
      //     : MoonColors.light.bulma;
      // selectSegmentColor = color.computeLuminance() < .5
      //     ? MoonColors.light.bulma
      //     : MoonColors.light.goku;
      themeData = ThemeData.light(useMaterial3: true);
    } else {
      color = ThemeUtils.accentToMoonColorDark[accentColor]!;
      token = _darkToken;
      textColor =
          color.computeLuminance() < .3
              ? MoonColors.dark.bulma
              : MoonColors.dark.goku;
      // selectedTextColor = color.computeLuminance() < .5
      //     ? MoonColors.dark.bulma
      //     : MoonColors.dark.goku;
      themeData = ThemeData.dark(useMaterial3: true);
    }
    return themeData.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        MoonTheme(
          tokens: token,
          segmentedControlTheme: MoonSegmentedControlTheme(
            tokens: token,
          ).copyWith(
            colors: MoonSegmentedControlTheme(tokens: token).colors.copyWith(
              selectedSegmentColor: MoonColors.dark.bulma,
              selectedTextColor: MoonColors.dark.goku,
              textColor: textColor,
              backgroundColor: color,
              // textColor: textColor
            ),
          ),
          switchTheme: MoonSwitchTheme(tokens: token).copyWith(
            colors: MoonSwitchTheme(
              tokens: token,
            ).colors.copyWith(activeTrackColor: color),
          ),
          chipTheme: MoonChipTheme(tokens: token).copyWith(
            colors: MoonChipTheme(tokens: token).colors.copyWith(
              activeBackgroundColor: color,
              activeColor: textColor,
            ),
          ),
          dotIndicatorTheme: MoonDotIndicatorTheme(tokens: token).copyWith(
            colors: MoonDotIndicatorTheme(
              tokens: token,
            ).colors.copyWith(selectedColor: color),
          ),
          tabBarTheme: MoonTheme(tokens: token).tabBarTheme.copyWith(
            colors: MoonTheme(tokens: token).tabBarTheme.colors.copyWith(
              selectedPillTabColor: color,
              indicatorColor: color,
              selectedTextColor: color,
            ),
          ),
          circularLoaderTheme: MoonTheme(
            tokens: token,
          ).circularLoaderTheme.copyWith(
            colors: MoonTheme(
              tokens: token,
            ).circularLoaderTheme.colors.copyWith(color: color),
          ),
          textInputTheme: MoonTextInputTheme(tokens: token).copyWith(
            colors: MoonTheme(
              tokens: token,
            ).textInputTheme.colors.copyWith(activeBorderColor: color),
          ),
          circularProgressTheme: MoonTheme(
            tokens: token,
          ).circularProgressTheme.copyWith(
            colors: MoonTheme(
              tokens: token,
            ).circularProgressTheme.colors.copyWith(color: color),
          ),
        ),
      ],
      brightness: Brightness.dark,
      sliderTheme: SliderThemeData(
        trackHeight: 2,
        activeTrackColor: color.withAlpha(200),
        thumbColor: color,
        secondaryActiveTrackColor: color.withAlpha(100),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
      ),
    );
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
      themeData: currentThemeData(state.themeText, accentColor),
    );
  }

  void changeTheme(String mode) {
    MiruStorage.setSettingSync(SettingKey.theme, mode);
    state = state.copyWith(
      themeText: mode,
      themeData: currentThemeData(mode, state.accentColor),
    );
  }
}
