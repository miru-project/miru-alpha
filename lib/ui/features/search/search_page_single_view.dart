import 'package:flutter/rendering.dart';
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
import 'package:miru_alpha/utils/core/i18n.dart';

/// Single-extension search results.
///
/// Desktop via window global bar. Mobile owns inline fancy search field that
/// hides on scroll-down (shrink to 0) and reappears on scroll-up, driven by
/// [MiruScaffold] + inner grid scroll direction.
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
    final singleState = ref.watch(searchPageSingleProviderProvider);
    final filterSummary = singleState.filterSummary;
    final searchController = useTextEditingController(text: singleState.query);
    final searchVisible = useState(true);

    // Keep controller in sync when provider query changes externally.
    useEffect(() {
      if (searchController.text != singleState.query) {
        searchController.value = TextEditingValue(
          text: singleState.query,
          selection: TextSelection.collapsed(offset: singleState.query.length),
        );
      }
      return null;
    }, [singleState.query]);

    // Clearable X -> propagate empty to provider.
    final controllerText = useValueListenable(searchController).text;
    useEffect(() {
      if (controllerText.isEmpty && singleState.query.isNotEmpty) {
        Future.microtask(
          () =>
              ref.read(searchPageSingleProviderProvider.notifier).setQuery(''),
        );
      }
      return null;
    }, [controllerText]);

    useEffect(() {
      Future.microtask(() {
        ref
            .read(searchPageSingleProviderProvider.notifier)
            .setPkg(meta.packageName);
        ref
            .read(searchPageSingleProviderProvider.notifier)
            .fetchInitialFilters();
        final incoming = query;
        if (incoming != null && incoming.isNotEmpty) {
          ref
              .read(searchPageSingleProviderProvider.notifier)
              .setQuery(incoming);
        }
      });
      MiruSettings.addRecentExtension(meta.packageName);
      return null;
    }, [meta.packageName]);

    useEffect(() {
      final notifier = ref.read(currentSingleExtensionProvider.notifier);
      Future.microtask(() => notifier.setExtension(meta));
      return () => Future.microtask(() => notifier.setExtension(null));
    }, [meta.packageName]);

    void submit(String value) {
      final trimmed = value.trim();
      ref.read(searchPageSingleProviderProvider.notifier).setQuery(trimmed);
      FocusScope.of(context).unfocus();
    }

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
      // Desktop keeps the window-edge global bar only: grid, no inline
      // search field, no hide-on-scroll. Mobile gets the collapsible bar.
      desktopBody: _buildGrid(scrollController),
      body: Column(
        children: [
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              child: searchVisible.value
                  ? Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: context.theme.colors.background,
                        border: Border(
                          bottom: BorderSide(
                            color: context.theme.colors.border.withAlpha(40),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: FTextField(
                          control: FTextFieldControl.managed(
                            controller: searchController,
                          ),
                          hint: 'common.search_by_keywords'.i18n,
                          clearable: (value) => value.text.isNotEmpty,
                          onSubmit: submit,
                          prefixBuilder: (context, style, states) => Padding(
                            padding: const EdgeInsets.only(left: 12, right: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FLucideIcons.search,
                                  size: 18,
                                  color: context.theme.colors.mutedForeground,
                                ),
                                if (filterSummary.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 120,
                                      ),
                                      child: FBadge(
                                        child: Text(
                                          filterSummary,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          Expanded(
            // Hide-on-scroll: drag up (reverse) collapses the search bar,
            // drag down (forward) brings it back. Declarative notification
            // instead of a controller listener so no scroll offset math or
            // effect lifecycle can silently break the toggle.
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.reverse) {
                  if (searchVisible.value) searchVisible.value = false;
                } else if (notification.direction == ScrollDirection.forward) {
                  if (!searchVisible.value) searchVisible.value = true;
                }
                return false;
              },
              child: _buildGrid(scrollController),
            ),
          ),
        ],
      ),
    );
  }

  /// Results grid shared by mobile body and desktop body. Desktop gets it
  /// bare (global bar owns search there); mobile wraps it with the
  /// collapsible search field above.
  Widget _buildGrid(ScrollController scrollController) {
    return LayoutBuilder(
      builder: (context, cons) {
        return Consumer(
          builder: (context, ref, _) {
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
        );
      },
    );
  }

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
