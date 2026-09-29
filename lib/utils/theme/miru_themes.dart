import 'package:forui/forui.dart';

import 'package:miru_alpha/utils/theme/miru_colors.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

/// A pair of [FThemeData] for desktop and touch platforms.
///
/// forui 0.24.0's [FPlatformThemeData] exposes a private constructor, so this
/// lightweight wrapper reproduces the `desktop`/`touch` accessors the app relied
/// on from the old `FThemes` themes.
class MiruPlatformTheme {
  final FThemeData desktop;
  final FThemeData touch;

  const MiruPlatformTheme({required this.desktop, required this.touch});
}

/// Miru's splash/legacy themes, reconstructed from the canonical forui_cli
/// base color scales in [baseColorsData].
///
/// The live, user-selectable theming is now driven by [ThemeUtils.composeColors]
/// (base × primary). This class only keeps a neutral light/dark pair for the
/// pre-init splash screen in `main.dart`.
class MiruThemes {
  /// Builds a light/dark [MiruPlatformTheme] pair for a [base] color with no
  /// primary override (`'none'`), used for splash and widget tests.
  static ({MiruPlatformTheme light, MiruPlatformTheme dark}) _baseTheme(
    String base,
  ) => (
    light: MiruPlatformTheme(
      desktop: FThemeData(
        touch: false,
        colors: ThemeUtils.composeColors(base, 'none', true),
      ),
      touch: FThemeData(
        touch: true,
        colors: ThemeUtils.composeColors(base, 'none', true),
      ),
    ),
    dark: MiruPlatformTheme(
      desktop: FThemeData(
        touch: false,
        colors: ThemeUtils.composeColors(base, 'none', false),
      ),
      touch: FThemeData(
        touch: true,
        colors: ThemeUtils.composeColors(base, 'none', false),
      ),
    ),
  );

  static final neutral = _baseTheme('neutral');

  /// Backwards-compatible convenience for tests/splash. `zinc` is now a base
  /// color (see [baseColorsData]); this returns the zinc base with no accent.
  static final zinc = _baseTheme('zinc');
}
