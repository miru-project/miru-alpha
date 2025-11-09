import 'package:flutter/material.dart';
import 'package:miru_app_new/widgets/grid_view/index.dart';

class SearchGridLoadingWidget extends StatelessWidget {
  final ScrollController scrollController;
  const SearchGridLoadingWidget({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cons) => MiruGridView(
        scrollController: scrollController,
        mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cons.maxWidth ~/ 110,
          childAspectRatio: 0.6,
        ),
        desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cons.maxWidth ~/ 180,
          childAspectRatio: 0.6,
        ),
        itemBuilder: (context, index) => const MiruGridTileLoadingBox(),
        itemCount: 20,
      ),
    );
  }
}

class MobileSeachGridLoadingWidget extends StatelessWidget {
  final ScrollController scrollController;
  const MobileSeachGridLoadingWidget({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cons) => MiruGridView(
        scrollController: scrollController,
        mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
        ),
        desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cons.maxWidth ~/ 180,
          childAspectRatio: 0.6,
        ),
        itemBuilder: (context, index) => const MobileTileLoadingBox(),
        itemCount: 20,
      ),
    );
  }
}
