import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Small uppercase section header with an optional trailing affordance.
class SearchSectionHeader extends StatelessWidget {
  const SearchSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            // The settings pages label their groups through forui's typography
            // tokens; the search sections speak the same language.
            style: typography.body.xs.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: context.theme.colors.mutedForeground,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Compound trailers (badge + action) can exceed the remaining width in
        // long locales; scale them as one unit instead of overflowing.
        if (trailing != null)
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: trailing,
            ),
          ),
      ],
    );
  }
}

/// The `/search` tab's pinned filter bar: the Type / Status / Sort pills only.
///
/// The "Extension Sources · Total N" label and the caption live in the body
/// above the cards (the label describes the list, so it scrolls with it); this
/// bar pins just the pills so they stay reachable while everything else moves.
class SearchSourceFilterBar extends ConsumerWidget {
  const SearchSourceFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchPageProvider);
    final notifier = ref.read(searchPageProvider.notifier);
    final colors = context.theme.colors;

    // The hairline marks the pinned layer: cards slide under it, so without a
    // border the row above looks like it is touching whatever scrolled there.
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: kSearchLabelGap),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 6,
            children: [
              SearchPill(
                label: 'search.all_sources'.i18n,
                selected: state.sourceFiltersReset,
                onTap: notifier.resetSourceFilters,
              ),
              SearchPickerPill<ExtensionType?>(
                label: 'common.type'.i18n,
                currentLabel: state.sourceType == null
                    ? 'common.all'.i18n
                    : searchContentTypeLabel(state.sourceType!),
                narrowed: state.sourceType != null,
                sheetTitle: 'common.type'.i18n,
                current: state.sourceType,
                options: [
                  SearchOption(
                    value: null,
                    label: 'common.all'.i18n,
                    icon: FLucideIcons.layers,
                  ),
                  for (final type in kSearchContentTypes)
                    SearchOption(
                      value: type,
                      label: searchContentTypeLabel(type),
                      icon: FLucideIcons.puzzle,
                    ),
                ],
                onPicked: notifier.setSourceType,
              ),
              SearchPickerPill<SearchSourceStatus>(
                label: 'common.status'.i18n,
                currentLabel: searchSourceStatusLabel(state.sourceStatus),
                narrowed: state.sourceStatus != SearchSourceStatus.all,
                sheetTitle: 'common.status'.i18n,
                current: state.sourceStatus,
                options: [
                  for (final value in SearchSourceStatus.values)
                    SearchOption(
                      value: value,
                      label: searchSourceStatusLabel(value),
                      icon: FLucideIcons.pin,
                    ),
                ],
                onPicked: notifier.setSourceStatus,
              ),
              SearchPickerPill<SearchSourceSort>(
                label: 'search.sort_label'.i18n,
                currentLabel: searchSourceSortLabel(state.sourceSort),
                // The sort always shows its value: it is a mode, not a filter.
                narrowed: true,
                icon: FLucideIcons.arrowUpDown,
                sheetTitle: 'search.sort_by'.i18n,
                current: state.sourceSort,
                options: [
                  for (final value in SearchSourceSort.values)
                    SearchOption(
                      value: value,
                      label: searchSourceSortLabel(value),
                      icon: FLucideIcons.arrowDownNarrowWide,
                    ),
                ],
                onPicked: notifier.setSourceSort,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Height of [SearchSourceFilterBar]: one pill row plus the gap under it.
/// Scaled with the text setting so a larger font doesn't clip a header that
/// cannot resize while scrolling.
double searchSourceFilterBarExtent(BuildContext context) {
  // ~34px of content plus slack: a pinned header can't resize to fit, so it is
  // cheaper to be a few px generous than to paint the overflow banner over the
  // pills.
  final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5);
  return 40 * scale;
}

/// The muted "N Selected" counter (suggest page sections).
class SearchSectionCount extends StatelessWidget {
  const SearchSectionCount(this.value, {super.key});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Text(
      'search.selected_count'.i18n.fill({'count': '$value'}),
      style: context.theme.typography.body.xs.copyWith(
        color: context.theme.colors.mutedForeground,
      ),
    );
  }
}

