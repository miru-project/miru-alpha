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
      {required T mobile, required T desktop, required BuildContext context}) {
    return isMobileLayout(context) ? mobile : desktop;
  }

  static Widget deviceWidget(
      {required Widget Function(Widget buildchild) mobile,
      required Widget Function(Widget buildchild) desktop,
      required Widget child,
      required BuildContext context}) {
    if (isMobileLayout(context)) {
      return mobile(child);
    }
    return desktop(child);
  }

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
}
