import 'package:flutter/material.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/widgets/index.dart';

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

  final SliverGridDelegate? mobileGridDelegate;
  final SliverGridDelegate? desktopGridDelegate;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final ScrollController? scrollController;
  final int paddingHeightOffest;

  const MiruGridView.desktop({
    super.key,
    required this.desktopGridDelegate,
    required this.itemBuilder,
    required this.itemCount,
    this.paddingHeightOffest = 0,
    this.scrollController,
  }) : mobileGridDelegate = null;

  const MiruGridView.mobile({
    super.key,
    required this.mobileGridDelegate,
    required this.itemBuilder,
    required this.itemCount,
    this.paddingHeightOffest = 0,
    this.scrollController,
  }) : desktopGridDelegate = null;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: DeviceUtil.device(
            mobile: EdgeInsets.fromLTRB(
              8,
              (8 + padding.top + paddingHeightOffest),
              8,
              190,
            ),
            desktop: EdgeInsets.fromLTRB(
              20,
              70.0 + paddingHeightOffest,
              20,
              20,
            ),
            context: context,
          ),
          sliver: MiruSliverGrid(
            mobileGridDelegate: mobileGridDelegate,
            desktopGridDelegate: desktopGridDelegate,
            itemBuilder: itemBuilder,
            itemCount: itemCount,
          ),
        ),
      ],
    );
  }
}

class MiruSliverGrid extends StatelessWidget {
  const MiruSliverGrid({
    super.key,
    required this.mobileGridDelegate,
    required this.desktopGridDelegate,
    required this.itemBuilder,
    required this.itemCount,
    this.paddingHeightOffest = 0,
  });

  final SliverGridDelegate? mobileGridDelegate;
  final SliverGridDelegate? desktopGridDelegate;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final int paddingHeightOffest;
  const MiruSliverGrid.desktop({
    super.key,
    required this.desktopGridDelegate,
    required this.itemBuilder,
    required this.itemCount,
    this.paddingHeightOffest = 0,
  }) : mobileGridDelegate = null;

  const MiruSliverGrid.mobile({
    super.key,
    required this.mobileGridDelegate,
    required this.itemBuilder,
    required this.itemCount,
    this.paddingHeightOffest = 0,
  }) : desktopGridDelegate = null;

  Widget _buildMobile(SliverGridDelegate delegate) {
    return SliverGrid.builder(
      gridDelegate: delegate,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
    );
  }

  Widget _buildDesktop(SliverGridDelegate delegate) {
    return SliverGrid.builder(
      gridDelegate: delegate,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (mobileGridDelegate != null && desktopGridDelegate != null) {
      return PlatformWidget(
        mobileWidget: _buildMobile(mobileGridDelegate!),
        desktopWidget: _buildDesktop(desktopGridDelegate!),
      );
    }

    if (mobileGridDelegate != null) {
      return _buildMobile(mobileGridDelegate!);
    }

    if (desktopGridDelegate != null) {
      return _buildDesktop(desktopGridDelegate!);
    }
    throw Exception(
      "mobileGridDelegate or desktopGridDelegate must be provided",
    );
  }
}
