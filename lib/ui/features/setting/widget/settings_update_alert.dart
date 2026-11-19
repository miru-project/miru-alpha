import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/app_update_provider.dart';
import 'package:miru_alpha/ui/features/setting/widget/update_changelog.dart';
import 'package:miru_alpha/ui/features/setting/widget/update_status_icon.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/update/update_installer.dart';

/// The auto-update banner shown at the top of the settings landing page.
///
/// It is the only surface the update flow needs: every state renders inside
/// one [FAlert] (title + detail + actions) and the whole widget collapses to
/// nothing when there is nothing to say — an idle or up-to-date automatic
/// check never occupies the page.
///
/// Both shells mount it: the mobile settings root page (`SettingPage`) and
/// the desktop settings content pane (`SettingGeneral`).
class SettingsUpdateAlert extends HookConsumerWidget {
  const SettingsUpdateAlert({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appUpdateProvider);
    if (!state.visible) return const SizedBox.shrink();

    final failed = state.status == UpdateStatus.failed;
    final subtitle = state.subtitleKey;
    final showActions = switch (state.status) {
      UpdateStatus.available => true,
      UpdateStatus.downloaded => true,
      UpdateStatus.failed => true,
      _ => false,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: FAlert(
        variant: failed ? .destructive : .primary,
        icon: Icon(updateStatusIcon(state.status)),
        title: Text(state.titleKey.i18n),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subtitle != null) Text(subtitle.fill(_params(state))),
            if (state.status == UpdateStatus.downloading) ...[
              const SizedBox(height: 8),
              // FProgress is indeterminate — it sweeps and cannot show how far
              // along the download is. FDeterminateProgress is the native
              // primitive for a known fraction, so the track and the "42%"
              // label are driven by the same number.
              FDeterminateProgress(
                value: state.progress.clamp(0.0, 1.0),
                semanticsLabel: 'settings.update.downloading'.i18n,
                style: .delta(
                  constraints: const .tightFor(height: 4),
                  trackDecoration: .boxDelta(
                    color: context.theme.colors.mutedForeground.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  fillDecoration: .boxDelta(
                    color: context.theme.colors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
            if (showActions) ...[
              // 8 / 12: the same ramp the launch dialog uses, so the two
              // surfaces keep one rhythm instead of two.
              const SizedBox(height: 12),
              // Actions start-aligned under the text they belong to: the alert
              // is read as one block, and a group pushed to the far edge of a
              // wide desktop card would sit a long way from the sentence it
              // modifies. FButton defaults to mainAxisSize.max, which would
              // stretch every action across the whole alert, so each button
              // hugs its label.
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _actions(context, ref, state),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Placeholder values for the detail line's i18n params.
  Map<String, String> _params(AppUpdateState state) => {
    'current': state.currentVersion,
    'latest': state.release?.version ?? '',
    'progress': '${(state.progress * 100).round()}%',
    'path': state.localPath ?? '',
  };

  /// The banner's action row, per state. A trailing "Later" closes it.
  List<Widget> _actions(
    BuildContext context,
    WidgetRef ref,
    AppUpdateState state,
  ) {
    final notifier = ref.read(appUpdateProvider.notifier);
    final buttons = <Widget>[];

    switch (state.status) {
      case UpdateStatus.available:
        buttons.addAll([
          FButton(
            size: .sm,
            mainAxisSize: .min,
            onPress: notifier.download,
            child: Text(
              state.needsBrowserFallback
                  ? 'settings.update.release_page'.i18n
                  : 'settings.update.download'.i18n,
            ),
          ),
          FButton(
            variant: .ghost,
            size: .sm,
            mainAxisSize: .min,
            // Notes open in the app; only the download page (no asset for
            // this platform) still leaves for the browser.
            onPress: state.needsBrowserFallback
                ? notifier.openReleasePage
                : () => showUpdateChangelogDialog(
                    context,
                    release: state.release!,
                  ),
            child: Text('settings.update.release_notes'.i18n),
          ),
        ]);
      case UpdateStatus.downloaded:
        buttons.add(
          FButton(
            size: .sm,
            mainAxisSize: .min,
            onPress: notifier.install,
            // Desktop restarts into the build that is already unpacked;
            // Android hands the APK to the package installer.
            child: Text(
              UpdateInstaller.appliesItself
                  ? 'settings.update.restart_now'.i18n
                  : 'settings.update.install'.i18n,
            ),
          ),
        );
      case UpdateStatus.failed:
        buttons.add(
          FButton(
            size: .sm,
            mainAxisSize: .min,
            // A failed download is retried by downloading again; a failed
            // *check* is retried by checking. `release` surviving tells the
            // two apart — the check that produced it succeeded.
            onPress: state.release == null
                ? notifier.checkNow
                : notifier.download,
            child: Text('settings.update.retry'.i18n),
          ),
        );
      case UpdateStatus.idle:
      case UpdateStatus.checking:
      case UpdateStatus.upToDate:
      case UpdateStatus.downloading:
        return buttons;
    }

    buttons.add(
      FButton(
        variant: .ghost,
        size: .sm,
        mainAxisSize: .min,
        // Same meaning as the dialog's Later: not now, not never. The version
        // is remembered so the launch prompt stays quiet, and the banner is
        // hidden for this sitting — the next check (or the next launch) brings
        // it back, because the build is still there.
        onPress: () {
          notifier.later();
          notifier.dismiss();
        },
        child: Text('settings.update.later'.i18n),
      ),
    );
    return buttons;
  }
}
