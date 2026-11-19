import 'dart:io';

import 'package:flutter/services.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/update/miru_release.dart';
import 'package:miru_alpha/utils/update/update_apply.dart';
import 'package:url_launcher/url_launcher.dart';

/// Hands a downloaded update to the platform.
///
/// There is no cross-platform "install" primitive, so the two families are
/// deliberately different:
///
/// * **Android** hands the APK to the package installer, which replaces the
///   app and reports its own progress.
/// * **desktop** is two-phase: the archive is extracted beside the install and
///   recorded as pending, and the swap happens on the next launch (or when the
///   user presses *Restart now*). The running app is never overwritten
///   underneath itself, and the restart itself is two renames rather than a
///   download — [DesktopUpdater].
class UpdateInstaller {
  const UpdateInstaller._();

  /// Channel implemented by `MainActivity.kt` (Android only). The name must
  /// match `MainActivity.updateChannel` exactly — a typo here fails at runtime
  /// with MissingPluginException, not at build time.
  static const MethodChannel _channel = MethodChannel('miru.alpha/update');

  /// Whether Miru replaces itself — desktop, where this class stages the build
  /// and swaps it in on restart. Android hands the APK to the package
  /// installer, which owns the update from there.
  ///
  /// Uses [currentUpdatePlatform] rather than `Platform.isX` so the answer
  /// always matches the asset [pickUpdateAsset] chose: if they disagreed, a
  /// `.tar.gz` could be handed to the APK installer.
  static bool get appliesItself =>
      currentUpdatePlatform == UpdatePlatform.linux ||
      currentUpdatePlatform == UpdatePlatform.windows;

  /// The CPU architecture the release names use (`x64`, `arm64`, `armv7l`), or
  /// null when the host will not say.
  ///
  /// Only used to break a tie when a release carries one archive per
  /// architecture; with a single build per OS it changes nothing.
  ///
  /// Windows reads the environment rather than spawning `cmd /c echo ...`,
  /// which would flash a console window. Linux asks `uname -m`, which has no
  /// window to flash.
  static String? _archToken;

  static String? get desktopArchToken {
    final cached = _archToken;
    if (cached != null) return cached;

    String? raw;
    try {
      if (Platform.isWindows) {
        raw = Platform.environment['PROCESSOR_ARCHITECTURE'];
      } else if (Platform.isLinux) {
        raw = Process.runSync('uname', ['-m']).stdout.trim();
      }
    } catch (error, stackTrace) {
      logger.warning(
        'Could not detect the CPU architecture',
        error,
        stackTrace,
      );
    }

    _archToken = switch (raw?.toLowerCase()) {
      'x86_64' || 'amd64' || 'x64' => 'x64',
      'aarch64' || 'arm64' => 'arm64',
      'armv7l' || 'armv8l' || 'arm' => 'armv7l',
      _ => null,
    };
    return _archToken;
  }

  /// The ABIs this Android build can run, most preferred first.
  ///
  /// `Build.SUPPORTED_ABIS` from the host side: Dart exposes no equivalent,
  /// and the asset name is the only thing that says which APK is which. Empty
  /// on every other platform, and empty on Android until
  /// [warmUpPlatformInfo] has run — [pickUpdateAsset] then falls back to its
  /// generic preference order instead of guessing wrong.
  static List<String> _supportedAbis = const [];

  static List<String> get supportedAbis => _supportedAbis;

  /// Resolves everything [pickUpdateAsset] needs about the host.
  ///
  /// Called once per update check, off the widget path: the ABI list costs a
  /// platform-channel round trip and the Linux architecture costs a process
  /// spawn, and neither should happen inside `build`.
  static Future<void> warmUpPlatformInfo() async {
    if (_supportedAbis.isEmpty &&
        currentUpdatePlatform == UpdatePlatform.android) {
      try {
        final abis = await _channel.invokeListMethod<String>(
          'getSupportedAbis',
        );
        if (abis != null && abis.isNotEmpty) {
          _supportedAbis = abis;
          logger.info('This build supports the ABIs: ${abis.join(', ')}');
        }
      } catch (error, stackTrace) {
        // An older app, or a build without the Kotlin shim: pickUpdateAsset's
        // fallback order still lands on a working APK for a 64-bit device.
        logger.warning('Could not read the supported ABIs', error, stackTrace);
      }
    }
    if (currentUpdatePlatform == UpdatePlatform.linux ||
        currentUpdatePlatform == UpdatePlatform.windows) {
      // Touch the getter now so the widget's `asset` lookup reads the cache
      // instead of spawning `uname` during a build.
      logger.fine(
        'Release assets will be matched for arch: '
        '${desktopArchToken ?? 'unknown'}',
      );
    }
  }

