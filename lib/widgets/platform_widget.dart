import 'package:flutter/material.dart';
import 'package:miru_app_new/utils/core/device_util.dart';

class PlatformWidget extends StatelessWidget {
  const PlatformWidget({
    super.key,
    required this.mobileWidget,
    required this.desktopWidget,
  });

  final Widget mobileWidget;
  final Widget desktopWidget;

  @override
  Widget build(BuildContext context) {
    if (DeviceUtil.isMobileLayout(context)) {
      return mobileWidget;
    }
    return desktopWidget;
  }
}
