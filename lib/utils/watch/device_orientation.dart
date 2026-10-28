import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

/// Whether one accelerometer sample says the device is physically held
/// landscape. Gravity is ~9.81 m/s²; a sample only counts when horizontal
/// gravity clearly dominates vertical, so flat-on-table (both axes small)
/// never flips the state — the caller keeps its previous one.
bool gravityIsLandscape(double x, double y) =>
    x.abs() > 6.5 && x.abs() > y.abs() + 1.0;

/// Portrait counterpart of [gravityIsLandscape].
bool gravityIsPortrait(double x, double y) =>
    y.abs() > 6.5 && y.abs() > x.abs() + 1.0;

/// Listens to the accelerometer and reports the *physical* device
/// orientation through [onChanged], debounced so a mid-rotation wobble
/// (gravity split across both axes) does not flip the state.
///
/// Window orientation (`MediaQuery.orientation`) cannot drive fullscreen
/// switching: the fullscreen player locks the window to landscape, which
/// stops window rotation events exactly when the user rotates back. The
/// sensor keeps working regardless of the window lock.
///
/// Platforms without an accelerometer (desktop) simply never fire.
StreamSubscription<AccelerometerEvent> listenDeviceOrientation(
  void Function(bool landscape) onChanged,
) {
  const sampling = Duration(milliseconds: 100);
  const samplesToConfirm = 4; // ~400ms of stable gravity before switching.
  var candidate = false;
  var streak = 0;
  var started = false;

  return accelerometerEventStream(samplingPeriod: sampling).listen(
    (event) {
      final landscape = gravityIsLandscape(event.x, event.y);
      final portrait = gravityIsPortrait(event.x, event.y);
      final bool? want = landscape ? true : (portrait ? false : null);
      if (want == null) {
        started = false;
        streak = 0;
        return;
      }
      if (!started || want != candidate) {
        candidate = want;
        streak = 1;
        started = true;
        return;
      }
      streak++;
      if (streak >= samplesToConfirm) {
        onChanged(candidate);
      }
    },
    // Desktop / web: no accelerometer — the fullscreen button stays the
    // only switch. Do not let the error tear down the page.
    onError: (Object error) {},
    cancelOnError: false,
  );
}
