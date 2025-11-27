import 'package:flutter/material.dart';
import 'package:forui/theme.dart';
import 'package:forui/widgets/toast.dart';
import 'package:miru_app_new/utils/router/router_util.dart';

void showSimpleToast(String title, [int duration = 3]) {
  final ctx = RouterUtil.rootNavigatorKey.currentContext;
  if (ctx == null) return;
  showFToast(
    duration: Duration(seconds: duration),
    context: ctx,
    title: Text(
      title,
      style: TextStyle(color: ctx.theme.colors.primaryForeground),
    ),
    alignment: FToastAlignment.bottomCenter,
  );
}

void iconsMessageToast(String title, IconData icon, [int duration = 3]) {
  final ctx = RouterUtil.rootNavigatorKey.currentContext;
  if (ctx == null) return;
  showFToast(
    context: ctx,
    title: Text(title, style: TextStyle(color: ctx.theme.colors.foreground)),
    icon: Icon(icon, color: ctx.theme.colors.primary),
    duration: Duration(seconds: duration),
    alignment: FToastAlignment.bottomCenter,
  );
}
