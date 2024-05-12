import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlatformWidget extends StatelessWidget {
  const PlatformWidget({
    super.key,
    required this.mobileWidget,
    required this.desktopBuilder,
  });

  final Widget mobileWidget;
  final Widget desktopBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (Get.width < 800) {
          return mobileWidget;
        }
        return desktopBuilder;
      },
    );
  }
}
