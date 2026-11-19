import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:miru_alpha/utils/core/log.dart';

/// What an update hand-off did.
enum UpdateApplyResult {
  /// Nothing was waiting — no staged build, or it went stale (deleted, or not
  /// a build any more). Nothing happened, and nothing should.
  none,

  /// The new build is running. The caller is running in the *old* one, whose
  /// image has just been unlinked, and must quit.
  applied,

  /// A detached helper will finish the swap the moment this process exits
  /// (Windows, where a running `.exe`'s directory cannot be renamed). The
  /// caller must quit.
  scheduled,

  /// Extracted and recorded on disk; it replaces the running build the next
  /// time Miru starts. The app keeps running the old build until then.
  staged,

  /// Android: the package installer owns the APK now and reports its own
  /// progress.
  handedOver,

  /// Nothing changed: no archive, no payload, no permission, or the new build
  /// would not start. The caller falls back to the release page.
  failed,
}

/// A build that has been downloaded, extracted, and is waiting for the next
/// launch to replace the running one.
///
/// Written as JSON beside the install (`<install>.pending-update.json`) so the
/// next launch finds it without scanning, and read back defensively: every
/// field is checked against the filesystem, and a marker pointing at something
/// missing is deleted rather than retried on every launch forever.
class PendingUpdate {
  const PendingUpdate({
    required this.version,
    required this.installDirectory,
    required this.stagedDirectory,
    required this.executableName,
    required this.stagedAt,
  });

  final String version;
  final String installDirectory;
  final String stagedDirectory;
  final String executableName;
  final DateTime stagedAt;

  Map<String, dynamic> toJson() => {
    'version': version,
    'installDirectory': installDirectory,
    'stagedDirectory': stagedDirectory,
    'executableName': executableName,
    'stagedAt': stagedAt.toIso8601String(),
  };

