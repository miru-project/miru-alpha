import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

/// Max number of filter categories that can be pinned to the top at once.
/// Pinning a fourth evicts the oldest pinned entry (FIFO).
const int kMaxPinnedFilters = 3;

/// Unified toggleable filter chip built on [FBadge].
///
/// Single selection source for every filter variant (select-all, select
/// options, multi-select options). Selected renders [FBadgeVariant.primary],
/// unselected renders [FBadgeVariant.outline].
class FilterChip extends StatelessWidget {
  const FilterChip({
    super.key,
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
      child: FBadge(
        variant: selected ? .primary : .outline,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  FLucideIcons.check,
                  size: 12,
                  color: context.theme.colors.foreground,
                ),
              ),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
