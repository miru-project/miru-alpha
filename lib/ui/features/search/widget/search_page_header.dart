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
  const SearchPageHeader({
    super.key,
    required this.field,
    this.trailing,
    this.title,
  });

  /// The field: a [SearchFieldStub] on the tab, the editable field on the
  /// pushed page.
  final Widget field;

  /// Trailing action (Cancel) — omitted when the field is only a tap target.
  final Widget? trailing;

  /// Heading override; `null` keeps [SearchPageTitle]'s plain "Search". The
  /// pushed input page names the aggregate flow it runs ("Global Search").
  final String? title;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SearchPageTitle(title: title),
      SearchFieldRow(field: field, trailing: trailing),
    ],
  );
}

/// The big heading word ("Search" by default), drawn with the same
/// [SnapSheetHeader] the Settings, Library and Extension pages use — one
/// heading language across the app.
///
/// Its extent is [kSearchTitleExtent], which is what lets the tab collapse it
/// to nothing on scroll.
const double kSearchTitleExtent = 62;

class SearchPageTitle extends StatelessWidget {
  const SearchPageTitle({
    super.key,
    this.suffix = const <Widget>[],
    this.title,
  });

  /// Trailing header actions; an empty list keeps the plain title layout and
  /// padding.
  final List<Widget> suffix;

  /// Heading text; `null` falls back to the `common.search` label.
  final String? title;

  @override
  Widget build(BuildContext context) {
    // SnapSheetHeader carries its own bottom padding; the extent leaves room
    // for the field row's 2px top gap, so nothing else is added. With a
    // suffix the actions are 44dp, so the default bottom padding would crowd
    // them — the smaller padding matches the Extension page's action bar.
    return SnapSheetHeader(
      title: title ?? 'common.search'.i18n,
      suffix: suffix,
      padding: suffix.isEmpty
          ? null
          : const EdgeInsets.only(left: 0, bottom: 10, right: 4),
    );
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
