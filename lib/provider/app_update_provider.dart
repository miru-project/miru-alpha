import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/core/miru_directory.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/update/miru_release.dart';
import 'package:miru_alpha/utils/update/update_apply.dart';
import 'package:miru_alpha/utils/update/update_installer.dart';
import 'package:miru_alpha/utils/update/update_service.dart';
import 'package:miru_alpha/utils/update/version_util.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_update_provider.g.dart';

/// The update banner's state machine.
///
/// The banner is not a modal: [AppUpdateState.visible] decides whether the
/// settings page shows it at all, so an idle or dismissed check renders
/// nothing instead of an empty alert.
enum UpdateStatus {
  /// Nothing checked yet.
  idle,

  /// A check is in flight.
  checking,

  /// The installed build is the newest published one.
  upToDate,

  /// A newer release exists and can be installed.
  available,

  /// An installer is being fetched.
  downloading,

  /// The build is on disk and unpacked: on desktop it replaces the install on
  /// the next launch, on Android it is ready to hand to the package installer.
  downloaded,

  /// The last check or download failed.
  failed,
}

/// The immutable snapshot the alert renders from.
class AppUpdateState {
  const AppUpdateState({
    this.status = UpdateStatus.idle,
    this.currentVersion = '',
    this.release,
    this.progress = 0,
    this.error,
    this.localPath,
    this.manual = false,
    this.dismissed = false,
    this.ignored = false,
    this.latered = false,
  });

  final UpdateStatus status;

  /// The installed build's version.
  final String currentVersion;

  /// The newest published release, when one was read.
  final MiruRelease? release;

  /// Download progress, 0.0-1.0 — only meaningful in [UpdateStatus.downloading].
  final double progress;

  /// A human-readable failure (an i18n key).
  final String? error;

  /// Where the installer landed on disk.
  final String? localPath;

  /// True when the user asked for the check (vs. the automatic launch check).
  final bool manual;

  /// True once the user closed the banner; cleared by the next check.
  final bool dismissed;

  /// True when this exact version was skipped from the launch prompt. It stays
  /// true until a *newer* release appears, and only silences the prompt — the
  /// settings banner and the manual check still offer the update.
  final bool ignored;

  /// True when the user pressed *Later* on this version's prompt. Same reach as
  /// [ignored] as far as the dialog is concerned, but the banner is left alone:
  /// "later" means "not now", not "never mention it again".
  final bool latered;

  MiruReleaseAsset? get asset => release == null
      ? null
      : pickUpdateAsset(release!.assets, platform: currentUpdatePlatform);

  /// Whether the release page should be offered instead of a download —
  /// no asset for this platform, or nothing to install at all.
  bool get needsBrowserFallback => asset == null;

  /// The banner's one-line description, as an i18n key.
  String get titleKey {
    switch (status) {
      case UpdateStatus.checking:
        return 'settings.update.checking';
      case UpdateStatus.upToDate:
        return 'settings.update.up_to_date';
      case UpdateStatus.available:
        return 'settings.update.available';
      case UpdateStatus.downloading:
        return 'settings.update.downloading';
      case UpdateStatus.downloaded:
        return 'settings.update.downloaded';
      case UpdateStatus.failed:
        // Three different failures land in `failed`: the feed being
        // unreachable, a download that died, and a download that arrived but
        // could not be unpacked. The title says which one — otherwise a
        // half-finished download is reported as "update check failed", and the
        // user is sent to re-check a feed that was fine.
        if (error == 'settings.update.prepare_failed') {
          return 'settings.update.prepare_failed_title';
        }
        return error == 'settings.update.download_failed'
            ? 'settings.update.download_failed_title'
            : 'settings.update.failed';
      case UpdateStatus.idle:
        return 'settings.update.idle';
    }
  }

