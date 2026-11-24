import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/features/favorite/widget/desktop_favorite_search_bar.dart';
import 'package:miru_alpha/ui/features/favorite/widget/favorite_group_sheet.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/ui/features/history_favorite/shared/list_helpers.dart';
import 'package:miru_alpha/ui/features/search/widget/search_field.dart';
import 'package:miru_alpha/ui/features/search/widget/search_page_header.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

class FavoriteView extends ConsumerStatefulWidget {
  const FavoriteView({super.key, this.type});

  /// Optional type filter applied on load (e.g. `/home/favorite?type=media.manga`).
  final ExtensionType? type;

  @override
  ConsumerState<FavoriteView> createState() => _FavoriteViewState();
}

class _FavoriteViewState extends ConsumerState<FavoriteView> {
  @override
  void initState() {
    super.initState();
    _applyTypeFilter();
  }

  @override
  void didUpdateWidget(covariant FavoriteView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-pushes of `/home/favorite?type=...` reuse this element because the
    // page key is unchanged, so `initState` will not run again.
    if (oldWidget.type != widget.type) _applyTypeFilter();
  }

  void _applyTypeFilter() {
    final type = widget.type;
    if (type != null) {
      Future.microtask(
        () => ref.read(favoritePageProvider.notifier).setTypeFilter(type),
      );
    }
  }

  void _openDetail(BuildContext context, Favorite favorite) {
    final meta = findMeta(ref, favorite.package);
    if (meta == null) return;
    openDetail(context, meta, favorite.url);
  }

  Future<void> _confirmDelete(BuildContext context, Favorite favorite) async {
    await showDeleteConfirmDialog(
      context: context,
      ref: ref,
      title: 'common.remove_favorite'.i18n,
      body: 'favorite.remove_favorite_confirm'.i18n,
      onConfirm: () async {
        final removed = await ref
            .read(favoritePageProvider.notifier)
            .deleteFavorite(favorite);
        if (!removed && context.mounted) {
          showSimpleToast('favorite.remove_favorite_failed'.i18n);
        }
      },
    );
  }

  Future<void> _manageGroups(BuildContext context) async {
    if (!context.mounted) return;
    await showFavoriteGroupSheet(context);
  }

