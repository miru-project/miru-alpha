import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';
import 'package:miru_alpha/widgets/core/search_filter_card.dart';
import './search_filter_dialog.dart';

class DesktopSearchSingleFilterBox extends HookConsumerWidget {
  const DesktopSearchSingleFilterBox({super.key, required this.meta});
  final ExtensionMeta meta;
  void refresh(WidgetRef ref) {
    ref.invalidate(fetchExtensionSearchLatestProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchPageSingleProviderProvider);
    final searchQuery = useState(state.query);
    final filters = ref.watch(
      searchPageSingleProviderProvider.select((v) => v.filter),
    );
    final selected = ref.watch(
      searchPageSingleProviderProvider.select((v) => v.selected),
    );
    final theme = context.theme;
    final filterSummary = state.filterSummary;

    return SizedBox(
      height: 75,
      child: SearchFilterCard(
        child: Row(
          children: [
            const SizedBox(width: 8),
            // Filter Button
            if (filters.isNotEmpty) ...[
              _buildFilterButton(context, ref, theme, selected),
              const SizedBox(width: 8),
            ],
            // Search Input Field
            Expanded(
              child: _buildSearchTextField(
                ref,
                state,
                searchQuery,
                filterSummary,
              ),
            ),
            const SizedBox(width: 8),
            // Refresh Button
            _buildRefreshButton(ref, state, searchQuery),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    WidgetRef ref,
    FThemeData theme,
    Map<String, List<String>> selected,
  ) {
    return FButton.icon(
      variant: .secondary,
      onPress: () async {
        final notifier = ref.read(searchPageSingleProviderProvider.notifier);
        final initialSelected = ref
            .read(searchPageSingleProviderProvider)
            .selected
            .map((k, v) => MapEntry(k, [...v]));

        final confirm = await showFDialog<bool>(
          context: context,
          routeStyle: FDialogRouteStyleDelta.delta(
            barrierFilter: () =>
                (animation) => ImageFilter.compose(
                  outer: ImageFilter.blur(
                    sigmaX: animation * 5,
                    sigmaY: animation * 5,
                  ),
                  inner: ColorFilter.mode(
                    theme.colors.barrier,
                    BlendMode.srcOver,
                  ),
                ),
          ),
          builder: (context, style, animation) => FTheme(
            data: theme,
            child: SearchFilterDialog(
              initialSelected: initialSelected,
              style: style,
              animation: animation,
            ),
          ),
        );

        if (confirm != true) {
          notifier.setSelected(initialSelected);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(FLucideIcons.listFilter),
          if (selected.values.any((e) => e.isNotEmpty))
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: context.theme.colors.primary,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchTextField(
    WidgetRef ref,
    SingleSearchPageState state,
    ValueNotifier<String> searchQuery,
    String filterSummary,
  ) {
    return FTextField(
      clearable: (value) => value.text.isNotEmpty,
      control: .managed(
        onChange: (value) {
          searchQuery.value = value.text;
        },
        initial: TextEditingValue(text: state.query),
      ),
      prefixBuilder: (context, style, states) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 12.0, right: 4),
              child: Icon(FLucideIcons.search),
            ),
            if (filterSummary.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FBadge(
                  variant: .secondary,
                  child: Text(
                    filterSummary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        );
      },
      hint: 'Search ',
      onSubmit: (value) {
        ref.read(searchPageSingleProviderProvider.notifier).setQuery(value);
      },
    );
  }

  Widget _buildRefreshButton(
    WidgetRef ref,
    SingleSearchPageState state,
    ValueNotifier<String> searchQuery,
  ) {
    return FButton.icon(
      variant: .secondary,
      onPress: () {
        ref.invalidate(
          fetchExtensionSearchLatestProvider.call(
            meta.packageName,
            1,
            query: searchQuery.value,
            filterJson: state.appliedFilterJson,
          ),
        );
        ref
            .read(searchPageSingleProviderProvider.notifier)
            .setQuery(searchQuery.value);
      },
      child: const Icon(FLucideIcons.refreshCcw),
    );
  }
}