  /// The banner's detail line, as an i18n key.
  String? get subtitleKey {
    switch (status) {
      case UpdateStatus.upToDate:
        return 'settings.update.up_to_date_information';
      case UpdateStatus.available:
        return 'settings.update.available_information';
      case UpdateStatus.downloaded:
        return 'settings.update.downloaded_information';
      case UpdateStatus.downloading:
        return 'settings.update.downloading_information';
      case UpdateStatus.failed:
        // Same split as [titleKey]: a download failure explains itself with
        // the download sentence, not the feed one.
        return switch (error) {
          'settings.update.prepare_failed' => 'settings.update.prepare_failed',
          'settings.update.download_failed' =>
            'settings.update.download_failed',
          _ => 'settings.update.failed_information',
        };
      case UpdateStatus.checking:
      case UpdateStatus.idle:
        return null;
    }
  }

  /// True when the banner should occupy space on the settings page.
  bool get visible {
    if (dismissed) return false;
    switch (status) {
      case UpdateStatus.idle:
        return false;
      case UpdateStatus.checking:
      case UpdateStatus.upToDate:
      case UpdateStatus.failed:
        // Only an explicit "check now" surfaces these; an automatic check that
        // finds nothing must not nag the user on every launch.
        return manual;
      case UpdateStatus.available:
      case UpdateStatus.downloading:
      case UpdateStatus.downloaded:
        return true;
    }
  }

  /// True when the launch prompt should be raised for this state: an
  /// automatic check found a newer build the user has not skipped.
  ///
  /// A manual check is excluded — the settings page is already showing the
  /// banner at that point, so a modal on top would say the same thing twice.
  bool get promptable =>
      status == UpdateStatus.available && !manual && !ignored && !latered;

  AppUpdateState copyWith({
    UpdateStatus? status,
    String? currentVersion,
    MiruRelease? release,
    double? progress,
    String? error,
    String? localPath,
    bool? manual,
    bool? dismissed,
    bool? ignored,
    bool? latered,
    bool clearError = false,
    bool clearLocalPath = false,
  }) {
    return AppUpdateState(
      status: status ?? this.status,
      currentVersion: currentVersion ?? this.currentVersion,
      release: release ?? this.release,
      progress: progress ?? this.progress,
      error: clearError ? null : (error ?? this.error),
      localPath: clearLocalPath ? null : (localPath ?? this.localPath),
      manual: manual ?? this.manual,
      dismissed: dismissed ?? this.dismissed,
      ignored: ignored ?? this.ignored,
      latered: latered ?? this.latered,
    );
  }
}

/// Builds the update [UpdateService] the notifier talks to. Overridden in
/// tests and in the widgetbook catalog with a fake.
final updateServiceProvider = Provider<UpdateService>((ref) => UpdateService());

/// Where the desktop updater unpacks a downloaded build — the directory that
/// will be swapped in, i.e. the parent of the running executable.
///
/// Null means "work it out from the running executable", which is what every
/// real build gets. It exists so a test can stage into a throwaway tree: the
/// real value points at the Flutter test binary, where unpacking a build would
/// write into the SDK cache.
final updateInstallDirectoryProvider = Provider<String?>((ref) => null);

/// Where the app keeps downloaded installers (the private support dir, so the
/// Android package installer can be handed a content:// URI).
final updateDirectoryProvider = Provider<String>((ref) {
  try {
    return updateDownloadDirectory(MiruDirectory.appSupportDirectory);
  } catch (error) {
    // Plugins are not up (tests, widgetbook): fall back to a temp dir so a
    // download still lands somewhere the installer can be opened from.
    logger.warning('Update directory unavailable, using temp', error);
    return Directory.systemTemp.createTempSync('miru-update-').path;
  }
});

/// Checks GitHub for a newer Miru build and drives the installer hand-off.
@Riverpod(keepAlive: true)
class AppUpdate extends _$AppUpdate {
  CancelToken? _token;

  @override
  AppUpdateState build() {
    ref.onDispose(() => _token?.cancel('disposed'));
    return const AppUpdateState();
  }