  Widget _buildTile(BuildContext context, Favorite favorite) {
    // AniList progress line: "WATCHING · Ep 8/12" when the account
    // is linked and the title matches an entry. Read from the favorite state's
    // `anilistByTitle` join via `select` — the favorite page is ONE service
    // now (no separate lookup provider). `select` on the specific title's
    // entry so only the cards whose AniList data changes rebuild.
    final anilist = ref.watch(
      favoritePageProvider.select(
        (s) => s.anilistByTitle[normalizeTitle(favorite.title)],
      ),
    );
    // When a type is selected, every card is that type — the type badge on
    // each cover is redundant (the header already says "Video"/"Manga"/
    // "Novel"), so hide it to declutter.
    final hideTypeBadge = ref
        .watch(favoritePageProvider.select((s) => s.selectedTypes))
        .isNotEmpty;
    return Dismissible(
      key: Key(favorite.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: context.theme.colors.destructive,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(
          FLucideIcons.heartMinus,
          color: context.theme.colors.background,
        ),
      ),
      confirmDismiss: (_) async {
        await _confirmDelete(context, favorite);
        return false;
      },
      child: _FavoriteCard(
        title: favorite.title,
        // Subtitle is the AniList progress line only (e.g. "WATCHING · Ep
        // 8/12"). The extension name is deliberately NOT shown — it's not
        // useful at a glance on the card (the source is implied by the
        // cover/type). When there's no AniList link, the subtitle is empty.
        subtitle: anilist?.progressLabel ?? '',
        imageUrl: favorite.cover,
        type: stringToExtensionType(favorite.type),
        score: anilist?.score,
        hideTypeBadge: hideTypeBadge,
        onTap: () => _openDetail(context, favorite),
        onLongPress: () {
          showRemoveSheet(
            context: context,
            title: favorite.title,
            actionLabel: 'common.remove_favorite'.i18n,
            actionIcon: FLucideIcons.heartMinus,
            onRemove: () => _confirmDelete(context, favorite),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(
      favoritePageProvider.select((s) => s.filteredFavorites),
    );

    return DeviceUtil.deviceWidget(
      context: context,
      desktop: _FavoriteDesktopView(
        onTap: _openDetail,
        onManage: () => _manageGroups(context),
      ),
      mobile: _FavoriteMobileView(favorites: favorites, buildTile: _buildTile),
    );
  }
}

class _FavoriteDesktopView extends ConsumerWidget {
  const _FavoriteDesktopView({required this.onTap, required this.onManage});

  final void Function(BuildContext, Favorite) onTap;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTypes = ref.watch(
      favoritePageProvider.select((s) => s.selectedTypes),
    );
    final typeTabs = <(String, ExtensionType?)>[
      ('common.all'.i18n, null),
      ('media.video'.i18n, ExtensionType.bangumi),
      ('media.manga'.i18n, ExtensionType.manga),
      ('media.novel'.i18n, ExtensionType.fikushon),
    ];
    final initialIndex = typeTabs.indexWhere(
      (t) =>
          t.$2 == null ? selectedTypes.isEmpty : selectedTypes.contains(t.$2),
    );

    return MiruScaffold.desktop(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedBoxDelegate(
              extent: 60,
              child: FScaffold(
                childPad: false,
                resizeToAvoidBottomInset: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: .center,
                    children: [
                      Text(
                        'favorite.name'.i18n,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _GroupBadgeRow(onManage: onManage),
                      const Spacer(),
                      _FavoriteTypeTabBar(
                        tabs: typeTabs,
                        initialIndex: initialIndex < 0 ? 0 : initialIndex,
                        onChanged: (index) {
                          final type = typeTabs[index].$2;
                          ref
                              .read(favoritePageProvider.notifier)
                              .filterWithType(type == null ? {} : {type});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedBoxDelegate(
              extent: 60,
              child: FScaffold(
                childPad: false,
                resizeToAvoidBottomInset: false,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: DesktopFavoriteSearchBar(),
                ),
              ),
            ),
          ),
          SliverFillRemaining(child: _FavoriteGrid(onTap: onTap)),
        ],
      ),
    );
  }
}

/// Pins a fixed-height [child] to the top of a [CustomScrollView] using a
/// non-collapsing [SliverPersistentHeader].
class _PinnedBoxDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedBoxDelegate({required this.extent, required this.child});

  final double extent;
  final Widget child;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox(height: extent, child: child);

  @override
  bool shouldRebuild(covariant _PinnedBoxDelegate old) =>
      old.extent != extent || old.child != child;
}

class _FavoriteTypeTabBar extends StatefulWidget {
  const _FavoriteTypeTabBar({
    required this.tabs,
    required this.initialIndex,
    required this.onChanged,
  });

  final List<(String, ExtensionType?)> tabs;
  final int initialIndex;
  final void Function(int) onChanged;

  @override
  State<_FavoriteTypeTabBar> createState() => _FavoriteTypeTabBarState();
}

class _FavoriteTypeTabBarState extends State<_FavoriteTypeTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _controller.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_controller.indexIsChanging) return;
    widget.onChanged(_controller.index);
  }

  @override
  void didUpdateWidget(covariant _FavoriteTypeTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reflect external filter changes (deep links, group selection) by
    // repositioning the tab indicator only — never fire [onChanged] here, as
    // that would mutate the provider mid-build.
    if (widget.initialIndex != oldWidget.initialIndex &&
        widget.initialIndex != _controller.index) {
      _controller.animateTo(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleTabChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = context.theme.tabsStyle;
    return DecoratedBox(
      decoration: style.decoration,
      child: SizedBox(
        height: 40,
        child: TabBar(
          controller: _controller,
          tabs: [for (final tab in widget.tabs) Tab(text: tab.$1)],
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: style.padding,
          indicator: style.indicatorDecoration,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          dividerHeight: 0,
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          labelColor: context.theme.colors.foreground,
          unselectedLabelColor: context.theme.colors.mutedForeground,
          labelStyle: context.theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: context.theme.typography.body.sm,
        ),
      ),
    );
  }
}

class _FavoriteGrid extends ConsumerWidget {
  const _FavoriteGrid({required this.onTap});

  final void Function(BuildContext, Favorite) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(
      favoritePageProvider.select((s) => s.filteredFavorites),
    );
    if (favorites.isEmpty) {
      return Center(child: Text('common.no_results'.i18n));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(15.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: DeviceUtil.getWidth(context) * .875 ~/ 220,
        childAspectRatio: 0.6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        return MiruDesktopGridTile(
          title: favorite.title,
          titleMaxline: 2,
          subtitle:
              ref
                  .watch(extensionPageProvider.select((s) => s.metaData))
                  .where((e) => e.packageName == favorite.package)
                  .firstOrNull
                  ?.name ??
              'common.package_not_found'.i18n,
          imageUrl: favorite.cover,
          onTap: () => onTap(context, favorite),
        );
      },
    );
  }
}

class _FavoriteMobileView extends HookConsumerWidget {
  const _FavoriteMobileView({required this.favorites, required this.buildTile});

  final List<Favorite> favorites;
  final Widget Function(BuildContext, Favorite) buildTile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final scrollPosition = useValueNotifier(0.0);
    final axisCnt = DeviceUtil.isMobileLayout(context)
        ? (MediaQuery.of(context).size.width ~/ 140).clamp(2, 8)
        : (MediaQuery.of(context).size.width * .875 ~/ 160).clamp(2, 12);

    return MiruScaffold.mobile(
      childPad: false,
      scrollController: scrollController,
      onScrollChange: (offset, _) => scrollPosition.value = offset,
      sliverHeaders: [
        // Title bar: Forui SnapSheetHeader (same as the extension page),
        // collapsing like the sibling pages.
        FlexibleHeaderDelegate(
          maxExtent: 56,
          minExtent: 0,
          scrollPosition: scrollPosition,
          builder: (context, shrinkOffset, shrinkProgress) {
            return SnapSheetHeader(
              title: 'favorite.name'.i18n,
              // Left padding 8 to align the title with the grid's left edge
              // (grid uses horizontal 8, matching Search/Extension).
              padding: const EdgeInsets.only(left: 8, bottom: 10, right: 4),
              suffix: const [_FavoriteHeaderActions()],
            );
          },
        ),
        // Pinned search + tag row under the title (Forui style, same pattern
        // as the extension page's searchHeaderSliver). The type filter now
        // lives in the header's upper-right (_HeaderTypeTabs), so this block
        // is just search + the tag row — no separate type row.
        searchHeaderSliver(
          context,
          // search field (~54) + gap (2) + tag row (40) = ~96, plus the
          // Column's own vertical padding (2+4). 104 leaves headroom so the
          // Column never overflows inside the pinned header.
          extent: 104,
          child: const _FavoriteControls(),
        ),
      ],
      slivers: [
        if (favorites.isEmpty)
          SliverFillRemaining(
            child: Center(child: Text('common.no_results'.i18n)),
          )
        else
          SliverPadding(
            // Match MiruGridView's mobile padding but tighter (user: compact):
            // horizontal 6, bottom 190 for the bottom-nav clearance.
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 190),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 4,
                mainAxisSpacing: 6,
                crossAxisCount: axisCnt,
                // Cover (2/3) is the card's only content — the title/subtitle
                // are overlaid on it, so the cell is exactly the cover's
                // aspect (width/height = 1/1.5 = 0.667). The old 0.5 forced
                // each cell to 2× its width, leaving ~0.5×width of empty
                // space below the 2/3 cover — that was the "large gap". 0.667
                // makes the cell hug the cover with no dead space.
                childAspectRatio: 0.667,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => buildTile(context, favorites[index]),
                childCount: favorites.length,
              ),
            ),
          ),
      ],
    );
  }
}

