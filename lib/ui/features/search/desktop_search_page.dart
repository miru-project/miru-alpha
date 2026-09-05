import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/ui/features/search/global_search.dart';
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/storage_index.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
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
    // The mutation is deferred to a microtask: flutter_hooks runs effects
    // right after the rebuild (still inside the build phase), and modifying
    // a provider there throws "Tried to modify a provider while the widget
    // tree was building".
    useEffect(() {
      final query = search;
      if (query != null && query.isNotEmpty) {
        Future.microtask(
          () => ref.read(searchPageProvider.notifier).setQuery(query),
        );
      }
      return null;
    }, [search]);

    final searchQuery = ref.watch(searchPageProvider.select((e) => e.query));

    return Stack(
      children: [
        if (searchQuery.isNotEmpty)
          Column(
            children: [
              _GlobalSearchHeader(query: searchQuery),
              Expanded(
                child: GlobalSearch(searchQuery: searchQuery, isMobile: false),
              ),
            ],
          )
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

/// Header above the global-search results: shows the active keyword, a
/// "Search results of …" summary line with the aggregated first-page result
/// count (shown once every extension in scope has responded), and a Cancel
/// button. Cancel clears the query, which unmounts [GlobalSearch] and
/// disposes every per-extension autoDispose search provider (in-flight
/// requests are dropped), aborting the global search.
class _GlobalSearchHeader extends ConsumerWidget {
  const _GlobalSearchHeader({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scopePackages = ref.watch(
      searchPageProvider.select((e) => e.searchScopePackages),
    );
    // Watching the exact same family instances [GlobalSearch] watches (same
    // package, page and query arguments) shares provider state, so counting
    // here never triggers extra network requests. The count stays hidden
    // while any response is still in flight so partial numbers are not
    // presented as final.
    var totalCount = 0;
    var isLoading = false;
    for (final pkg in scopePackages) {
      final snapshot = ref.watch(
        fetchExtensionSearchLatestProvider.call(pkg, 1, query: query),
      );
      isLoading = isLoading || snapshot.isLoading;
      totalCount += snapshot.value?.length ?? 0;
    }
    var summary = 'extension.search_results_of'.i18n.replaceAll(
      '{query}',
      query,
    );
    if (!isLoading) {
      summary +=
          ' · ${'extension.results_count'.i18n.replaceAll('{count}', totalCount.toString())}';
    }

    // Match GlobalSearch's horizontal padding so the header aligns with the
    // result rows.
    return Padding(
      padding: const EdgeInsets.fromLTRB(70, 16, 70, 4),
      child: Row(
        children: [
          Icon(
            FLucideIcons.search,
            size: 18,
            color: context.theme.colors.mutedForeground,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Text(
                  query,
                  style: context.theme.typography.body.lg.copyWith(
                    fontWeight: .bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  summary,
                  style: context.theme.typography.body.xs.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FButton(
            variant: .outline,
            onPress: () {
              ref.read(searchPageProvider.notifier).setQuery('');
            },
            prefix: Icon(FLucideIcons.x),
            child: Text('common.cancel'.i18n),
          ),
        ],
      ),
    );
  }
}
