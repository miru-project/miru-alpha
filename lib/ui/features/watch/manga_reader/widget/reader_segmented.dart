import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_button.dart';

/// Compact horizontal single-selection strip.
///
/// FORUI ships no segmented control, and its closest relatives
/// ([FSelectTileGroup] / [FTileGroup]) are **vertical** shrink-wrapping
/// viewports — unusable for the joined pill row the reader HUD needs. This
/// widget therefore composes FORUI's own interaction primitive, [FTappable]
/// (which carries the `selected` variant, press bounce, focus and semantics) and
/// owns only the geometry.
///
/// Used in two shapes, both straight from the reference design:
/// * [expand] false — intrinsic-width pills for the reader HUD, sitting next to
///   the brightness/fit shortcuts.
/// * [expand] true — three equal columns for the settings sheet.
class ReaderSegmented<T> extends StatelessWidget {
  const ReaderSegmented({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.labelBuilder,
    this.iconBuilder,
    this.expand = false,
  });

  /// Currently selected value.
  final T value;

  /// Every selectable value, in display order.
  final List<T> options;

  /// Called with the newly selected value.
  final ValueChanged<T> onChanged;

  /// Per-option label. Always required so a raw enum name can never reach the
  /// screen when a key is missing.
  final String Function(T option) labelBuilder;

  /// Optional per-option leading icon (settings sheet only).
  final IconData Function(T option)? iconBuilder;

  /// Whether each option takes an equal share of the available width. True gives
  /// the strip the reference's `tabAlignment: .fill` behaviour — the labels sit in
  /// equal columns and centre in them — which is what the settings sheet wants.
  /// False keeps the pills intrinsic-width, for the inline HUD strip.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: .circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          // `max` so the strip fills its box when [expand] is set; the
          // `Expanded`/`Flexible` split below is what makes the columns equal.
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            for (final option in options) ...[
              // Equal shares, not loose ones: a loose `Flexible` takes only its
              // intrinsic width and leaves the rest of the row unallocated, so
              // the columns come out ragged and the selected thumb no longer
              // lines up with its label.
              if (expand)
                Expanded(child: _segment(context, option))
              else
                Flexible(child: _segment(context, option)),
              if (option != options.last) const SizedBox(width: 4),
            ],
          ],
        ),
      ),
    );
  }

  Widget _segment(BuildContext context, T option) {
    final colors = context.theme.colors;
    final selected = option == value;
    final label = ReaderLabel(
      labelBuilder(option),
      style: context.theme.typography.body.xs.copyWith(
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected ? colors.foreground : colors.mutedForeground,
      ),
    );
    final icon = iconBuilder?.call(option);
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        // `max` + centre is FORUI's `tabAlignment: .fill`: with equal columns the
        // label (and its icon) sit in the middle of its column rather than
        // hugging the leading edge, which is what made the sheet's tabs look
        // left-aligned.
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: .center,
        spacing: 4,
        children: [
          if (icon case final icon?)
            Icon(
              icon,
              size: 16,
              color: selected ? colors.foreground : colors.mutedForeground,
            ),
          Flexible(child: label),
        ],
      ),
    );

    return FTappable(
      selected: selected,
      selectable: true,
      onPress: () => onChanged(option),
      semanticsLabel: labelBuilder(option),
      child: DecoratedBox(
        // The selected pill is the *background* colour on a muted track, which is
        // exactly what FORUI's own `FTabs` draws for its indicator
        // (`FTabsStyle.inherit` -> `indicatorDecoration: colors.background`). It
        // keeps the thumb neutral, so the strip stays legible when the app's
        // primary is a saturated hue.
        decoration: BoxDecoration(
          color: selected ? colors.background : null,
          borderRadius: .circular(6),
          border: Border.all(
            color: selected ? colors.muted : Colors.transparent,
          ),
        ),
        child: content,
      ),
    );
  }
}
