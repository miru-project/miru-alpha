import 'package:material_ui/material_ui.dart';
import 'package:forui/theme.dart';
import 'package:forui/widgets/toast.dart';
import 'package:miru_alpha/utils/router/router_util.dart';

void showSimpleToast(String title, [int duration = 1]) {
  final ctx = RouterUtil.rootNavigatorKey.currentContext;
  if (ctx == null || !ctx.mounted) return;
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
  final ctx = RouterUtil.rootNavigatorKey.currentContext;
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
