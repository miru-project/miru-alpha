import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/widgets/settings/setting_base_tile.dart';

class SettingsInputTile extends StatelessWidget with FTileMixin {
  const SettingsInputTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.initialValue,
    required this.onChanged,
    this.onTap,
    this.icon,
    this.isMobileLayout = false,
  });
  final String title;
  final String subtitle;
  final String initialValue;
  final void Function(String) onChanged;
  final void Function()? onTap;
  final IconData? icon;
  final bool isMobileLayout;

  @override
  Widget build(BuildContext context) {
    if (isMobileLayout) {
      return FTile(
        title: Text(title),
        subtitle: Text(subtitle),
        details: Text(initialValue),
      );
    }
    return SettingBaseTile(
      title: title,
      subtitle: subtitle,
      child: FTextField(onChange: onChanged, initialText: initialValue),
    );
  }
}

// class MobileSettingInputTile extends StatelessWidget with FTileMixin {
//   const MobileSettingInputTile({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.initialValue,
//     required this.onChanged,
//     this.onTap,
//     this.icon,
//   });
//   final String title;
//   final String subtitle;
//   final String initialValue;
//   final void Function(String) onChanged;
//   final void Function()? onTap;
//   final IconData? icon;

//   @override
//   Widget build(BuildContext context) {
//     return SettingBaseTile(
//       title: title,
//       subtitle: subtitle,
//       child: FTextField(onChange: onChanged, initialText: initialValue),
//     );
//   }
// }
