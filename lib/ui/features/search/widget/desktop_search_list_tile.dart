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
import 'package:miru_alpha/ui/features/search/widget/extension_load_status.dart';

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
    // Derive once: a failed extension has nothing to search, so the whole
    // tile is inert and the affordance is the error dialog (same behaviour
    // as the mobile card).
    final loadState = extensionLoadState(ext);
    final broken = loadState?.failed ?? false;

    return AnimatedBox(
      onTap: broken
          ? null
          : () {
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
              if (broken)
                FTile(
                  prefix: Icon(
                    FLucideIcons.circleAlert,
                    color: context.theme.colors.destructive,
                  ),
                  title: Text('extension.failed'.i18n),
                  onPress: () => showExtensionError(context, ext),
                )
              else
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
                  Expanded(
                    child: Row(
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      ext.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (ext.nsfw) ...[
                                    const SizedBox(width: 8),
                                    FBadge(
                                      variant: .destructive,
                                      child: Text('extension.nsfw'.i18n),
                                    ),
                                  ],
                                ],
                              ),
                              if (extensionLoadState(ext)
                                  case final state?) ...[
                                const SizedBox(height: 6),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      if (state.failed) ...[
                                        TextSpan(
                                          text: 'extension.failed'.i18n,
                                          style: context
                                              .theme
                                              .typography
                                              .body
                                              .xs
                                              .copyWith(
                                                color: context
                                                    .theme
                                                    .colors
                                                    .destructive,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const TextSpan(text: '  '),
                                      ],
                                      TextSpan(
                                        text: state.label,
                                        style: context.theme.typography.body.xs
                                            .copyWith(
                                              color: state.failed
                                                  ? context
                                                        .theme
                                                        .colors
                                                        .destructive
                                                  : context
                                                        .theme
                                                        .colors
                                                        .mutedForeground,
                                            ),
                                      ),
                                    ],
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
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
