import 'dart:io';

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

late PackageInfo packageInfo;
late AndroidDeviceInfo androidDeviceInfo;
late WindowsDeviceInfo windowsDeviceInfo;
late LinuxDeviceInfo linuxDeviceInfo;

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

  static T device<T>({
    required BuildContext context,
    required T mobile,
    required T desktop,
  }) {
    return isMobileLayout(context) ? mobile : desktop;
  }

  // Widget for device specific by checking layout
  static Y deviceWidgetFunction<T, Y>({
    required Y Function(T buildchild) mobile,
    required Y Function(T buildchild) desktop,
    required T child,
    required BuildContext context,
  }) {
    if (isMobileLayout(context)) {
      return mobile(child);
    }
    return desktop(child);
  }

  // Widget for device specific by checking layout
  static Widget deviceWidget({
    required Widget mobile,
    required Widget desktop,
    required BuildContext context,
  }) {
    if (isMobileLayout(context)) {
      return mobile;
    }
    return desktop;
  }

  // Widget for device specific by checking platform
  static Y platformWidgetFunction<T, Y>({
    required Y Function(T buildchild) mobile,
    required Y Function(T buildchild) desktop,
    required T child,
  }) {
    if (Platform.isAndroid || Platform.isIOS) {
      return mobile(child);
    }
    return desktop(child);
  }

  // Widget for device specific by checking platform
  static Widget platformWidget({
    required Widget mobile,
    required Widget desktop,
  }) {
    if (Platform.isAndroid || Platform.isIOS) {
      return mobile;
    }
    return desktop;
  }

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  static Future<PackageInfo> ensureInitialized() async {
    packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfo.androidInfo;
      return packageInfo;
    }
    if (Platform.isLinux) {
      linuxDeviceInfo = await deviceInfo.linuxInfo;
      return packageInfo;
    }
    if (Platform.isWindows) {
      windowsDeviceInfo = await deviceInfo.windowsInfo;
    }
    return packageInfo;
  }
}