/// Pinned controls: a Forui search field, then the two filter tiers as
/// DISTINCT grouped blocks — a labelled "type" track and a labelled "tags"
/// row. Two identically-styled stacked rows read as one homogeneous list
/// (Gestalt similarity/proximity); the labels make the hierarchy explicit
/// instead of leaving the user to guess which row is which.
class _FavoriteControls extends HookConsumerWidget {
  const _FavoriteControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritePageProvider);
    final searchController = useTextEditingController(text: state.query);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchFieldRow(
            field: searchField(
              controller: searchController,
              hint: 'common.search_for_favorites'.i18n,
              onChange: (value) {
                ref
                    .read(favoritePageProvider.notifier)
                    .filterWithKeyword(value);
              },
              onSubmit: (value) {
                ref
                    .read(favoritePageProvider.notifier)
                    .filterWithKeyword(value);
              },
            ),
          ),
          const SizedBox(height: 2),
          // Type filter now lives in the header's upper-right (see
          // _HeaderTypeTabs). This block keeps only search + the tag row.
          const SizedBox(height: 40, child: _FavoriteTagRow()),
        ],
      ),
    );
  }
}

/// A tag chip for the favorites "tags" row.
///
/// Deliberately distinct from the type-filter chips: a tag chip leads with a
/// small primary-colored dot + the group name + a dimmed count, so the tags
/// row reads as a different facet. Uses Forui theme colors only (user
/// directive: too many colors confuse) — the dot and the selected fill both
/// use the single `primary` token, so all tags read as one cohesive set.
class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Reuse the Search page's SearchPill (the app's real filter-pill, built on
    // FButton with primary/outline variants + count). Same component as the
    // search filter strip — one filter-chip language across the app, no
    // lookalike. Uses the default minHeight (28) exactly like the search
    // filter strip, so the pills are pixel-identical.
    return SearchPill(
      label: label,
      count: count,
      selected: selected,
      onTap: onTap,
    );
  }
}