  static PendingUpdate? fromJson(Map<String, dynamic> json) {
    final version = json['version'] as String?;
    final install = json['installDirectory'] as String?;
    final staged = json['stagedDirectory'] as String?;
    final executable = json['executableName'] as String?;
    if (version == null ||
        install == null ||
        staged == null ||
        executable == null ||
        version.isEmpty ||
        install.isEmpty ||
        staged.isEmpty ||
        executable.isEmpty) {
      return null;
    }
    return PendingUpdate(
      version: version,
      installDirectory: install,
      stagedDirectory: staged,
      executableName: executable,
      stagedAt:
          DateTime.tryParse(json['stagedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Replaces a running desktop build with the one inside a downloaded archive.
///
/// Miru's desktop artifacts are a *directory* — `Miru-alpha/` from the release
/// tarball (`tar -czvf Miru-Alpha-linux.tar.gz -C build/linux/x64/release
/// Miru-alpha`) and the same folder zipped for Windows — so the unit that has
/// to be swapped is the install directory itself, not a single binary. A
/// running process cannot overwrite its own image, but it can rename its own
/// directory; that is what makes a self-update possible without shipping a
/// helper binary.
///
/// The flow is two-phase, so the swap never competes with the user:
///
/// 1. **stage** — extract the archive into a sibling of the install (same
///    filesystem, so the later renames are atomic rather than a copy) and
///    record a [PendingUpdate] marker beside it.
/// 2. **commit** — at the next launch, or when the user presses *Restart now*,
///    rename the old build aside, move the staged one in, and start it.
///
/// That split is what makes the update seamless: the download and the
/// extraction happen while the user is using the app, and the only thing left
/// for the restart is two renames.
///
/// The old build is kept as `…​.bak-<stamp>` until the next update or the next
/// launch, so a bad build is one rename away from being undone by hand.
class DesktopUpdater {
  const DesktopUpdater._();

  static final _log = Logger('${logger.name}.update');

  static final _backupPattern = RegExp(r'\.bak-\d+$');

  /// A staged download: the extraction shell (`.update-<stamp>`) or the
  /// payload hoisted out of it (`.update-<stamp>-payload`). Left behind only
  /// when the app died between staging and swapping.
  static final _stagingPattern = RegExp(r'\.update-\d+(-payload)?$');

  /// The directory the running build lives in — the parent of the real
  /// executable, symlinks resolved, so a launcher in `~/.local/bin` does not
  /// make the updater look at the wrong folder.
  static String get installDirectory => parentOf(Platform.resolvedExecutable)!;

  /// The file name the OS started this process with (`miru_alpha`,
  /// `miru_alpha.exe`). Used to prove a staged payload is really a build and
  /// to relaunch it after the swap.
  static String get executableName =>
      Platform.resolvedExecutable.split(Platform.pathSeparator).last;

  /// The marker recording the build the next launch should switch to.
  static File pendingUpdateFile(String installDirectory) =>
      File('$installDirectory.pending-update.json');

  /// Extracts [archive] next to [installDirectory] and returns the directory
  /// that holds the new build, or null when the archive is unusable.
  ///
  /// The staging directory is a sibling of the install rather than a temp
  /// dir: `/tmp` is a different filesystem on most desktops, and a rename
  /// across filesystems is a copy — half of which the user would be left with
  /// if the app died mid-swap.
  static Future<Directory?> stage({
    required String archive,
    required String installDirectory,
    required String executableName,
  }) async {
    final file = File(archive);
    if (!file.existsSync()) {
      _log.warning('Update archive is missing: $archive');
      return null;
    }

    final parent = parentOf(installDirectory);
    if (parent == null) {
      // A relative install path (`./Miru-alpha`) has no sibling to stage in —
      // better to say so than to extract next to whatever the cwd happens to
      // be.
      _log.warning('Install path has no parent directory: $installDirectory');
      return null;
    }

    final staging = Directory(
      '$parent${Platform.pathSeparator}'
      '${_baseName(installDirectory)}.update-${_stamp()}',
    );
    // A staging directory from a run that died mid-extract must not be reused:
    // it holds a half-written build that would pass the "has an executable"
    // check and then fail to start.
    if (await staging.exists()) await staging.delete(recursive: true);
    await staging.create(recursive: true);

    if (!await _extract(file, staging)) {
      await staging.delete(recursive: true);
      return null;
    }

    Directory? payload = _payloadIn(staging);
    if (payload == null) {
      _log.warning('Update archive has no top-level build directory: $archive');
      await staging.delete(recursive: true);
      return null;
    }

    if (payload.path != staging.path) {
      // The archive wrapped the build in a single folder (`Miru-alpha/`).
      // Hoist it out of the extraction shell so the swap renames exactly one
      // directory and no empty `<base>.update-<stamp>` shell is left beside the
      // install.
      final hoisted = Directory('${staging.path}-payload');
      await _deleteIfPresent(hoisted);
      await payload.rename(hoisted.path);
      await staging.delete(recursive: true);
      payload = Directory(hoisted.path);
    }

    final executable = File(
      '${payload.path}${Platform.pathSeparator}$executableName',
    );
    if (!executable.existsSync()) {
      _log.warning('Staged build has no "$executableName": ${executable.path}');
      await payload.delete(recursive: true);
      return null;
    }

    return payload;
  }

  /// Records [staged] as the build the next launch should switch to.
  ///
  /// A second download simply overwrites the marker: the newest build wins,
  /// and the previous staging directory is collected by [pruneBackups].
  static Future<void> stagePendingUpdate({
    required Directory staged,
    required String installDirectory,
    required String executableName,
    required String version,
  }) async {
    final update = PendingUpdate(
      version: version,
      installDirectory: installDirectory,
      stagedDirectory: staged.path,
      executableName: executableName,
      stagedAt: DateTime.now().toUtc(),
    );

    final marker = pendingUpdateFile(installDirectory);
    await marker.parent.create(recursive: true);
    await marker.writeAsString(
      const JsonEncoder.withIndent('  ').convert(update.toJson()),
    );
    _log.info('Staged $version for the next launch: ${staged.path}');
  }

  /// The staged build waiting to be applied, or null when there is none.
  ///
  /// Doubles as the cleanup path: a marker whose install directory, staged
  /// directory or executable has gone away is deleted here, so a half-finished
  /// update cannot resurrect itself on every launch.
  static Future<PendingUpdate?> readPendingUpdate({
    String? installDirectory,
  }) async {
    final install = installDirectory ?? DesktopUpdater.installDirectory;
    final marker = pendingUpdateFile(install);
    if (!marker.existsSync()) return null;

    PendingUpdate? update;
    try {
      update = PendingUpdate.fromJson(
        jsonDecode(marker.readAsStringSync()) as Map<String, dynamic>,
      );
    } catch (error, stackTrace) {
      _log.warning('Ignoring an unreadable update marker', error, stackTrace);
    }

    if (update == null || update.installDirectory != install) {
      await _deleteQuietly(marker);
      return null;
    }

    final staged = Directory(update.stagedDirectory);
    final executable = File(
      '${staged.path}${Platform.pathSeparator}${update.executableName}',
    );
    if (!staged.existsSync() || !executable.existsSync()) {
      // The app died between staging and the swap, or the staging directory
      // was collected. Retrying forever would be worse than dropping it.
      _log.warning(
        'Staged build for ${update.version} is gone: '
        '${update.stagedDirectory}',
      );
      await _deleteQuietly(staged);
      await _deleteQuietly(marker);
      return null;
    }

    return update;
  }

  /// Forgets a staged build — used once it has been applied.
  static Future<void> clearPendingUpdate(PendingUpdate update) async {
    await _deleteQuietly(Directory(update.stagedDirectory));
    await _deleteQuietly(pendingUpdateFile(update.installDirectory));
  }

  /// Applies the staged build: swap, relaunch, quit.
  ///
  /// Called from two places that must agree because they share the whole
  /// mechanism: the bootstrap (so an update downloaded in an earlier session
  /// lands on the next launch with no click at all) and the *Restart now*
  /// button (the same code, run immediately).
  ///
  /// Returns [UpdateApplyResult.none] when nothing was waiting, and
  /// [UpdateApplyResult.failed] when the swap was refused — in both cases the
  /// caller keeps running the build it started.
  static Future<UpdateApplyResult> commitPendingUpdate({
    String? installDirectory,
    bool exitWhenDone = true,
  }) async {
    final install = installDirectory ?? DesktopUpdater.installDirectory;
    final update = await readPendingUpdate(installDirectory: install);
    if (update == null) return UpdateApplyResult.none;

    final outcome = await _swapNow(
      staged: Directory(update.stagedDirectory),
      installDirectory: install,
      executableName: update.executableName,
    );

    switch (outcome) {
      case _SwapOutcome.applied:
        await clearPendingUpdate(update);
        if (exitWhenDone) exit(0);
        return UpdateApplyResult.applied;
      case _SwapOutcome.refused:
        // Windows would not let a running process rename the directory its own
        // `.exe` lives in. The helper performs the same two moves once this pid
        // is gone — the one platform where the update is applied by something
        // other than the app itself.
        final queued = await _scheduleWindowsSwap(
          staged: Directory(update.stagedDirectory),
          installDirectory: install,
          executableName: update.executableName,
          marker: pendingUpdateFile(install),
        );
        if (queued) {
          if (exitWhenDone) exit(0);
          return UpdateApplyResult.scheduled;
        }
        return UpdateApplyResult.failed;
      case _SwapOutcome.failed:
        // The old build is already back in place (or was never moved). The
        // marker stays, so a later launch can try again.
        return UpdateApplyResult.failed;
    }
  }

  /// Renames the old build aside, moves the staged one in, and starts it.
  static Future<_SwapOutcome> _swapNow({
    required Directory staged,
    required String installDirectory,
    required String executableName,
  }) async {
    final install = Directory(installDirectory);
    final backup = Directory(_backupPath(installDirectory));

    try {
      await _deleteIfPresent(backup);
      await install.rename(backup.path);
    } catch (error, stackTrace) {
      _log.warning('Could not move the current build aside', error, stackTrace);
      return _SwapOutcome.refused;
    }

    try {
      await staged.rename(install.path);
    } catch (error, stackTrace) {
      _log.severe('Could not move the new build into place', error, stackTrace);
      await _restore(backup, install);
      return _SwapOutcome.failed;
    }

    final executable =
        '${install.path}${Platform.pathSeparator}$executableName';

    try {
      await Process.start(
        executable,
        const [],
        mode: ProcessStartMode.detached,
      );
      _log.info('Started the updated build: $executable');
      return _SwapOutcome.applied;
    } catch (error, stackTrace) {
      _log.severe('The updated build would not start', error, stackTrace);
      await _restore(backup, install);
      return _SwapOutcome.failed;
    }
  }

  /// Writes a detached `.cmd` that waits for this pid to exit and then swaps.
  ///
  /// Windows will not let a running process rename the directory its own
  /// `.exe` lives in (and never overwrite the mapped image), so the swap has to
  /// happen after the exit — the one platform where the update is applied by
  /// something other than the app itself.
  static Future<bool> _scheduleWindowsSwap({
    required Directory staged,
    required String installDirectory,
    required String executableName,
    required File marker,
  }) async {
    final script = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}'
      'miru-update-${_stamp()}.cmd',
    );

    try {
      script.writeAsStringSync(
        windowsSwapScript(
          installDirectory: installDirectory,
          stagedDirectory: staged.path,
          backupDirectory: _backupPath(installDirectory),
          executableName: executableName,
          markerPath: marker.path,
          pid: pid,
        ),
      );
      await Process.start('cmd', [
        '/c',
        script.path,
      ], mode: ProcessStartMode.detached);
      _log.info('Queued the update swap for pid $pid');
      return true;
    } catch (error, stackTrace) {
      _log.severe('Could not queue the update swap', error, stackTrace);
      return false;
    }
  }

  /// The batch file the Windows helper runs once this process is gone.
  ///
  /// Every path is quoted and the swap is guarded: if the new build is not
  /// where it should be after the move, the old one is moved back, so a failed
  /// update leaves a working install rather than an empty folder.
  @visibleForTesting
  static String windowsSwapScript({
    required String installDirectory,
    required String stagedDirectory,
    required String backupDirectory,
    required String executableName,
    required String markerPath,
    required int pid,
  }) =>
      '''
@echo off
setlocal
set "INSTALL=$installDirectory"
set "STAGED=$stagedDirectory"
set "BACKUP=$backupDirectory"
set "EXE=$executableName"
set "MARKER=$markerPath"

:wait
tasklist /FI "PID eq $pid" 2>nul | findstr /R /C:"$pid" >nul
if not errorlevel 1 (
  ping -n 2 127.0.0.1 >nul
  goto wait
)

move /Y "%INSTALL%" "%BACKUP%" >nul 2>&1
if not exist "%BACKUP%" goto failed
move /Y "%STAGED%" "%INSTALL%" >nul 2>&1
if not exist "%INSTALL%\\%EXE%" (
  rmdir /S /Q "%INSTALL%" >nul 2>&1
  move /Y "%BACKUP%" "%INSTALL%" >nul 2>&1
  goto failed
)
del "%MARKER%" >nul 2>&1
start "" "%INSTALL%\\%EXE%"
rmdir /S /Q "%BACKUP%" >nul 2>&1
goto done

:failed
:done
endlocal
''';

  /// Deletes what previous updates left behind: the backups and any staged
  /// download that was never committed.
  ///
  /// Best-effort: a read-only install simply keeps them.
  ///
  /// A staged build a live marker still points at is kept: a swap that failed
  /// for a transient reason must be retryable on the next launch, and the
  /// collector runs right after it.
  static Future<void> pruneBackups({
    String? parent,
    String? installDirectory,
  }) async {
    final install = installDirectory ?? DesktopUpdater.installDirectory;
    final scan = parent ?? parentOf(install);
    if (scan == null) return;

    final pending = await readPendingUpdate(installDirectory: installDirectory);
    final keep = pending?.stagedDirectory;

    try {
      await for (final entity in Directory(scan).list(followLinks: false)) {
        if (entity is! Directory) continue;
        final name = _baseName(entity.path);
        if (!_backupPattern.hasMatch(name) && !_stagingPattern.hasMatch(name)) {
          continue;
        }
        if (keep != null && entity.path == keep) continue;
        try {
          await entity.delete(recursive: true);
          _log.fine('Removed an old update backup: ${entity.path}');
        } catch (error, stackTrace) {
          _log.warning('Could not remove ${entity.path}', error, stackTrace);
        }
      }
    } catch (error, stackTrace) {
      _log.warning('Could not list $scan', error, stackTrace);
    }
  }

  static String _backupPath(String installDirectory) =>
      '$installDirectory.bak-${_stamp()}';

  static Future<void> _restore(Directory backup, Directory install) async {
    try {
      await _deleteIfPresent(install);
      await backup.rename(install.path);
    } catch (error, stackTrace) {
      _log.severe('Could not restore the previous build', error, stackTrace);
    }
  }

  static Future<void> _deleteIfPresent(FileSystemEntity entity) async {
    if (await entity.exists()) await entity.delete(recursive: true);
  }

  static Future<void> _deleteQuietly(FileSystemEntity entity) async {
    try {
      await _deleteIfPresent(entity);
    } catch (error, stackTrace) {
      _log.warning('Could not remove ${entity.path}', error, stackTrace);
    }
  }

  /// The directory inside [staging] that holds the build.
  ///
  /// Miru's archives contain exactly one top-level folder (`Miru-alpha/`). Any
  /// other shape — files at the root, or two folders — is used as the staging
  /// directory itself rather than guessed at.
  static Directory? _payloadIn(Directory staging) {
    Directory? single;
    var count = 0;
    var hasFiles = false;

    for (final entity in staging.listSync(followLinks: false)) {
      if (entity is Directory) {
        single = entity;
        count++;
      } else {
        hasFiles = true;
      }
    }

    if (count == 1 && !hasFiles) return single;
    return staging;
  }

  /// Extracts a `.tar.gz` or a `.zip` into [into].
  ///
  /// `tar` is used for both: Windows 10 ships bsdtar, which reads zip as well
  /// as tar.gz, so the common path is one process on every desktop. PowerShell
  /// is the fallback for an older Windows without it.
  static Future<bool> _extract(File archive, Directory into) async {
    try {
      final result = await Process.run('tar', [
        '-xf',
        archive.path,
        '-C',
        into.path,
      ]);
      if (result.exitCode == 0) return true;
      _log.warning('tar refused the update archive', result.stderr);
    } catch (error, stackTrace) {
      _log.warning('tar is unavailable', error, stackTrace);
    }

    if (Platform.isWindows) {
      try {
        final result = await Process.run('powershell', [
          '-NoProfile',
          '-ExecutionPolicy',
          'Bypass',
          '-Command',
          "Expand-Archive -LiteralPath '${archive.path}' "
              "-DestinationPath '${into.path}' -Force",
        ]);
        if (result.exitCode == 0) return true;
        _log.warning(
          'Expand-Archive refused the update archive',
          result.stderr,
        );
      } catch (error, stackTrace) {
        _log.warning('Could not run Expand-Archive', error, stackTrace);
      }
    }

    return false;
  }

  /// The parent of [path], or null when it has no separator at all.
  ///
  /// A path that sits at a filesystem root (`/Miru-alpha`) has the root as its
  /// parent, not null — null is reserved for "no separator", which only a
  /// relative path is.
  static String? parentOf(String path) {
    final trimmed = path.endsWith(Platform.pathSeparator)
        ? path.substring(0, path.length - 1)
        : path;
    final cut = trimmed.lastIndexOf(Platform.pathSeparator);
    if (cut < 0) return null;
    return cut == 0 ? trimmed.substring(0, 1) : trimmed.substring(0, cut);
  }

  static String _baseName(String path) {
    final trimmed = path.endsWith(Platform.pathSeparator)
        ? path.substring(0, path.length - 1)
        : path;
    return trimmed.split(Platform.pathSeparator).last;
  }

  static String _stamp() =>
      DateTime.now().toUtc().millisecondsSinceEpoch.toString();
}

/// Why a swap stopped where it did. Only the first rename can be `refused`,
/// and only Windows needs to tell that apart from a failure that already
/// rolled back.
enum _SwapOutcome {
  /// The new build is in place and running.
  applied,

  /// Moving the current build aside was refused; nothing was changed.
  refused,

  /// Something broke after the first rename; the old build is back.
  failed,
}
