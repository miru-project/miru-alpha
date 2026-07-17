import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'package:miru_alpha/utils/theme/miru_colors.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';

/// Ordered list of selectable base (greyscale) colors, matching forui_cli's
/// [BaseColor] values.
const List<String> baseColorNames = [
  'neutral',
  'stone',
  'zinc',
  'mauve',
  'olive',
  'mist',
  'taupe',
];

/// Ordered list of selectable primary (accent) colors, matching forui_cli's
/// [PrimaryColor] values. `'none'` inherits the base color's own primary
/// (forui_cli encodes this as `'a'` / `PrimaryColor?` null).
const List<String> primaryColorNames = [
  'none',
  'amber',
  'blue',
  'cyan',
  'emerald',
  'fuchsia',
  'green',
  'indigo',
  'lime',
  'orange',
  'pink',
  'purple',
  'red',
  'rose',
  'sky',
  'teal',
  'violet',
  'yellow',
];

class ThemeUtils {
  /// Clamps [t] to the valid tint-strength range `[0, 1]`.
  static double clampTintStrength(double t) => t.clamp(0.0, 1.0);

  /// Blends [from] a [t] fraction (0..1) towards [to] in sRGB.
  static int _blend(int from, int to, double t) {
    final a = (((from >> 24) & 0xFF) + (((to >> 24 & 0xFF) - (from >> 24 & 0xFF)) * t)).round();
    final r = (((from >> 16) & 0xFF) + (((to >> 16 & 0xFF) - (from >> 16 & 0xFF)) * t)).round();
    final g = (((from >> 8) & 0xFF) + (((to >> 8 & 0xFF) - (from >> 8 & 0xFF)) * t)).round();
    final b = ((from & 0xFF) + (((to & 0xFF) - (from & 0xFF)) * t)).round();
    return (a << 24) | (r << 16) | (g << 8) | b;
  }

  /// Composes an [FColors] from a [baseColorsData] scale and a
  /// [primaryColorsData] accent pair, applying forui_cli's exact rule:
  ///
  /// ```dart
  /// primary          = primary?.primary          ?? base.primary;
  /// primaryForeground = primary?.primaryForeground ?? base.primaryForeground;
  /// // all other 12 fields are taken from the base scale
  /// ```
  ///
  /// [primary] may be `'none'`, in which case the base's own primary pair is
  /// used. This mirrors forui_cli's 2-dimensional `base` + `primary` theme
  /// model instead of a flat list of presets.
  ///
  /// In addition, when [tintStrength] > 0, `background` and `card` are subtly
  /// tinted towards the base's `border` hue (which carries the strongest
  /// neutral tint) so that each of the 7 bases is visibly distinguishable even
  /// in light mode, restoring the perceptible surface difference of the old
  /// `FTheme.<color>` presets. The strength is user-adjustable (see
  /// [ApplicationController.changeTintStrength]); `0` means 100% faithful to
  /// forui_cli (pure white light surfaces).
  static FColors composeColors(
    String base,
    String primary,
    bool light, {
    double tintStrength = 0.5,
  }) {
    final baseScale = (baseColorsData[base] ?? baseColorsData['zinc'])!;
    final baseColors_ = light ? baseScale.light : baseScale.dark;

    final usesBasePrimary =
        primary == 'none' || !primaryColorsData.containsKey(primary);
    final primaryColors_ = !usesBasePrimary
        ? (light
              ? primaryColorsData[primary]!.light
              : primaryColorsData[primary]!.dark)
        : null;

    // Tint neutral surfaces towards the base hue so bases are distinguishable.
    // Only applied in light mode: there forui makes `background`/`card` pure
    // white for every base, so without this the base picker is invisible on
    // those surfaces. In dark mode each base already has a distinct (opaque)
    // background, and the dark `border` is semi-transparent white, so tinting
    // there would wash the surface out — we leave dark surfaces untouched.
    // `border` carries the strongest neutral tint of the light base scale.
    final t = clampTintStrength(tintStrength);
    final applyTint = light && t > 0;
    final tintedBackground = applyTint
        ? _blend(baseColors_.background, baseColors_.border, t)
        : baseColors_.background;
    final tintedCard = applyTint
        ? _blend(baseColors_.card, baseColors_.border, t)
        : baseColors_.card;

    return FColors(
      brightness: light ? Brightness.light : Brightness.dark,
      systemOverlayStyle: light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      barrier: Color(baseColors_.barrier),
      background: Color(tintedBackground),
      foreground: Color(baseColors_.foreground),
      primary: Color(primaryColors_?.primary ?? baseColors_.primary),
      primaryForeground: Color(
        primaryColors_?.primaryForeground ?? baseColors_.primaryForeground,
      ),
      secondary: Color(baseColors_.secondary),
      secondaryForeground: Color(baseColors_.secondaryForeground),
      muted: Color(baseColors_.muted),
      mutedForeground: Color(baseColors_.mutedForeground),
      destructive: Color(baseColors_.destructive),
      destructiveForeground: Color(baseColors_.destructiveForeground),
      error: Color(baseColors_.error),
      errorForeground: Color(baseColors_.errorForeground),
      card: Color(tintedCard),
      border: Color(baseColors_.border),
    );
  }

  /// Resolves the [MiruPlatformTheme] (desktop + touch variants) for the given
  /// 2-dimensional [base] and [primary] selection. [tintStrength] controls how
  /// strongly the base hue tints the light `background`/`card` surfaces.
  static MiruPlatformTheme resolveTheme(
    String base,
    String primary, {
    double tintStrength = 0.5,
  }) {
    return MiruPlatformTheme(
      desktop: FThemeData(
        touch: false,
        colors: composeColors(base, primary, true, tintStrength: tintStrength),
      ),
      touch: FThemeData(
        touch: true,
        colors: composeColors(base, primary, true, tintStrength: tintStrength),
      ),
    );
  }

  static MiruPlatformTheme resolveDarkTheme(
    String base,
    String primary, {
    double tintStrength = 0.5,
  }) {
    return MiruPlatformTheme(
      desktop: FThemeData(
        touch: false,
        colors: composeColors(base, primary, false, tintStrength: tintStrength),
      ),
      touch: FThemeData(
        touch: true,
        colors: composeColors(base, primary, false, tintStrength: tintStrength),
      ),
    );
  }

  static FThemeData getThemeData(MiruPlatformTheme theme) {
    double width = 0;
    if (RouterUtil.rootNavigatorKey.currentContext == null) {
      if (Platform.isAndroid || Platform.isIOS) {
        return theme.touch;
      } else {
        return theme.desktop;
      }
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
