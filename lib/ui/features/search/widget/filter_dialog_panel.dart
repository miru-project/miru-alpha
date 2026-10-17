import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';
import 'package:miru_alpha/ui/features/search/extension_filter_view.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_select_controls.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_text_tile.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// The `Miruro Filters` dialog's scrollable body: a FLAT list of labelled
/// sections, one per extension filter, with no accordion and no pinning.
///
/// Layout follows the mock: every section is `[UPPERCASE label (+ count)] /
/// control`, sections are separated by 16px, and two dropdown-shaped selects
/// share one row when the measured columns leave `widestLabel + 32` of room
/// (`.agents/ui.md` §3's 2-column rule). It is the dialog's ONLY scroll owner
/// — the header and footer are siblings, outside the scrollable.
///
/// Commit model: the dialog STAGES. A tap, a text commit or Reset writes
/// `selected` only; the fetch happens once, when the dialog is left
/// (`Done`, the close button or the system back gesture) —
/// `beginFilterStaging()` / `applyFilters()`. Committing per edit fired one
/// `createFilter` request and one results refetch per chip tap. The desktop
/// overlay keeps its own commit-on-Apply footer; this panel is used by
/// [SearchFilterDialog] only.
class ExtensionFilterPanel extends ConsumerWidget {
  const ExtensionFilterPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchPageSingleProviderProvider);
    final notifier = ref.read(searchPageSingleProviderProvider.notifier);

    if (state.filterOrder.isEmpty) {
      return Text(
        'extension.no_filter'.i18n,
        style: context.theme.typography.body.sm.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      );
    }

    // Staged edit: mutate the draft only. One place, so no control forgets it.
    void apply(void Function(SearchPageSingleProvider n) mutate) =>
        mutate(notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final labelStyle = context.theme.typography.body.xs2;

        final sections = <_Section>[];
        for (final key in state.filterOrder) {
          final raw = state.filter[key];
          if (raw == null) continue;
          final sel = state.selected[key] ?? const <String>[];
          // Resolved once here and again inside FilterSelectField's own
          // LayoutBuilder — same inputs, so same verdict; the panel only needs
          // it for the pairing decision.
          final shape = raw.whichKind() == ExtensionFilter_Kind.select
              ? selectShape(raw.select, width, labelStyle)
              : FilterSelectShape.empty;

          final section = switch (raw.whichKind()) {
            ExtensionFilter_Kind.text => _Section(
              title: raw.text.title,
              control: FilterTextField(
                filter: raw.text,
                value: sel.isEmpty ? '' : sel.first,
                showLabel: false,
                onChanged: (value) => apply((n) => n.setTextFilter(key, value)),
              ),
            ),
            ExtensionFilter_Kind.select =>
              shape == FilterSelectShape.empty
                  ? null
                  : _Section(
                      title: raw.select.title,
                      // Only dropdowns may pair; segmented and switch rows take
                      // the full row (the mock never splits them).
                      widestLabel: shape == FilterSelectShape.dropdown
                          ? selectWidestLabel(raw.select, labelStyle)
                          : null,
                      control: FilterSelectField(
                        filter: raw.select,
                        selected: sel,
                        onChanged: (optionKey) => apply(
                          (n) => optionKey.isEmpty
                              ? n.clearFilterValue(key)
                              : n.setFilterValue(key, [optionKey]),
                        ),
                      ),
                    ),
            ExtensionFilter_Kind.multiSelect =>
              raw.multiSelect.min > raw.multiSelect.max
                  ? _Section(
                      title: raw.multiSelect.title,
                      control: Text(
                        'Selection error: min (${raw.multiSelect.min}) > '
                        'max (${raw.multiSelect.max})',
                        style: TextStyle(
                          color: context.theme.colors.error,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : _Section(
                      title: raw.multiSelect.title,
                      count: sel.isEmpty ? null : sel.length,
                      control: FilterMultiSelectField(
                        options: [
                          for (final e in raw.multiSelect.options.entries)
                            ExtensionFilterOptionEntry(e.key, e.value.label),
                        ]..sort((a, b) => a.key.compareTo(b.key)),
                        selected: sel,
                        onToggle: (optionKey) {
                          final next = sel.contains(optionKey)
                              ? sel.where((e) => e != optionKey).toList()
                              : <String>[...sel, optionKey];
                          apply((n) => n.setFilterValue(key, next));
                        },
                      ),
                    ),
            ExtensionFilter_Kind.range => _Section(
              title: raw.range.title,
              control: RangeFilterField(
                filter: raw.range,
                selected: sel,
                onChanged: (from, to) =>
                    apply((n) => n.setRangeFilter(key, from, to)),
              ),
            ),
            ExtensionFilter_Kind.notSet => null,
          };
          if (section != null) sections.add(section);
        }

        // Two consecutive dropdowns share a row while (width - 10) / 2 leaves
        // `widestLabel + 32` (value + 16px padding + chevron) per column.
        final rows = <Widget>[];
        for (var i = 0; i < sections.length; i++) {
          final section = sections[i];
          final next = i + 1 < sections.length ? sections[i + 1] : null;
          final widest = section.widestLabel;
          final nextWidest = next?.widestLabel;
          final pairable =
              widest != null &&
              nextWidest != null &&
              (width - 10) / 2 >= max(widest, nextWidest) + 32;
          if (pairable) {
            rows.add(
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Expanded(child: section),
                  Expanded(child: next!),
                ],
              ),
            );
            i++;
          } else {
            rows.add(section);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: rows,
        );
      },
    );
  }
}

/// One labelled filter block: uppercase header row (with the mock's optional
/// `N selected` counter) above the control.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.control,
    this.count,
    this.widestLabel,
  });

  final String title;
  final Widget control;

  /// Multi-select selection count, shown right of the header while set.
  final int? count;

  /// Measured widest option label when the control is dropdown-shaped — null
  /// for every other shape (they never pair).
  final double? widestLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: colors.mutedForeground,
                  ),
                ),
              ),
              if (count != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'search.selected_count'.i18n.fill({'count': '$count'}),
                    maxLines: 1,
                    style: context.theme.typography.body.xs2.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          control,
        ],
      ),
    );
  }
}

/// Two numeric inputs (From / To) backing a [RangeFilter]. Commits on submit.
///
/// Shared by the dialog panel and the desktop overlay's accordion body, so the
/// same control renders identically in both. `padding` exists because the
/// overlay insets the row inside its accordion while the panel already pads
/// its content.
class RangeFilterField extends StatefulWidget {
  const RangeFilterField({
    super.key,
    required this.filter,
    required this.selected,
    required this.onChanged,
    this.padding = EdgeInsets.zero,
  });

  final RangeFilter filter;
  final List<String> selected;
  final void Function(int from, int to) onChanged;
  final EdgeInsetsGeometry padding;

  @override
  State<RangeFilterField> createState() => _RangeFilterFieldState();
}

class _RangeFilterFieldState extends State<RangeFilterField> {
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
      padding: widget.padding,
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
