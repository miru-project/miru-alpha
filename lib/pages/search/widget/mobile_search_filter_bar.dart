import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';

class MobileSearchFilterBar extends ConsumerWidget {
  const MobileSearchFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchPageSingleProviderProvider);
    final notifier = ref.read(searchPageSingleProviderProvider.notifier);

    if (state.filter.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (final key in state.filterOrder) ...[
          () {
            final filter = state.filter[key];
            final selected = (state.selected[key] ?? []).cast<String>();
            final min = (filter?.min ?? 0) == 0 ? 1 : (filter?.min ?? 1);
            final max = (filter?.max ?? 0) == 0 ? 1 : (filter?.max ?? 1);
            final hasError = min > max;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    filter?.title ?? '',
                    style: context.theme.typography.sm.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Selection error: min ($min) > max ($max)',
                      style: TextStyle(
                        color: context.theme.colors.error,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option
                          in (filter?.options.entries.toList() ?? [])
                            ..sort((a, b) => a.key.compareTo(b.key)))
                        () {
                          final isSelected = selected.contains(option.key);
                          return FTappable(
                            onPress: () {
                              final next = isSelected
                                  ? selected
                                        .where((e) => e != option.key)
                                        .toList()
                                  : <String>[...selected, option.key];
                              notifier.setFilterValue(key, next);
                              notifier.commitFilters();
                            },
                            child: FBadge(
                              variant: isSelected ? .primary : .outline,
                              child: Text(option.value),
                            ),
                          );
                        }(),
                    ],
                  ),
                const SizedBox(height: 10),
              ],
            );
          }(),
        ],
      ],
    );
  }
}
