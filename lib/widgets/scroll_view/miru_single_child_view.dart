import 'package:flutter/material.dart';
import 'package:miru_app_new/widgets/index.dart';

class MiruSingleChildView extends StatelessWidget {
  const MiruSingleChildView({super.key, required this.child, this.padding, this.maxWidth, this.scrollDirection = Axis.vertical, this.controller});

  final Axis scrollDirection;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    EdgeInsets viewPadding = MediaQuery.paddingOf(context);

    EdgeInsets widthPadding = EdgeInsets.zero;

    // 计算需要添加的 padding
    if (maxWidth != null) {
      double widthPaddingValue = (MediaQuery.of(context).size.width - maxWidth!) / 2;
      if (widthPaddingValue > 0) {
        widthPadding = EdgeInsets.only(left: widthPaddingValue, right: widthPaddingValue);
      } else {
        widthPadding = EdgeInsets.zero;
      }
    }

    return PlatformWidget(
      mobileWidget: SingleChildScrollView(
        scrollDirection: scrollDirection,
        padding: EdgeInsets.fromLTRB(8, (8 + viewPadding.top), 8, 190).add(padding ?? EdgeInsets.zero).add(widthPadding),
        child: child,
      ),
      desktopWidget: SingleChildScrollView(
        scrollDirection: scrollDirection,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20).add(padding ?? EdgeInsets.zero).add(widthPadding),
        child: child,
      ),
    );
  }
}
