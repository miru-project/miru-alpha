import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/router/router_util.dart';

/// Returns the context to show a toast with, or null after logging why not.
///
/// `showFToast` throws when there is no [FToaster] above the root navigator.
/// A toast fired from inside the global error handler would then throw back
/// into that handler, which schedules another toast — an error every frame.
BuildContext? _toastContext(String title) {
  final ctx = RouterUtil.rootNavigatorKey.currentContext;
  if (ctx == null || !ctx.mounted) return null;
  if (ctx.findAncestorStateOfType<FToasterState>() == null) {
    logger.warning('No FToaster mounted, dropping toast: $title');
    return null;
  }
  return ctx;
}

void showSimpleToast(String title, [int duration = 1]) {
  final ctx = _toastContext(title);
  if (ctx == null) return;
  showFToast(
    duration: Duration(seconds: duration),
    context: ctx,
    title: Text(title, style: TextStyle(color: ctx.theme.colors.primary)),
    alignment: FToastAlignment.bottomCenter,
  );
}

void iconsMessageToast({
  required String title,
  required IconData icon,
  int duration = 1,
}) {
  final ctx = _toastContext(title);
  if (ctx == null) return;
  showFToast(
    context: ctx,
    title: Text(title, style: TextStyle(color: ctx.theme.colors.primary)),
    icon: Icon(icon, color: ctx.theme.colors.primary),
    duration: Duration(seconds: duration),
    alignment: FToastAlignment.bottomCenter,
    swipeToDismiss: [.down, .left, .right],
  );
}

/// Delete-data toast: [title], a linear bar draining over the toast's own
/// lifetime (the remaining-time line), and an Undo button on the right that
/// dismisses the toast and re-runs [onUndo]. Past the window the change
/// stands.
void showUndoToast({
  required String title,
  required IconData icon,
  required VoidCallback onUndo,
  Duration duration = const Duration(seconds: 5),
}) {
  final ctx = _toastContext(title);
  if (ctx == null) return;
  showFToast(
    context: ctx,
    title: Text(title, style: TextStyle(color: ctx.theme.colors.primary)),
    icon: Icon(icon, color: ctx.theme.colors.primary),
    duration: duration,
    alignment: FToastAlignment.bottomCenter,
    swipeToDismiss: [.down, .left, .right],
    description: TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: duration,
      curve: Curves.linear,
      builder: (context, remaining, _) => LinearProgressIndicator(
        value: remaining,
        minHeight: 2,
        valueColor: AlwaysStoppedAnimation(context.theme.colors.primary),
      ),
    ),
    suffixBuilder: (context, entry) => FButton(
      variant: .ghost,
      size: .xs,
      mainAxisSize: .min,
      onPress: () {
        entry.dismiss();
        onUndo();
      },
      child: Text('common.undo'.i18n),
    ),
  );
}
