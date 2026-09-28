import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/widget/miru_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';
import 'package:miru_alpha/ui/features/search/extension_filter_view.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_chip.dart';
import 'package:miru_alpha/ui/features/search/widget/mobile_filter_slivers.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

export 'package:miru_alpha/ui/features/search/widget/filter_chip.dart';

/// Reusable body that renders the current extension's filters as toggleable
/// chips. Shared by [SearchFilterDialog] and the single-extension mode of the
/// app-wide global search popup so the filter UI stays identical everywhere.
///
/// Every category is wrapped in an [FAccordionItem]. Each header carries a pin
/// button that moves the category to the top of the scroll; at most
/// [kMaxPinnedFilters] stay pinned (FIFO eviction). A pinned item expands in
/// place at the top, pushing the remaining content downward.
class ExtensionFilterBody extends ConsumerStatefulWidget {
  const ExtensionFilterBody({super.key});

  @override
  ConsumerState<ExtensionFilterBody> createState() =>
      _ExtensionFilterBodyState();
}

class _ExtensionFilterBodyState extends ConsumerState<ExtensionFilterBody> {
  /// Filter keys pinned to the top, in pin order (oldest first).
  final List<String> _pinned = [];

  /// Filter keys currently expanded. `null` means "not yet seeded".
  Set<String>? _expanded;

  void _seedExpanded(List<String> order) {
    _expanded ??= order.toSet();
    _expanded!.removeWhere((k) => !order.contains(k));
  }

  void _togglePin(String key) {
    setState(() {
      if (_pinned.contains(key)) {
        _pinned.remove(key);
      } else {
        _pinned.add(key);
        while (_pinned.length > kMaxPinnedFilters) {
          _pinned.removeAt(0);
        }
      }
    });
  }

  void _onAccordionChange(List<String> displayOrder, int index, bool expanded) {
    setState(() {
      _expanded ??= displayOrder.toSet();
      if (expanded) {
        _expanded!.add(displayOrder[index]);
      } else {
        _expanded!.remove(displayOrder[index]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchPageSingleProviderProvider);
    final notifier = ref.read(searchPageSingleProviderProvider.notifier);
    final filters = state.filter;
    final selected = state.selected;
    final order = state.filterOrder;

    if (order.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'extension.no_filter'.i18n,
          style: context.theme.typography.body.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
      );
    }

    _pinned.removeWhere((k) => !order.contains(k));
    _seedExpanded(order);
    final displayOrder = [
      ..._pinned.where(order.contains),
      ...order.where((k) => !_pinned.contains(k)),
    ];

    Widget contentFor(String key) {
      final raw = filters[key];
      if (raw != null && raw.whichKind() == ExtensionFilter_Kind.range) {
        return _RangeFilterField(
          filter: raw.range,
          selected: selected[key] ?? [],
          onChanged: (from, to) => notifier.setRangeFilter(key, from, to),
        );
      }
      if (raw != null && raw.whichKind() == ExtensionFilter_Kind.select) {
        return _SelectFilterField(
          filter: raw.select,
          selected: selected[key] ?? [],
          onChanged: (optionKey) {
            if (optionKey.isEmpty) {
              notifier.clearFilterValue(key);
            } else {
              notifier.setFilterValue(key, [optionKey]);
            }
          },
        );
      }
      final filter = raw == null ? null : ExtensionFilterView.from(raw);
      final min = filter?.isSingleSelect == true ? 1 : (filter?.min ?? 1);
      final max = filter?.isSingleSelect == true ? 1 : (filter?.max ?? 1);
      if (min > max) {
        return Text(
          'Selection error: min ($min) > max ($max)',
          style: TextStyle(color: context.theme.colors.error, fontSize: 12),
        );
      }
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final option in [
            ...?filter?.options,
          ]..sort((a, b) => a.key.compareTo(b.key)))
            () {
              final isSelected = (selected[key] ?? []).contains(option.key);
              return FilterChip(
                label: option.label,
                selected: isSelected,
                onTap: () {
                  final current = (selected[key] ?? []).cast<String>();
                  final next = isSelected
                      ? current.where((e) => e != option.key).toList()
                      : <String>[...current, option.key];
                  notifier.setFilterValue(key, next);
                },
              );
            }(),
        ],
      );
    }

