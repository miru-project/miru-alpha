import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

import 'package:forui/forui.dart';

/// The app's badge everywhere a bare [FBadge] would be typed out: forui's own
/// badge geometry (label, padding and shape inherit from the theme) with two
/// additions — [labelColor] tints the label (semantic count accents) while
/// keeping the variant's surface, and [onPress] wraps the badge in a tap
/// surface (FBadge itself is display-only).
class SmallBadge extends StatelessWidget {
  const SmallBadge({
    super.key,
    required this.label,
    this.variant = FBadgeVariant.secondary,
    this.onPress,
    this.labelColor,
    this.onCover = false,
  });

  final String label;
  final FBadgeVariant variant;
  final VoidCallback? onPress;

  /// Overrides the label colour (e.g. semantic count accents on the shell
  /// sidebar); the variant's own surface/border stay untouched.
  final Color? labelColor;

  /// Sits the badge on top of artwork.
  ///
  /// The variant's own surface is opaque and tuned for a plain card, so over a
  /// cover it loses contrast against bright art. This swaps it for a frosted
  /// pane (translucent fill + blur + hairline border) that keeps the artwork
  /// readable underneath instead of punching a solid block out of it.
  final bool onCover;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final badge = FBadge(
      variant: variant,
      style: onCover
          ? .delta(
              decoration: .boxDelta(
                color: colors.background.withAlpha(165),
                border: Border.fromBorderSide(BorderSide(color: colors.border)),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: EdgeInsetsGeometryDelta.value(
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              labelTextStyle: .delta(
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w600,
                color: labelColor ?? colors.foreground,
              ),
            )
          : .delta(labelTextStyle: TextStyleDelta.delta(color: labelColor)),
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );

    final Widget surfaced = onCover
        ? ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: badge,
            ),
          )
        : badge;

    if (onPress == null) return surfaced;
    return FTappable(onPress: onPress, child: surfaced);
  }
}
