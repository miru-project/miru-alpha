import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart';
import 'package:miru_alpha/ui/features/search/extension_filter_view.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_chip.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Fill of every control INSIDE the filter dialog: the text field, the dropdown
/// and the switch row.
///
/// One token on purpose. The three controls shipped three different fills -
/// the fields took forui's `colors.card`, the switch row `colors.background`
/// and the segmented track `colors.muted` - so inside one card they read as
/// "raised", "inset" and "a lighter slab" at the same time, and the segmented
/// row's selected thumb (also `colors.muted`) was lighter than the field next
/// to it. The reference draws every one of them `bg-zinc-950`, a single step
/// BELOW the `zinc-900` card, separated by `border-white/10` alone.
///
/// `colors.background` is that step: measured live, card `#171C1E`,
/// `background` `#0B0D0E`. Do not re-introduce `card`/`muted` here.
Color filterControlFill(FColors colors) => colors.background;

/// The border every control carries, matching the reference's
/// `border-white/10`.
Color filterControlBorder(FColors colors) => colors.border;

/// Style for forui fields ([FTextField], and [FSelect], whose field is one) so
/// a filter form's inputs match [filterControlFill] instead of the theme's
/// default `card` fill.
FTextFieldStyleDelta filterFieldStyle(FColors colors) =>
    FTextFieldStyleDelta.delta(
      color:
          FVariantsValueDelta<
            FTextFieldVariantConstraint,
            FTextFieldVariant,
            Color?,
            Delta
          >.delta([
            FVariantValueDeltaOperation.base(filterControlFill(colors)),
          ]),
    );

/// Widest rendered label width, in logical pixels.
///
/// The segmented-vs-dropdown decision depends on the real label widths, not on
/// a guess: the widest label sets the per-segment floor, so it is measured with
/// a [TextPainter] against the actual text style the control will use.
double _widestLabel(List<String> labels, TextStyle style) {
  var widest = 0.0;
  for (final label in labels) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    if (painter.width > widest) widest = painter.width;
    painter.dispose();
  }
  return widest;
}

/// True when `count` equal-share segments still fit inside [available].
///
/// This is the fit test from `.agents/ui.md` §3, run against measured widths:
/// `N × (widestLabel + 22) + 8 + 4(N-1) ≤ inner`, where 22 is the control's
/// horizontal padding (11 per side) and `8 + 4px gaps` is the track's inset.
/// Below the threshold every label would be squeezed narrower than it can
/// render, so the caller must switch shape instead of shrinking text.
bool segmentedFits({
  required int count,
  required double widestLabelWidth,
  required double available,
}) {
  if (count < 2) return false;
  final perSegment = widestLabelWidth + 22;
  final needed = count * perSegment + 8 + 4 * (count - 1);
  return needed <= available && available / count >= perSegment;
}

/// The control a `select` filter resolves to at a given width.
enum FilterSelectShape {
  /// No options — render nothing.
  empty,

  /// N == 2: a binary choice is a boolean in disguise — a switch row.
  toggle,

  /// N 3-4 that fits: the mock's equal-fill `Status` strip.
  segmented,

  /// N >= 5, or the segments do not fit: the mock's `Format` / `Sort By` row.
  dropdown,
}

/// Resolves [filter]'s shape at [available] width — the single source for both
/// rendering and layout decisions (the dialog panel reads it to decide when
/// two dropdowns may share a row).
///
/// [labelStyle] must be the style the control will actually render with, since
/// `typography.body.xs2` differs between desktop (12) and touch (10).
FilterSelectShape selectShape(
  SelectFilter filter,
  double available,
  TextStyle labelStyle,
) {
  final entries = filter.options.entries;
  final count = entries.length;
  if (count == 0) return FilterSelectShape.empty;
  // rules §2: N == 2 is a boolean, not a strip.
  if (count == 2) return FilterSelectShape.toggle;
  // rules §2: N >= 5 always the dropdown — equal shares collapse past ~4.
  if (count >= 5) return FilterSelectShape.dropdown;
  final widest = _widestLabel([
    for (final e in entries) e.value.label,
  ], labelStyle);
  return segmentedFits(
        count: count,
        widestLabelWidth: widest,
        available: available,
      )
      ? FilterSelectShape.segmented
      : FilterSelectShape.dropdown;
}

