/// Mirrors test/ui/features/setting/settings_update_alert_test.dart states for
/// the catalog: the settings banner in every state, plus the startup dialog.
///
/// skipped: the tap-through flows (download -> install -> OS hand-off) — they
/// drive a real GitHub release and a real installer, so they stay in the
/// widget/unit tests with a fake service. What the catalog validates is the
/// thing that is easy to get wrong without seeing it: the banner's shape in
/// each state and its spacing at the top of the settings page.
///
/// Copy renders in English: the catalog registers none of the app's delegates
/// (its MaterialApp lives inside the widgetbook package), so `.i18n` resolves
/// against `I18nStatic` — the same `assets/i18n/en.json` the app ships, loaded
/// once at startup. The keys themselves are asserted in the widget test; what
/// this folder adds is whether the English *reads* right.
library;

import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/app_update_provider.dart';
import 'package:miru_alpha/ui/features/setting/widget/settings_update_alert.dart';
import 'package:miru_alpha/ui/features/setting/widget/update_available_dialog.dart';
import 'package:miru_alpha/utils/update/miru_release.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// A release fixture shaped like the ones the CI publishes (per-ABI APKs plus
/// the desktop archives).
MiruRelease buildReleaseFixture({String version = '2.1.0'}) => MiruRelease(
  tagName: 'v$version',
  name: 'Miru Alpha $version',
  htmlUrl: 'https://github.com/miru-project/miru-alpha/releases/tag/v$version',
  // A GitHub-shaped body: headings, a task list, a table and a fenced block.
  // Empty would prove nothing — the point of the fixture is that the parser
  // gets the same markdown the release feed actually delivers.
  body: _releaseNotes,
  publishedAt: DateTime.utc(2026, 11, 19),
  assets: [
    MiruReleaseAsset(
      name: 'app-arm64-v8a-release.apk',
      size: 28 * 1024 * 1024,
      downloadUrl: 'https://example.test/app-arm64-v8a-release.apk',
    ),
    MiruReleaseAsset(
      name: 'Miru-Alpha-linux.tar.gz',
      size: 61 * 1024 * 1024,
      downloadUrl: 'https://example.test/Miru-Alpha-linux.tar.gz',
    ),
    MiruReleaseAsset(
      name: 'Miru-Alpha-windows.zip',
      size: 64 * 1024 * 1024,
      downloadUrl: 'https://example.test/Miru-Alpha-windows.zip',
    ),
  ],
);

/// A notifier pinned to one state — the catalog's stand-in for the real
/// GitHub-backed check.
class _SeededAppUpdate extends AppUpdate {
  _SeededAppUpdate(this.seed);

  final AppUpdateState seed;

  @override
  AppUpdateState build() => seed;
}

/// Hosts the alert with a seeded update state.
Widget buildUpdateAlertHost(AppUpdateState seed) {
  return ProviderScope(
    overrides: [appUpdateProvider.overrideWith(() => _SeededAppUpdate(seed))],
    child: const SizedBox(
      width: 460,
      child: SettingsUpdateAlert(),
    ),
  );
}

/// The alert's states, as the catalog can render them.
List<WidgetbookUseCase> settingsUpdateAlertUseCases() {
  return [
    WidgetbookUseCase(
      name: 'Available · download + release notes',
      builder: (context) => catalogFrame(
        buildUpdateAlertHost(
          AppUpdateState(
            status: UpdateStatus.available,
            currentVersion: '2.0.3-alpha',
            release: buildReleaseFixture(),
          ),
        ),
        center: false,
      ),
    ),
    WidgetbookUseCase(
      name: 'Downloading · 42% + progress track',
      builder: (context) => catalogFrame(
        buildUpdateAlertHost(
          AppUpdateState(
            status: UpdateStatus.downloading,
            currentVersion: '2.0.3-alpha',
            release: buildReleaseFixture(),
            progress: 0.42,
          ),
        ),
        center: false,
      ),
    ),
    WidgetbookUseCase(
      name: 'Downloaded · install ready',
      builder: (context) => catalogFrame(
        buildUpdateAlertHost(
          AppUpdateState(
            status: UpdateStatus.downloaded,
            currentVersion: '2.0.3-alpha',
            release: buildReleaseFixture(),
            progress: 1,
            localPath: '/data/user/0/miru.alpha/files/miru/updates/app.apk',
          ),
        ),
        center: false,
      ),
    ),
    WidgetbookUseCase(
      name: 'Failed · retry (destructive variant)',
      builder: (context) => catalogFrame(
        buildUpdateAlertHost(
          const AppUpdateState(
            status: UpdateStatus.failed,
            currentVersion: '2.0.3-alpha',
            error: 'settings.update.failed',
            manual: true,
          ),
        ),
        center: false,
      ),
    ),
    WidgetbookUseCase(
      name: 'Up to date · only after an explicit check',
      builder: (context) => catalogFrame(
        buildUpdateAlertHost(
          AppUpdateState(
            status: UpdateStatus.upToDate,
            currentVersion: '2.1.0',
            release: buildReleaseFixture(),
            manual: true,
          ),
        ),
        center: false,
      ),
    ),
    WidgetbookUseCase(
      name: 'Hidden · automatic check found nothing',
      builder: (context) => catalogFrame(
        buildUpdateAlertHost(
          AppUpdateState(
            status: UpdateStatus.upToDate,
            currentVersion: '2.1.0',
            release: buildReleaseFixture(),
          ),
        ),
        center: false,
      ),
    ),
    WidgetbookUseCase(
      name: 'Launch prompt · update available',
      builder: (context) => catalogFrame(
        ProviderScope(
          overrides: [
            appUpdateProvider.overrideWith(
              () => _SeededAppUpdate(
                AppUpdateState(
                  status: UpdateStatus.available,
                  currentVersion: '2.0.3-alpha',
                  release: buildReleaseFixture(version: '2.1.0'),
                ),
              ),
            ),
          ],
          child: const _LaunchPromptHost(),
        ),
        center: false,
      ),
    ),
  ];
}

/// Opens [showUpdateAvailableDialog] once the frame is on screen — a dialog
/// story has no button to press, so it raises itself.
class _LaunchPromptHost extends ConsumerStatefulWidget {
  const _LaunchPromptHost();

  @override
  ConsumerState<_LaunchPromptHost> createState() => _LaunchPromptHostState();
}

class _LaunchPromptHostState extends ConsumerState<_LaunchPromptHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showUpdateAvailableDialog(context, ref);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox(width: 460, height: 320);
}

/// What the release feed hands over verbatim: GitHub's own markdown.
///
/// Deliberately awkward — a heading, a task list, a table and a fenced block —
/// so a rendering regression shows up as a change in the catalog rather than as
/// a wall of `##` in a dialog.
const _releaseNotes = r"""
## What's new

- **Readers** — the manga and webtoon infinite scrollers now keep their place
  across a chapter junction instead of snapping back to the first page.
- [x] Chapter chaining no longer drops the last page of a chapter
- [x] Zoom resets when a new chapter loads
- [ ] Offline download queue (still landing)

### Fixed

| Area | Symptom | Status |
| ---- | ------- | ------ |
| Reader | wrong page after a junction | fixed |
| Settings | update banner stuck at 40% | fixed |

### For developers

The extension runtime now pins `miru-core` to the tagged build:

```dart
final release = await MiruUpdateService().fetchLatest();
```

> Upgrade notes: the update prompt now shows these notes in the app, so the
> release page is only a fallback.

Full diff: https://github.com/miru-project/miru-alpha/compare/v2.0.3-alpha...v2.1.0
""";
