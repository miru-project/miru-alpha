import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/widgets/core/outter_card.dart';

class SettingGroup extends StatelessWidget {
  const SettingGroup({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
    this.isMobileLayout = false,
  });
  final List<FTileMixin> children;
  final String title;
  final Widget? trailing;
  final bool isMobileLayout;

  @override
  Widget build(BuildContext context) {
    if (isMobileLayout) {
      return FTileGroup(label: Text(title), children: children);
    }
    return OutterCard(
      title: title,
      trailing: trailing,
      child: Column(children: _withDividers(children)),
    );
  }

  List<Widget> _withDividers(List<FTileMixin> tiles) {
    final result = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      result.add(tiles[i]);
      if (i != tiles.length - 1) {
        result.add(const FDivider());
      }
    }
    return result;
  }
}
