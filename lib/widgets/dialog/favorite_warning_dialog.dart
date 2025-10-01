import 'package:flutter/material.dart';
import 'package:forui/widgets/button.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app_new/utils/database_service.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:moon_design/moon_design.dart';

class FavoriteWarningDialog extends StatelessWidget {
  final ValueNotifier<List<int>> selectedToDelete;
  final ValueNotifier<List<FavoriateGroup>> group;
  final ValueNotifier<List<int>> selected;
  final ValueNotifier<List<int>> setLongPress;
  final ValueNotifier<List<int>> setSelected;
  const FavoriteWarningDialog({
    super.key,
    required this.selectedToDelete,
    required this.setLongPress,
    required this.setSelected,
    required this.selected,
    required this.group,
  });
  @override
  Widget build(BuildContext context) {
    final factor = DeviceUtil.isMobileLayout(context) ? 0.8 : .5;
    final width = DeviceUtil.getWidth(context);
    final height = DeviceUtil.getHeight(context);
    return MoonModal(
      decoration: BoxDecoration(
        color: MoonColors.dark.goku,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: SizedBox(
        width: width * factor + 20,
        height: DeviceUtil.device(
          mobile: height * factor / 3,
          desktop: height * factor / 2,
          context: context,
        ),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            // fontFamily: "HarmonyOS_Sans",
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('Delete Group', style: TextStyle(fontSize: 25)),
                const SizedBox(height: 60),
                const Text(
                  'Are you sure you want to delete these group?',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FButton(
                      // textColor:
                      //     context
                      //         .moonTheme
                      //         ?.segmentedControlTheme
                      //         .colors
                      //         .backgroundColor,
                      // buttonSize: MoonButtonSize.lg,
                      child: const Text('Cancel'),
                      onPress: () {
                        context.pop();
                      },
                    ),
                    MoonButton(
                      buttonSize: MoonButtonSize.lg,
                      label: const Text('Confirm'),
                      onTap: () {
                        final intersectingValues = selectedToDelete.value
                            .toSet()
                            .intersection(selected.value.toSet());

                        selected.value.removeWhere(
                          (element) => intersectingValues.contains(element),
                        );
                        setSelected.value = selected.value;
                        setLongPress.value = [];

                        DatabaseService.deleteFavoriteGroup(
                          selectedToDelete.value
                              .map((e) => group.value[e].name)
                              .toList(),
                        );
                        //shift the slected index
                        for (int element in selectedToDelete.value) {
                          for (int i = 0; i < setSelected.value.length; i++) {
                            if (setSelected.value[i] > element) {
                              setSelected.value[i] -= 1;
                            }
                          }
                        }

                        selectedToDelete.value = [];

                        context.pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