class _FavoriteHeaderActions extends ConsumerWidget {
  const _FavoriteHeaderActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [const _HeaderTypeTabs()],
    );
  }
}

/// Compact icon-only type filter for the header's upper-right (user
/// directive: Video / Manga / Novel live in the header, not a separate row).
/// Each type is a 36px tappable segment; the selected one fills with the
/// primary accent, the rest are muted icons. Tapping the selected type again
/// clears it (back to All). Sits in the SnapSheetHeader suffix next to the
/// title, so it costs zero extra vertical rows.
class _HeaderTypeTabs extends ConsumerWidget {
  const _HeaderTypeTabs();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTypes = ref.watch(
      favoritePageProvider.select((s) => s.selectedTypes),
    );
    // Compact icon-only segmented control for the header's upper-right (user
    // directive: icons, not text, in the top-right). The first segment is a
    // GENERAL "All" icon (clears the type filter); then Video / Manga / Novel
    // with their media glyphs. The selected one fills with the primary accent.
    final tabs = <(ExtensionType?, IconData)>[
      (null, FLucideIcons.layers), // All — general Lucide layers icon (reads as "all", avoids grid/list collision)
      (ExtensionType.bangumi, FLucideIcons.clapperboard),
      (ExtensionType.manga, FLucideIcons.bookOpen),
      (ExtensionType.fikushon, FLucideIcons.scrollText),
    ];
    final colors = context.theme.colors;
    return Container(
      height: 44,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.muted.withAlpha(40),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final tab in tabs)
            FTappable(
              onPress: () {
                final notifier = ref.read(favoritePageProvider.notifier);
                // The "All" tab (type == null) clears the type filter; a
                // selected media type toggles off back to All.
                if (tab.$1 == null || selectedTypes.contains(tab.$1)) {
                  notifier.filterWithType({});
                } else {
                  notifier.filterWithType({tab.$1!});
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      (tab.$1 == null
                          ? selectedTypes.isEmpty
                          : selectedTypes.contains(tab.$1))
                      ? colors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  tab.$2,
                  size: 18,
                  color:
                      (tab.$1 == null
                          ? selectedTypes.isEmpty
                          : selectedTypes.contains(tab.$1))
                      ? colors.background
                      : colors.mutedForeground,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Ordering for two favorite-group names.
///
/// Case-folded compare first so casing never reorders a tag, then raw code
/// points as a tie-break so names that fold equal (e.g. `あ１` vs a full-width
/// variant) keep a stable, deterministic order instead of depending on the
/// list's incoming order.
int compareFavoriteGroupNames(String a, String b) {
  final folded = a.trim().toLowerCase().compareTo(b.trim().toLowerCase());
  return folded != 0 ? folded : a.compareTo(b);
}

/// The tag row of the filter block: a single horizontal scroll of ALL the
/// user's tags, with the Filter button PINNED at the end (outside the scroll
/// — `Row([Expanded(scrolling tags), FilterButton])`). The user can have
/// unlimited tags; they all scroll, and the Filter button opens the full
/// filter sheet for the long tail. No '+N' chip, no 'All' chip (the header's
/// 'All' type tab + the filter sheet handle clearing).
/// (The type filter lives in the header's upper-right — see
/// [_HeaderTypeTabs].)
class _FavoriteTagRow extends ConsumerWidget {
  const _FavoriteTagRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(
      favoritePageProvider.select((s) => s.favoriteGroups),
    );
    final selectedGroups = ref.watch(
      favoritePageProvider.select((s) => s.selectedFavoriteGroups),
    );
    final selectedNames = {
      for (final g in selectedGroups) favoriteGroupKey(g.name),
    };
    // Locale-aware ordering: raw UTF-16 `compareTo` orders non-ASCII tags
    // (kana, hangul, accented Latin) by code unit, which does not match what
    // the user reads as alphabetical. Compare through a case-folded key with
    // a code-point tie-break so `あ１` and its variants sort together and
    // deterministically.
    final sortedGroups = [...groups]
      ..sort((a, b) => compareFavoriteGroupNames(a.name, b.name));

    return Row(
      children: [
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: sortedGroups.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final group = sortedGroups[index];
              return SizedBox(
                height: 44,
                child: Center(
                  child: _TagChip(
                    label: group.name,
                    count: group.favorites.length,
                    selected: selectedNames.contains(
                      favoriteGroupKey(group.name),
                    ),
                    onTap: () => ref
                        .read(favoritePageProvider.notifier)
                        .toggleGroupName(group.name),
                  ),
                ),
              );
            },
          ),
        ),
        // Vertical divider between the scrolling tag chips and the pinned
        // filter button, at the end — separates the two facets so the filter
        // action reads as a distinct control, not another chip.
        Container(
          width: 1,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          color: context.theme.colors.border,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.theme.colors.background.withAlpha(0),
                context.theme.colors.background.withAlpha(180),
                context.theme.colors.background,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.only(right: 12, left: 24),
          child: Center(
            child: _FilterButton(onTap: () => showFavoriteGroupSheet(context)),
          ),
        ),
      ],
    );
  }
}

