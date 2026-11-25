import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/provider/app_update_provider.dart';
import 'package:miru_alpha/ui/features/setting/widget/update_changelog.dart';
import 'package:miru_alpha/ui/features/setting/widget/update_status_icon.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/update/miru_release.dart';
import 'package:miru_alpha/utils/update/update_installer.dart';

/// The launch update prompt: "New alpha build ready", the version delta and
/// the release notes, with an explicit escape hatch (the close button) and a
/// quiet "Ignore this version" that hides only this build.
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
    barrierDismissible: state.status != UpdateStatus.downloading,
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

    // The window between the title block and the actions is the only part that
    // can outgrow a short viewport (a phone in landscape, a 600px test window):
    // the notes and the technical changelog are unbounded, so they scroll
    // inside the space that is left rather than pushing the actions off screen.
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // When the headline below already carries the status title
              // (downloading, downloaded), the chip's uppercase label would
              // repeat it — only the glyph stays. Every other state keeps
              // icon + label.
              if (downloading || state.status == UpdateStatus.downloaded)
                Icon(
                  updateStatusIcon(state.status),
                  size: 16,
                  color: colors.mutedForeground,
                )
              else ...[
                Icon(
                  updateStatusIcon(state.status),
                  size: 16,
                  color: colors.mutedForeground,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    state.titleKey.i18n.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.body.xs.copyWith(
                      color: colors.mutedForeground,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              FTappable(
                onPress: () => Navigator.of(context).pop(),
                semanticsLabel: 'settings.update.close'.i18n,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    FLucideIcons.x,
                    size: 18,
                    color: colors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // The headline and the version delta: the human line, then the
          // machine line (current → latest, plus the publish date).
          Text(
            state.status == UpdateStatus.available
                ? 'settings.update.new_build_ready'.i18n
                : state.titleKey.i18n,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: style.titleTextStyle.copyWith(
              fontSize: style.titleTextStyle.fontSize == null ? null : 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          _VersionDelta(state: state, release: release),
          const SizedBox(height: 12),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // One animated slot for "the part that changes": while bytes
                  // are moving it holds the progress bar, otherwise the release
                  // notes and the fine print. Keeping a single AnimatedSize
                  // here is what makes the state change a collapse instead of
                  // a jump cut — the dialog keeps its top edge and the card
                  // shrinks to the new content.
                  AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    alignment: Alignment.topLeft,
                    child: downloading
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              FDeterminateProgress(
                                value: state.progress.clamp(0.0, 1.0),
                                semanticsLabel:
                                    'settings.update.downloading'.i18n,
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
                              const SizedBox(height: 8),
                              Text(
                                'settings.update.downloading_information'.fill({
                                  'progress':
                                      '${(state.progress * 100).round()}%',
                                }),
                                style: context.theme.typography.body.sm
                                    .copyWith(color: colors.mutedForeground),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              // The release notes, parsed rather than linked:
                              // the notes are the only thing that says what
                              // this build actually changes, and sending the
                              // reader to a browser to find out is a worse
                              // answer than showing them here. Bounded,
                              // because a release body is unbounded and the
                              // actions below must stay reachable.
                              UpdateChangelog(
                                markdown: release.body,
                                maxHeight: 168,
                              ),
                            ],
                          ),
                  ),
                  if (state.status == UpdateStatus.available) ...[
                    const SizedBox(height: 16),
                    _TechnicalChangelog(release: release),
                  ],
                ],
              ),
            ),
          ),
          if (_actions(context, ref, state).isNotEmpty) ...[
            const SizedBox(height: 20),
            // On a phone the actions stack full-width: a primary and a ghost
            // side by side reads as a desktop toolbar crammed into a 350dp
            // card, and each was only ~36dp tall. Full-width + 48dp min is
            // both the alignment fix and the touch-target fix. Desktop keeps
            // the start-aligned wrap (room for three, and the banner's flow).
            if (_isMobile(context))
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final action in _actions(context, ref, state)) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: action,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              )
            else
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 6,
                runSpacing: 6,
                children: _actions(context, ref, state),
              ),
          ],
          // The fine print explains the *secondary* action, so it sits below
          // the buttons. Quiet muted text, not a heavy bordered box. Only the
          // decision state has a secondary action to explain.
          if (state.status == UpdateStatus.available) ...[
            const SizedBox(height: 10),
            Text(
              _promptInformation(context),
              style: context.theme.typography.body.xs.copyWith(
                color: colors.mutedForeground,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// The dialog's actions, per state, primary first.
  ///
  /// Each button carries no leading icon: the status chip beside the title
  /// already names the state, and repeating its glyph on the main action puts
  /// the same arrow twice inside a 420px card.
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
            size: .lg,
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
            variant: .outline,
            size: .lg,
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
            size: .lg,
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
            size: .lg,
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
    size: .lg,
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

/// The machine line under the headline: `current → latest • Nov 14`.
class _VersionDelta extends StatelessWidget {
  const _VersionDelta({required this.state, required this.release});

  final AppUpdateState state;
  final MiruRelease release;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final current = shortVersion(state.currentVersion);
    final latest = shortVersion(release.version);
    final published = release.publishedAt;

    return Text.rich(
      TextSpan(
        style: context.theme.typography.body.xs.copyWith(
          color: colors.mutedForeground,
          fontFamily: 'monospace',
          fontFamilyFallback: const ['DejaVu Sans Mono', 'Liberation Mono'],
        ),
        children: [
          TextSpan(text: current),
          const TextSpan(text: ' → '),
          TextSpan(text: latest),
          if (published != null) ...[
            const TextSpan(text: ' • '),
            TextSpan(text: _monthDay(published)),
          ],
        ],
      ),
    );
  }

  static String _monthDay(DateTime date) =>
      '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
}

/// The progressive-disclosure block: a "Technical changelog (N commits)"
/// toggle that reveals the raw commit list, parsed out of the release body.
class _TechnicalChangelog extends StatefulWidget {
  const _TechnicalChangelog({required this.release});

  final MiruRelease release;

  @override
  State<_TechnicalChangelog> createState() => _TechnicalChangelogState();
}

class _TechnicalChangelogState extends State<_TechnicalChangelog> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final commits = _commitLines(widget.release.body);
    if (commits.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FTappable(
          onPress: () => setState(() => _expanded = !_expanded),
          semanticsLabel: 'settings.update.technical_changelog'.i18n,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    FLucideIcons.chevronRight,
                    size: 16,
                    color: colors.mutedForeground,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'settings.update.technical_changelog'.fill({
                      'count': '${commits.length}',
                    }),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.body.xs.copyWith(
                      color: colors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.muted.withAlpha(40),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in commits)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      line,
                      style: context.theme.typography.body.xs.copyWith(
                        color: colors.mutedForeground,
                        fontFamily: 'monospace',
                        fontFamilyFallback: const [
                          'DejaVu Sans Mono',
                          'Liberation Mono',
                        ],
                        height: 1.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// The bullet lines of the release body, in order — the commit list GitHub
  /// writes under the "Bug Fixes"/"Features" headings.
  static List<String> _commitLines(String body) => body
      .split('\n')
      .map((line) => line.trimRight())
      .where((line) => line.trimLeft().startsWith('- '))
      .map((line) => line.trimLeft().substring(2).trim())
      .where((line) => line.isNotEmpty)
      .toList();
}
