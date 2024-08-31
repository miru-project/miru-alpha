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

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
}
