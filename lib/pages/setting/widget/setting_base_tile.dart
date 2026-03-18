import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

class SettingBaseTile extends StatelessWidget with FTileMixin {
  const SettingBaseTile({
    super.key,
    this.subtitle,
    required this.title,
    required this.child,
    this.isMobileLayout = false,
  });
  final String title;
  final String? subtitle;
  final Widget child;
  final bool isMobileLayout;
  @override
  Widget build(BuildContext context) {
    var name = '$title.name'.i18n;
    var information = '$title.information'.i18n;

    // Check if the keys actually returned translated values
    final hasProperI18n = name != '$title.name';
    final titleText = hasProperI18n ? name : title.i18n;
    final subtitleText = hasProperI18n && information != '$title.information'
        ? information
        : subtitle?.i18n;

    if (isMobileLayout) {
      return FTile(
        title: Text(titleText),
        subtitle: subtitleText == null ? null : Text(subtitleText),
        details: child,
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: FLabel(
              axis: Axis.vertical,
              description: subtitleText == null ? null : Text(subtitleText),
              child: Text(
                titleText,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            constraints: const BoxConstraints(maxWidth: 300),
            height: 40,
            child: child,
          ),
        ],
      ),
    );
  }
}
