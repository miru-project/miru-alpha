import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/home_dashboard_provider.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:miru_alpha/ui/features/history_favorite/shared/list_helpers.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_poster_rail.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_section_header.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// "Feed" — poster rail of the selected tag's favorites (every favorite when
/// no tag is selected), filtered by the dashboard's media type. Cards carry
/// only the score-style meta line per the simplified mockup.
class HomeDynamicFeed extends ConsumerWidget {
  const HomeDynamicFeed({super.key});

  static const _maxCards = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeDashboardProvider);
    final groups = ref.watch(
      favoritePageProvider.select((s) => s.favoriteGroups),
    );
    final favorites = ref.watch(
      favoritePageProvider.select((s) => s.favorites),
    );
    // No favorites yet: the section hides entirely instead of stacking a
    // second dead-end empty state under the resume shelf (UX-review) — the
    // Trending rail carries the empty dashboard.
    if (favorites.isEmpty) return const SizedBox.shrink();
    final selected = ref.watch(
      favoritePageProvider.select((s) => s.selectedFavoriteGroups),
    );
    // One selection everywhere: the strip, the manager sheet and this feed
    // read favoritePageProvider's selected groups (resolved by name, so a
    // favorites refresh cannot break the highlight).
    final selectedGroups = selected
        .map((g) => groups.where((e) => e.name == g.name).firstOrNull)
        .whereType<FavoriteGroup>()
        .toList();
    final scoped = selectedGroups.isEmpty
        ? favorites
        // Read, not watch: the watched selects above already trigger the
        // rebuild when the selection or the favorites change.
        : ref
              .read(favoritePageProvider.notifier)
              .favoritesInGroups(selectedGroups);
    final items = scoped
        .where(
          (f) =>
              !state.filtersByType ||
              stringToExtensionType(f.type) == state.type,
        )
        .take(_maxCards)
        .toList();

    // Mockup header: "Feed: <tag>", falling back to "Feed: All". Several
    // selected groups collapse to the first name plus the overflow count.
    final tag = selectedGroups.isEmpty
        ? 'common.all'.i18n
        : selectedGroups.length == 1
        ? selectedGroups.first.name
        : '${selectedGroups.first.name} +${selectedGroups.length - 1}';
    final title = 'home.feed_title'.i18n.fill({'tag': tag});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HomeSectionHeader(
            // Mockup: the feed header carries the sparkles lead.
            leading: FLucideIcons.sparkles,
            title: title,
            trailing: items.isEmpty
                ? null
                : SearchPill(
                    label: 'home.view_all'.i18n,
                    selected: false,
                    icon: FLucideIcons.chevronRight,
                    onTap: () => context.push('/home/favorite'),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HomeEmpty(text: 'home.feed_empty'.i18n),
          )
        else
          HomePosterRail(
            itemCount: items.length,
            builder: (context, index) {
              final item = items[index];
              return HomePosterCard(
                key: ValueKey(item.url),
                title: item.title,
                cover: item.cover,
                subtitle: searchExtensionTypeLabel(
                  stringToExtensionType(item.type),
                ),
                onTap: () => _openDetail(context, ref, item),
              );
            },
          ),
      ],
    );
  }

  void _openDetail(BuildContext context, WidgetRef ref, Favorite item) {
    final meta = findMeta(ref, item.package);
    if (meta == null) {
      showSimpleToast('common.package_not_found'.i18n);
      return;
    }
    openDetail(context, meta, item.url);
  }
}
