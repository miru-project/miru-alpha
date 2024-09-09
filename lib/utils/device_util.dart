import 'dart:io';

import 'package:flutter/material.dart';

class DeviceUtil {
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static bool isMobileLayout(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }

  static T device<T>(
      {required BuildContext context, required T mobile, required T desktop}) {
    return isMobileLayout(context) ? mobile : desktop;
  }

  static Y deviceWidget<T, Y>(
      {required Y Function(T buildchild) mobile,
      required Y Function(T buildchild) desktop,
      required T child,
      required BuildContext context}) {
    if (isMobileLayout(context)) {
      return mobile(child);
    }
    return desktop(child);
  }

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
}
