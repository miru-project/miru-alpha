import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';

class SearchFilterDialog extends ConsumerWidget {
  const SearchFilterDialog({
    super.key,
    required this.initialSelected,
    required this.style,
    required this.animation,
  });

  final Map<String, List<String>> initialSelected;
  final FDialogStyle style;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchPageSingleProviderProvider);
    final notifier = ref.read(searchPageSingleProviderProvider.notifier);
    final filters = state.filter;
    final selected = state.selected;
    final order = state.filterOrder;

    return FDialog(
      style: style,
      animation: animation,
      direction: Axis.horizontal,
      title: const Text('Filters'),
      body: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          minWidth: MediaQuery.of(context).size.width * 0.8,
          maxWidth: 500,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              for (var i = 0; i < order.length; i++) ...[
                () {
                  final filter = filters[order[i]];
                  final min = (filter?.min ?? 0) == 0 ? 1 : (filter?.min ?? 1);
                  final max = (filter?.max ?? 0) == 0 ? 1 : (filter?.max ?? 1);
                  final hasError = min > max;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          bottom: 8.0,
                          top: 16.0,
                        ),
                        child: Text(
                          filter?.title ?? '',
                          style: context.theme.typography.sm.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (hasError)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          child: Text(
                            'Selection error: min ($min) > max ($max)',
                            style: TextStyle(
                              color: context.theme.colors.error,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final option
                                  in (filter?.options.entries.toList() ?? [])
                                    ..sort((a, b) => a.key.compareTo(b.key)))
                                () {
                                  final filterKey = order[i];
                                  final isSelected = (selected[filterKey] ?? [])
                                      .contains(option.key);
                                  return FTappable(
                                    onPress: () {
                                      final current =
                                          (selected[filterKey] ?? [])
                                              .cast<String>();
                                      final next = isSelected
                                          ? current
                                                .where((e) => e != option.key)
                                                .toList()
                                          : <String>[...current, option.key];
                                      notifier.setFilterValue(filterKey, next);
                                    },
                                    child: FBadge(
                                      variant: isSelected ? .primary : .outline,
                                      child: Text(option.value),
                                    ),
                                  );
                                }(),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  );
                }(),
                if (i < order.length - 1)
                  const FDivider(
                    style: .delta(
                      width: 1,
                      padding: .add(.symmetric(horizontal: 3)),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        FButton(
          variant: .outline,
          onPress: () {
            notifier.setSelected(initialSelected);
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        FButton(
          onPress: () {
            notifier.commitFilters();
            Navigator.of(context).pop(true);
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
