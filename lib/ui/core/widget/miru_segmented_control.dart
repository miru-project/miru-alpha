import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

/// One selectable entry of a [MiruSegmentedControl].
class MiruSegment<T> {
  const MiruSegment({required this.value, required this.label});

  final T value;
  final String label;
}

/// FORUI-style segmented control — the dashboard mock's media-type tablist.
///
/// FORUI ships no segmented control (its `FTabs` is an underline tab bar, a
/// different shape), so this composes forui's own primitives: an inset track
/// one step below the page (`colors.background` + border, radius
/// `style.borderRadius.sm`) holding equal segments that are plain
/// [FButton]s — `primary` when selected, `ghost` otherwise — keeping forui's
/// own radius and squircle shape. Segment height follows the HTML reference:
/// 32px segments inside a 42px track. The mock's flex-1 equal segments are
/// preserved on common phone widths; below the tracked minimum the strip
/// scrolls horizontally instead of squeezing labels.
class MiruSegmentedControl<T> extends StatelessWidget {
  const MiruSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelected,
    this.selectedVariant = FButtonVariant.primary,
    this.unselectedVariant = FButtonVariant.ghost,
    this.selectionMarkers = false,
    this.dimUnselectedText = false,
    this.trackColor,
  });

  final List<MiruSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onSelected;

  /// The active segment's variant. `primary` (default) is the dashboard
  /// mock's solid fill; `secondary` is a container fill — on a dark surface
  /// a near-white primary block reads as "raised, clickable" rather than
  /// "selected" (UX-review on dark-mode state clarity).
  final FButtonVariant selectedVariant;

  /// The inactive segment's variant. `ghost` (default) keeps the dashboard
  /// mock's bare text on the inset track; `outline` adds a border stroke so
  /// the active state stays unambiguous on low-contrast surfaces.
  final FButtonVariant unselectedVariant;

  /// Draws a radio marker in front of every label: a filled dot on the
  /// selected segment, an empty ring on the others. The marker inherits the
  /// variant's own foreground colour.
  final bool selectionMarkers;

  /// Softens the inactive labels (semi-transparent) so the selected segment
  /// carries the emphasis.
  final bool dimUnselectedText;

  /// The inset track's fill. Defaults to `colors.background` — the mock's
  /// darkest inset — which vanishes on surfaces that are already
  /// `colors.background` (e.g. a bottom sheet); pass `colors.card` there.
  final Color? trackColor;

  /// Narrowest segment that keeps the widest label un-truncated. Below
  /// `segments.length * this + gaps` the track scrolls (320px-class
  /// screens); at 360px+ the segments stay equal and flex-1 like the mock.
  static const double minSegmentWidth = 78;

  static const _gap = 4.0;
  static const _trackPadding = 4.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: trackColor ?? colors.background,
        borderRadius: context.theme.style.borderRadius.sm,
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_trackPadding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fits =
                constraints.maxWidth >=
                segments.length * minSegmentWidth +
                    (segments.length - 1) * _gap;
            final row = Row(
              children: [
                for (final (i, segment) in segments.indexed) ...[
                  if (fits)
                    Expanded(child: _segment(context, segment))
                  else
                    SizedBox(
                      width: minSegmentWidth,
                      child: _segment(context, segment),
                    ),
                  if (i != segments.length - 1) const SizedBox(width: _gap),
                ],
              ],
            );
            return fits
                ? row
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: row,
                  );
          },
        ),
      ),
    );
  }

  Widget _segment(BuildContext context, MiruSegment<T> segment) {
    final selected = segment.value == this.selected;
    // Nested-radius geometry: the track's radius is `sm` (8) with 4px
    // padding, so a segment at the default `md` (10) bulged past the
    // track's corners. The segment takes `xs2` (4) — the correct inner
    // token (8 − 4) — while keeping forui's squircle shape and variant
    // colours.
    final radii = context.theme.style.borderRadius;
    return FButton(
      variant: selected ? selectedVariant : unselectedVariant,
      size: .sm,
      onPress: () => onSelected(segment.value),
      semanticsLabel: segment.label,
      // Radio marker: filled dot on the selected segment, empty ring on the
      // others. The icon inherits the variant's own foreground colour from
      // the button's IconTheme.
      prefix: selectionMarkers
          ? Icon(
              selected ? FLucideIcons.circleDot : FLucideIcons.circle,
              size: 12,
            )
          : null,
      style: .delta(
        contentStyle: FButtonContentStyleDelta.delta(
          // HTML ref: a `py-1.5` (6px) segment around the 20px label-md line
          // = 32px, inside a `p-1` + border track = 42px total. FORUI's own
          // touch `.sm` measures 42px per segment (v12 padding + 18px label
          // + 40 min) — the content box, not the size variant, is what
          // pins the height: 18px label + 2×7 = 32.
          constraints: const BoxConstraints(minHeight: 32),
          padding: EdgeInsetsGeometryDelta.value(
            const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          ),
        ),
        decoration: FVariantsDelta.delta([
          FVariantOperation.all(
            DecorationDelta.shapeDelta(
              shape: RoundedSuperellipseBorder(borderRadius: radii.xs2),
            ),
          ),
        ]),
      ),
      // The label borrows the variant's own text colour (typography tokens
      // bake in colors.foreground, which vanishes on the primary fill) and
      // opts into shrinking: FButton's content row is not flexible, so a
      // bare Text overflows instead of ellipsising.
      builder: (context, style, textStyle, iconStyle, progressStyle, child) =>
          Flexible(
            child: Text(
              segment.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.theme.typography.body.xs.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: dimUnselectedText && !selected
                    ? textStyle.color?.withValues(alpha: 0.65)
                    : textStyle.color,
              ),
            ),
          ),
    );
  }
}
