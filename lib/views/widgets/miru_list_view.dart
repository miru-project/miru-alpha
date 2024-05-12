import 'package:flutter/material.dart';
import 'package:miru_app_new/views/widgets/index.dart';

class MiruListView extends StatelessWidget {
  const MiruListView({
    super.key,
    required this.children,
    this.padding,
    this.maxWidth,
  })  : assert(children != null, 'children must not be null'),
        itemBuilder = null,
        itemCount = 0;

  final IndexedWidgetBuilder? itemBuilder;
  final int itemCount;
  final List<Widget>? children;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  const MiruListView.builder({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.padding,
    this.maxWidth,
  }) : children = null;

  @override
  Widget build(BuildContext context) {
    EdgeInsets viewPadding = MediaQuery.paddingOf(context);

    EdgeInsets widthPadding = EdgeInsets.zero;

    // 计算需要添加的 padding
    if (maxWidth != null) {
      double widthPaddingValue =
          (MediaQuery.of(context).size.width - maxWidth!) / 2;
      if (widthPaddingValue > 0) {
        widthPadding = EdgeInsets.only(
          left: widthPaddingValue,
          right: widthPaddingValue,
        );
      } else {
        widthPadding = EdgeInsets.zero;
      }
    }

    if (itemBuilder == null) {
      return PlatformWidget(
        mobileWidget: ListView(
          padding: EdgeInsets.fromLTRB(8, (8 + viewPadding.top), 8, 130)
              .add(padding ?? EdgeInsets.zero)
              .add(widthPadding),
          children: children!,
        ),
        desktopBuilder: ListView(
          padding: const EdgeInsets.fromLTRB(20, 70, 20, 20)
              .add(padding ?? EdgeInsets.zero)
              .add(widthPadding),
          children: children!,
        ),
      );
    }

    return PlatformWidget(
      mobileWidget: ListView.builder(
        padding: EdgeInsets.fromLTRB(8, (8 + viewPadding.top), 8, 130)
            .add(padding ?? EdgeInsets.zero)
            .add(widthPadding),
        itemBuilder: itemBuilder!,
        itemCount: itemCount,
      ),
      desktopBuilder: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 70, 20, 20)
            .add(padding ?? EdgeInsets.zero)
            .add(widthPadding),
        itemBuilder: itemBuilder!,
        itemCount: itemCount,
      ),
    );
  }
}
