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
            builder: (context, style, animation) => SingleChildScrollView(
              child:
                  // FDialog.raw(builder: (context,style){
                  //            return  FTextField(
                  //         // style: context.theme.textFieldStyle.copyWith(
                  //         //   border: FWidgetStateMap(),
                  //         // ),
                  //         label: const Text('Username'),
                  //         hint: 'JaneDoe',
                  //         description: const Text('Please enter your username.'),
                  //         maxLines: 1,
                  //       )
                  // })
                  FDialog(
                    style: style.call,
                    animation: animation,
                    title: const Text('TMDB Api keys'),
                    body: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FTextField(
                          // style: context.theme.textFieldStyle.copyWith(
                          //   border: FWidgetStateMap(),
                          // ),
                          label: const Text('Username'),
                          hint: 'JaneDoe',
                          description: const Text(
                            'Please enter your username.',
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                    actions: [
                      FButton(
                        style: FButtonStyle.outline(),
                        onPress: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      FButton(
                        onPress: () => Navigator.of(context).pop(),
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
            ),
          );
        },
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
