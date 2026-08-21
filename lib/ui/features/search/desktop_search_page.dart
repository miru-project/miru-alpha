import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/ui/features/search/global_search.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/storage_index.dart';
import 'package:miru_alpha/ui/core/core/inner_card.dart';
import 'package:miru_alpha/ui/features/search/widget/desktop_search_list_tile.dart';

class DesktopSearchPage extends HookConsumerWidget {
  const DesktopSearchPage({super.key, this.search});
  final String? search;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metaData = ref.watch(searchPageProvider).filteredMetaData;
    final existedPinnedExtensions = ref.watch(
      searchPageProvider.select((e) => e.existedPinnedExtensions),
    );

    // Seed the global-search query from a deep-link keyword (e.g. the
    // top-bar popup or /search?q=). Source of truth stays in the provider.
    useEffect(() {
      if (search != null && search!.isNotEmpty) {
        ref.read(searchPageProvider.notifier).setQuery(search!);
      }
      return null;
    }, [search]);

    final searchQuery = ref.watch(searchPageProvider.select((e) => e.query));

    return Stack(
      children: [
        if (searchQuery.isNotEmpty)
          GlobalSearch(searchQuery: searchQuery, isMobile: false)
        else
          CustomScrollView(
            slivers: [
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
                            .firstOrNull;
                        // Skip pinned packages that are no longer present in
                        // the metadata (e.g. uninstalled or not yet loaded) to
                        // avoid a "No element" crash.
                        if (ext == null) return const SizedBox.shrink();
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
      ],
    );
  }
}