  /// Checks for a newer release.
  ///
  /// [manual] is the difference between the launch check (silent unless a
  /// newer build exists) and the settings-page "Check now" tile (which always
  /// shows the outcome).
  Future<void> check({bool manual = false}) async {
    if (state.status == UpdateStatus.downloading) return;

    state = state.copyWith(
      status: UpdateStatus.checking,
      manual: manual,
      dismissed: false,
      clearError: true,
    );

    final current = await UpdateService.resolveCurrentVersion();
    state = state.copyWith(currentVersion: current);

    try {
      final service = ref.read(updateServiceProvider);
      _token = CancelToken();
      final release = await service.fetchLatestRelease(cancelToken: _token);
      if (!ref.mounted) return;

      if (release == null) {
        state = state.copyWith(status: UpdateStatus.upToDate, release: null);
        return;
      }

      final isNewer =
          current.isNotEmpty && compareVersions(release.version, current) > 0;
      // An ignored or postponed version keeps the *prompt* quiet on later
      // silent launches. Only `ignored` also hides the banner: pressing Later
      // means "not now", and the settings page still has to offer the build.
      final skipped = isNewer && release.version == _ignoredVersion;
      final postponed = isNewer && release.version == _laterVersion;
      state = state.copyWith(
        status: isNewer ? UpdateStatus.available : UpdateStatus.upToDate,
        release: release,
        ignored: skipped,
        latered: postponed,
        dismissed: skipped && !manual,
      );
    } catch (error, stackTrace) {
      if (error is DioException && error.type == DioExceptionType.cancel) {
        return;
      }
      logger.warning('Update check failed', error, stackTrace);
      if (!ref.mounted) return;
      state = state.copyWith(
        status: UpdateStatus.failed,
        error: 'settings.update.failed',
      );
    }
  }

  /// The version the user skipped from the launch prompt, or '' when none.
  ///
  /// A settings-store failure must not fail the update check — the feed is
  /// reachable, the answer is just "nothing was skipped".
  String get _ignoredVersion {
    try {
      return MiruSettings.getSettingSync<String>(
        SettingKey.ignoredUpdateVersion,
      );
    } catch (error, stackTrace) {
      logger.warning(
        'Could not read the ignored update version',
        error,
        stackTrace,
      );
      return '';
    }
  }

  /// The version the user pressed *Later* on, or '' when none.
  ///
  /// Same contract as [_ignoredVersion]: a settings-store failure degrades to
  /// "nothing was postponed" rather than breaking the check.
  String get _laterVersion {
    try {
      return MiruSettings.getSettingSync<String>(SettingKey.laterUpdateVersion);
    } catch (error, stackTrace) {
      logger.warning(
        'Could not read the postponed update version',
        error,
        stackTrace,
      );
      return '';
    }
  }

  /// Downloads the platform's build and prepares it for the next launch.
  ///
  /// When the release has no asset for this platform (a phone build without
  /// an APK, macOS) the release page is opened instead — the user still gets
  /// the update, just not through the in-app path.
  ///
  /// On desktop this also unpacks the build beside the install and records it
  /// as pending, so the download dialog flows straight into "restart to
  /// apply": nothing is left to wait for afterwards. A download that unpacked
  /// but could not be staged reports `prepare_failed`, not `download_failed` —
  /// the bytes arrived, and the reason the user needs is "Miru's folder is not
  /// writable".
  Future<void> download() async {
    final release = state.release;
    final asset = state.asset;
    if (release == null) return;

    if (asset == null) {
      await UpdateInstaller.openReleasePage(release.htmlUrl);
      return;
    }

    state = state.copyWith(status: UpdateStatus.downloading, progress: 0);
    final service = ref.read(updateServiceProvider);
    final directory = ref.read(updateDirectoryProvider);

    try {
      final file = await service.downloadAsset(
        asset,
        directory: directory,
        onProgress: (progress) {
          if (ref.mounted) state = state.copyWith(progress: progress);
        },
      );
      if (!ref.mounted) return;

      final prepared = await UpdateInstaller.installDownloaded(
        file.path,
        version: release.version,
        installDirectory: ref.read(updateInstallDirectoryProvider),
      );
      if (!ref.mounted) return;

      if (prepared == UpdateApplyResult.failed) {
        state = state.copyWith(
          status: UpdateStatus.failed,
          progress: 1,
          localPath: file.path,
          error: 'settings.update.prepare_failed',
        );
        return;
      }

      state = state.copyWith(
        status: UpdateStatus.downloaded,
        progress: 1,
        localPath: file.path,
      );
    } catch (error, stackTrace) {
      logger.severe('Update download failed', error, stackTrace);
      if (!ref.mounted) return;
      state = state.copyWith(
        status: UpdateStatus.failed,
        error: 'settings.update.download_failed',
      );
    }
  }

