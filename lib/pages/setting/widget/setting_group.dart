import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/widgets/core/outter_card.dart';

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
    final name = '$title.name'.i18n;
    final information = '$title.information'.i18n;

    // Check if the keys actually returned translated values or just the key string
    final hasProperI18n = name != '$title.name';
    final titleText = hasProperI18n ? name : title.i18n;
    final descriptionText = hasProperI18n && information != '$title.information'
        ? information
        : null;

    if (isMobileLayout) {
      return FTileGroup(
        label: Text(titleText),
        description: descriptionText != null ? Text(descriptionText) : null,
        children: children,
      );
    }
    return OutterCard(
      title: title, // OutterCard handles .i18n internally, but we might want to pass the refactored one
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
