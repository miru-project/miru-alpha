import 'package:flutter/material.dart';
import 'package:miru_app_new/views/widgets/index.dart';

class MiruGridView extends StatelessWidget {
  const MiruGridView({
    super.key,
    required this.mobileGridDelegate,
    required this.desktopGridDelegate,
    required this.itemBuilder,
    required this.itemCount,
    this.paddingHeightOffest = 0,
    this.scrollController,
  });

  final SliverGridDelegate mobileGridDelegate;
  final SliverGridDelegate desktopGridDelegate;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final ScrollController? scrollController;
  final int paddingHeightOffest;
  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = MediaQuery.paddingOf(context);

    return PlatformWidget(
      mobileWidget: GridView.builder(
        padding: EdgeInsets.fromLTRB(8, (8 + padding.top + paddingHeightOffest), 8, 190),
        gridDelegate: mobileGridDelegate,
        itemBuilder: itemBuilder,
        itemCount: itemCount,
      ),
      desktopWidget: GridView.builder(
        padding: EdgeInsets.fromLTRB(20, 70.0 + paddingHeightOffest, 20, 20),
        gridDelegate: desktopGridDelegate,
        itemBuilder: itemBuilder,
        itemCount: itemCount,
      ),
    );
  }
}
