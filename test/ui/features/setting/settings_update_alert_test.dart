import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/app_update_provider.dart';
import 'package:miru_alpha/ui/features/setting/widget/settings_update_alert.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:miru_alpha/utils/update/miru_release.dart';
import 'package:miru_alpha/utils/update/update_apply.dart';
import 'package:miru_alpha/utils/update/update_service.dart';

/// A release shaped like the ones CI publishes: a per-ABI APK plus the
/// desktop archives.
MiruRelease _release({String version = '2.1.0'}) => MiruRelease(
  tagName: 'v$version',
  name: 'Miru Alpha $version',
  htmlUrl: 'https://example.test/releases/v$version',
  body: '',
  publishedAt: DateTime.utc(2026, 11, 19),
  assets: [
    MiruReleaseAsset(
      name: 'app-arm64-v8a-release.apk',
      size: 1024,
      downloadUrl: 'https://example.test/arm64.apk',
    ),
    MiruReleaseAsset(
      name: 'Miru-Alpha-linux.tar.gz',
      size: 1024,
      downloadUrl: 'https://example.test/linux.tar.gz',
    ),
    MiruReleaseAsset(
      name: 'Miru-Alpha-windows.zip',
      size: 1024,
      downloadUrl: 'https://example.test/windows.zip',
    ),
  ],
);

/// The action the alert shows on the platform the test runs on — a download
/// where the release carries an installable asset, the release page elsewhere
/// (flutter_test reports android unless the runner overrides it).
String get _primaryActionKey =>
    pickUpdateAsset(_release().assets, platform: currentUpdatePlatform) == null
    ? 'settings.update.release_page'
    : 'settings.update.download';

/// A service that answers from memory — no network, no dio.
class _FakeUpdateService extends UpdateService {
  _FakeUpdateService({this.releases = const [], this.error});

  final List<MiruRelease> releases;
  final Object? error;

  @override
  Future<List<MiruRelease>> fetchReleases({CancelToken? cancelToken}) async {
    if (error != null) throw error!;
    return releases;
  }

  @override
  Future<File> downloadAsset(
    MiruReleaseAsset asset, {
    required String directory,
    CancelToken? cancelToken,
    void Function(double progress)? onProgress,
  }) async {
    final dir = await Directory.systemTemp.createTemp('miru-update-test');
    final file = File('${dir.path}${Platform.pathSeparator}${asset.name}');
    if (asset.name.endsWith('.apk')) {
      await file.writeAsString('apk');
    } else {
      // A real archive: the desktop path unpacks what it downloads, so a
      // placeholder would only ever prove the failure branch.
      final payload = Directory('${dir.path}${Platform.pathSeparator}new')
        ..createSync(recursive: true);
      File('${payload.path}${Platform.pathSeparator}miru_alpha')
          .writeAsStringSync('#!/bin/sh\nexit 0\n');
      // Same shape the release workflow produces: the archive holds one
      // top-level folder.
      final result = await Process.run('tar', [
        '-czf',
        file.path,
        '-C',
        dir.path,
        'new',
      ]);
      expect(result.exitCode, 0, reason: '${result.stderr}');
    }
    onProgress?.call(1);
    return file;
  }
}

/// A notifier pinned to a state, so a single widget test can render any
/// banner state without walking the real check.
class _SeededAppUpdate extends AppUpdate {
  _SeededAppUpdate(this.seed);

  final AppUpdateState seed;

  @override
  AppUpdateState build() => seed;
}

Future<void> _pumpSeeded(WidgetTester tester, AppUpdateState seed) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appUpdateProvider.overrideWith(() => _SeededAppUpdate(seed))],
      child: FTheme(
        data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: SettingsUpdateAlert(),
        ),
      ),
    ),
  );
}