  /// Applies the prepared update, or opens the release page when there is
  /// nothing to apply.
  ///
  /// On desktop this is the *Restart now* action: the swap happens here and
  /// the process does not come back, because the build that was running has
  /// been unlinked. The exact same call runs at startup
  /// ([UpdateInstaller.applyPendingUpdate]) — pressing the button is only
  /// "do now what the next launch would have done", so the two paths cannot
  /// drift apart. Android hands the APK to the package installer, which
  /// reports its own progress and kills the app.
  Future<void> install() async {
    final path = state.localPath;
    if (path == null) {
      await UpdateInstaller.openReleasePage(state.release?.htmlUrl ?? '');
      return;
    }

    final result = await UpdateInstaller.applyPendingUpdate(
      installDirectory: ref.read(updateInstallDirectoryProvider),
    );
    if (result == UpdateApplyResult.applied ||
        result == UpdateApplyResult.scheduled) {
      // The replacement is running or about to be. There is nothing left to
      // report and no state to write.
      return;
    }

    // Nothing was waiting: Android (the APK is handed over here), or a
    // desktop build whose staged copy went missing — the archive is still on
    // disk, so prepare it again rather than giving up.
    final prepared = await UpdateInstaller.installDownloaded(
      path,
      version: state.release?.version ?? '',
      installDirectory: ref.read(updateInstallDirectoryProvider),
    );
    if (prepared == UpdateApplyResult.failed) {
      // Read-only install, a refused swap, an archive with no payload — the
      // user still gets the build, from the release page.
      await UpdateInstaller.openReleasePage(state.release?.htmlUrl ?? '');
      return;
    }

    // The marker is written again, so the restart the button promised can go
    // through instead of leaving the user on the old build with a re-staged
    // copy and nothing to show for the click.
    await UpdateInstaller.applyPendingUpdate(
      installDirectory: ref.read(updateInstallDirectoryProvider),
    );
  }

  /// Opens the release page directly ("Release notes" on the banner).
  Future<void> openReleasePage() =>
      UpdateInstaller.openReleasePage(state.release?.htmlUrl ?? '');

  /// Closes the banner. The next explicit check brings it back.
  void dismiss() {
    state = state.copyWith(dismissed: true);
  }

  /// Skips this version's launch prompt for good ("Ignore this version").
  ///
  /// Only the prompt is silenced: the settings banner and a manual check still
  /// offer the update, which is what the dialog's subtitle promises. The
  /// skipped version is persisted, so a later release raises the prompt again.
  Future<void> ignore() async {
    final version = state.release?.version;
    if (version == null) return;

    MiruSettings.setSettingSync(SettingKey.ignoredUpdateVersion, version);
    state = state.copyWith(ignored: true, dismissed: true);
  }

  /// Postpones this version's launch prompt ("Later").
  ///
  /// Unlike [ignore] the banner is untouched: "later" means not now, so the
  /// build stays one tap away on the settings page. The version is persisted
  /// all the same, otherwise the next launch would ask again — which is the
  /// nag the button exists to stop. A newer release raises the prompt again.
  Future<void> later() async {
    final version = state.release?.version;
    if (version == null) return;

    MiruSettings.setSettingSync(SettingKey.laterUpdateVersion, version);
    state = state.copyWith(latered: true);
  }

  /// Re-arms the banner after a dismissal (the settings tile's "Check now").
  Future<void> checkNow() => check(manual: true);

  /// True when the app should auto-check at launch.
  static bool get autoCheckEnabled =>
      MiruSettings.getSettingSync<bool>(SettingKey.autoCheckUpdate);
}
