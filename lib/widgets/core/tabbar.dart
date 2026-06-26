import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class MiruTabBar extends StatelessWidget {
  final TabController controller;
  final List<Widget> tabs;
  final bool isScrollable;
  const MiruTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = context.theme.tabsStyle;
    return DecoratedBox(
      decoration: style.decoration,
      child: TabBar(
        tabs: tabs,
        controller: controller,
        isScrollable: isScrollable,
        tabAlignment: isScrollable ? TabAlignment.start : null,
        padding: style.padding,
        indicator: style.indicatorDecoration,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        dividerHeight: 0,
        splashFactory: NoSplash.splashFactory,
        labelColor: context.theme.colors.foreground,
        unselectedLabelColor: context.theme.colors.mutedForeground,
        labelStyle: context.theme.typography.body.sm.copyWith(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: context.theme.typography.body.sm,
      ),
    );
  }
}
