import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_dialog.dart';
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';
import 'package:miru_alpha/provider/search/current_single_extension.dart';
import 'package:miru_alpha/utils/setting_dir_index.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/features/search/widget/search_grid_loading.dart';
import 'package:miru_alpha/ui/features/search/widget/search_grid_view.dart';

/// Single-extension search results.
///
/// Searching is performed by the app-wide global search bar (the window-edge
/// [SearchTrigger] -> [SearchOverlayPopup]); this page intentionally has NO
/// search input of its own so a page never carries two search functions. Only
/// a filter button (not a search function) is offered for extension-specific
/// filtering.
class SearchPageSingleView extends HookConsumerWidget {
  const SearchPageSingleView({super.key, this.query, required this.meta});
  final String? query;
  final ExtensionMeta meta;

  @override
  Widget build(context, ref) {
    final showPageNumber = MiruSettings.getSettingSync<bool>(
      SettingKey.showPageNumber,
    );
    final scrollController = useScrollController();

    useEffect(() {
      Future.microtask(() {
        ref
            .read(searchPageSingleProviderProvider.notifier)
            .setPkg(meta.packageName);
        ref
            .read(searchPageSingleProviderProvider.notifier)
            .fetchInitialFilters();
        // Carry the global query into this extension's search so the user keeps
        // the context of what they were looking for.
        final incoming = query;
        if (incoming != null && incoming.isNotEmpty) {
          ref
              .read(searchPageSingleProviderProvider.notifier)
              .setQuery(incoming);
        }
      });
      // Entering the extension's latest page marks it as recently visited.
      MiruSettings.addRecentExtension(meta.packageName);
      return null;
    }, [meta.packageName]);

    // Publish this extension to the app-wide global search bar so it can show
    // the extension name and switch into single-extension (filter) mode while
    // this page is the active route. The mutation is deferred to a microtask
    // to avoid modifying a provider during the build phase.
    useEffect(() {
      final notifier = ref.read(currentSingleExtensionProvider.notifier);
      Future.microtask(() => notifier.setExtension(meta));
      return () => Future.microtask(() => notifier.setExtension(null));
    }, [meta.packageName]);

    return MiruScaffold.mobile(
      sliverHeaders: [
        SimpleSliverHeaderDelegate(
          maxExtent: 50,
          child: Padding(
            padding: EdgeInsetsGeometry.only(bottom: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 12.0,
                      top: 4,
                      left: 10,
                    ),
                    child: Icon(
                      FLucideIcons.chevronLeft,
                      size: 28,
                      color: context.theme.colors.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: showPageNumber ? 20 : 22,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (MiruSettings.getSettingSync(
                        SettingKey.showPageNumber,
                      ))
                        Consumer(
                          builder: (context, ref, _) {
                            final page = ref.watch(
                              searchPageSingleProviderProvider.select(
                                (v) => v.page,
                              ),
                            );
                            return Text(
                              'page: ${page.toString()}',
                              style: const TextStyle(fontSize: 13),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                // Filter button only (not a search field) — extension-specific
                // filtering without adding a second search function to the page.
                FButton.icon(
                  variant: FButtonVariant.secondary,
                  onPress: () => _openFilterDialog(context, ref),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(FLucideIcons.listFilter),
                      if (ref.watch(
                        searchPageSingleProviderProvider.select(
                          (v) => v.selected.values.any((e) => e.isNotEmpty),
                        ),
                      ))
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: context.theme.colors.primary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 8,
                              minHeight: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      body: LayoutBuilder(
        builder: (context, cons) {
          final state = ref.watch(searchPageSingleProviderProvider);
          final snapshot = ref.watch(
            fetchExtensionSearchLatestProvider.call(
              meta.packageName,
              1,
              query: state.query,
              filter: state.appliedFilter,
            ),
          );

          return snapshot.when(
            data: (data) => SearchGridView(
              meta: meta,
              scrollController: scrollController,
              cons: cons,
              res: data,
            ),
            error: (err, stack) => ErrorDisplay.grpc(err: err, stack: stack),
            loading: () =>
                SearchGridLoadingWidget(scrollController: scrollController),
          );
        },
      ),
    );
  }

  /// Opens the per-extension filter dialog and applies the selection.
  ///
  /// The current selection is snapshotted first so that dismissing the dialog
  /// (or cancelling it) restores the previous choices instead of committing the
  /// in-progress edits. On confirmation the new selection stays; a refetch is
  /// triggered by the caller via [ref.invalidate].
  Future<void> _openFilterDialog(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(searchPageSingleProviderProvider.notifier);
    final initialSelected = Map<String, List<String>>.from(
      ref
          .read(searchPageSingleProviderProvider)
          .selected
          .map((k, v) => MapEntry(k, [...v])),
    );
    final confirm = await showMiruDialog<bool>(
      context: context,
      builder: (context, style, animation) => FTheme(
        data: context.theme,
        child: SearchFilterDialog(
          initialSelected: initialSelected,
          style: style,
          animation: animation,
        ),
      ),
    );
    if (confirm != true) notifier.setSelected(initialSelected);
  }
}
