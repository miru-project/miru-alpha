import 'package:flutter/widgets.dart';

import 'package:forui/forui.dart';

/// The compact rectangular badge used on dense cards (extension list tile,
/// search source card): the 12px label step on a tightened padding instead
/// of forui's touch padding. Pass [onPress] to make it tappable — FBadge
/// itself is display-only, so the tap surface wraps it.
class SmallBadge extends StatelessWidget {
  const SmallBadge({
    super.key,
    required this.label,
    this.variant = FBadgeVariant.secondary,
    this.onPress,
  });

  final String label;
  final FBadgeVariant variant;
  final VoidCallback? onPress;

  @override
  Widget build(BuildContext context) {
    final badge = FBadge(
      variant: variant,
      style: .delta(
        padding: EdgeInsetsGeometryDelta.value(
          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        ),
        labelTextStyle: TextStyleDelta.delta(
          fontSize: context.theme.typography.body.xs2.fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      child: Text(label),
    );
    if (onPress == null) return badge;
    return FTappable(onPress: onPress, child: badge);
  }
}
