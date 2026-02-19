import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/pages/setting/widget/setting_base_tile.dart';

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
              title: const Text('TMDB Api keys (WIP)'),
              body: Form(child: FTextField(hint: 'Enter your TMDB Api keys')),
              actions: [
                FButton(
                  size: .sm,
                  child: const Text('Confirm'),
                  onPress: () => Navigator.of(context).pop(),
                ),
                FButton(
                  size: .sm,
                  variant: .outline,
                  child: const Text('Cancel'),
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
