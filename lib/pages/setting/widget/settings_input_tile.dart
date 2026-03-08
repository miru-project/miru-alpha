import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/pages/setting/widget/setting_base_tile.dart';

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
        title: Text(title.i18n),
        subtitle: Text(subtitle.i18n),
        details: Text(initialValue),
        onPress: () {
          showFDialog(
            context: context,
            routeStyle: .delta(
              barrierFilter: () =>
                  (animation) => ImageFilter.compose(
                    outer: ImageFilter.blur(
                      sigmaX: animation * 5,
                      sigmaY: animation * 5,
                    ),
                    inner: ColorFilter.mode(
                      context.theme.colors.barrier,
                      .srcOver,
                    ),
                  ),
            ),
            builder: (context, style, animation) => FDialog(
              style: style,
              animation: animation,
              title: Text('tmdb_api_key_wip'.i18n),
              body: Form(child: FTextField(hint: 'enter_tmdb_api_key'.i18n)),
              actions: [
                FButton(
                  size: .sm,
                  child: Text('confirm'.i18n),
                  onPress: () => Navigator.of(context).pop(),
                ),
                FButton(
                  size: .sm,
                  variant: .outline,
                  child: Text('cancel'.i18n),
                  onPress: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        },
      );
    }
    return SettingBaseTile(
      title: title,
      subtitle: subtitle,
      child: FTextField(
        control: FTextFieldControl.managed(
          initial: TextEditingValue(text: initialValue),
          onChange: (value) => onChanged(value.text),
        ),
      ),
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
