/// Knob-driven prototype of the auto-update flow.
///
/// The mirrored folders pin one state per use-case (that is what the tests
/// assert); this folder is the opposite — every input is a knob, so the flow
/// can be pushed around live while designing it: what the prompt says when the
/// installed build is a year behind, what the banner does when the release has
/// no asset for the platform, how a 400-character version string behaves in a
/// 320dp dialog.
///
/// Nothing here touches the network or the installer: the notifier is seeded
/// from the knobs and `dismiss`/`ignore` are the real notifier methods, so the
/// only thing that persists is whatever the knobs themselves carry.
library;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/provider/app_update_provider.dart';
import 'package:miru_alpha/ui/features/setting/widget/settings_update_alert.dart';
import 'package:miru_alpha/ui/features/setting/widget/update_available_dialog.dart';
import 'package:miru_alpha/ui/features/setting/widget/update_changelog.dart';
import 'package:miru_alpha/utils/update/miru_release.dart';
import 'package:widgetbook/widgetbook.dart';

import '../settings/settings_update_alert.dart' show buildReleaseFixture;
import '../use_case_harness.dart';

/// The state one pass of the knobs produces.
typedef _Knobs = ({AppUpdateState state, String signature});

/// Reads every knob and folds them into a state.
///
/// The signature exists so the prompt can be re-raised from `initState` when a
/// knob changes — a dialog story has no button to press, and a story whose
/// dialog opened once before the first knob edit is not a prototype.
_Knobs _readKnobs(BuildContext context) {
  final current = context.knobs.string(
    label: 'Current version',
    initialValue: '2.0.3-alpha',
  );
  final latest = context.knobs.string(
    label: 'Latest release',
    initialValue: '2.1.0',
  );
  final status = context.knobs.object.dropdown<UpdateStatus>(
    label: 'Status',
    initialOption: UpdateStatus.available,
    options: UpdateStatus.values,
    labelBuilder: (value) => value.name,
  );
  final progress = context.knobs.double.slider(
    label: 'Progress',
    initialValue: 0.42,
    min: 0,
    max: 1,
  );
  final hasAsset = context.knobs.boolean(
    label: 'Has an asset for this platform',
    initialValue: true,
  );
  final manual = context.knobs.boolean(
    label: 'Manual check',
    initialValue: false,
  );
  final dismissed = context.knobs.boolean(
    label: 'Banner dismissed',
    initialValue: false,
  );
  final ignored = context.knobs.boolean(
    label: 'Version ignored',
    initialValue: false,
  );
  final error = context.knobs.string(
    label: 'Error key',
    initialValue: 'settings.update.failed',
  );
  final localPath = context.knobs.string(
    label: 'Local path',
    initialValue:
        '/data/user/0/miru.alpha/files/miru/updates/app-arm64-v8a-release.apk',
  );

  final fixture = buildReleaseFixture(version: latest);
  // An empty asset list is the real macOS shape: the release exists, there is
  // simply nothing installable for the platform, and both surfaces fall back to
  // the release page.
  final release = hasAsset
      ? fixture
      : MiruRelease(
          tagName: fixture.tagName,
          name: fixture.name,
          htmlUrl: fixture.htmlUrl,
          body: fixture.body,
          publishedAt: fixture.publishedAt,
          assets: const [],
        );

  final state = AppUpdateState(
    status: status,
    currentVersion: current,
    release: release,
    progress: progress,
    error: status == UpdateStatus.failed ? error : null,
    localPath: status == UpdateStatus.downloaded ? localPath : null,
    manual: manual,
    dismissed: dismissed,
    ignored: ignored,
  );

  return (
    state: state,
    signature: [
      current,
      latest,
      status.name,
      hasAsset,
      manual,
      dismissed,
      ignored,
      progress,
    ].join('|'),
  );
}

/// A notifier pinned to one state — the prototype's stand-in for the real
/// GitHub-backed check.
class _SeededAppUpdate extends AppUpdate {
  _SeededAppUpdate(this.seed);

  final AppUpdateState seed;

  @override
  AppUpdateState build() => seed;
}

/// Hosts [showUpdateChangelogDialog] once the catalog frame is on screen.
class _ChangelogHost extends ConsumerStatefulWidget {
  const _ChangelogHost({required this.release});

  final MiruRelease release;

  @override
  ConsumerState<_ChangelogHost> createState() => _ChangelogHostState();
}

class _ChangelogHostState extends ConsumerState<_ChangelogHost> {
  bool _open = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _open) return;
      _open = true;
      showUpdateChangelogDialog(context, release: widget.release);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox(width: 460, height: 320);
}

/// Hosts [showUpdateAvailableDialog] with a seeded state, re-raising it
/// whenever [signature] changes.
class _PromptHost extends ConsumerStatefulWidget {
  const _PromptHost({
    required this.signature,
    this.constraints,
    this.width = 460,
  });

