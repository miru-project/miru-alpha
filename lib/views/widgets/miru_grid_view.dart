import 'package:flutter/material.dart';
import 'package:miru_app_new/views/widgets/index.dart';

class MiruGridView extends StatelessWidget {
  const MiruGridView({
    super.key,
    required this.mobileGridDelegate,
    required this.desktopGridDelegate,
    required this.itemBuilder,
    required this.itemCount,
  });

  final SliverGridDelegate mobileGridDelegate;
  final SliverGridDelegate desktopGridDelegate;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = MediaQuery.paddingOf(context);

    return PlatformWidget(
      mobileWidget: GridView.builder(
        padding: EdgeInsets.fromLTRB(8, (8 + padding.top), 8, 130),
        gridDelegate: mobileGridDelegate,
        itemBuilder: itemBuilder,
        itemCount: itemCount,
      ),
      desktopBuilder: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
        gridDelegate: desktopGridDelegate,
        itemBuilder: itemBuilder,
        itemCount: itemCount,
      ),
    );
  }
}
