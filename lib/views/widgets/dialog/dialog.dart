import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:flutter/material.dart';

showPaltformDialog(BuildContext context,
    {required Widget mobile, required Widget desktop}) {
  return showMoonModal(
      context: context,
      builder: (context) {
        if (GetPlatform.isMobile) {
          return mobile;
        }
        return desktop;
      });
}

class PlatformDialogButton extends StatelessWidget {
  final BuildContext context;
  final Widget mobile;
  final Widget desktop;
  final Text title;
  final Widget? leading;
  final Widget? label;
  final Widget? trailing;
  const PlatformDialogButton(
      {super.key,
      required this.context,
      required this.mobile,
      required this.desktop,
      required this.title,
      this.leading,
      this.label,
      this.trailing});
  @override
  Widget build(BuildContext context) {
    return MoonButton(
      onTap: () {
        showPaltformDialog(context, mobile: mobile, desktop: desktop);
      },
      leading: leading,
      label: label,
      trailing: trailing,
    );
  }
}
