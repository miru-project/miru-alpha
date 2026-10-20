import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'search_filter_controls.dart';

/// The title-bar tune button's sheet: the query-side filter set (scope,
/// content types, sort) on one screen.
///
/// The tab shows the *source-list* filters as pills because they apply to the
/// visible cards; the query-side set used to live only inside the full filter
/// dialog, which meant no way to reach it from the phone header. This sheet
/// reuses the suggest page's section widgets so the pills behave identically
/// wherever they appear.
Future<void> showSearchSettingsSheet() {
  return showFSheet(
    context: RouterUtil.rootNavigatorKey.currentContext!,
    side: .btt,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: context.theme.colors.background,
        border: Border(top: BorderSide(color: context.theme.colors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: context.theme.colors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(
              'search.edit_filters'.i18n,
              style: context.theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: const _SearchSettingsSheetContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SearchSettingsSheetContent extends ConsumerWidget {
  const _SearchSettingsSheetContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchPageProvider);
    final notifier = ref.read(searchPageProvider.notifier);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchSection(
          title: 'search.scope'.i18n,
          child: SearchScopeSegmented(
            value: state.scopeMode,
            onChanged: notifier.setScopeMode,
            pinnedCount: state.existedPinnedExtensions.length,
            allCount: state.visibleMetaData.length,
            specificCount: state.specificPackages.length,
          ),
        ),
        const SizedBox(height: kSearchSectionGap),
        SearchSection(
          title: 'search.content_type'.i18n,
          child: SearchContentTypeChips(
            value: state.contentTypes,
            onChanged: notifier.toggleContentType,
          ),
        ),
        const SizedBox(height: kSearchSectionGap),
        SearchSection(
          title: 'search.sort_by'.i18n,
          child: SearchSortPills(
            value: state.sort,
            onChanged: notifier.setSort,
          ),
        ),
      ],
    );
  }
}
