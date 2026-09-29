import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// One layer of a reader's floating overlay.
///
/// Fades and slides as a unit, and is inert while hidden. Keeping the HUD halves
/// and the status pill mounted is what lets a centre tap cross-fade between
/// them instead of snapping from one to the other; each half gets its own layer
/// because the top bar enters from above and the control panel from below.
class ReaderOverlayLayer extends StatelessWidget {
  const ReaderOverlayLayer({
    super.key,
    required this.visible,
    required this.offset,
    required this.child,
  });

  final bool visible;

  /// Vertical slide applied while hidden, in logical pixels.
  final double offset;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : Offset(0, offset / 100),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: child,
        ),
      ),
    );
  }
}

/// What has already been handed to the platform channels for one reader, so a
/// rebuild does not re-issue a brightness or wakelock call every frame.
@immutable
class ReaderScreenApplied {
  const ReaderScreenApplied({this.brightness, this.auto, this.keepScreenOn});

  final int? brightness;
  final bool? auto;
  final bool? keepScreenOn;

  ReaderScreenApplied copyWith({int? brightness, bool? auto, bool? keepScreenOn}) =>
      ReaderScreenApplied(
        brightness: brightness ?? this.brightness,
        auto: auto ?? this.auto,
        keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      );
}

/// Applies a reader's screen preferences, skipping anything already applied.
///
/// [applied] is the caller's ref, so the record of what is already on the device
/// lives as long as the reader does rather than being rebuilt per frame.
void applyReaderScreenPreferences(
  ObjectRef<ReaderScreenApplied?> applied,
  MangaBrightnessMode brightnessMode,
  int brightness,
  bool keepScreenOn,
) {
  final previous = applied.value ?? const ReaderScreenApplied();
  if (brightnessMode == MangaBrightnessMode.auto) {
    // Auto hands the screen back to the system, including undoing a manual
    // override this session applied — otherwise switching to auto would keep the
    // forced value until the reader closed.
    if (previous.auto != true) {
      applied.value = ReaderScreenApplied(auto: true, keepScreenOn: keepScreenOn);
      try {
        unawaited(ScreenBrightness().resetApplicationScreenBrightness());
      } catch (error, stack) {
        logger.fine('brightness release failed', error, stack);
      }
    }
  } else {
    if (previous.brightness != brightness) {
      applied.value = ReaderScreenApplied(
        brightness: brightness,
        auto: false,
        keepScreenOn: keepScreenOn,
      );
      try {
        unawaited(
          ScreenBrightness().setApplicationScreenBrightness(brightness / 100),
        );
      } catch (error, stack) {
        logger.fine('brightness apply failed', error, stack);
      }
    }
  }
  if (previous.keepScreenOn == keepScreenOn) return;
  applied.value =
      applied.value?.copyWith(keepScreenOn: keepScreenOn) ??
      ReaderScreenApplied(
        brightness: brightnessMode == MangaBrightnessMode.manual
            ? brightness
            : null,
        auto: brightnessMode == MangaBrightnessMode.auto,
        keepScreenOn: keepScreenOn,
      );
  try {
    unawaited(keepScreenOn ? WakelockPlus.enable() : WakelockPlus.disable());
  } catch (error, stack) {
    logger.fine('wakelock apply failed', error, stack);
  }
}

/// Restores the platform brightness and releases the wake lock a reader grabbed.
///
/// Both are best-effort: a test host has no platform channels.
Future<void> releaseReaderScreen() async {
  try {
    if (await WakelockPlus.enabled) await WakelockPlus.disable();
  } catch (error, stack) {
    logger.fine('wakelock release failed', error, stack);
  }
  try {
    await ScreenBrightness().resetApplicationScreenBrightness();
  } catch (error, stack) {
    logger.fine('brightness reset failed', error, stack);
  }
}