  /// Opens the release page in the system browser — the fallback when the
  /// release carries no installable asset for this platform, or when the
  /// update itself was refused.
  static Future<bool> openReleasePage(String url) async {
    if (url.isEmpty) return false;
    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      logger.warning('Could not open release page: $url');
    }
    return launched;
  }

  /// Prepares the downloaded [archive] for the next launch.
  ///
  /// Desktop: extracts it beside the install and records it as pending, so a
  /// later restart applies it with no further clicks — [UpdateApplyResult.staged].
  /// Android: hands the APK to the package installer and returns
  /// [UpdateApplyResult.handedOver].
  ///
  /// Returns [UpdateApplyResult.failed] when the archive could not be unpacked
  /// or the install directory is not writable; the caller then offers the
  /// release page.
  ///
  /// [installDirectory] exists for tests: the real path comes from the running
  /// executable, and a test run must never extract next to the test binary.
  static Future<UpdateApplyResult> installDownloaded(
    String archive, {
    required String version,
    String? installDirectory,
  }) async {
    if (currentUpdatePlatform == UpdatePlatform.android) {
      final opened = await openApk(archive);
      // The package installer owns the process from here; it is not a swap we
      // can time, so this reports "handed over" rather than "applied".
      return opened ? UpdateApplyResult.handedOver : UpdateApplyResult.failed;
    }

    final install = installDirectory ?? DesktopUpdater.installDirectory;
    final executable = installDirectory == null
        ? DesktopUpdater.executableName
        : _executableNameFor(Platform.isWindows);

    final staged = await DesktopUpdater.stage(
      archive: archive,
      installDirectory: install,
      executableName: executable,
    );
    if (staged == null) return UpdateApplyResult.failed;

    await DesktopUpdater.stagePendingUpdate(
      staged: staged,
      installDirectory: install,
      executableName: executable,
      version: version,
    );
    return UpdateApplyResult.staged;
  }

  /// Applies the pending update now: swap, relaunch, quit.
  ///
  /// The *Restart now* action and the startup check are the same call — one
  /// mechanism entered at two moments, so the two can never drift apart.
  static Future<UpdateApplyResult> applyPendingUpdate({
    String? installDirectory,
    bool exitWhenDone = true,
  }) => DesktopUpdater.commitPendingUpdate(
    installDirectory: installDirectory,
    exitWhenDone: exitWhenDone,
  );

  /// Removes the backups and stale staging earlier updates left behind.
  static Future<void> pruneUpdateBackups() => DesktopUpdater.pruneBackups();

  /// The executable name a *staged* build carries on this platform. Only used
  /// with an explicit install directory (tests); the real path reads it from
  /// [Platform.resolvedExecutable].
  static String _executableNameFor(bool windows) =>
      windows ? 'miru_alpha.exe' : 'miru_alpha';

  /// Hands an APK to Android's package installer.
  ///
  /// Returns false when the platform cannot run an installer from inside the
  /// app (a build without the Kotlin shim, or an older app), so the caller can
  /// fall back to the release page.
  static Future<bool> openApk(String path) async {
    if (!File(path).existsSync()) {
      logger.warning('Installer file missing: $path');
      return false;
    }

    try {
      await _channel.invokeMethod<bool>('installApk', {'path': path});
      return true;
    } on MissingPluginException {
      // A build without the Kotlin shim (or an older app): fall through.
      logger.warning('Android installer channel unavailable');
      return false;
    } catch (error, stackTrace) {
      logger.severe('Android installer failed', error, stackTrace);
      return false;
    }
  }
}