/// Trailing filter button on the tag rail — opens the full filter sheet.
class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final radius = context.theme.style.borderRadius.md;
    return FTappable(
      onPress: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.muted.withAlpha(40),
          borderRadius: radius,
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FLucideIcons.slidersHorizontal,
              size: 12,
              color: colors.foreground,
            ),
            const SizedBox(width: 4),
            Text(
              'common.filter'.i18n,
              style: context.theme.typography.body.xs.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Forui-style favorite card: a 2/3 cover on top, then title + source on the
/// solid card canvas below (the FCard media-browser pattern). Replaces the
/// old `MiruMobileTile`, which drew title/source text over the cover art and
/// failed WCAG AA contrast.
///
/// History and Favorites are SEPARATE — this card renders ONLY the favorites
/// backend's own fields (title, cover, type, source). No History progress bar
/// or episode labels; "continue watching" belongs to Home, not here.
class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.type,
    this.score,
    this.hideTypeBadge = false,
    this.onTap,
    this.onLongPress,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final ExtensionType? type;
  final double? score;
  final bool hideTypeBadge;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final radius = context.theme.style.borderRadius.md;
    // Subtitle is the AniList progress line only (e.g. "WATCHING · Ep 8/12").
    // The "<TYPE> · Added <Mon Year>" fallback was removed —
    // the type is already shown by the top-left badge, and the date is not
    // useful at a glance on the cover. When there's no AniList link, the
    // subtitle is empty and only the title shows.
    final subtitleText = subtitle;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: MiruCard(
        style: FCardStyleDelta.delta(
          decoration: .boxDelta(
            borderRadius: radius,
            border: .all(color: colors.border, width: 1),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        // Single cohesive tile: the title + subtitle are overlaid on the
        // bottom of the cover with a gradient scrim (Netflix/Apple TV poster
        // style) — one image tile instead of image + text-below. The type
        // badge (top-left) and score badge (top-right) stay as overlays. The
        // gradient ramps to ~92% black at the bottom edge so white text keeps
        // WCAG AA contrast over unpredictable cover art, plus a text shadow.
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ImageWidget(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errChild: _CoverFallback(title: title, type: type),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.4, 0.6, 0.8, 1.0],
                      colors: [
                        Colors.black.withAlpha(0),
                        Colors.black.withAlpha(60),
                        Colors.black.withAlpha(190),
                        Colors.black.withAlpha(242),
                      ],
                    ),
                  ),
                ),
              ),
              // Type badge overlay (top-left) — only when NO type filter is
              // active. When a type is selected, every card is that type and
              // the header already names it, so the per-card badge is
              // redundant noise.
              if (!hideTypeBadge)
                Positioned(top: 6, left: 6, child: _TypeBadge(type: type)),

              if (score != null && score! > 0)
                Positioned(top: 6, right: 6, child: _ScoreBadge(score: score!)),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.typography.body.xs2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.25,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (subtitleText.isNotEmpty)
                      Text(
                        subtitleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.theme.typography.body.xs.copyWith(
                          color: Colors.white.withAlpha(204),
                          fontWeight: FontWeight.w500,
                          shadows: const [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact media-type chip for a favorite card (VIDEO / MANGA / NOVEL).
///
/// [type] may be null (unknown type): the widget then renders an empty box,
/// so the card keeps its fixed height and the grid rows still align.
class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final ExtensionType? type;

  @override
  Widget build(BuildContext context) {
    final resolved = type;
    if (resolved == null) return const SizedBox(height: 16);
    final (label, icon) = switch (resolved) {
      ExtensionType.bangumi => ('VIDEO', FLucideIcons.clapperboard),
      ExtensionType.manga => ('MANGA', FLucideIcons.bookOpen),
      ExtensionType.fikushon => ('NOVEL', FLucideIcons.bookText),
      _ => ('MIXED', FLucideIcons.library),
    };
    return Container(
      // Solid dark background so the badge reads over any cover art (it is
      // an overlay now, not a footer row on the card canvas).
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(160),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.theme.typography.body.xs.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

/// AniList score badge for the top-right of a favorite card's cover.
/// Shows the mean score (0-100) as "★ 85". Hidden when unscored.
class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(160),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 10, color: Colors.amber),
          const SizedBox(width: 3),
          Text(
            '${score.round()}',
            style: context.theme.typography.body.xs.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

/// Styled fallback for a favorite whose extension returned no cover (common
/// for torrent/fansub sources). A layered charcoal gradient + a media-type
/// glyph + the title's leading characters — deliberately NOT a bare
/// "missing image" icon, which reads as a broken UI in the primary focal spot.
class _CoverFallback extends StatelessWidget {
  const _CoverFallback({required this.title, this.type});

  final String title;
  final ExtensionType? type;

  /// Strips release-group brackets and takes the first meaningful token, so
  /// the fallback shows something readable instead of "[Group] …".
  String get _initials {
    final cleaned = title
        .replaceAll(RegExp(r'\[[^\]]*\]'), ' ')
        .replaceAll(RegExp(r'[_\-]+'), ' ')
        .trim();
    if (cleaned.isEmpty) return '?';
    final words = cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final head = words.take(2).join(' ');
    return head.length > 14 ? head.substring(0, 14) : head;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final icon = switch (type) {
      ExtensionType.bangumi => FLucideIcons.clapperboard,
      ExtensionType.manga => FLucideIcons.bookOpen,
      ExtensionType.fikushon => FLucideIcons.bookText,
      _ => FLucideIcons.library,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.muted.withAlpha(55),
            colors.muted.withAlpha(20),
            colors.background,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 26, color: colors.mutedForeground),
            const Spacer(),
            Text(
              _initials,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.theme.typography.body.sm.copyWith(
                color: colors.mutedForeground,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desktop group badge row (kept for the desktop view's header): shows the
/// selected favorite-group chips, or "All tags" when none are selected.
class _GroupBadgeRow extends ConsumerWidget {
  const _GroupBadgeRow({required this.onManage});

  final VoidCallback onManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGroups = ref.watch(
      favoritePageProvider.select((s) => s.selectedFavoriteGroups),
    );

    final badges = <Widget>[];
    if (selectedGroups.isEmpty) {
      badges.add(FBadge(child: Text('favorite.all-tags'.i18n)));
    } else if (selectedGroups.length <= 2) {
      badges.addAll(
        selectedGroups.map(
          (g) => FBadge(variant: .android, child: Text(g.name)),
        ),
      );
    } else {
      final shown = selectedGroups.take(2).map((g) => g.name).join(', ');
      badges.add(
        FBadge(
          variant: .android,
          child: Text('$shown +(${selectedGroups.length - 2})'),
        ),
      );
    }

    return FTappable(
      onPress: onManage,
      child: Wrap(spacing: 4, runSpacing: 4, children: badges),
    );
  }
}
