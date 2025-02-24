import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class SettingsInputTile extends StatelessWidget {
  const SettingsInputTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.initialValue,
    required this.onChanged,
    this.onTap,
    this.icon,
  });
  final String title;
  final String subtitle;
  final String initialValue;
  final void Function(String) onChanged;
  final void Function()? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return MoonMenuItem(
      onTap: onTap ?? () {},
      content: Text(subtitle),
      label: Text(title),
      leading: (icon == null)
          ? null
          : Icon(
              icon!,
              size: 20,
            ),
      trailing: Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: MoonFormTextInput(
            onChanged: onChanged,
            initialValue: initialValue,
          )),
    );
    // return Row(
    //   children: [
    //     Expanded(
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Text(title),
    //           Text(
    //             subtitle,
    //             style: Theme.of(context).textTheme.bodySmall,
    //           ),
    //         ],
    //       ),
    //     ),
    //     Container(
    //       constraints: const BoxConstraints(maxWidth: 200),
    //       child: CupertinoTextField(
    //         controller: TextEditingController(text: initialValue),
    //         onChanged: onChanged,
    //       ),
    //     ),
    //   ],
    // );
  }
}
