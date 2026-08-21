import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/widget/miru_dialog.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/storage_index.dart';
import 'package:miru_alpha/ui/core/amination/animated_box.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:miru_alpha/ui/core/core/image_widget.dart';

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
            return MiruDialog(
              animation: animation,
              direction: Axis.horizontal,
              title: Text(
                'extension.uninstall_confirm'.fill({'name': ext.name}),
              ),
              body: FCheckbox(
                label: Text('extension.do_not_show_again'.i18n),

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
                  child: Text('common.cancel'.i18n),
                ),
                FButton(
                  onPress: () {
                    final notifier = ref.read(extensionPageProvider.notifier);
                    notifier.uninstallPackage(ext.packageName);
                    Navigator.of(context).pop();
                  },
                  child: Text('common.continue_text'.i18n),
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
      showSimpleToast("extension.uninstall_success".i18n);
      return;
    }
    showSimpleToast("${"extension.uninstall_failed".i18n}: \n  $res");
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
                prefix: const Icon(FLucideIcons.trash),
                title: Text('extension.uninstall'.i18n),
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
                prefix: const Icon(FLucideIcons.bolt),
                title: Text("extension.setting_wip".i18n),
                onPress: () {},
              ),
            ],
          ),
        ],
        builder: (context, controller, _) => GestureDetector(
          onSecondaryTap: () => controller.show(),
          onLongPress: () => controller.show(),
          behavior: HitTestBehavior.translucent,
          child: MiruCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Row(
                children: [
                  Row(
                    children: [
                      MiruCard(
                        child: SizedBox.square(
                          dimension: 40,
                          child: ext.icon == null
                              ? Icon(FLucideIcons.toyBrick)
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
