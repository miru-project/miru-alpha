import 'package:flutter/material.dart';
import 'package:forui/widgets/toast.dart';
import 'package:miru_app_new/utils/router/router_util.dart';

void showSimpleToast(String title) {
  final ctx = RouterUtil.rootNavigatorKey.currentContext;
  if (ctx == null) return;
  showFToast(
    context: ctx,
    title: Text(title),
    alignment: FToastAlignment.bottomCenter,
  );
}

void iconsMessageToast(String title, IconData icon) {
  final ctx = RouterUtil.rootNavigatorKey.currentContext;
  if (ctx == null) return;
  showFToast(
    context: ctx,
    title: Text(title),
    icon: Icon(icon, color: Colors.white),
    alignment: FToastAlignment.bottomCenter,
  );
}