  final String signature;

  /// Passed through to [showUpdateAvailableDialog]; the phone stories use it to
  /// keep the card at a phone's width inside a desktop window.
  final BoxConstraints? constraints;

  /// The placeholder the story draws behind the dialog. It is never seen while
  /// the dialog is up, but it has to be a real size or the route has nothing to
  /// sit over.
  final double width;

  @override
  ConsumerState<_PromptHost> createState() => _PromptHostState();
}

class _PromptHostState extends ConsumerState<_PromptHost> {
  @override
  void initState() {
    super.initState();
    _raise();
  }

  @override
  void didUpdateWidget(_PromptHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.signature != widget.signature) _raise();
  }

  bool _open = false;

  /// Waits for this frame to be on screen — a dialog cannot be pushed during
  /// build.
  ///
  /// A knob change replaces the open dialog rather than adding a second one: the
  /// dialog now follows the notifier's state itself (downloading → downloaded),
  /// so a stack of them would be three copies of the same flow.
  void _raise() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (_open) {
        Navigator.of(context).pop();
        _open = false;
      }
      _open = true;
      await showUpdateAvailableDialog(
        context,
        ref,
        constraints:
            widget.constraints ??
            const BoxConstraints(minWidth: 300, maxWidth: 420),
        useRootNavigator: false,
      );
      _open = false;
    });
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: widget.width, height: 320);
}

