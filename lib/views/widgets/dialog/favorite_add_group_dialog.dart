import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:moon_design/moon_design.dart';
import 'package:go_router/go_router.dart';

class FavoriteAddGroupDialog extends HookWidget {
  const FavoriteAddGroupDialog({super.key, required this.onComplete});
  final void Function(String) onComplete;
  @override
  Widget build(BuildContext context) {
    final factor = DeviceUtil.isMobileLayout(context) ? 0.8 : .5;
    final width = DeviceUtil.getWidth(context);
    final height = DeviceUtil.getHeight(context);
    final textcontorller = useTextEditingController();
    return Material(
        color: Colors.transparent,
        child: MoonModal(
          decoration: BoxDecoration(
            color: MoonColors.dark.goku,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: DefaultTextStyle(
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontFamily: "HarmonyOS_Sans"),
              child: SizedBox(
                  width: width * factor,
                  height: DeviceUtil.device(
                      mobile: height * factor / 4,
                      desktop: height * factor / 3,
                      context: context),
                  child: (Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        const Text('Add Group', style: TextStyle(fontSize: 25)),
                        const SizedBox(height: 30),
                        MoonFormTextInput(
                          hintText: 'Group Name',
                          textInputSize: MoonTextInputSize.xl,
                          onTapOutside: (event) {
                            FocusScope.of(context).unfocus();
                          },
                          onEditingComplete: () {
                            onComplete(textcontorller.text);
                            context.pop();
                          },
                          trailing: MoonButton.icon(
                            icon: const Icon(
                                MoonIcons.generic_check_alternative_24_light),
                            onTap: () {
                              onComplete(textcontorller.text);
                              context.pop();
                            },
                          ),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "HarmonyOS_Sans"),
                          activeBorderColor: context.moonTheme
                              ?.segmentedControlTheme.colors.backgroundColor,
                          controller: textcontorller,
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      ]))))),
        ));
  }
}
