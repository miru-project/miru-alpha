import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miru_alpha/provider/app_update_provider.dart';
import 'package:miru_alpha/ui/features/setting/widget/update_available_dialog.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/router/router_util.dart';

/// Raises the launch update prompt exactly once per newer version.
///
/// Mounted above the router (in `MaterialApp.router`'s `builder`) so it sees
/// the app-wide update state regardless of which route the user lands on. It
/// deliberately does not own the decision of *whether* to prompt — that is
/// [AppUpdateState.promptable], so the settings banner and this dialog can
/// never disagree about what the check found.
class UpdatePromptListener extends ConsumerStatefulWidget {
  const UpdatePromptListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UpdatePromptListener> createState() =>
      _UpdatePromptListenerState();
}

class _UpdatePromptListenerState extends ConsumerState<UpdatePromptListener> {
  /// The version already prompted for in this process, so a rebuild (theme
  /// change, language switch) or a second check cannot stack dialogs.
  String? _shownVersion;

  @override
  void initState() {
    super.initState();
    // The launch check starts in the app bootstrap's initState, so its result
    // can land before this listener has finished its first build.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _maybePrompt(ref.read(appUpdateProvider)),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appUpdateProvider.select((state) => state), (_, next) {
      _maybePrompt(next);
    });
    return widget.child;
  }

  void _maybePrompt(AppUpdateState state) {
    if (!state.promptable || !mounted) return;

    final version = state.release?.version;
    if (version == null || version == _shownVersion) return;
    _shownVersion = version;

    _showWhenReady();
  }

  /// Waits for the root navigator to exist, then shows the prompt.
  ///
  /// The check is fired from the bootstrap's `initState`, so on a cold launch
  /// the state can be `available` before the first frame has a navigator at
  /// all. Rather than drop the prompt, retry briefly.
  Future<void> _showWhenReady() async {
    for (var attempt = 0; attempt < 20; attempt++) {
      final navigator = RouterUtil.rootNavigatorKey.currentState;
      if (navigator == null) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        continue;
      }

      final context = navigator.overlay?.context;
      // The overlay's context is *below* the navigator, so `Navigator.of`
      // resolves to the root navigator. The navigator's own context sits
      // above it and would resolve to nothing — the same reason
      // `I18nUtils.changeLanguage` reaches for `overlay.context`.
      if (!mounted || context == null || !context.mounted) return;
      await showUpdateAvailableDialog(context, ref);
      return;
    }
    logger.warning('Update prompt skipped: no navigator became available');
  }
}