/// The prototype's components.
WidgetbookComponent updateFlowComponent() {
  return WidgetbookComponent(
    name: 'Update flow (prototype)',
    useCases: [
      WidgetbookUseCase(
        name: 'Banner · every knob',
        builder: (context) {
          final knobs = _readKnobs(context);
          return catalogFrame(
            ProviderScope(
              overrides: [
                appUpdateProvider.overrideWith(
                  () => _SeededAppUpdate(knobs.state),
                ),
              ],
              child: const SizedBox(
                width: 460,
                child: SettingsUpdateAlert(),
              ),
            ),
            center: false,
          );
        },
      ),
      WidgetbookUseCase(
        name: 'Banner · desktop layout',
        builder: (context) {
          final knobs = _readKnobs(context);
          return catalogFrame(
            ProviderScope(
              overrides: [
                appUpdateProvider.overrideWith(
                  () => _SeededAppUpdate(knobs.state),
                ),
              ],
              // The desktop shell gives the banner the full content width, so
              // the same strings get far more line length than the 460-wide
              // mobile frame above — that is the comparison this story exists
              // for.
              child: SizedBox(
                width: 720,
                child: SettingsUpdateAlert(),
              ),
            ),
            center: false,
          );
        },
      ),
      // The download state pinned, so the determinate track and its
      // percentage can be reviewed without hunting for the knob.
      WidgetbookUseCase(
        name: 'Banner · downloading · 42%',
        builder: (context) => catalogFrame(
          ProviderScope(
            overrides: [
              appUpdateProvider.overrideWith(
                () => _SeededAppUpdate(
                  AppUpdateState(
                    status: UpdateStatus.downloading,
                    currentVersion: '2.0.3-alpha',
                    release: buildReleaseFixture(version: '2.1.0'),
                    progress: 0.42,
                  ),
                ),
              ),
            ],
            child: const SizedBox(
              width: 460,
              child: SettingsUpdateAlert(),
            ),
          ),
          center: false,
        ),
      ),
      // The release body, parsed. Opened by the banner's *Release notes*
      // action; here it is raised directly so the rendering can be reviewed
      // without walking the banner first.
      WidgetbookUseCase(
        name: 'Changelog · parsed release body',
        builder: (context) => catalogFrame(
          _ChangelogHost(release: buildReleaseFixture()),
          center: false,
        ),
      ),
      WidgetbookUseCase(
        name: 'Launch prompt · every knob',
        builder: (context) {
          final knobs = _readKnobs(context);
          return catalogFrame(
            ProviderScope(
              overrides: [
                appUpdateProvider.overrideWith(
                  () => _SeededAppUpdate(knobs.state),
                ),
              ],
              child: _PromptHost(signature: knobs.signature),
            ),
            center: false,
          );
        },
      ),
      // The same prompt at a phone's width. [PhoneFrame] supplies the phone
      // viewport, so the card is laid out for 412 and takes forui's touch
      // tokens; the tighter `constraints` below are the card's own phone cap
      // (the app's default 420 leaves 8px of air on each side).
      WidgetbookUseCase(
        name: 'Launch prompt · mobile (412)',
        builder: (context) {
          final knobs = _readKnobs(context);
          return catalogFrame(
            ProviderScope(
              overrides: [
                appUpdateProvider.overrideWith(
                  () => _SeededAppUpdate(knobs.state),
                ),
              ],
              child: PhoneFrame(
                child: _PromptHost(
                  signature: knobs.signature,
                  constraints: const BoxConstraints(
                    minWidth: 260,
                    maxWidth: 372,
                  ),
                  width: 380,
                ),
              ),
            ),
            center: false,
          );
        },
      ),
      // The download and install steps pinned. Knobs are for exploring; a
      // review needs the same three frames every time, so these seed the state
      // instead of exposing it.
      WidgetbookUseCase(
        name: 'Launch prompt · mobile · downloading 42%',
        builder: (context) => catalogFrame(
          ProviderScope(
            overrides: [
              appUpdateProvider.overrideWith(
                () => _SeededAppUpdate(
                  AppUpdateState(
                    status: UpdateStatus.downloading,
                    currentVersion: '2.0.3-alpha',
                    release: buildReleaseFixture(version: '2.1.0'),
                    progress: 0.42,
                  ),
                ),
              ),
            ],
            child: const PhoneFrame(
              child: _PromptHost(
                signature: 'mobile-downloading',
                constraints: BoxConstraints(minWidth: 260, maxWidth: 372),
                width: 380,
              ),
            ),
          ),
          center: false,
        ),
      ),
      WidgetbookUseCase(
        name: 'Launch prompt · mobile · downloaded',
        builder: (context) => catalogFrame(
          ProviderScope(
            overrides: [
              appUpdateProvider.overrideWith(
                () => _SeededAppUpdate(
                  AppUpdateState(
                    status: UpdateStatus.downloaded,
                    currentVersion: '2.0.3-alpha',
                    release: buildReleaseFixture(version: '2.1.0'),
                    localPath: '/data/data/miru.alpha/files/app-arm64-v8a.apk',
                  ),
                ),
              ),
            ],
            child: const PhoneFrame(
              child: _PromptHost(
                signature: 'mobile-downloaded',
                constraints: BoxConstraints(minWidth: 260, maxWidth: 372),
                width: 380,
              ),
            ),
          ),
          center: false,
        ),
      ),
      WidgetbookUseCase(
        name: 'Launch prompt · mobile · failed download',
        builder: (context) => catalogFrame(
          ProviderScope(
            overrides: [
              appUpdateProvider.overrideWith(
                () => _SeededAppUpdate(
                  AppUpdateState(
                    status: UpdateStatus.failed,
                    currentVersion: '2.0.3-alpha',
                    release: buildReleaseFixture(version: '2.1.0'),
                    // A failed *download*, not a failed check: `release` is
                    // still here, which is what makes the banner offer Retry
                    // instead of Check again.
                    error: 'settings.update.download_failed',
                  ),
                ),
              ),
            ],
            child: const PhoneFrame(
              child: _PromptHost(
                signature: 'mobile-failed',
                constraints: BoxConstraints(minWidth: 260, maxWidth: 372),
                width: 380,
              ),
            ),
          ),
          center: false,
        ),
      ),
      // The settings banner in the same frame. Both mobile surfaces side by
      // side is the point: the banner is the only one that stays behind after
      // the prompt is dismissed.
      WidgetbookUseCase(
        name: 'Banner · mobile frame',
        builder: (context) {
          final knobs = _readKnobs(context);
          return catalogFrame(
            ProviderScope(
              overrides: [
                appUpdateProvider.overrideWith(
                  () => _SeededAppUpdate(knobs.state),
                ),
              ],
              child: const PhoneFrame(
                child: SizedBox(
                  width: 380,
                  child: SettingsUpdateAlert(),
                ),
              ),
            ),
            center: false,
          );
        },
      ),
      WidgetbookUseCase(
        name: 'Banner · mobile · downloading 42%',
        builder: (context) => catalogFrame(
          ProviderScope(
            overrides: [
              appUpdateProvider.overrideWith(
                () => _SeededAppUpdate(
                  AppUpdateState(
                    status: UpdateStatus.downloading,
                    currentVersion: '2.0.3-alpha',
                    release: buildReleaseFixture(version: '2.1.0'),
                    progress: 0.42,
                  ),
                ),
              ),
            ],
            child: const PhoneFrame(
              child: SizedBox(width: 380, child: SettingsUpdateAlert()),
            ),
          ),
          center: false,
        ),
      ),
      WidgetbookUseCase(
        name: 'Both · the whole first-run surface',
        builder: (context) {
          final knobs = _readKnobs(context);
          return catalogFrame(
            ProviderScope(
              overrides: [
                appUpdateProvider.overrideWith(
                  () => _SeededAppUpdate(knobs.state),
                ),
              ],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 460,
                    child: SettingsUpdateAlert(),
                  ),
                  const SizedBox(height: 24),
                  const _PromptHost(signature: 'both'),
                ],
              ),
            ),
            center: false,
          );
        },
      ),
    ],
  );
}
