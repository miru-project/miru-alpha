
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:miru_app_new/widgets/amination/animated_box.dart';
import 'package:miru_app_new/widgets/core/inner_card.dart';

class DesktopDetailItemBox extends HookWidget {
  const DesktopDetailItemBox({
    required this.padding,
    required this.child,
    required this.title,
    this.isMobile = false,
    this.needExpand = true,
    super.key,
  });

  final Widget child;
  final double padding;
  final String title;
  final bool isMobile;
  final bool needExpand;

  @override
  Widget build(BuildContext context) {
    return AnimatedBox(
      child: InnerCard(title: title, child: child),
    );
  }
}