/// The widest rendered option label of [filter] under [labelStyle] — exported
/// for the dialog panel's 2-column pairing test, which must measure with the
/// same style the control renders with.
double selectWidestLabel(SelectFilter filter, TextStyle labelStyle) =>
    _widestLabel([
      for (final e in filter.options.entries) e.value.label,
    ], labelStyle);

/// A `select` filter rendered with the control its option count calls for.
///
/// Per `.agents/ui.md` §2 the shape is decided by N, not by taste — resolved
/// by [selectShape]:
/// * N ≤ 1 → nothing (not a disabled control)
/// * N == 2 → switch row (the mock's `Stream Flags` shape)
/// * N 3-4 → equal-fill segmented, **only if** [segmentedFits] passes
/// * N ≥ 5, or the segments do not fit → dropdown
///
/// The segmented shape is the mock's `Status` row (All / Airing / Completed /
/// Upcoming); the dropdown is its `Format` / `Sort By` row.
class FilterSelectField extends StatelessWidget {
  const FilterSelectField({
    super.key,
    required this.filter,
    required this.selected,
    required this.onChanged,
  });

  final SelectFilter filter;

  /// The selected option keys; empty means "no selection".
  final List<String> selected;

  /// Called with the chosen option key, or `''` for the reset option.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final entries = filter.options.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final shape = selectShape(
          filter,
          constraints.maxWidth,
          context.theme.typography.body.xs2,
        );
        return switch (shape) {
          FilterSelectShape.empty => const SizedBox.shrink(),
          FilterSelectShape.toggle => _Toggle(
            filter: filter,
            entries: entries,
            selected: selected,
            onChanged: onChanged,
          ),
          FilterSelectShape.segmented => _Segmented(
            entries: entries,
            selected: selected,
            onChanged: onChanged,
          ),
          FilterSelectShape.dropdown => _Dropdown(
            filter: filter,
            entries: entries,
            selected: selected,
            onChanged: onChanged,
          ),
        };
      },
    );
  }
}

