import 'package:flutter/material.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/pages/search/global_search.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/storage_index.dart';
import 'package:miru_alpha/widgets/core/inner_card.dart';
import 'package:miru_alpha/widgets/core/search_filter_card.dart';
import 'package:miru_alpha/pages/search/widget/desktop_search_list_tile.dart';

class DesktopSearchPage extends HookConsumerWidget {
  const DesktopSearchPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metaData = ref.watch(searchPageProvider).filteredMetaData;
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
                    title: 'extension.pinned',
                    subtitle: 'extension.pinned_extensions',
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final pinnedPkg = existedPinnedExtensions.elementAt(
                          index,
                        );
                        final ext = metaData
                            .where((ext) => ext.packageName == pinnedPkg)
                            .first;
                        return DesktopSearchListTile(
                          ext: ext,
                          trailing: Row(
                            children: [
                              FButton.icon(
                                variant: .ghost,
                                onPress: () {
                                  context.push(
                                    "/extensionSettings",
                                    extra: ExtensionSettingParam(
                                      pkg: ext.packageName,
                                      name: ext.name,
                                    ),
                                  );
                                },
                                child: Icon(FLucideIcons.cog),
                              ),
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
                                    ? Icon(FLucideIcons.pinOff)
                                    : Icon(FLucideIcons.pin),
                              ),
                            ],
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
                  title: 'extension',
                  subtitle: 'extension.extensions_installed_desc',
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
                              onPress: () {
                                context.push(
                                  "/extensionSettings",
                                  extra: ExtensionSettingParam(
                                    pkg: ext.packageName,
                                    name: ext.name,
                                  ),
                                );
                              },
                              child: Icon(FLucideIcons.settings),
                            ),
                            FButton.icon(
                              variant: .ghost,
                              onPress: () {
                                context.push(
                                  '/mobileWebView',
                                  extra: WebviewParam(
                                    meta: ext,
                                    url: ext.webSite,
                                  ),
                                );
                              },
                              child: Icon(FLucideIcons.globe),
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
                                  ? Icon(FLucideIcons.pinOff)
                                  : Icon(FLucideIcons.pin),
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
        SearchFilterCard(
          child: Row(
            children: [
              FTooltip(
                tipBuilder: (context, controller) =>
                    Text('extension.search_with_pinned_extensions'.i18n),
                child: HookBuilder(
                  builder: (context) {
                    final variant = useState(FButtonVariant.windows);
                    return FButton.icon(
                      variant: variant.value,
                      onPress: () {
                        variant.value = variant.value == FButtonVariant.windows
                            ? FButtonVariant.outline
                            : FButtonVariant.windows;
                      },
                      child: Icon(
                        variant.value == FButtonVariant.windows
                            ? FLucideIcons.pin
                            : FLucideIcons.pinOff,
                      ),
                    );
                  },
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
                      child: Icon(FLucideIcons.search),
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
                        Text('common.custom_context_menu'.i18n),
                        // Add more context menu items here
                      ],
                    );
                  },
                  hint: 'common.search_globally'.i18n,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
