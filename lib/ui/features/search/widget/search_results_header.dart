import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/ui/features/search/widget/search_field.dart';

/// Header row 2: what is being searched and the "Pinned Only" shortcut.
class MobileSearchScopeSummary extends ConsumerWidget {
  const MobileSearchScopeSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchPageProvider);
    final notifier = ref.read(searchPageProvider.notifier);
    final scopePackages = state.searchScopePackages;
    // The pill always names the scope that is actually being searched — never
    // a fixed "pinned" answer — via the same label helper the scope selector
    // uses, so the two can't drift apart.
    final names = [
      if (state.scopeMode != SearchScopeMode.all)
        for (final meta in state.filteredMetaData)
          if (scopePackages.contains(meta.packageName)) meta.name,
    ];
    final label = searchScopeLabel(state);
    final icon = switch (state.scopeMode) {
      SearchScopeMode.pinned => FLucideIcons.pin,
      SearchScopeMode.all => FLucideIcons.puzzle,
      SearchScopeMode.specific => FLucideIcons.filter,
    };

    return Padding(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: context.theme.colors.secondary.withAlpha(70),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: context.theme.colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 13, color: context.theme.colors.foreground),
                  const SizedBox(width: 5),
                  Flexible(
                    flex: 1,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (names.isNotEmpty)
                    Flexible(
                      flex: 3,
                      child: Text(
                        '· ${names.join(', ')}',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.theme.colors.mutedForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          FTappable(
            onPress: () => notifier.setPinnedScope(!state.pinnedScope),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'search.pinned_only'.i18n,
                    style: TextStyle(
                      fontSize: 11,
                      color: state.pinnedScope
                          ? context.theme.colors.foreground
                          : context.theme.colors.mutedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    state.pinnedScope ? FLucideIcons.check : FLucideIcons.pin,
                    size: 14,
                    color: state.pinnedScope
                        ? context.theme.colors.foreground
                        : context.theme.colors.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header of the results state: back + field, then the scope summary and the
/// Relevance / By-Extension segmented control. Shared by the pushed input page
/// and the search tab.
class SearchResultsHeader extends StatelessWidget {
  const SearchResultsHeader({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.onBack,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmit;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
          child: Row(
            children: [
              FTappable(
                onPress: onBack,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(FLucideIcons.chevronLeft, size: 22),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: searchField(
                  controller: controller,
                  focusNode: focusNode,
                  onSubmit: onSubmit,
                ),
              ),
            ],
          ),
        ),
        const MobileSearchScopeSummary(),
        const SizedBox(height: kSearchLabelGap),
        const _ResultsViewSegmented(),
      ],
    );
  }
}

/// Relevance grid vs per-extension shelves — the mockup's segmented control.
class _ResultsViewSegmented extends ConsumerWidget {
  const _ResultsViewSegmented();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(searchPageProvider.select((s) => s.resultsViewMode));
    final notifier = ref.read(searchPageProvider.notifier);
    final colors = context.theme.colors;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.secondary.withAlpha(70),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          for (final (mode_, icon, label) in [
            (
              ResultsViewMode.relevance,
              FLucideIcons.sparkles,
              'search.view_relevance',
            ),
            (
              ResultsViewMode.byExtension,
              FLucideIcons.layoutArrowDown,
              'search.view_by_extension',
            ),
          ])
            Expanded(
              child: FTappable(
                onPress: () => notifier.setResultsViewMode(mode_),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: mode == mode_
                        ? colors.secondary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: mode == mode_
                            ? colors.foreground
                            : colors.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          label.i18n,
                          style: context.theme.typography.body.xs2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: mode == mode_
                                ? colors.foreground
                                : colors.mutedForeground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