/// N == 2 as a switch row in a bordered card — the mock's `Stream Flags` shape.
///
/// The section label above already carries the filter title, so the switch
/// shows only the two option labels as its description: reading `off / on`
/// next to a physical switch is unambiguous where a bare toggle would not be.
class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.filter,
    required this.entries,
    required this.selected,
    required this.onChanged,
  });

  final SelectFilter filter;
  final List<MapEntry<String, FilterOption>> entries;
  final List<String> selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    // OFF = the extension's declared default (the untouched filter state),
    // falling back to the first option; ON is the other one — picking it is
    // the explicit narrowing, so an untouched filter reads switch-OFF with
    // the description ordered `off / on`. An extension that defaults to an
    // ACTIVE value shows OFF=that value, which is still truthful: OFF means
    // "still at the default".
    final defaultKey = filter.default_2;
    final offEntry = entries.firstWhere(
      (e) => e.key == defaultKey,
      orElse: () => entries.first,
    );
    final onEntry = entries.firstWhere((e) => e.key != offEntry.key);
    final value = selected.contains(onEntry.key);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: filterControlFill(colors),
        borderRadius: .circular(12),
        border: Border.all(color: filterControlBorder(colors)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: FSwitch(
          semanticsLabel:
              '${filter.title}: ${value ? onEntry.value.label : offEntry.value.label}',
          value: value,
          onChange: (next) => onChanged(next ? onEntry.key : offEntry.key),
          description: Text(
            '${offEntry.value.label} / ${onEntry.value.label}',
            style: context.theme.typography.body.xs2.copyWith(
              color: colors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}

/// Equal-fill single-select strip: the mock's `Status` row.
///
/// Forui ships no segmented control (`reader_segmented.dart` documents why
/// `FSelectTileGroup` cannot stand in — it is a vertical shrink-wrapping list),
/// so this composes Forui's own interaction primitive, [FTappable], which
/// carries the press/focus/semantics behaviour, and owns only the geometry.
class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.entries,
    required this.selected,
    required this.onChanged,
  });

  final List<MapEntry<String, FilterOption>> entries;
  final List<String> selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final style = context.theme.typography.body.xs2;

    return DecoratedBox(
      decoration: BoxDecoration(
        // Track shares the one control fill; the SELECTED thumb is the lighter
        // step above it. Previously the track was `muted` and the thumb
        // `background` — the inverse of every other control here, which is why
        // the selected segment read as a hole punched in a lighter slab.
        color: filterControlFill(colors),
        borderRadius: .circular(8),
        border: Border.all(color: filterControlBorder(colors)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          // `max` + one `Expanded` per segment: equal shares, so the selected
          // thumb lines up with its label. A loose `Flexible` would take only
          // its intrinsic width and leave the row ragged.
          mainAxisSize: MainAxisSize.max,
          children: [
            for (final entry in entries) ...[
              Expanded(child: _segment(context, entry, colors, style)),
              if (entry != entries.last) const SizedBox(width: 4),
            ],
          ],
        ),
      ),
    );
  }

  Widget _segment(
    BuildContext context,
    MapEntry<String, FilterOption> entry,
    FColors colors,
    TextStyle style,
  ) {
    final isSelected = selected.contains(entry.key);
    return FTappable(
      selected: isSelected,
      selectable: true,
      onPress: () => onChanged(entry.key),
      semanticsLabel: entry.value.label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // Selected = the step ABOVE the shared control fill (the reference's
          // `bg-zinc-800` thumb on its `bg-zinc-950` track), with the border
          // colour, not a fill, as the separating line.
          color: isSelected ? colors.muted : null,
          borderRadius: .circular(6),
          border: Border.all(
            color: isSelected
                ? filterControlBorder(colors)
                : const Color(0x00000000),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: .center,
            children: [
              // Flexible + ellipsis: a translated label can outgrow its column
              // even when the fit test passed for the measured one.
              Flexible(
                child: Text(
                  entry.value.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: style.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? colors.foreground
                        : colors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Popover single-select: the mock's `Format` / `Sort By` row.
///
/// Forui native: [FSelect.rich] supplies the field, popover, keyboard handling
/// and semantics; this only feeds it the extension's options and labels the
/// current value.
class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.filter,
    required this.entries,
    required this.selected,
    required this.onChanged,
  });

  final SelectFilter filter;
  final List<MapEntry<String, FilterOption>> entries;
  final List<String> selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    // '' models "nothing selected" so the dropdown can offer a reset row
    // without an empty-string option key colliding with a real one.
    final value = selected.isEmpty ? '' : selected.first;

    return FSelect<String>.rich(
      key: ValueKey('select-${filter.title}-$value'),
      // No `label`: the section header above already carries the filter title
      // once (rules.md #23). Forui's default label duplicated it as lowercase
      // `sort-by` above the field.
      // Root overlay, not the default `.nearestOverlay`: inside the filter
      // dialog the nearest overlay lives under the dialog's clip, so the
      // popover bottom row rendered half-cut mid-glyph. A modal's popover
      // must escape the modal's own clip.
      contentOverlayLocation: .rootOverlay,
      // Field fill = the shared control fill, not forui's default `card`.
      style: FSelectStyleDelta.delta(
        fieldStyles:
            FVariantsDelta<
              FTextFieldSizeVariantConstraint,
              FTextFieldSizeVariant,
              FTextFieldStyle,
              FTextFieldStyleDelta
            >.delta([
              FVariantOperation<
                FTextFieldSizeVariantConstraint,
                FTextFieldSizeVariant,
                FTextFieldStyle,
                FTextFieldStyleDelta
              >.base(filterFieldStyle(context.theme.colors)),
            ]),
      ),
      control: .managed(
        initial: value,
        onChange: (next) => onChanged(next ?? ''),
      ),
      format: (key) => key.isEmpty
          ? 'common.all'.i18n
          : entries
                .firstWhere(
                  (e) => e.key == key,
                  orElse: () => MapEntry(key, FilterOption()..label = key),
                )
                .value
                .label,
      children: [
        FSelectItem(value: '', title: Text('common.all'.i18n)),
        for (final entry in entries)
          FSelectItem(value: entry.key, title: Text(entry.value.label)),
      ],
    );
  }
}

/// A `multi_select` filter: wrapping pills, toggled independently.
///
/// Chips are the only correct shape here — a dropdown cannot show which subset
/// of a range is active, so a bounded multi-select (`min`/`max`) must stay
/// visible as pills. The selection count is rendered by the caller's section
/// label row (the mock's `Genres & Tags` header), not here.
class FilterMultiSelectField extends StatelessWidget {
  const FilterMultiSelectField({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final List<ExtensionFilterOptionEntry> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          FilterChip(
            label: option.label,
            selected: selected.contains(option.key),
            onTap: () => onToggle(option.key),
          ),
      ],
    );
  }
}
