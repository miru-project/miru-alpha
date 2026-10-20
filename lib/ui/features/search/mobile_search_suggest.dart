import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/ui/features/history_favorite/shared/list_helpers.dart';
import 'package:miru_alpha/utils/watch/history_session.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// The state shown while a query is being typed but not yet submitted:
/// Recent Searches (the only history surface, six entries), the matching
/// History / Favorite entries, and the query's scope / content-type / sort
/// filters at the bottom.
class MobileSearchSuggest extends HookConsumerWidget {
  const MobileSearchSuggest({
    super.key,
    required this.query,
    required this.onSubmit,
  });

  final String query;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchPageProvider);
    final notifier = ref.read(searchPageProvider.notifier);
    final needle = query.trim().toLowerCase();

    // One history surface: Recent Searches, truncated to six entries. There is
    // no separate "Suggestions" section — with a query typed it would just
    // repeat the same list filtered by the needle.
    final recents = state.history.take(6).toList();

    // The Library halves of the same search: the History and Favorite rows
    // whose titles contain the needle, so one query reaches every shelf.
    final histories = needle.isEmpty
        ? const <History>[]
        : ref
              .watch(historyPageProvider.select((s) => s.history))
              .where((e) => e.title.toLowerCase().contains(needle))
              .take(4)
              .toList();
    final favorites = needle.isEmpty
        ? const <Favorite>[]
        : ref
              .watch(favoritePageProvider.select((s) => s.favorites))
              .where((e) => e.title.toLowerCase().contains(needle))
              .take(4)
              .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, kSearchHeaderGap, 0, 32),
      children: [
        if (recents.isNotEmpty) ...[
          SearchSection(
            title: 'extension.recent_searches'.i18n,
            trailing: FTappable(
              onPress: notifier.clearHistory,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  'history_tools.clear_all'.i18n,
                  style: context.theme.typography.body.xs.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in recents)
                  _SuggestionTile(
                    icon: FLucideIcons.clock,
                    title: entry,
                    onTap: () => onSubmit(entry),
                    onRemove: () => notifier.removeHistory(entry),
                  ),
              ],
            ),
          ),
          const SizedBox(height: kSearchSectionGap),
        ],
        if (histories.isNotEmpty) ...[
          SearchSection(
            title: 'common.history'.i18n,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in histories)
                  _LibraryTile(
                    icon: FLucideIcons.history,
                    title: entry.title,
                    subtitle: findMeta(ref, entry.package)?.name,
                    onTap: () => openHistoryWatchSession(
                      context: context,
                      ref: ref,
                      history: entry,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: kSearchSectionGap),
        ],
        if (favorites.isNotEmpty) ...[
          SearchSection(
            title: 'favorite.name'.i18n,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in favorites)
                  _LibraryTile(
                    icon: FLucideIcons.heart,
                    title: entry.title,
                    subtitle: findMeta(ref, entry.package)?.name,
                    onTap: () {
                      final meta = findMeta(ref, entry.package);
                      if (meta != null) openDetail(context, meta, entry.url);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: kSearchSectionGap),
        ],
        // The query's filters, at the bottom of the page: which sources are
        // queried, which content types count, and how hits are ordered.
        SearchSection(
          title: 'search.scope'.i18n,
          trailing: SearchSectionCount(state.searchScopePackages.length),
          child: SearchScopeSegmented(
            value: state.scopeMode,
            pinnedCount: state.existedPinnedExtensions.length,
            allCount: state.visibleMetaData.length,
            specificCount: state.specificPackages.length,
            onChanged: notifier.setScopeMode,
          ),
        ),
        const SizedBox(height: kSearchSectionGap),
        SearchSection(
          title: 'search.content_type'.i18n,
          trailing: SearchSectionCount(state.contentTypes.length),
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

/// One Library row in the suggest list: History or Favorite, with the source
/// it belongs to as the muted trailing text.
class _LibraryTile extends StatelessWidget {
  const _LibraryTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: kSearchCardGap / 2),
      child: FTappable(
        onPress: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: colors.secondary.withAlpha(50),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: colors.mutedForeground),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (subtitle != null) ...[
                Text(
                  subtitle!,
                  style: context.theme.typography.body.xs.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Icon(
                FLucideIcons.arrowRight,
                size: 14,
                color: colors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One tappable recent-search row: clock icon, label, and a remove button.
class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.onRemove,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: kSearchCardGap / 2),
      child: Row(
        children: [
          Expanded(
            child: FTappable(
              onPress: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: colors.secondary.withAlpha(50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: colors.mutedForeground),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: context.theme.typography.body.sm,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      FLucideIcons.arrowRight,
                      size: 14,
                      color: colors.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (onRemove != null) ...[
            FTappable(
              onPress: onRemove,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  FLucideIcons.x,
                  size: 15,
                  color: colors.mutedForeground,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
