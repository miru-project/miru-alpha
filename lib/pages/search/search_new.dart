import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/extension_page_provider.dart';
import 'package:miru_app_new/utils/storage_index.dart';
import 'package:miru_app_new/widgets/core/search_filter_card.dart';
import 'package:miru_app_new/widgets/core/setting_card.dart';

class NewSearchPage extends HookConsumerWidget {
  const NewSearchPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metaData = ref.read(extensionPageControllerProvider).metaData;
    final pinnedExtensions = MiruStorage.getSettingSync<List<String>>(
      SettingKey.pinnedExtension,
    );
    // MiruStorage.getSettingSync
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 100)),
            SliverToBoxAdapter(
              child: SettingCard(title: 'Pinned', child: Text('')),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Text(
                  'Extension',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                  ),
                ),
              ),
            ),
            SliverList.builder(
              itemBuilder: (context, index) {
                final ext = metaData[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: FCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(ext.name),
                    ),
                  ),
                );
              },
              itemCount: metaData.length,
            ),
          ],
        ),

        SizedBox(
          height: 100,
          child: SearchFilterCard(
            child: Row(
              children: [
                SizedBox(
                  width: 400,
                  child: FMultiSelect<String>.searchBuilder(
                    format: (s) => Text(s),
                    filter: (query) {
                      final pkg = metaData.map((ext) => ext.packageName);
                      return query.isEmpty
                          ? pkg
                          : pkg.where(
                            (ext) =>
                                ext.toLowerCase().contains(query.toLowerCase()),
                          );
                    },
                    contentBuilder: (context, query, value) {
                      return [
                        for (final ext in metaData)
                          FSelectItem(
                            title: Text(ext.name),
                            value: ext.packageName,
                          ),
                      ];
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FTextField(
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
