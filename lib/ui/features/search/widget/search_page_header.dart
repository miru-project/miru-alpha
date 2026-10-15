import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// The pinned, opaque sliver header both search screens use.
///
/// Same extent for `min`/`max` so the header never collapses while scrolling —
/// the field has to stay reachable.
SliverPersistentHeaderDelegate searchHeaderSliver(
  BuildContext context, {
  required double extent,
  required Widget child,
}) => SimpleSliverHeaderDelegate(
  maxExtent: extent,
  minExtent: extent,
  child: ColoredBox(color: context.theme.colors.background, child: child),
);

/// Title + field row, shared by the search tab and the pushed input page.
///
/// The two screens differ only in which field they show and what sits next to
/// it, so the block lives here instead of being drawn twice. On the tab the two
/// halves are separate slivers (the title one collapses on scroll), so
/// [SearchPageTitle] and [SearchFieldRow] exist on their own as well.
class SearchPageHeader extends StatelessWidget {
  const SearchPageHeader({super.key, required this.field, this.trailing});

  /// The field: a [SearchFieldStub] on the tab, the editable field on the
  /// pushed page.
  final Widget field;

  /// Trailing action (Cancel) — omitted when the field is only a tap target.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SearchPageTitle(),
      SearchFieldRow(field: field, trailing: trailing),
    ],
  );
}

/// The big "Search" word, drawn with the same [SnapSheetHeader] the Settings,
/// Library and Extension pages use — one heading language across the app.
///
/// Its extent is [kSearchTitleExtent], which is what lets the tab collapse it
/// to nothing on scroll.
const double kSearchTitleExtent = 62;

class SearchPageTitle extends StatelessWidget {
  const SearchPageTitle({super.key});

  @override
  Widget build(BuildContext context) {
    // SnapSheetHeader carries its own bottom padding; the extent leaves room
    // for the field row's 2px top gap, so nothing else is added.
    return SnapSheetHeader(title: 'common.search'.i18n);
  }
}

/// Extent of [SearchFieldRow]: its own padding plus the row, with slack so a
/// pinned header never renders the overflow banner.
const double kSearchFieldExtent = 56;

class SearchFieldRow extends StatelessWidget {
  const SearchFieldRow({super.key, required this.field, this.trailing});

  final Widget field;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: field),
          if (trailing != null) ...[const SizedBox(width: 6), trailing!],
        ],
      ),
    );
  }
}
