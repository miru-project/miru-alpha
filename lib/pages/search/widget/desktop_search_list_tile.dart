import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';
import 'package:miru_app_new/utils/store/storage_index.dart';
import 'package:miru_app_new/widgets/amination/animated_box.dart';
import 'package:miru_app_new/widgets/core/toast.dart';
import 'package:miru_app_new/widgets/core/image_widget.dart';

class DesktopSearchListTile extends HookConsumerWidget {
  const DesktopSearchListTile({super.key, required this.ext, this.trailing});
  final ExtensionMeta ext;
  final Widget? trailing;

  void showDeleteExtensionDialog(BuildContext context) {
    showFDialog(
      context: context,
      builder: (context, style, animation) {
        return HookConsumer(
          builder: (context, WidgetRef ref, _) {
            final checkboxVal = useState(false);
            return FDialog(
              animation: animation,
              direction: Axis.horizontal,
              title: Text('Uninstall ${ext.name}?'),
              body: FCheckbox(
                label: const Text(
                  'Do not show again  this dialog when try to uninstall',
                ),

                value: checkboxVal.value,
                onChange: (value) {
                  checkboxVal.value = value;
                  MiruSettings.setSettingSync(
                    SettingKey.showDeleteExtensionDialog,
                    value.toString(),
                  );
                },
              ),
              actions: [
                FButton(
                  variant: .outline,
                  onPress: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FButton(
                  onPress: () {
                    final notifier = ref.read(extensionPageProvider.notifier);
                    notifier.uninstallPackage(ext.packageName);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void deleteCallBack(WidgetRef ref) async {
    final notifier = ref.read(extensionPageProvider.notifier);
    final res = await notifier.uninstallPackage(ext.packageName);

    if (res != null) {
      showSimpleToast("Uninstall Success");
      return;
    }
    showSimpleToast("Install Failed: \n  $res");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedBox(
      onTap: () {
        context.push('/search/single', extra: SearchPageParam(meta: ext));
      },
      child: FPopoverMenu.tiles(
        menu: [
          FTileGroup(
            children: [
              FTile.raw(
                child: Text(
                  ext.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              FTile(
                prefix: const Icon(FIcons.trash),
                title: const Text('Uninstall'),
                onPress: () {
                  // final context = RouterUtil.rootNavigatorKey.currentContext;
                  // if (context == null) return;
                  // showFToast(context: context, title: Text("Test"));
                  if (MiruSettings.getSettingSync<bool>(
                    SettingKey.showDeleteExtensionDialog,
                  )) {
                    deleteCallBack(ref);
                    return;
                  }

                  showDeleteExtensionDialog(context);
                },
              ),
              FTile(
                prefix: const Icon(FIcons.bolt),
                title: const Text("Setting (WIP)"),
                onPress: () {},
              ),
            ],
          ),
        ],
        builder: (context, controller, _) => GestureDetector(
          onSecondaryTap: () => controller.show(),
          onLongPress: () => controller.show(),
          behavior: HitTestBehavior.translucent,
          child: FCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  Row(
                    children: [
                      FCard.raw(
                        child: SizedBox.square(
                          dimension: 40,
                          child: ext.icon == null
                              ? Icon(FIcons.toyBrick)
                              : ImageWidget(imageUrl: ext.icon!),
                        ),
                      ),
                      SizedBox(width: 20),
                      Text(ext.name),
                    ],
                  ),
                  if (trailing != null) ...[Spacer(), trailing!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
