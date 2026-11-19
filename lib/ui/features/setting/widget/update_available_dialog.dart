import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/provider/app_update_provider.dart';
import 'package:miru_alpha/ui/features/setting/widget/update_changelog.dart';
import 'package:miru_alpha/ui/features/setting/widget/update_status_icon.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/update/update_installer.dart';

/// The launch update prompt: "Miru X is ready, you're on Y", with a plain
/// note that ignoring it only closes the prompt — the download stays available
/// under Settings, and an explicit check there always shows it again.
///
/// Kept separate from [SettingsUpdateAlert] on purpose: the banner is
/// informational and lives on a page the user chose to open, while this is the
/// one interrupt the app is allowed to make at startup.
///
/// The dialog stays open for the whole update, not just the question: pressing
/// *Update now* morphs it into the download (with the real percentage) and then
/// into the install step. There is no banner behind it on a cold launch, so
/// closing here would leave a multi-minute download with nothing on screen.
Future<void> showUpdateAvailableDialog(
  BuildContext context,
  WidgetRef ref, {

  /// How wide the card is allowed to get. Defaults to the app's window; the
  /// catalog passes a phone width so the mobile flow can be reviewed inside a
  /// desktop window, where the card would otherwise lay out at its 420 cap.
  BoxConstraints constraints = const BoxConstraints(
    minWidth: 300,
    maxWidth: 420,
  ),

  /// Where the route goes. The app always wants the root navigator — the check
  /// fires above the router, where the nearest navigator is whatever route the
  /// user happens to be on. The catalog's phone frame passes `false` so the
  /// dialog lands on the phone's own back stack and sees the phone's MediaQuery
  /// (a root route would sit above it and read the desktop window's width).
  bool useRootNavigator = true,
}) {
  final state = ref.read(appUpdateProvider);
  if (state.release == null) return Future.value();

  // Captured here, in the caller's context, not inside the builder: the dialog
  // goes on the *root* navigator, which can sit above the ProviderScope that
  // opened it (the widgetbook catalog mounts one per use-case, below its own
  // MaterialApp). A `ConsumerWidget` reading `ref` inside that route would
  // throw "No ProviderScope found", so the route carries its own scope.
  final container = ProviderScope.containerOf(context);

  return showFDialog(
    context: context,
    // The root navigator, not the nearest one: this fires from a listener
    // above the router, where the local navigator is whatever route the user
    // happens to be on (or none, mid-launch).
    useRootNavigator: useRootNavigator,
    builder: (context, style, _) => UncontrolledProviderScope(
      container: container,
      child: FDialog.adaptive(
        constraints: constraints,
        semanticsLabel: state.titleKey.i18n,
        verticalBuilder: (context, style) => _UpdateDialog(style: style),
        horizontalBuilder: (context, style) => _UpdateDialog(style: style),
      ),
    ),
  );
}

/// Watches the update state so the open dialog follows the flow instead of
/// freezing on the state it was opened with.
class _UpdateDialog extends ConsumerWidget {
  const _UpdateDialog({required this.style});

