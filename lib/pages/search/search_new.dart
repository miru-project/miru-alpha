import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/extension_page_provider.dart';
import 'package:miru_app_new/utils/storage_index.dart';
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
        // context.pushNamed();
      },
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
                      child:
                          ext.icon == null
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
    );
  }
}

class NewSearchPage extends HookConsumerWidget {
  const NewSearchPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metaData = ref.watch(extensionPageControllerProvider).metaData;
    final pinnedExtensions = useState(
      MiruStorage.getSettingSync<Set<String>>(SettingKey.pinnedExtension),
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
                      final ext =
                          metaData
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
                            MiruStorage.setSettingSync(
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
                          MiruStorage.setSettingSync(
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
                  // FMultiSelect<String>.searchBuilder(
                  //   hint: Text('Select extension'),
                  //   format: (s) => Text(s),
                  //   filter: (query) {
                  //     final pkg = metaData.map((ext) => ext.packageName);
                  //     return query.isEmpty
                  //         ? pkg
                  //         : pkg.where(
                  //           (ext) =>
                  //               ext.toLowerCase().contains(query.toLowerCase()),
                  //         );
                  //   },
                  //   contentBuilder: (context, query, value) {
                  //     return [
                  //       for (final ext in metaData)
                  //         FSelectItem(
                  //           title: Text(ext.name),
                  //           value: ext.packageName,
                  //         ),
                  //     ];
                  //   },
                  // ),
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
                    hint: 'Search globally',
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
