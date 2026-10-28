import 'package:flutter/services.dart';

/// Owner of the app-wide system-UI mode: status bar hidden, bottom system
/// navigation bar kept (see `runMiruApp` in app_bootstrap.dart).
///
/// Android does not re-assert the app's hidden-status-bar state after the
/// user pulls down the notification shade — the bar stays visible until the
/// app hides it again. `_App.didChangeMetrics` schedules that re-hide through
/// [restore]; surfaces that legitimately own the bars (video fullscreen's
/// `immersiveSticky`) set [surfaceOwned] so the re-hide stands down.
class AppSystemUi {
  AppSystemUi._();

  /// True while a surface intentionally owns the system-UI mode (e.g. video
  /// fullscreen). The auto-rehide timer does nothing while this is set.
  static bool surfaceOwned = false;

  /// Re-applies the app-wide mode: status bar hidden, bottom bar kept.
  static void restore() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
  }
}