    String titleFor(String key) {
      final raw = filters[key];
      if (raw == null) return '';
      return switch (raw.whichKind()) {
        ExtensionFilter_Kind.range => raw.range.title,
        ExtensionFilter_Kind.select => raw.select.title,
        _ => ExtensionFilterView.from(raw).title,
      };
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        FAccordion(
          control: .lifted(
            expanded: (index) => _expanded!.contains(displayOrder[index]),
            onChange: (index, expanded) =>
                _onAccordionChange(displayOrder, index, expanded),
          ),
          children: [
            for (final key in displayOrder)
              FAccordionItem(
                key: ValueKey('filter-$key'),
                title: Row(
                  children: [
                    FButton.icon(
                      variant: .ghost,
                      onPress: () => _togglePin(key),
                      child: Icon(
                        _pinned.contains(key)
                            ? FLucideIcons.pinOff
                            : FLucideIcons.pin,
                        size: 16,
                        color: _pinned.contains(key)
                            ? context.theme.colors.primary
                            : null,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              titleFor(key),
                              overflow: TextOverflow.ellipsis,
                              style: context.theme.typography.body.sm.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if ((selected[key] ?? []).isNotEmpty) ...[
                            const SizedBox(width: 6),
                            FBadge(
                              child: Text(
                                '${(selected[key] ?? []).length}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  child: contentFor(key),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

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
    final selected = state.selected;

    return MiruDialog(
      style: style,
      animation: animation,
      direction: Axis.horizontal,
      title: const Text('Filters'),
      body: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          minWidth: (MediaQuery.of(context).size.width * 0.8).clamp(0.0, 500.0),
          maxWidth: 500,
        ),
        // Mobile sticky filter list: owns its scroll so pinned
        // SliverPersistentHeaders stay stuck at the top while scrolling.
        child: const MobileFilterSliverBody(autoCommit: false),
      ),
      actions: [
        FButton(
          variant: .outline,
          onPress: () {
            if (!selected.values.any((e) => e.isNotEmpty)) return;
            notifier.setSelected({});
            notifier.commitFilters();
            Navigator.of(context).pop(true);
          },
          child: const Text('Clear'),
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

/// Two numeric inputs (From / To) backing a [RangeFilter]. Commits on submit.
class _RangeFilterField extends StatefulWidget {
  const _RangeFilterField({
    required this.filter,
    required this.selected,
    required this.onChanged,
  });

  final RangeFilter filter;
  final List<String> selected;
  final void Function(int from, int to) onChanged;

  @override
  State<_RangeFilterField> createState() => _RangeFilterFieldState();
}

class _RangeFilterFieldState extends State<_RangeFilterField> {
  late final TextEditingController fromCtrl;
  late final TextEditingController toCtrl;

  @override
  void initState() {
    super.initState();
    fromCtrl = TextEditingController(
      text: widget.selected.isNotEmpty
          ? widget.selected[0]
          : widget.filter.defaultMin.toString(),
    );
    toCtrl = TextEditingController(
      text: widget.selected.length > 1
          ? widget.selected[1]
          : widget.filter.defaultMax.toString(),
    );
  }

  @override
  void dispose() {
    fromCtrl.dispose();
    toCtrl.dispose();
    super.dispose();
  }

  void _commit() => widget.onChanged(
    int.tryParse(fromCtrl.text) ?? widget.filter.min,
    int.tryParse(toCtrl.text) ?? widget.filter.max,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: FTextField(
              keyboardType: TextInputType.number,
              control: FTextFieldControl.managed(controller: fromCtrl),
              hint: widget.filter.min.toString(),
              onSubmit: (_) => _commit(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '-',
              style: context.theme.typography.body.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: FTextField(
              keyboardType: TextInputType.number,
              control: FTextFieldControl.managed(controller: toCtrl),
              hint: widget.filter.max.toString(),
              onSubmit: (_) => _commit(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single-select filter rendered as unified [FilterChip]s with an "All" reset.
class _SelectFilterField extends StatelessWidget {
  const _SelectFilterField({
    required this.filter,
    required this.selected,
    required this.onChanged,
  });

  final SelectFilter filter;
  final List<String> selected;
  final void Function(String key) onChanged; // '' means "All"

  @override
  Widget build(BuildContext context) {
    final entries = filter.options.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final isAll = selected.isEmpty;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: 'extension.all'.i18n,
          selected: isAll,
          onTap: () => onChanged(''),
        ),
        for (final e in entries)
          FilterChip(
            label: e.value.label,
            selected: selected.contains(e.key),
            onTap: () => onChanged(e.key),
          ),
      ],
    );
  }
}
