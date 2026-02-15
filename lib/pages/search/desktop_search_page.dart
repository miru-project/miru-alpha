import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/pages/search/global_search.dart';
import 'package:miru_app_new/pages/webview/desktop_webview.dart';
import 'package:miru_app_new/provider/search_page_provider.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/utils/store/storage_index.dart';
import 'package:miru_app_new/widgets/core/inner_card.dart';
import 'package:miru_app_new/widgets/core/search_filter_card.dart';
import 'package:miru_app_new/pages/search/widget/desktop_search_list_tile.dart';

class DesktopSearchPage extends HookConsumerWidget {
  const DesktopSearchPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metaData = ref.watch(searchPageProvider.select((e) => e.metaData));
    final existedPinnedExtensions = ref.watch(
      searchPageProvider.select((e) => e.existedPinnedExtensions),
    );
    // query for the global search
    final searchQuery = useState("");

    return Stack(
      children: [
        if (searchQuery.value.isNotEmpty)
          GlobalSearch(searchQuery: searchQuery.value, isMobile: false)
        else
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 150)),
              if (existedPinnedExtensions.isNotEmpty)
                SliverToBoxAdapter(
                  child: InnerCard(
                    title: 'Pinned',
                    subtitle: 'Pinned extensions ',
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final pinnedPkg = existedPinnedExtensions.elementAt(
                          index,
                        );
                        final ext = metaData
                            .where((ext) => ext.packageName == pinnedPkg)
                            .first;
                        logger.info('Pinned ext: ${ext.packageName}');
                        return DesktopSearchListTile(
                          ext: ext,
                          trailing: FButton.icon(
                            selected: true,
                            onPress: () {
                              final newSet = {...existedPinnedExtensions};
                              if (newSet.contains(ext.packageName)) {
                                newSet.remove(ext.packageName);
                              } else {
                                newSet.add(ext.packageName);
                              }
                              ref
                                  .read(searchPageProvider.notifier)
                                  .setExistedPinnedExtensions(newSet);
                              MiruSettings.setSettingSync(
                                SettingKey.pinnedExtension,
                                newSet.toString(),
                              );
                            },
                            child:
                                existedPinnedExtensions.contains(
                                  ext.packageName,
                                )
                                ? Icon(FIcons.pinOff)
                                : Icon(FIcons.pin),
                          ),
                        );
                      },
                      itemCount: existedPinnedExtensions.length,
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
                      return DesktopSearchListTile(
                        ext: ext,
                        trailing: Row(
                          children: [
                            FButton.icon(
                              variant: .ghost,
                              onPress: () => openWebview(ext),
                              child: Icon(FIcons.globe),
                            ),
                            SizedBox(width: 8),
                            FButton.icon(
                              selected: true,
                              onPress: () {
                                final newSet = {...existedPinnedExtensions};
                                if (newSet.contains(ext.packageName)) {
                                  newSet.remove(ext.packageName);
                                } else {
                                  newSet.add(ext.packageName);
                                }
                                ref
                                    .read(searchPageProvider.notifier)
                                    .setExistedPinnedExtensions(newSet);
                                MiruSettings.setSettingSync(
                                  SettingKey.pinnedExtension,
                                  newSet.toString(),
                                );
                              },
                              child:
                                  existedPinnedExtensions.contains(
                                    ext.packageName,
                                  )
                                  ? Icon(FIcons.pinOff)
                                  : Icon(FIcons.pin),
                            ),
                          ],
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
                    clearable: (value) => value.text.isNotEmpty,
                    onSubmit: (value) {
                      searchQuery.value = value;
                    },
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
