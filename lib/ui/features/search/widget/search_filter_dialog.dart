import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/widget/miru_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';
import 'package:miru_alpha/ui/features/search/extension_filter_view.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Reusable body that renders the current extension's filters as toggleable
/// chips. Shared by [SearchFilterDialog] and the single-extension mode of the
/// app-wide global search popup so the filter UI stays identical everywhere.
class ExtensionFilterBody extends ConsumerWidget {
  const ExtensionFilterBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        for (var i = 0; i < order.length; i++) ...[
          () {
            final raw = filters[order[i]];

            // Range filters render two numeric inputs instead of option chips.
            if (raw != null && raw.whichKind() == ExtensionFilter_Kind.range) {
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
                      raw.range.title,
                      style: context.theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _RangeFilterField(
                    filter: raw.range,
                    selected: selected[order[i]] ?? [],
                    onChanged: (from, to) =>
                        notifier.setRangeFilter(order[i], from, to),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }

            // Single-select renders as a segmented control with an "All" reset.
            if (raw != null && raw.whichKind() == ExtensionFilter_Kind.select) {
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
                      raw.select.title,
                      style: context.theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _SelectFilterField(
                    filter: raw.select,
                    selected: selected[order[i]] ?? [],
                    onChanged: (key) {
                      if (key.isEmpty) {
                        notifier.clearFilterValue(order[i]);
                      } else {
                        notifier.setFilterValue(order[i], [key]);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }

            final filter = raw == null ? null : ExtensionFilterView.from(raw);
            final min = filter?.isSingleSelect == true ? 1 : (filter?.min ?? 1);
            final max = filter?.isSingleSelect == true ? 1 : (filter?.max ?? 1);
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
                    style: context.theme.typography.body.sm.copyWith(
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
                        for (final option in [
                          ...?filter?.options,
                        ]..sort((a, b) => a.key.compareTo(b.key)))
                          () {
                            final filterKey = order[i];
                            final isSelected = (selected[filterKey] ?? [])
                                .contains(option.key);
                            return FTappable(
                              onPress: () {
                                final current = (selected[filterKey] ?? [])
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
                                child: Text(option.label),
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
              style: .delta(width: 1, padding: .add(.symmetric(horizontal: 3))),
            ),
        ],
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
        child: SingleChildScrollView(child: ExtensionFilterBody()),
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

/// Single-select filter rendered as a horizontal segmented control with an
/// "All" option that clears the selection.
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        spacing: 8,
        children: [
          _SegChip(
            label: 'extension.all'.i18n,
            selected: isAll,
            onTap: () => onChanged(''),
          ),
          for (final e in entries)
            _SegChip(
              label: e.value.label,
              selected: selected.contains(e.key),
              onTap: () => onChanged(e.key),
            ),
        ],
      ),
    );
  }
}

class _SegChip extends StatelessWidget {
  const _SegChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FTappable(
      onPress: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? context.theme.colors.primary
              : context.theme.colors.secondary,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: context.theme.typography.body.sm.copyWith(
            color: selected
                ? context.theme.colors.background
                : context.theme.colors.mutedForeground,
          ),
        ),
      ),
    );
  }
}
