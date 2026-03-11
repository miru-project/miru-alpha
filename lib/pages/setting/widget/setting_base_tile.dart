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
    if (isMobileLayout) {
      return FTile(
        title: Text(title.i18n),
        subtitle: (subtitle == null) ? null : Text(subtitle!.i18n),
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
              description: subtitle == null ? null : Text(subtitle!.i18n),
              child: Text(
                title.i18n,
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
