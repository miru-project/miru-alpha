import 'package:flutter/widgets.dart';

import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';

/// Shared dashboard section primitives: the header every block opens with, the
/// inset empty-state box, and the small overlay chip used on cover images.

/// Section header: 20px semibold title with an optional icon lead and a
/// baseline-aligned trailing counter or action.
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.leading,
    this.titleTrailing,
    this.trailing,
  });

  final String title;
  final IconData? leading;

  /// A compact widget hugging the title text (the trending header's
  /// "Source: AniList" selector). Sits inside the title's own slot, so it
  /// travels with the text — distinct from [trailing], which pins to the
  /// row's right edge.
  final Widget? titleTrailing;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    // The trailing slot must be BOUNDED for its FittedBox to scale down: a
    // Row hands non-flex children unbounded width (flex.dart's
    // _constraintsForNonFlexChild), so an unbounded FittedBox never scales
    // and a wide trailing (long raw i18n keys, large user text scales)
    // overflows the header instead of shrinking. Cap it at 60% of the row —
    // every current trailing is narrower, so nothing visually changes.
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxTrailingWidth = constraints.maxWidth * 0.6;
        return Row(
          children: [
            if (leading case final icon?) ...[
              Icon(icon, size: 18, color: colors.primary),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.typography.body.lg.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        height: 1.1,
                      ),
                    ),
                  ),
                  // Non-flex after the Flexible title: the chip hugs the text
                  // when the title is short and the title ellipsises when long.
                  if (titleTrailing case final titleTrailing?) ...[
                    const SizedBox(width: 6),
                    FittedBox(fit: BoxFit.scaleDown, child: titleTrailing),
                  ],
                ],
              ),
            ),
            if (trailing case final trailing?) ...[
              // Non-flex child AFTER the Expanded title: the title absorbs all
              // slack, so the trailing is pinned to the row's right edge. The
              // old Flexible(child: FittedBox(...)) made the trailing a second
              // flex child — Expanded and Flexible split the leftover width
              // 1:1, so a natural-width pill was laid out at the row's
              // midpoint and never reached the right edge (and the FittedBox's
              // alignment never applied: under loose constraints it sizes to
              // its child, so there is no room to align within).
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxTrailingWidth),
                child: FittedBox(fit: BoxFit.scaleDown, child: trailing),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Inset empty-state box a section shows instead of its rail. Stretched to the
/// section's full width — inside a `crossAxisAlignment: start` column a card
/// would otherwise shrink to its text.
class HomeEmpty extends StatelessWidget {
  const HomeEmpty({super.key, required this.text, this.action, this.icon});

  final String text;

  /// Optional retry-style affordance rendered under the text.
  final Widget? action;

  /// Optional illustrative glyph above the text (empty-state guidance).
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return MiruCard(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon case final icon?) ...[
                Icon(icon, size: 28, color: colors.mutedForeground),
                const SizedBox(height: 8),
              ],
              Text(
                text,
                textAlign: TextAlign.center,
                style: context.theme.typography.body.xs2.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
              if (action case final action?) ...[
                const SizedBox(height: 10),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Small overlay chip used for type badges, rank badges and scores on covers —
/// an [FBadge] with the mockup's translucent-surface decoration.
class HomeChip extends StatelessWidget {
  const HomeChip({super.key, this.icon, required this.label});

  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return FBadge(
      style: .delta(
        decoration: .boxDelta(
          color: colors.background.withAlpha(230),
          border: Border.fromBorderSide(BorderSide(color: colors.border)),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsetsGeometryDelta.value(
          const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        ),
        labelTextStyle: .delta(
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w600,
          color: colors.foreground,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon case final icon?) ...[
            Icon(icon, size: 11, color: colors.foreground),
            const SizedBox(width: 3),
          ],
          Text(label),
        ],
      ),
    );
  }
}
