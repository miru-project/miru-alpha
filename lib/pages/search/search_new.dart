import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
import 'package:miru_app_new/utils/router/router_util.dart';
import 'package:miru_app_new/utils/store/storage_index.dart';
import 'package:miru_app_new/widgets/amination/animated_box.dart';
import 'package:miru_app_new/widgets/core/inner_card.dart';
import 'package:miru_app_new/widgets/core/search_filter_card.dart';
import 'package:miru_app_new/widgets/image_widget.dart';

class _ExtensionListTile extends HookWidget {
  const _ExtensionListTile({required this.ext, this.trailing});
  final ExtensionMeta ext;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
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
                              },
                            ),
                            actions: [
                              FButton(
                                style: FButtonStyle.outline(),
                                onPress: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              FButton(
                                onPress: () {
                                  final notifier = ref.read(
                                    extensionPageProvider.notifier,
                                  );
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

class NewSearchPage extends HookConsumerWidget {
  const NewSearchPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metaData = ref.watch(extensionPageProvider).metaData;
    final pinnedExtensions = useState(
      MiruSettings.getSettingSync<Set<String>>(SettingKey.pinnedExtension),
    );
    // MiruStorage.getSettingSync
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 150)),
            if (pinnedExtensions.value.isNotEmpty)
              SliverToBoxAdapter(
                child: InnerCard(
                  title: 'Pinned',
                  subtitle: 'Pinned extensions ',
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final pinnedPkg = pinnedExtensions.value.elementAt(index);
                      final ext = metaData
                          .where((ext) => ext.packageName == pinnedPkg)
                          .first;
                      return _ExtensionListTile(
                        ext: ext,
                        trailing: FButton.icon(
                          selected: true,
                          onPress: () {
                            final newSet = {...pinnedExtensions.value};
                            if (newSet.contains(ext.packageName)) {
                              newSet.remove(ext.packageName);
                            } else {
                              newSet.add(ext.packageName);
                            }
                            pinnedExtensions.value = newSet;
                            MiruSettings.setSettingSync(
                              SettingKey.pinnedExtension,
                              newSet.toString(),
                            );
                          },
                          child:
                              pinnedExtensions.value.contains(ext.packageName)
                              ? Icon(FIcons.pinOff)
                              : Icon(FIcons.pin),
                        ),
                      );
                    },
                    itemCount: pinnedExtensions.value.length,
                  ),
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: InnerCard(
                title: 'Extension',
                subtitle: 'Extensions that already installed',
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final ext = metaData[index];
                    return _ExtensionListTile(
                      ext: ext,
                      trailing: FButton.icon(
                        selected: true,
                        onPress: () {
                          final newSet = {...pinnedExtensions.value};
                          if (newSet.contains(ext.packageName)) {
                            newSet.remove(ext.packageName);
                          } else {
                            newSet.add(ext.packageName);
                          }
                          pinnedExtensions.value = newSet;
                          MiruSettings.setSettingSync(
                            SettingKey.pinnedExtension,
                            newSet.toString(),
                          );
                        },
                        child: pinnedExtensions.value.contains(ext.packageName)
                            ? Icon(FIcons.pinOff)
                            : Icon(FIcons.pin),
                      ),
                    );
                  },
                  itemCount: metaData.length,
                ),
              ),
            ),
          ],
        ),

        SizedBox(
          height: 75,
          child: SearchFilterCard(
            child: Row(
              children: [
                SizedBox(
                  width: 250,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('Pinned Only'),
                      ),
                      FSwitch(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('All'),
                      ),
                      FDivider(axis: Axis.vertical),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FTextField(
                    prefixBuilder: (context, style, states) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 4),
                        child: Icon(FIcons.search),
                      );
                    },
                    suffixBuilder: (context, style, states) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 8),
                        child: FBadge(child: Text('↵')),
                      );
                    },
                    contextMenuBuilder: (context, editableTextState) {
                      return Column(
                        children: [
                          Text('Custom Context Menu'),
                          // Add more context menu items here
                        ],
                      );
                    },
                    hint: 'Search globally (WIP)',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