  final FDialogStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appUpdateProvider);
    final release = state.release;
    final colors = context.theme.colors;

    if (release == null) {
      // A background re-check that finds nothing clears `release` while this
      // route is still open. A title with no body and no buttons is a dead end
      // whose only exit is the system back gesture, so the dialog leaves with
      // the state that invalidated it.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return const SizedBox.shrink();
    }

    final downloading = state.status == UpdateStatus.downloading;
    final actions = _actions(context, ref, state);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Bare, exactly as FAlert draws its own leading icon: forui has
              // no "icon tile" primitive, and the hand-rolled 36px box with a
              // 28-alpha fill that used to sit here was a delta the banner did
              // not share.
              Icon(
                updateStatusIcon(state.status),
                size: 18,
                color: colors.primary,
              ),
              const SizedBox(width: 10),
              // No percentage here: the line under it already says "42% of
              // the new build", and printing the same number twice — in two
              // type styles, 80px apart — reads as a rendering bug.
              Expanded(
                child: Text(state.titleKey.i18n, style: style.titleTextStyle),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _message(context, state, release.version),
          // One animated slot for "the part that changes": while bytes are
          // moving it holds the progress bar, otherwise the release notes and
          // the fine print. Keeping a single AnimatedSize here is what makes
          // the state change a collapse instead of a jump cut — the dialog
          // keeps its top edge and the card shrinks to the new content.
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topLeft,
            child: downloading
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // Same primitive the settings banner uses, at the
                      // dialog's larger size — one bar implementation, two
                      // densities. Downloads only: a full bar is work in
                      // progress, and once the file is on disk the next step
                      // is a restart, not more waiting.
                      FDeterminateProgress(
                        value: state.progress.clamp(0.0, 1.0),
                        semanticsLabel: 'settings.update.downloading'.i18n,
                        style: .delta(
                          constraints: const .tightFor(height: 6),
                          trackDecoration: .boxDelta(
                            color: colors.muted,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          fillDecoration: .boxDelta(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // The release body, parsed rather than linked: the notes
                      // are the only thing that says what this build actually
                      // changes, and sending the reader to a browser to find
                      // out is a worse answer than showing them here. Bounded,
                      // because a release body is unbounded and the actions
                      // below must stay reachable.
                      UpdateChangelog(markdown: release.body, maxHeight: 168),
                      // Only the decision state has two actions to explain.
                      // On the install and retry steps the buttons are
                      // self-describing, and promising an "Ignore this version"
                      // that is not on screen reads as a bug.
                      if (state.status == UpdateStatus.available) ...[
                        const SizedBox(height: 12),
                        // What the remaining secondary action actually does,
                        // spelled out where it is read. On a phone there is
                        // only one thing to explain — "Later" is not offered
                        // there — so the desktop's two-sentence note would
                        // describe a button that is not on screen.
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colors.muted.withAlpha(60),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colors.border.withAlpha(120),
                            ),
                          ),
                          child: Text(
                            _promptInformation(context),
                            style: context.theme.typography.body.xs.copyWith(
                              color: colors.mutedForeground,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 16),
            // Wrap, not Row: three actions flow to a second line on a narrow
            // phone instead of overflowing the dialog. Start-aligned and
            // primary-first, exactly like the settings banner, so the same
            // flow reads the same way on both surfaces.
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 6,
              runSpacing: 6,
              children: actions,
            ),
          ],
        ],
      ),
    );
  }

  /// The one line that changes per state: the question while deciding, the
  /// percentage while fetching, the restart hint once it is on disk.
  Widget _message(BuildContext context, AppUpdateState state, String latest) {
    final body = context.theme.typography.body.sm;
    final text = switch (state.status) {
      UpdateStatus.available => 'settings.update.prompt_message'.fill({
        'current': _oneLine(state.currentVersion),
        'latest': _oneLine(latest),
      }),
      UpdateStatus.downloading =>
        'settings.update.downloading_information'.fill({
          'progress': '${(state.progress * 100).round()}%',
        }),
      UpdateStatus.downloaded => 'settings.update.downloaded_information'.fill({
        'latest': _oneLine(latest),
      }),
      // `error` is an i18n key (see [AppUpdateState.error]) and the fallback
      // is one too — both have to be resolved, or the dialog prints
      // "settings.update.download_failed" at the user.
      UpdateStatus.failed =>
        state.error?.i18n ?? 'settings.update.failed_information'.i18n,
      _ => state.subtitleKey?.fill(_params(state)) ?? '',
    };

    return Text(
      text,
      style: body.copyWith(
        color: context.theme.colors.foreground,
        height: 1.45,
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

  /// Keeps a version number on one line.
  ///
  /// A hyphen is a legal break, so "You're running 2.0.3-alpha." could end a
  /// line with "2.0.3-" and start the next with a bare "alpha." — a version
  /// split across two lines reads as a broken build. A word joiner after the
  /// hyphen forbids that break and draws nothing, so the glyphs are unchanged.
  static String _oneLine(String version) => version.replaceAll('-', '-\u2060');

  /// The dialog's actions, per state, primary first.
  ///
  /// Each button carries no leading icon: the tile beside the title already
  /// names the state, and repeating its glyph on the main action puts the same
  /// arrow twice inside a 420px card.
  List<Widget> _actions(
    BuildContext context,
    WidgetRef ref,
    AppUpdateState state,
  ) {
    final notifier = ref.read(appUpdateProvider.notifier);
    // A phone gets two actions, not three: "Update now" and "Ignore this
    // version" are the whole decision, and a third way to say "not now" that
    // is really a fourth state to explain is a worse dialog than one with a
    // single quiet exit. Desktop keeps Later — there is room for three, and
    // its banner already taught the split.
    final mobile = _isMobile(context);
    final later = mobile ? null : _laterButton(context, notifier);

    switch (state.status) {
      case UpdateStatus.available:
        return [
          FButton(
            size: .sm,
            mainAxisSize: .min,
            onPress: notifier.download,
            // Bounded + ellipsis: a long translation shrinks its label
            // instead of overflowing the dialog. Not `Flexible` — a flex child
            // inside FButton's `mainAxisSize.min` row makes the button expand
            // to the whole row, which put every action on its own line.
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                'settings.update.update_now'.i18n,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          FButton(
            variant: .ghost,
            size: .sm,
            mainAxisSize: .min,
            onPress: () async {
              Navigator.of(context).pop();
              await notifier.ignore();
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                'settings.update.ignore_version'.i18n,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          ?later,
        ];
      case UpdateStatus.downloaded:
        return [
          FButton(
            size: .sm,
            mainAxisSize: .min,
            onPress: () async {
              Navigator.of(context).pop();
              await notifier.install();
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                // Desktop: the build is already unpacked, so the button
                // restarts into it. Android: it hands the APK to the
                // package installer, which is an install.
                UpdateInstaller.appliesItself
                    ? 'settings.update.restart_now'.i18n
                    : 'settings.update.install'.i18n,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          ?later,
        ];
      case UpdateStatus.failed:
        return [
          FButton(
            size: .sm,
            mainAxisSize: .min,
            onPress: () => notifier.download(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                'settings.update.retry'.i18n,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          ?later,
        ];
      case UpdateStatus.downloading:
        // Deliberately empty: this dialog is the only thing showing the
        // download on a cold launch, so it has no "hide this" while the bytes
        // are still moving. Closing it would leave a multi-minute download
        // with no visible progress — the one thing this file's header
        // promises not to do.
        return const [];
      case UpdateStatus.checking:
      case UpdateStatus.upToDate:
      case UpdateStatus.idle:
        return [?later];
    }
  }

  /// Whether this dialog is being drawn on a phone.
  ///
  /// The same predicate `FDialog.adaptive` uses to pick its vertical layout,
  /// read from the theme's own breakpoints rather than a width literal, so the
  /// action set can never contradict the frame it is drawn in. forui's default
  /// `sm` is 640.
  bool _isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < context.theme.breakpoints.sm;

  /// The fine print under the changelog.
  ///
  /// Desktop explains both secondary actions; a phone only ever shows one, so
  /// it gets the sentence that describes the button it actually has.
  String _promptInformation(BuildContext context) => _isMobile(context)
      ? 'settings.update.prompt_ignore_only'.i18n
      : 'settings.update.prompt_information'.i18n;

  /// The shared "hide this" action. It never discards the download — the
  /// banner takes over — so it is offered in every state that can be walked
  /// away from.
  ///
  /// Pressing it also postpones the prompt for this version: a dialog that
  /// returns on the next launch is a dialog the user has to keep dismissing.
  /// The banner on the settings page is deliberately left alone, so the build
  /// stays one tap away.
  FButton _laterButton(BuildContext context, AppUpdate notifier) => FButton(
    variant: .ghost,
    size: .sm,
    mainAxisSize: .min,
    onPress: () {
      notifier.later();
      Navigator.of(context).pop();
    },
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Text(
        'settings.update.later'.i18n,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}