/// Wrapping pill strip: every filter group on the search screens is one of
/// these, so the strip's gap lives in a single place.
class SearchPillStrip extends StatelessWidget {
  const SearchPillStrip({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 6, runSpacing: 6, children: children);
  }
}

/// Three-way source scope picker: pinned subset / every extension / hand-picked.
class SearchScopeSegmented extends StatelessWidget {
  const SearchScopeSegmented({
    super.key,
    required this.value,
    required this.onChanged,
    required this.pinnedCount,
    required this.allCount,
    this.specificCount = 0,
  });

  final SearchScopeMode value;
  final ValueChanged<SearchScopeMode> onChanged;
  final int pinnedCount;
  final int allCount;
  final int specificCount;

  @override
  Widget build(BuildContext context) {
    return SearchPillStrip(
      children: [
        SearchPill(
          label: '${'extension.pinned'.i18n} ($pinnedCount)',
          selected: value == SearchScopeMode.pinned,
          leading: value == SearchScopeMode.pinned
              ? Icon(FLucideIcons.check, size: 13)
              : null,
          onTap: () => onChanged(SearchScopeMode.pinned),
        ),
        SearchPill(
          label: 'search.all_extensions'.i18n.fill({'count': '$allCount'}),
          selected: value == SearchScopeMode.all,
          leading: value == SearchScopeMode.all
              ? Icon(FLucideIcons.check, size: 13)
              : null,
          onTap: () => onChanged(SearchScopeMode.all),
        ),
        SearchPill(
          label: 'search.scope_specific'.i18n,
          selected: value == SearchScopeMode.specific,
          count: specificCount == 0 ? null : specificCount,
          leading: value == SearchScopeMode.specific
              ? Icon(FLucideIcons.check, size: 13)
              : null,
          onTap: () => onChanged(SearchScopeMode.specific),
        ),
      ],
    );
  }
}

