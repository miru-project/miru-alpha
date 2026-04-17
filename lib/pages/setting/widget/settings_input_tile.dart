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
    this.hintText,
    this.onTap,
    this.icon,
    this.description,
    this.defaultValue,
    this.isMobileLayout = false,
  });
  final String title;
  final String? subtitle;
  final String initialValue;
  final String? hintText;
  final String? description;
  final String? defaultValue;
  final void Function(String) onChanged;
  final void Function()? onTap;
  final IconData? icon;
  final bool isMobileLayout;

  @override
  Widget build(BuildContext context) {
    if (isMobileLayout) {
      return FTile(
        title: Text(title.i18n),
        subtitle: subtitle == null ? null : Text(subtitle!.i18n),
        details: Icon(
          FIcons.chevronsLeftRightEllipsis,
          color: context.theme.colors.mutedForeground,
        ),
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
              title: Text(title.i18n),
              body: Form(
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    if (description != null)
                      Padding(
                        padding: .only(bottom: 10),
                        child: Text(description!.i18n),
                      ),
                    FTextField(
                      hint: hintText?.i18n,
                      control: FTextFieldControl.managed(
                        initial: TextEditingValue(text: initialValue),
                        onChange: (value) => onChanged(value.text),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                FButton(
                  size: .sm,
                  child: Text('confirm'.i18n),
                  onPress: () => Navigator.of(context).pop(),
                ),
                if (defaultValue == null)
                  FButton(
                    size: .sm,
                    variant: .outline,
                    child: Text('cancel'.i18n),
                    onPress: () => Navigator.of(context).pop(),
                  )
                else
                  FButton(
                    size: .sm,
                    variant: .destructive,
                    child: Text('reset'.i18n),
                    onPress: () {
                      onChanged(defaultValue!);
                      Navigator.of(context).pop();
                    },
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
