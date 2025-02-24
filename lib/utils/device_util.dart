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