/// Multi-select content type chips (Anime / Manga / Light Novel).
class SearchContentTypeChips extends StatelessWidget {
  const SearchContentTypeChips({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Set<ExtensionType> value;
  final ValueChanged<ExtensionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SearchPillStrip(
      children: [
        for (final type in kSearchContentTypes)
          SearchPill(
            label: searchContentTypeLabel(type),
            selected: value.contains(type),
            leading: value.contains(type)
                ? Icon(FLucideIcons.check, size: 13)
                : Icon(
                    FLucideIcons.puzzle,
                    size: 13,
                    color: context.theme.colors.mutedForeground,
                  ),
            onTap: () => onChanged(type),
          ),
      ],
    );
  }
}

/// Single-select sort pills.
class SearchSortPills extends StatelessWidget {
  const SearchSortPills({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final SearchSortMode value;
  final ValueChanged<SearchSortMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SearchPillStrip(
      children: [
        for (final mode in SearchSortMode.values)
          SearchPill(
            label: searchSortLabel(mode),
            selected: value == mode,
            leading: value == mode ? Icon(FLucideIcons.check, size: 13) : null,
            onTap: () => onChanged(mode),
          ),
      ],
    );
  }
}

/// Display label for a source-list status filter.
String searchSourceStatusLabel(SearchSourceStatus status) => switch (status) {
  SearchSourceStatus.all => 'common.all'.i18n,
  SearchSourceStatus.pinned => 'extension.pinned'.i18n,
  SearchSourceStatus.unpinned => 'search.status_unpinned'.i18n,
};

/// Display label for a source-list order.
String searchSourceSortLabel(SearchSourceSort sort) => switch (sort) {
  SearchSourceSort.pinned => 'search.sort_pinned_first'.i18n,
  SearchSourceSort.name => 'search.sort_name'.i18n,
  SearchSourceSort.version => 'search.sort_version'.i18n,
};

/// forui's palette has no semantic "success" colour, so the "this source is
/// healthy" dot keeps one named green instead of a literal in every card.
const Color kSearchStatusDot = Color(0xFF34D399);

/// Search result card aspect ratio: width / height = 0.65, matching the
/// single-extension grid's `MiruMobileTile` poster ratio.
const double kSearchCardAspectRatio = 0.65;

/// Skeleton cards appended to the relevance grid while the next page loads.
const int kSearchSkeletonCount = 4;

/// Extension versions already carry their own "v" (manifest publishes "v2.0.0",
/// not "2.0.0"), so prefixing one more turned every card into "vv2.0.0".
String searchVersionLabel(String version) {
  final trimmed = version.trim();
  if (trimmed.isEmpty) return '';
  return trimmed.toLowerCase().startsWith('v') ? trimmed : 'v$trimmed';
}

/// Vertical rhythm shared by every search screen: 20 between sections, 8 from
/// a section header to its content, 8 between sibling cards, 6 under the page
/// header. Named here so the pages stop inventing their own gaps.
const double kSearchSectionGap = 20;
const double kSearchLabelGap = 8;
const double kSearchCardGap = 8;
const double kSearchHeaderGap = 6;

/// A labelled block: [SearchSectionHeader] with its content [kSearchLabelGap]
/// below. Every section on the search screens is this shape, so the pair is
/// written once instead of once per section.
class SearchSection extends StatelessWidget {
  const SearchSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.description,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  /// Muted caption directly under the title, before the content gap.
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchSectionHeader(title: title, trailing: trailing),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            style: TextStyle(
              fontSize: 11,
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ],
        const SizedBox(height: kSearchLabelGap),
        child,
      ],
    );
  }
}

/// Filter pill that picks its value from [showSearchOptionSheet].
///
/// Shows only [label] while it sits at its default and `Label: value` once it
/// is narrowed, so the default strip still fits one line.
class SearchPickerPill<T> extends StatelessWidget {
  const SearchPickerPill({
    super.key,
    required this.label,
    required this.currentLabel,
    required this.narrowed,
    required this.sheetTitle,
    required this.options,
    required this.current,
    required this.onPicked,
    this.icon = FLucideIcons.chevronDown,
  });

  final String label;
  final String currentLabel;

  /// Whether the value differs from its default (controls both the wording and
  /// the pill's selected styling).
  final bool narrowed;
  final String sheetTitle;
  final List<SearchOption<T>> options;
  final T current;
  final ValueChanged<T> onPicked;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SearchPill(
      label: narrowed ? '$label: $currentLabel' : label,
      icon: icon,
      selected: narrowed,
      onTap: () async {
        final picked = await showSearchOptionSheet<T>(
          context: context,
          title: sheetTitle,
          selected: current,
          options: options,
        );
        if (picked != null) onPicked(picked.value);
      },
    );
  }
}

