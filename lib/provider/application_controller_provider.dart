import 'package:material_ui/material_ui.dart';
import 'package:forui/theme.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/setting_dir_index.dart';
part 'application_controller_provider.g.dart';

class ApplicationState {
  final String themeText;
  final String baseColor;
  final String primaryColor;
  final FThemeData themeData;
  final ThemeMode themeMode;
  final bool isMobileTitleOnTop;
  final String language;

  /// Strength (0..1) of the per-base `background`/`card` tint in light mode.
  /// 0 = faithful to forui_cli (pure white); higher = stronger base hue.
  final double tintStrength;
  ApplicationState({
    required this.themeText,
    required this.baseColor,
    required this.primaryColor,
    required this.themeData,
    required this.themeMode,
    required this.language,
    this.isMobileTitleOnTop = true,
    this.tintStrength = 0.5,
  });

  ApplicationState copyWith({
    String? themeText,
    String? baseColor,
    String? primaryColor,
    FThemeData? themeData,
    ThemeMode? themeMode,
    bool? isMobileTitleOnTop,
    String? language,
    double? tintStrength,
  }) {
    return ApplicationState(
      themeData: themeData ?? this.themeData,
      themeText: themeText ?? this.themeText,
      baseColor: baseColor ?? this.baseColor,
      primaryColor: primaryColor ?? this.primaryColor,
      themeMode: themeMode ?? this.themeMode,
      isMobileTitleOnTop: isMobileTitleOnTop ?? this.isMobileTitleOnTop,
      language: language ?? this.language,
      tintStrength: tintStrength ?? this.tintStrength,
    );
  }
}

@Riverpod(keepAlive: true)
class ApplicationController extends _$ApplicationController {
  @override
  ApplicationState build() {
    final themeText = MiruSettings.getSettingSync<String>(SettingKey.theme);
    final baseColor = MiruSettings.getSettingSync<String>(SettingKey.baseColor);
    final primaryColor = MiruSettings.getSettingSync<String>(
      SettingKey.accentColor,
    );
    final isMobileTitleOnTop = MiruSettings.getSettingSync<bool>(
      SettingKey.mobiletitleIsonTop,
    );
    final language = MiruSettings.getSettingSync<String>(SettingKey.language);
    final tintStrength = MiruSettings.getSettingSync<double>(
      SettingKey.baseColorTintStrength,
    );
    final themeData = currentThemeData(
      themeText,
      baseColor,
      primaryColor,
      tintStrength: tintStrength,
    );

    return ApplicationState(
      themeText: themeText,
      baseColor: baseColor,
      primaryColor: primaryColor,
      themeData: themeData,
      themeMode: _themeModeFromText(themeText),
      isMobileTitleOnTop: isMobileTitleOnTop,
      language: language,
      tintStrength: tintStrength,
    );
  }

  static ThemeMode _themeModeFromText(String text) => switch (text) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  FThemeData currentThemeData(
    String themeText,
    String baseColor,
    String primaryColor, {
    double tintStrength = 0.5,
  }) {
    // Pick Forui theme data by 2-dimensional base + primary and brightness.
    //
    // `themeText` may be 'light', 'dark', or 'system'. For 'system' we resolve
    // the *actual* platform brightness so the Forui theme (which drives every
    // `FTheme` descendant's colors, typography and widget styles) stays in sync
    // with `MaterialApp.themeMode` instead of always falling back to dark.
    final isLight = switch (themeText) {
      'light' => true,
      'dark' => false,
      _ =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.light,
    };
    final theme = isLight
        ? ThemeUtils.resolveTheme(
            baseColor,
            primaryColor,
            tintStrength: tintStrength,
          )
        : ThemeUtils.resolveDarkTheme(
            baseColor,
            primaryColor,
            tintStrength: tintStrength,
          );
    return ThemeUtils.getThemeData(theme);
  }

  /// Recomputes [ApplicationState.themeData] from the current base/primary/mode.
  /// Call this whenever any theme input changes so *all* `FTheme` descendants
  /// rebuild with a freshly-derived [FThemeData].
  void _refreshThemeData() {
    state = state.copyWith(
      themeData: currentThemeData(
        state.themeText,
        state.baseColor,
        state.primaryColor,
        tintStrength: state.tintStrength,
      ),
    );
  }

  /// Re-resolves the theme when the OS brightness changes while in 'system'
  /// mode. Wired from [App] via `didChangePlatformBrightness`.
  void onPlatformBrightnessChanged() {
    if (state.themeText == 'system') {
      _refreshThemeData();
    }
  }

  void changeBaseColor(String color) {
    MiruSettings.setSettingSync(SettingKey.baseColor, color);
    final baseColor = baseColorNames.contains(color) ? color : 'zinc';
    state = state.copyWith(
      baseColor: baseColor,
      themeData: currentThemeData(
        state.themeText,
        baseColor,
        state.primaryColor,
      ),
    );
  }

  void changePrimaryColor(String color) {
    MiruSettings.setSettingSync(SettingKey.accentColor, color);
    final primaryColor = primaryColorNames.contains(color) ? color : 'none';
    state = state.copyWith(
      primaryColor: primaryColor,
      themeData: currentThemeData(
        state.themeText,
        state.baseColor,
        primaryColor,
      ),
    );
  }

  /// Updates the per-base light-mode `background`/`card` tint strength (0..1).
  /// 0 disables the tint (pure white, faithful to forui_cli); 1 fully applies
  /// the base hue. Persists the value and re-derives [ApplicationState.themeData]
  /// so the change is visible everywhere immediately.
  void changeTintStrength(double strength) {
    final clamped = ThemeUtils.clampTintStrength(strength);
    MiruSettings.setSettingSync(
      SettingKey.baseColorTintStrength,
      clamped.toString(),
    );
    state = state.copyWith(
      tintStrength: clamped,
      themeData: currentThemeData(
        state.themeText,
        state.baseColor,
        state.primaryColor,
        tintStrength: clamped,
      ),
    );
  }

  void changeTheme(String mode) {
    MiruSettings.setSettingSync(SettingKey.theme, mode);
    final themeMode = (mode == 'system')
        ? ThemeMode.system
        : (mode == 'light')
        ? ThemeMode.light
        : ThemeMode.dark;
    state = state.copyWith(
      themeMode: themeMode,
      themeText: mode,
      themeData: currentThemeData(mode, state.baseColor, state.primaryColor),
    );
  }

  void updateMobileTitleOnTop(bool isOnTop) {
    MiruSettings.setSettingSync(
      SettingKey.mobiletitleIsonTop,
      isOnTop.toString(),
    );
    state = state.copyWith(isMobileTitleOnTop: isOnTop);
  }

  void changeLanguage(String language) {
    MiruSettings.setSettingSync(SettingKey.language, language);
    state = state.copyWith(language: language);
  }
}
