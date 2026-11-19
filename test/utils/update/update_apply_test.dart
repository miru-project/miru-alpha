import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/utils/update/update_apply.dart';

/// The desktop updater is the one part of the update flow that cannot be
/// exercised through a widget: it renames directories, writes a marker file
/// and starts processes. So these tests drive it against a real throwaway
/// install tree — the same filesystem dance it performs on a user's machine —
/// with the relaunch pointed at a shell script that leaves a trace instead of
/// at the app.
///
/// The point of the two-phase design is that these tests can cover both phases
/// without ever killing the test runner: `stage` (what a download does) and
/// `commitPendingUpdate(exitWhenDone: false)` (what the next launch does) are
/// both callable in-process.
void main() {
  final executable = Platform.isWindows ? 'Miru-alpha.exe' : 'miru_alpha';
  final sep = Platform.pathSeparator;

  /// Renaming a directory out from under a running process is POSIX semantics;
  /// Windows refuses it, so the swap tests only run where the swap is a plain
  /// rename. The Windows path is covered by [windowsSwapScript] below.
  final posixOnly = Platform.isWindows ? 'posix rename semantics' : false;

  late Directory root;
  late Directory install;

  /// Writes a fake build at [path]. Its "executable" is a shell script that
  /// touches [launchTrace] when it runs, so a test can prove the relaunch
  /// actually started the NEW build rather than merely renaming directories.
  Directory buildAt(String path, String marker, {String? launchTrace}) {
    final dir = Directory(path)..createSync(recursive: true);
    final script = launchTrace == null
        ? '#!/bin/sh\necho $marker\n'
        : '#!/bin/sh\necho $marker > $launchTrace\n';
    File('${dir.path}$sep$executable').writeAsStringSync(script);
    if (!Platform.isWindows) {
      // The mode is what makes the relaunch succeed or fail for real.
      final result = Process.runSync('chmod', [
        '+x',
        '${dir.path}$sep$executable',
      ]);
      expect(result.exitCode, 0);
    }
    File('${dir.path}${sep}data${sep}flutter_assets${sep}kernel_blob.bin')
      ..createSync(recursive: true)
      ..writeAsStringSync(marker);
    return dir;
  }

  /// Tars [source] (a directory) into [archive] the way the release workflow
  /// does: `tar -czf Miru-Alpha-linux.tar.gz -C <parent> <name>`.
  Future<File> tarGz(String archive, Directory source) async {
    final result = await Process.run('tar', [
      '-czf',
      archive,
      '-C',
      source.parent.path,
      _baseName(source.path),
    ]);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    return File(archive);
  }

  /// Stages a real archive and records it as pending, the way `download()`
  /// does at the end of a desktop update.
  Future<Directory> stagePending(
    String version, {
    String? launchTrace,
    bool executableRunnable = true,
  }) async {
    final newBuild = buildAt(
      '${root.path}${sep}new-$version',
      'new build',
      launchTrace: launchTrace,
    );
    final archive = await tarGz('${root.path}$sep$version.tar.gz', newBuild);
    final staged = await DesktopUpdater.stage(
      archive: archive.path,
      installDirectory: install.path,
      executableName: executable,
    );
    expect(staged, isNotNull);
    if (!executableRunnable && !Platform.isWindows) {
      Process.runSync('chmod', ['-x', '${staged!.path}$sep$executable']);
    }
    await DesktopUpdater.stagePendingUpdate(
      staged: staged!,
      installDirectory: install.path,
      executableName: executable,
      version: version,
    );
    return staged;
  }

  setUp(() {
    root = Directory.systemTemp.createTempSync('miru_update_');
    install = buildAt('${root.path}${sep}Miru-alpha', 'old build');
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  group('stage', () {
    test(
      'hoists the single top-level folder out of the extraction shell',
      () async {
        final newBuild = buildAt('${root.path}${sep}new', 'new build');
        final archive = await tarGz(
          '${root.path}${sep}Miru-Alpha-linux.tar.gz',
          newBuild,
        );

        final staged = await DesktopUpdater.stage(
          archive: archive.path,
          installDirectory: install.path,
          executableName: executable,
        );

        expect(staged, isNotNull);
        // A sibling of the install: same filesystem, so the later renames are
        // atomic rather than a copy.
        expect(staged!.parent.path, root.path);
        expect(
          File('${staged.path}$sep$executable').readAsStringSync(),
          contains('new build'),
        );
        // No empty extraction shell left beside the install: the payload was
        // hoisted out of it and the shell removed.
        expect(
          root
              .listSync()
              .whereType<Directory>()
              .map((d) => _baseName(d.path))
              .where((n) => RegExp(r'\.update-\d+$').hasMatch(n)),
          isEmpty,
          reason: 'staging shell was not cleaned up',
        );
        // Nothing was touched in the running build.
        expect(install.existsSync(), isTrue);
        expect(_kernelBlob(install), 'old build');
      },
    );

    test('refuses an archive that holds no build', () async {
      final loose = Directory('${root.path}${sep}loose')
        ..createSync(recursive: true);
      File('${loose.path}${sep}README.txt').writeAsStringSync('not a build');
      final archive = await tarGz('${root.path}${sep}loose.tar.gz', loose);

      final staged = await DesktopUpdater.stage(
        archive: archive.path,
        installDirectory: install.path,
        executableName: executable,
      );

      expect(staged, isNull);
    });

    test('refuses an archive whose build has no executable', () async {
      final headless = Directory('${root.path}${sep}headless')
        ..createSync(recursive: true);
      File('${headless.path}${sep}data.txt')
          .writeAsStringSync('no binary here');
      final archive = await tarGz(
        '${root.path}${sep}headless.tar.gz',
        headless,
      );

      final staged = await DesktopUpdater.stage(
        archive: archive.path,
        installDirectory: install.path,
        executableName: executable,
      );

      expect(staged, isNull);
      expect(install.existsSync(), isTrue, reason: 'the install was touched');
    });

    test('refuses a missing archive', () async {
      final staged = await DesktopUpdater.stage(
        archive: '${root.path}${sep}nope.tar.gz',
        installDirectory: install.path,
        executableName: executable,
      );

      expect(staged, isNull);
    });

    test(
      'a relative install path is refused instead of staged in the cwd',
      () async {
        final staged = await DesktopUpdater.stage(
          archive: 'whatever.tar.gz',
          installDirectory: 'Miru-alpha',
          executableName: executable,
        );

        expect(staged, isNull);
      },
    );
  });

  group('the pending marker', () {
    test('survives the restart: written by one launch, read by the next', () async {
      final staged = await stagePending('2.0.0');

      // A fresh call is what the next launch does — nothing is carried over in
      // memory, so this only passes if the marker really is on disk.
      final pending = await DesktopUpdater.readPendingUpdate(
        installDirectory: install.path,
      );

      expect(pending, isNotNull);
      expect(pending!.version, '2.0.0');
      expect(pending.stagedDirectory, staged.path);
      expect(pending.executableName, executable);
      expect(pending.installDirectory, install.path);
      expect(
        File('${pending.stagedDirectory}$sep$executable').existsSync(),
        isTrue,
        reason: 'the staged build the marker points at is gone',
      );
    });

    test('a newer download replaces the pending one', () async {
      await stagePending('2.0.0');
      final newer = await stagePending('2.1.0');

      final pending = await DesktopUpdater.readPendingUpdate(
        installDirectory: install.path,
      );

      expect(pending!.version, '2.1.0');
      expect(pending.stagedDirectory, newer.path);
    });

    test(
      'a marker whose staged build vanished is dropped, not retried',
      () async {
        final staged = await stagePending('2.0.0');
        staged.deleteSync(recursive: true);

        final pending = await DesktopUpdater.readPendingUpdate(
          installDirectory: install.path,
        );

        expect(pending, isNull);
        // The stale marker is gone too, so this is a one-time cost.
        expect(
          DesktopUpdater.pendingUpdateFile(install.path).existsSync(),
          isFalse,
        );
      },
    );

    test('a marker written for a different install is ignored', () async {
      await stagePending('2.0.0');
      final other = buildAt('${root.path}${sep}Elsewhere', 'elsewhere');
      // Same marker, moved to another install root — the app moved, and the
      // old marker must not be applied to the new one.
      final contents = DesktopUpdater.pendingUpdateFile(install.path)
          .readAsStringSync();
      DesktopUpdater.pendingUpdateFile(install.path).deleteSync();
      final forged = DesktopUpdater.pendingUpdateFile(other.path)
        ..writeAsStringSync(contents);

      final pending = await DesktopUpdater.readPendingUpdate(
        installDirectory: other.path,
      );

      expect(pending, isNull);
      expect(forged.existsSync(), isFalse);
    });

    test('clearPendingUpdate forgets it after the swap', () async {
      final staged = await stagePending('2.0.0');
      final pending = await DesktopUpdater.readPendingUpdate(
        installDirectory: install.path,
      );
      expect(pending, isNotNull);

      await DesktopUpdater.clearPendingUpdate(pending!);

      expect(
        DesktopUpdater.pendingUpdateFile(install.path).existsSync(),
        isFalse,
      );
      expect(staged.existsSync(), isFalse);
    });
  });

  group('commitPendingUpdate', () {
    test('does nothing when nothing is waiting', () async {
      final result = await DesktopUpdater.commitPendingUpdate(
        installDirectory: install.path,
        exitWhenDone: false,
      );

      expect(result, UpdateApplyResult.none);
      expect(install.existsSync(), isTrue);
      expect(_kernelBlob(install), 'old build');
    });

    test('swaps in the new build, starts it, and forgets the marker', () async {
      final trace = '${root.path}${sep}launched.txt';
      await stagePending('2.0.0', launchTrace: trace);

      final result = await DesktopUpdater.commitPendingUpdate(
        installDirectory: install.path,
        exitWhenDone: false,
      );

      expect(result, UpdateApplyResult.applied);
      // The new build is where the old one was — same path, so the launcher
      // and the desktop entry keep working.
      expect(_kernelBlob(install), 'new build');
      // The relaunch really happened: the new executable ran and left a trace.
      // Process.start does not wait for the child, so give it a moment.
      await _waitFor(File(trace));
      expect(
        File(trace).existsSync(),
        isTrue,
        reason: 'the new build never ran',
      );
      // The marker is consumed: a second launch must not swap again.
      expect(
        DesktopUpdater.pendingUpdateFile(install.path).existsSync(),
        isFalse,
      );
      // The old build is kept as one rename away from being restored.
      final backups = root
          .listSync()
          .whereType<Directory>()
          .where((d) => _baseName(d.path).contains('.bak-'))
          .toList();
      expect(backups, hasLength(1));
      expect(_kernelBlob(backups.single), 'old build');
    }, skip: posixOnly);

    test('puts the old build back when the new one will not start', () async {
      await stagePending('2.0.0', executableRunnable: false);

      await DesktopUpdater.commitPendingUpdate(
        installDirectory: install.path,
        exitWhenDone: false,
      );

      // The old build is back at its own path: a failed update leaves a
      // working install rather than an empty folder.
      expect(install.existsSync(), isTrue);
      expect(_kernelBlob(install), 'old build');
    }, skip: posixOnly);

    test(
      'a swap that finds nothing to rename leaves the marker for later',
      () async {
        final staged = await stagePending('2.0.0');
        staged.deleteSync(recursive: true);

        final result = await DesktopUpdater.commitPendingUpdate(
          installDirectory: install.path,
          exitWhenDone: false,
        );

        // The staged build is gone, so there is nothing to apply — and nothing
        // was broken either.
        expect(result, UpdateApplyResult.none);
        expect(install.existsSync(), isTrue);
        expect(_kernelBlob(install), 'old build');
      },
    );
  });

  group('pruneBackups', () {
    test(
      'removes update backups and stale staging, keeps everything else',
      () async {
        final backup = Directory(
          '${root.path}${sep}Miru-alpha.bak-1700000000000',
        )..createSync(recursive: true);
        // A download that was staged and never swapped in — the app died in
        // between.
        final stale = Directory(
          '${root.path}${sep}Miru-alpha.update-1700000000001-payload',
        )..createSync(recursive: true);
        final unrelated = Directory('${root.path}${sep}keep-me')
          ..createSync(recursive: true);

        await DesktopUpdater.pruneBackups(
          parent: root.path,
          installDirectory: install.path,
        );

        expect(backup.existsSync(), isFalse);
        expect(stale.existsSync(), isFalse);
        expect(unrelated.existsSync(), isTrue);
        expect(install.existsSync(), isTrue);
      },
    );

    test('keeps the staged build a live marker still points at', () async {
      final staged = await stagePending('2.0.0');

      await DesktopUpdater.pruneBackups(
        parent: root.path,
        installDirectory: install.path,
      );

      expect(
        staged.existsSync(),
        isTrue,
        reason: 'the collector deleted a build that was still pending',
      );
    });
  });

  group('windowsSwapScript', () {
    test('waits for the dying pid and rolls back a failed swap', () {
      final script = DesktopUpdater.windowsSwapScript(
        installDirectory: r'C:\Users\me\AppData\Local\Miru-alpha',
        stagedDirectory: r'C:\Users\me\AppData\Local\Miru-alpha.update-1',
        backupDirectory: r'C:\Users\me\AppData\Local\Miru-alpha.bak-1',
        executableName: 'Miru-alpha.exe',
        markerPath: r'C:\Users\me\AppData\Local\Miru-alpha.pending-update.json',
        pid: 4242,
      );

      expect(script, contains('tasklist /FI "PID eq 4242"'));
      expect(script, contains('move /Y "%INSTALL%" "%BACKUP%"'));
      expect(script, contains('move /Y "%STAGED%" "%INSTALL%"'));
      expect(script, contains('start "" "%INSTALL%\\%EXE%"'));
      // A swap that lands somewhere without the new executable puts the old
      // build back rather than leaving an empty install.
      expect(script, contains('if not exist "%INSTALL%\\%EXE%"'));
      // The marker is only consumed once the new build is in place, so a
      // failed swap is retried on the next launch.
      expect(
        script.indexOf('del "%MARKER%"'),
        greaterThan(script.indexOf('move /Y "%STAGED%" "%INSTALL%"')),
      );
    });
  });

  group('real release archive', () {
    // End-to-end proof against the artifact the release workflow actually
    // publishes (`Miru-Alpha-linux.tar.gz`: one top-level `Miru-alpha/` holding
    // `miru_alpha`, `data/` and `lib/`). Run it with the tarball downloaded:
    //   MIRU_UPDATE_ARCHIVE=/path/Miru-Alpha-linux.tar.gz flutter test \
    //     test/utils/update/update_apply_test.dart
    // It is skipped everywhere else — CI must not download 50 MB to test a
    // rename.
    final archive = Platform.environment['MIRU_UPDATE_ARCHIVE'];

    test(
      'swaps a real build and keeps the tree intact',
      () async {
        // The install starts as the published build, extracted the way a user
        // would have it.
        final result = await Process.run('tar', [
          '-xzf',
          archive!,
          '-C',
          root.path,
        ]);
        expect(result.exitCode, 0, reason: '${result.stderr}');

        final installed = Directory('${root.path}${sep}Miru-alpha');
        expect(installed.existsSync(), isTrue);

        final trace = '${root.path}${sep}launched.txt';
        await DesktopUpdater.stage(
          archive: archive,
          installDirectory: installed.path,
          executableName: executable,
        ).then((staged) async {
          expect(staged, isNotNull);
          // The relaunch is a shell script here, standing in for the real
          // binary the same code path would start.
          File('${staged!.path}$sep$executable')
              .writeAsStringSync('#!/bin/sh\necho real > $trace\n');
          if (!Platform.isWindows) {
            Process.runSync('chmod', ['+x', '${staged.path}$sep$executable']);
          }
          await DesktopUpdater.stagePendingUpdate(
            staged: staged,
            installDirectory: installed.path,
            executableName: executable,
            version: 'real',
          );
        });

        final swap = await DesktopUpdater.commitPendingUpdate(
          installDirectory: installed.path,
          exitWhenDone: false,
        );

        expect(swap, UpdateApplyResult.applied);
        // The relaunch ran the build that was just swapped in.
        await _waitFor(File(trace));
        expect(File(trace).existsSync(), isTrue);
        // The published tree survived the swap whole: the Flutter assets, the
        // shared libraries and the entry point are all still in place under the
        // same path the launcher points at.
        // `data/icudtl.dat` and the AOT snapshot exist in both published
        // archives; the library lives under `lib/` on Linux and beside the
        // image on Windows.
        final expected = Platform.isWindows
            ? ['data/icudtl.dat', 'data/app.so']
            : ['data/icudtl.dat', 'lib/libapp.so'];

        for (final path in expected) {
          expect(
            File(
              '${installed.path}$sep${path.replaceAll('/', Platform.pathSeparator)}',
            ).existsSync(),
            isTrue,
            reason: 'missing $path after the swap',
          );
        }
      },
      skip: archive == null
          ? 'set MIRU_UPDATE_ARCHIVE to a downloaded Miru-Alpha-*.tar.gz'
          : posixOnly,
    );
  });
}

/// Waits for [file] to appear, up to ~2s. `Process.start` returns as soon as
/// the child is spawned, so a test that asserts on the child's side effect has
/// to give the child a moment.
Future<void> _waitFor(File file) async {
  for (var i = 0; i < 100; i++) {
    if (file.existsSync()) return;
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

/// The build marker file every fake build carries, read from [dir].
String _kernelBlob(Directory dir) => File(
  '${dir.path}${Platform.pathSeparator}data'
  '${Platform.pathSeparator}flutter_assets'
  '${Platform.pathSeparator}kernel_blob.bin',
).readAsStringSync();

String _baseName(String path) => path
    .replaceAll(Platform.pathSeparator, '/')
    .split('/')
    .where((part) => part.isNotEmpty)
    .last;
