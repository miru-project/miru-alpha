import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:miru_app_new/utils/theme/theme.dart';
import 'package:moon_design/moon_design.dart';
import '../utils/index.dart';
import 'package:moon_design/src/theme/tab_bar/tab_bar_theme.dart';

class ApplicationController extends GetxController {
  static const _themeList = [
    'system',
    'dark',
    'light',
    'black',
  ];
  List<String> get themeList => _themeList;
  final RxString _themeText = "system".obs;
  final Rx<AccentColors> _accentColor = AccentColors.piccolo.obs;
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
  @override
  void onInit() async {
    _themeText.value = await MiruStorage.getSetting(SettingKey.theme, String);
    _accentColor.value = ThemeUtils.settingToAccentColor[
        await MiruStorage.getSetting(SettingKey.accentColor, String)]!;
    super.onInit();
  }

  ThemeData get currentThemeData {
    switch (_themeText.value) {
      case "light":
        final color = ThemeUtils.accentToMoonColorBright[_accentColor.value]!;
        return ThemeData.light().copyWith(
          extensions: <ThemeExtension<dynamic>>[
            MoonTheme(
              tokens: _lightToken,
              // text,
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
        final color = ThemeUtils.accentToMoonColorDark[_accentColor.value]!;
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
                tabBarTheme: MoonTabBarTheme(tokens: _darkToken)
                    .copyWith(colors: MoonTabBarTheme(tokens: _darkToken).colors.copyWith(selectedPillTabColor: color, indicatorColor: color, selectedTextColor: color.computeLuminance() < .5 ? MoonColors.light.goku : MoonColors.light.bulma))),
          ],
        );
      // case "black":
      //   return ThemeData.dark(
      //     useMaterial3: true,
      //   ).copyWith(
      //     scaffoldBackgroundColor: Colors.black,
      //     canvasColor: Colors.black,
      //     cardColor: Colors.black,
      //     dialogBackgroundColor: Colors.black,
      //     primaryColor: Colors.black,
      //     hintColor: Colors.black,
      //     primaryColorDark: Colors.black,
      //     primaryColorLight: Colors.black,
      //     colorScheme: const ColorScheme.dark(
      //       primary: Colors.white,
      //       onSecondary: Colors.white,
      //       onSurface: Colors.white,
      //       secondary: Colors.grey,
      //       surface: Colors.black,
      //       onPrimary: Colors.black,
      //       primaryContainer: Color.fromARGB(255, 31, 31, 31),
      //       surfaceTint: Colors.black,
      //     ),
      //   );
      // default:
      //   return ThemeData.light(useMaterial3: true);
    }
  }

  get moonTokens => MoonTokens.dark;
  ThemeMode get theme {
    switch (_themeText.value) {
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

  changeAccentColor(String color) {
    MiruStorage.setSettingSync(SettingKey.accentColor, color);
    _accentColor.value = ThemeUtils.settingToAccentColor[color]!;
    Get.forceAppUpdate();
  }

  changeTheme(String mode) {
    MiruStorage.setSettingSync(SettingKey.theme, mode);
    _themeText.value = mode;
    Get.forceAppUpdate();
  }
}
