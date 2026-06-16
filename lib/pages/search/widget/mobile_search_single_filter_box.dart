import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/provider/extension_provider.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

class MobileSearchSingleFilterBox extends HookConsumerWidget {
  const MobileSearchSingleFilterBox({
    super.key,
    required this.meta,
    this.sheetController,
  });
  final ExtensionMeta meta;
  final SheetController? sheetController;

  void refresh(WidgetRef ref, String query, String filterJson) {
    ref.invalidate(
      fetchExtensionSearchLatestProvider.call(
        meta.packageName,
        1,
        query: query,
        filterJson: filterJson,
      ),
    );
    ref.read(searchPageSingleProviderProvider.notifier).setQuery(query);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchPageSingleProviderProvider);
    final searchQuery = useState(state.query);
    final filters = state.filter;
    final selected = state.selected;
    final order = state.filterOrder;
    final filterSummary = state.filterSummary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FTextField(
          onTap: () {
            if (sheetController != null) {
              final current = sheetController!.value;
              if (current != null && (current.toInt() - 150).abs() < 2) {
                sheetController!.animateTo(
                  const ProportionalToViewportSheetOffset(.55),
                );
              }
            }
          },
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
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Padding(
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
                  ),
              ],
            );
          },
          hint: 'Search ',
          onSubmit: (value) {
            refresh(ref, value, state.appliedFilterJson);
          },
        ),
        if (filters.isNotEmpty) ...[
          if (selected.values.any((e) => e.isNotEmpty))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FTappable(
                    onPress: () {
                      final notifier = ref.read(
                        searchPageSingleProviderProvider.notifier,
                      );
                      notifier.commitFilters();
                      final updatedState = ref.read(
                        searchPageSingleProviderProvider,
                      );
                      refresh(
                        ref,
                        updatedState.query,
                        updatedState.appliedFilterJson,
                      );
                    },
                    child: Text(
                      'Sort',
                      style: TextStyle(
                        color: context.theme.colors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  FTappable(
                    onPress: () {
                      ref
                          .read(searchPageSingleProviderProvider.notifier)
                          .clearFiltersToDefault();
                    },
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: context.theme.colors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          for (final key in order) _buildFilterGroup(context, ref, state, key),
        ],
      ],
    );
  }

  Widget _buildFilterGroup(
    BuildContext context,
    WidgetRef ref,
    SingleSearchPageState state,
    String key,
  ) {
    final filter = state.filter[key];
    final selected = (state.selected[key] ?? []).cast<String>();
    if (filter == null) return const SizedBox.shrink();

    // Enforce selection logic
    final min = (filter.min == 0) ? 1 : filter.min;
    final max = (filter.max == 0) ? 1 : filter.max;
    final hasError = min > max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            filter.title,
            style: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.w600,
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ),
        if (hasError)
          Text(
            'Selection error: min ($min) > max ($max)',
            style: TextStyle(color: context.theme.colors.error, fontSize: 12),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option
                  in (filter.options.entries.toList())
                    ..sort((a, b) => a.key.compareTo(b.key)))
                () {
                  final isSelected = selected.contains(option.key);
                  return FTappable(
                    onPress: () {
                      final notifier = ref.read(
                        searchPageSingleProviderProvider.notifier,
                      );
                      final next = isSelected
                          ? selected.where((e) => e != option.key).toList()
                          : <String>[...selected, option.key];
                      notifier.setFilterValue(key, next);
                    },
                    child: FBadge(
                      variant: isSelected ? .primary : .outline,
                      child: Text(option.value),
                    ),
                  );
                }(),
            ],
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
