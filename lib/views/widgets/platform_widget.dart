import 'package:flutter/material.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (MediaQuery.of(context).size.width < 800) {
          return mobileWidget;
        }
        return desktopWidget;
      },
    );
  }
}
