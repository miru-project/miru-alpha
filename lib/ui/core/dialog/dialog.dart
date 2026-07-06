import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';

Future<T?> showMiruDialog<T>({
  required BuildContext context,
  Widget Function(BuildContext, FDialogStyle, Animation<double>)? builder,
  List<Widget>? actions,
  Widget? body,
  Widget? title,
}) => showFDialog<T>(
  routeStyle: .delta(
    barrierFilter: () =>
        (animation) => ImageFilter.compose(
          outer: ImageFilter.blur(sigmaX: animation * 5, sigmaY: animation * 5),
          inner: ColorFilter.mode(context.theme.colors.barrier, .srcOver),
        ),
  ),
  context: context,
  builder:
      builder ??
      (context, style, animation) => FTheme(
        data: context.theme,
        child: FDialog(
          style: style,
          animation: animation,
          title: title,
          body: body,
          actions: actions ?? [],
        ),
      ),
);