/// A throwaway install tree: the real one is where the test binary lives, and
/// nothing may be unpacked or swapped there.
Directory _fakeInstall() {
  final install = Directory.systemTemp.createTempSync('miru-install-');
  addTearDown(() {
    if (install.existsSync()) install.deleteSync(recursive: true);
  });
  File('${install.path}${Platform.pathSeparator}miru_alpha')
      .writeAsStringSync('#!/bin/sh\nexit 0\n');
  File(
      '${install.path}${Platform.pathSeparator}data'
      '${Platform.pathSeparator}flutter_assets'
      '${Platform.pathSeparator}kernel_blob.bin',
    )
    ..createSync(recursive: true)
    ..writeAsStringSync('old build');
  return install;
}

/// The marker file a fake build carries.
String _kernelBlob(Directory dir) => File(
  '${dir.path}${Platform.pathSeparator}data'
  '${Platform.pathSeparator}flutter_assets'
  '${Platform.pathSeparator}kernel_blob.bin',
).readAsStringSync();

ProviderContainer _container({
  required UpdateService service,
  AppUpdateState seed = const AppUpdateState(),
  String? installDirectory,
}) {
  final container = ProviderContainer(
    overrides: [
      updateServiceProvider.overrideWithValue(service),
      updateInstallDirectoryProvider.overrideWithValue(installDirectory),
      appUpdateProvider.overrideWith(() => _SeededAppUpdate(seed)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  setUp(MiruSettings.seedDefaultsForTest);
  tearDown(() {
    UpdateService.debugSetCurrentVersion(null);
    debugUpdatePlatform = null;
  });

  group('SettingsUpdateAlert rendering', () {
    testWidgets('shows download actions when a newer build exists', (
      tester,
    ) async {
      await _pumpSeeded(
        tester,
        AppUpdateState(
          status: UpdateStatus.available,
          currentVersion: '2.0.3-alpha',
          release: _release(),
        ),
      );

      // i18n has no delegate in the bare harness, so the keys are the titles.
      expect(find.text('settings.update.available'), findsOneWidget);
      expect(find.text(_primaryActionKey), findsOneWidget);
      expect(find.text('settings.update.release_notes'), findsOneWidget);
      expect(find.text('settings.update.later'), findsOneWidget);
    });

    testWidgets('offers install once the download finished', (tester) async {
      await _pumpSeeded(
        tester,
        AppUpdateState(
          status: UpdateStatus.downloaded,
          currentVersion: '2.0.3-alpha',
          release: _release(),
          progress: 1,
          localPath: '/tmp/miru.apk',
        ),
      );

      expect(find.text('settings.update.downloaded'), findsOneWidget);
      expect(find.text('settings.update.install'), findsOneWidget);
      expect(find.text(_primaryActionKey), findsNothing);
    });

    testWidgets('renders the retry action for a failed check', (tester) async {
      await _pumpSeeded(
        tester,
        const AppUpdateState(
          status: UpdateStatus.failed,
          currentVersion: '2.0.3-alpha',
          error: 'settings.update.failed',
          manual: true,
        ),
      );

      expect(find.text('settings.update.failed'), findsOneWidget);
      expect(find.text('settings.update.retry'), findsOneWidget);
      expect(find.text('settings.update.later'), findsOneWidget);
    });

    testWidgets('renders the progress track while downloading', (tester) async {
      await _pumpSeeded(
        tester,
        AppUpdateState(
          status: UpdateStatus.downloading,
          currentVersion: '2.0.3-alpha',
          release: _release(),
          progress: 0.5,
        ),
      );

      expect(find.text('settings.update.downloading'), findsOneWidget);
      // The fill is the download, not a decoration: half a download must be a
      // half-full track, and the track's semantics has to agree with the
      // "50%" the alert already announces.
      final bar = tester.widget<FDeterminateProgress>(
        find.byType(FDeterminateProgress),
      );
      expect(bar.value, 0.5);
      expect(bar.semanticsLabel, 'settings.update.downloading');
      final handle = tester.ensureSemantics();
      final semantics = tester.getSemantics(find.byType(FDeterminateProgress));
      // FAlert merges its descendants into one node, so the label is the
      // alert's whole text rather than this bar's alone.
      expect(semantics.label, contains('settings.update.downloading'));
      handle.dispose();
      // No action row mid-download: the only honest control is to wait.
      expect(find.text('settings.update.later'), findsNothing);
    });

    testWidgets('stays invisible for an automatic check that found nothing', (
      tester,
    ) async {
      await _pumpSeeded(
        tester,
        AppUpdateState(
          status: UpdateStatus.upToDate,
          currentVersion: '2.1.0',
          release: _release(),
        ),
      );

      expect(find.byType(SettingsUpdateAlert), findsOneWidget);
      expect(find.byType(FAlert), findsNothing);
    });

    testWidgets('shows up-to-date after an explicit check', (tester) async {
      await _pumpSeeded(
        tester,
        AppUpdateState(
          status: UpdateStatus.upToDate,
          currentVersion: '2.1.0',
          release: _release(),
          manual: true,
        ),
      );

      expect(find.text('settings.update.up_to_date'), findsOneWidget);
      expect(find.text(_primaryActionKey), findsNothing);
    });

    testWidgets('hides the whole banner once dismissed', (tester) async {
      await _pumpSeeded(
        tester,
        AppUpdateState(
          status: UpdateStatus.available,
          currentVersion: '2.0.3-alpha',
          release: _release(),
          dismissed: true,
        ),
      );

      expect(find.byType(FAlert), findsNothing);
    });

    testWidgets('later on the banner quiets the launch prompt too', (
      tester,
    ) async {
      final container = _container(
        service: _FakeUpdateService(releases: [_release()]),
        seed: AppUpdateState(
          status: UpdateStatus.available,
          currentVersion: '2.0.3-alpha',
          release: _release(),
        ),
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: FTheme(
            data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: SettingsUpdateAlert(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('settings.update.later'));
      await tester.pumpAndSettle();

      // One meaning for "later", wherever it is pressed: this version is
      // remembered, so the next launch does not raise the dialog either.
      expect(container.read(appUpdateProvider).latered, isTrue);
      expect(
        MiruSettings.getSettingSync<String>(SettingKey.laterUpdateVersion),
        '2.1.0',
      );
      expect(find.byType(FAlert), findsNothing);
    });
  });

  group('AppUpdate notifier', () {
    test('check() flips to available when the release is newer', () async {
      UpdateService.debugSetCurrentVersion('2.0.3-alpha');
      final container = _container(
        service: _FakeUpdateService(releases: [_release(version: '2.1.0')]),
      );

      await container.read(appUpdateProvider.notifier).check(manual: true);

      final state = container.read(appUpdateProvider);
      expect(state.status, UpdateStatus.available);
      expect(state.release?.version, '2.1.0');
      expect(state.currentVersion, '2.0.3-alpha');
      expect(
        state.needsBrowserFallback,
        _primaryActionKey == 'settings.update.release_page',
      );
    });

    test('check() reports up to date for the installed version', () async {
      UpdateService.debugSetCurrentVersion('2.1.0');
      final container = _container(
        service: _FakeUpdateService(releases: [_release(version: '2.1.0')]),
      );

      await container.read(appUpdateProvider.notifier).check(manual: true);

      expect(container.read(appUpdateProvider).status, UpdateStatus.upToDate);
    });

    test('check() reports failed when the feed throws', () async {
      UpdateService.debugSetCurrentVersion('2.0.3-alpha');
      final container = _container(
        service: _FakeUpdateService(
          error: DioException.connectionError(
            requestOptions: RequestOptions(path: 'x'),
            reason: 'offline',
          ),
        ),
      );

      await container.read(appUpdateProvider.notifier).check(manual: true);

      final state = container.read(appUpdateProvider);
      expect(state.status, UpdateStatus.failed);
      expect(state.error, 'settings.update.failed');
    });

    test('download() stores the installer and reports progress', () async {
      final service = _FakeUpdateService(
        releases: [_release(version: '2.1.0')],
      );
      UpdateService.debugSetCurrentVersion('2.0.3-alpha');
      debugUpdatePlatform = UpdatePlatform.linux;
      final install = _fakeInstall();
      final container = _container(
        service: service,
        installDirectory: install.path,
      );

      await container.read(appUpdateProvider.notifier).check(manual: true);
      await container.read(appUpdateProvider.notifier).download();

      final state = container.read(appUpdateProvider);
      expect(state.status, UpdateStatus.downloaded);
      expect(state.progress, 1);
      expect(state.localPath, isNotNull);
      expect(File(state.localPath!).existsSync(), isTrue);
    });

    test(
      'download() unpacks a desktop build and records it as pending',
      () async {
        final service = _FakeUpdateService(
          releases: [_release(version: '2.1.0')],
        );
        UpdateService.debugSetCurrentVersion('2.0.3-alpha');
        debugUpdatePlatform = UpdatePlatform.linux;
        final install = _fakeInstall();
        final container = _container(
          service: service,
          installDirectory: install.path,
        );

        await container.read(appUpdateProvider.notifier).check(manual: true);
        await container.read(appUpdateProvider.notifier).download();

        // The build is unpacked and waiting for the next launch — and nothing
        // has been swapped yet, so the running build is untouched.
        final pending = await DesktopUpdater.readPendingUpdate(
          installDirectory: install.path,
        );
        expect(pending, isNotNull);
        expect(pending!.version, '2.1.0');
        expect(_kernelBlob(install), 'old build');
        // A second download replaces the pending build rather than stacking.
        expect(
          install.parent.listSync().whereType<Directory>().where(
            (d) => d.path.startsWith('${install.path}.update-'),
          ),
          hasLength(1),
        );
      },
    );

    test('dismiss() hides the banner without losing the release', () async {
      UpdateService.debugSetCurrentVersion('2.0.3-alpha');
      final container = _container(
        service: _FakeUpdateService(releases: [_release(version: '2.1.0')]),
      );

      await container.read(appUpdateProvider.notifier).check(manual: true);
      container.read(appUpdateProvider.notifier).dismiss();

      final state = container.read(appUpdateProvider);
      expect(state.dismissed, isTrue);
      expect(state.visible, isFalse);
      expect(state.release?.version, '2.1.0');
    });

    test(
      'check() stays promptable for a build the user never skipped',
      () async {
        UpdateService.debugSetCurrentVersion('2.0.3-alpha');
        final container = _container(
          service: _FakeUpdateService(releases: [_release(version: '2.1.0')]),
        );

        await container.read(appUpdateProvider.notifier).check();

        final state = container.read(appUpdateProvider);
        expect(state.status, UpdateStatus.available);
        expect(state.ignored, isFalse);
        expect(state.promptable, isTrue);
      },
    );

    test('check() quiets the launch prompt for an ignored version', () async {
      MiruSettings.setSettingSync(SettingKey.ignoredUpdateVersion, '2.1.0');
      UpdateService.debugSetCurrentVersion('2.0.3-alpha');
      final container = _container(
        service: _FakeUpdateService(releases: [_release(version: '2.1.0')]),
      );

      await container.read(appUpdateProvider.notifier).check();

      final state = container.read(appUpdateProvider);
      expect(state.status, UpdateStatus.available);
      expect(state.ignored, isTrue);
      // Ignored means "do not interrupt me": the banner hides too, and the
      // dialog's own note points at Settings for the manual path.
      expect(state.dismissed, isTrue);
      expect(state.visible, isFalse);
      expect(state.promptable, isFalse);
    });

    test('a newer release than the skipped one prompts again', () async {
      MiruSettings.setSettingSync(SettingKey.ignoredUpdateVersion, '2.1.0');
      UpdateService.debugSetCurrentVersion('2.0.3-alpha');
      final container = _container(
        service: _FakeUpdateService(releases: [_release(version: '2.2.0')]),
      );

      await container.read(appUpdateProvider.notifier).check();

      final state = container.read(appUpdateProvider);
      expect(state.ignored, isFalse);
      expect(state.promptable, isTrue);
    });

    test(
      'a manual check re-surfaces an ignored version on the banner',
      () async {
        MiruSettings.setSettingSync(SettingKey.ignoredUpdateVersion, '2.1.0');
        UpdateService.debugSetCurrentVersion('2.0.3-alpha');
        final container = _container(
          service: _FakeUpdateService(releases: [_release(version: '2.1.0')]),
        );

        await container.read(appUpdateProvider.notifier).check(manual: true);

        final state = container.read(appUpdateProvider);
        // Asking explicitly is not nagging: the banner comes back. The prompt
        // still stays suppressed, which is what `ignored` records.
        expect(state.dismissed, isFalse);
        expect(state.visible, isTrue);
        expect(state.ignored, isTrue);
        expect(state.promptable, isFalse);
      },
    );

    test('ignore() persists the version and quiets the prompt', () async {
      UpdateService.debugSetCurrentVersion('2.0.3-alpha');
      final container = _container(
        service: _FakeUpdateService(releases: [_release(version: '2.1.0')]),
      );

      await container.read(appUpdateProvider.notifier).check();
      await container.read(appUpdateProvider.notifier).ignore();

      final state = container.read(appUpdateProvider);
      expect(state.ignored, isTrue);
      expect(state.dismissed, isTrue);
      expect(state.promptable, isFalse);
      expect(
        MiruSettings.getSettingSync<String>(SettingKey.ignoredUpdateVersion),
        '2.1.0',
      );
    });

    test('later() persists the version but leaves the banner alone', () async {
      UpdateService.debugSetCurrentVersion('2.0.3-alpha');
      final container = _container(
        service: _FakeUpdateService(releases: [_release(version: '2.1.0')]),
      );
      final notifier = container.read(appUpdateProvider.notifier);
      await notifier.check();

      await notifier.later();

      final state = container.read(appUpdateProvider);
      // "Not now", not "never": the dialog stays quiet, the settings banner
      // does not — it is the only remaining way to get the build.
      expect(state.latered, isTrue);
      expect(state.ignored, isFalse);
      expect(state.dismissed, isFalse);
      expect(state.visible, isTrue);
      expect(state.promptable, isFalse);
      expect(
        MiruSettings.getSettingSync<String>(SettingKey.laterUpdateVersion),
        '2.1.0',
      );
      expect(
        MiruSettings.getSettingSync<String>(SettingKey.ignoredUpdateVersion),
        isEmpty,
      );
    });

    test('a launch after Later still does not raise the prompt', () async {
      // The point of the button: the dismissal has to survive a restart.
      MiruSettings.setSettingSync(SettingKey.laterUpdateVersion, '2.1.0');
      UpdateService.debugSetCurrentVersion('2.0.3-alpha');
      final container = _container(
        service: _FakeUpdateService(releases: [_release(version: '2.1.0')]),
      );

      await container.read(appUpdateProvider.notifier).check();

      final state = container.read(appUpdateProvider);
      expect(state.latered, isTrue);
      expect(state.promptable, isFalse);
      // …and the banner is still there, offering the update.
      expect(state.visible, isTrue);
      expect(state.status, UpdateStatus.available);
    });

    test('a newer release than the postponed one prompts again', () async {
      MiruSettings.setSettingSync(SettingKey.laterUpdateVersion, '2.1.0');
      UpdateService.debugSetCurrentVersion('2.0.3-alpha');
      final container = _container(
        service: _FakeUpdateService(releases: [_release(version: '2.2.0')]),
      );

      await container.read(appUpdateProvider.notifier).check();

      final state = container.read(appUpdateProvider);
      expect(state.latered, isFalse);
      expect(state.promptable, isTrue);
    });
  });
}
