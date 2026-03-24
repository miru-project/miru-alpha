import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/router/router_util.dart';

enum AccentColors {
  zinc,
  neutral,
  slate,
  red,
  rose,
  orange,
  green,
  blue,
  yellow,
  violet,
}

final overrideTheme = FThemes.zinc.dark;

class ThemeUtils {
  static const settingToAccentColor = <String, AccentColors>{
    'zinc': AccentColors.zinc,
    'slate': AccentColors.slate,
    'red': AccentColors.red,
    'rose': AccentColors.rose,
    'orange': AccentColors.orange,
    'green': AccentColors.green,
    'blue': AccentColors.blue,
    'yellow': AccentColors.yellow,
    'violet': AccentColors.violet,
    'neutral': AccentColors.neutral,
  };

  static final accentToBright = <AccentColors, FPlatformThemeData>{
    AccentColors.zinc: FThemes.zinc.light,
    AccentColors.slate: FThemes.slate.light,
    AccentColors.red: FThemes.red.light,
    AccentColors.rose: FThemes.rose.light,
    AccentColors.orange: FThemes.orange.light,
    AccentColors.green: FThemes.green.light,
    AccentColors.blue: FThemes.blue.light,
    AccentColors.yellow: FThemes.yellow.light,
    AccentColors.violet: FThemes.violet.light,
    AccentColors.neutral: FThemes.neutral.light,
  };

  static final accentToDark = <AccentColors, FPlatformThemeData>{
    AccentColors.zinc: FThemes.zinc.dark,
    AccentColors.slate: FThemes.slate.dark,
    AccentColors.red: FThemes.red.dark,
    AccentColors.rose: FThemes.rose.dark,
    AccentColors.orange: FThemes.orange.dark,
    AccentColors.green: FThemes.green.dark,
    AccentColors.blue: FThemes.blue.dark,
    AccentColors.yellow: FThemes.yellow.dark,
    AccentColors.violet: FThemes.violet.dark,
    AccentColors.neutral: FThemes.neutral.dark,
  };
  static FThemeData getThemeData(FPlatformThemeData theme) {
    double width = 0;
    if (RouterUtil.rootNavigatorKey.currentContext == null) {
      return theme.touch;
    }
    width = MediaQuery.of(
      RouterUtil.rootNavigatorKey.currentContext!,
    ).size.width;
    final breakpoints = theme.desktop.breakpoints;
    return switch (width) {
      _ when width < breakpoints.sm => theme.touch,
      _ when width < breakpoints.lg => theme.desktop,
      _ => theme.desktop,
    };
  }
}