/// Rounded toggle pill used by every filter strip on the search screens.
///
/// An [FButton]: [selected] renders the primary variant, everything else
/// renders the outline variant, so the pressed/unpressed pair reads as a
/// toggle rather than two shades of the same chip.
class SearchPill extends StatelessWidget {
  const SearchPill({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.count,
    this.leading,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final int? count;
  final Widget? leading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: selected ? .primary : .outline,
      onPress: onTap,
      mainAxisSize: .min,
      prefix: leading,
      suffix: icon == null ? null : Icon(icon, size: 14),
      // FButton's content row is not flexible, so the label has to opt in or
      // it overflows instead of ellipsising.
      builder: _flexChild,
      style: .delta(
        contentStyle: FButtonContentStyleDelta.delta(
          // Height comes from the content box, which is what keeps FORUI's
          // 44px touch minimum from inflating every pill in the strip.
          constraints: const BoxConstraints(minHeight: 28),
          // Horizontal only: a vertical value would fight minHeight.
          padding: EdgeInsetsGeometryDelta.value(
            const EdgeInsets.symmetric(horizontal: 11),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.theme.typography.body.xs2.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 5),
            Text(
              '$count',
              style: context.theme.typography.body.xs2.copyWith(
                fontWeight: FontWeight.w600,
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// [FButton]'s documented `builder` hook; wrapping the child in [Flexible]
  /// lets the internal Row shrink instead of overflowing.
  static Widget _flexChild(
    BuildContext context,
    FButtonStyle style,
    TextStyle textStyle,
    IconThemeData iconStyle,
    FCircularProgressStyle progressStyle,
    Widget? child,
  ) => Flexible(child: child ?? const SizedBox.shrink());
}

/// Display label for a filterable content type.
String searchContentTypeLabel(ExtensionType type) => switch (type) {
  ExtensionType.bangumi => 'search.type_anime'.i18n,
  ExtensionType.manga => 'search.type_manga'.i18n,
  ExtensionType.fikushon => 'search.type_novel'.i18n,
  ExtensionType.all => 'common.all'.i18n,
};

/// Short label used by the result type tabs.
String searchContentTabLabel(ExtensionType type) => switch (type) {
  ExtensionType.bangumi => 'search.tab_anime'.i18n,
  ExtensionType.manga => 'search.tab_manga'.i18n,
  ExtensionType.fikushon => 'search.tab_novel'.i18n,
  ExtensionType.all => 'common.all'.i18n,
};

/// Short label for an extension's own type badge (source cards, tiles).
///
/// Kept to the manifest's vocabulary so a card's badge stays one short word;
/// the long "Anime / Video" wording belongs to the content-type filter chips.
String searchExtensionTypeLabel(ExtensionType type) => switch (type) {
  ExtensionType.bangumi => 'media.bangumi'.i18n,
  ExtensionType.manga => 'media.manga'.i18n,
  ExtensionType.fikushon => 'media.novel'.i18n,
  ExtensionType.all => 'common.all'.i18n,
};

/// Display label for a sort mode.
String searchSortLabel(SearchSortMode mode) => switch (mode) {
  SearchSortMode.relevance => 'search.sort_relevance'.i18n,
  SearchSortMode.latest => 'search.sort_latest'.i18n,
  SearchSortMode.sourcePriority => 'search.sort_source_priority'.i18n,
};

/// Short human label of the active scope, used by the "scope" indicator.
String searchScopeLabel(SearchPageState state) => switch (state.scopeMode) {
  SearchScopeMode.pinned =>
    '${'extension.pinned'.i18n} (${state.existedPinnedExtensions.length})',
  SearchScopeMode.all => 'search.all_extensions'.i18n.fill({
    'count': '${state.filteredMetaData.length}',
  }),
  SearchScopeMode.specific =>
    '${'search.scope_specific'.i18n} (${state.specificPackages.length})',
};

/// One row of a [showSearchOptionSheet].
class SearchOption<T> {
  const SearchOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// FORUI bottom sheet listing [options]; resolves to the chosen option, or
/// `null` when it is dismissed without picking. Returning the option (not its
/// value) keeps "picked the null value" distinguishable from "closed it".
Future<SearchOption<T>?> showSearchOptionSheet<T>({
  required BuildContext context,
  required String title,
  required List<SearchOption<T>> options,
  T? selected,
}) {
  return showFSheet<SearchOption<T>>(
    context: context,
    side: .btt,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: context.theme.colors.background,
        border: Border(top: BorderSide(color: context.theme.colors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: context.theme.colors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ),
          FTileGroup(
            children: [
              for (final option in options)
                FTile(
                  selected: option.value == selected,
                  prefix: option.icon == null
                      ? null
                      : Icon(option.icon, size: 18),
                  title: Text(option.label),
                  onPress: () => Navigator.of(context).pop(option),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
