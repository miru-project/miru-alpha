import 'dart:ui';
import 'package:forui/forui.dart';
import 'package:flutter/widgets.dart';
import 'package:miru_alpha/ui/core/widget/miru_dialog.dart';

Future<T?> showMiruDialog<T>({
  required BuildContext context,
  Widget Function(BuildContext, FDialogStyle, Animation<double>)? builder,
  List<Widget>? actions,
  Widget? body,
  Widget? title,
}) => showFDialog<T>(
  routeStyle: .delta(
    barrierFilter: () =>
        (context, animation) => ImageFilter.compose(
          outer: ImageFilter.blur(sigmaX: animation * 5, sigmaY: animation * 5),
          inner: ColorFilter.mode(context.theme.colors.barrier, .srcOver),
        ),
  ),
  context: context,
  builder:
      builder ??
      (context, style, animation) => FTheme(
        data: context.theme,
        child: MiruDialog(
          style: style,
          animation: animation,
          title: title,
          body: body,
          actions: actions,
        ),
      ),
);
