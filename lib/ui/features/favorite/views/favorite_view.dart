import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/features/favorite/widget/desktop_favorite_search_bar.dart';
import 'package:miru_alpha/ui/features/favorite/widget/favorite_group_dialog.dart';
import 'package:miru_alpha/ui/features/history_favorite/shared/list_helpers.dart';
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
    if (widget.type != null) {
      Future.microtask(
        () =>
            ref.read(favoritePageProvider.notifier).setTypeFilter(widget.type),
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
      body: 'common.favorite.remove_favorite_confirm'.i18n,
      onConfirm: () =>
          ref.read(favoritePageProvider.notifier).deleteFavorite(favorite),
    );
  }

  Future<void> _manageGroups(BuildContext context) async {
    if (!context.mounted) return;
    await showMiruDialog<void>(
      context: context,
      builder: (ctx, style, animation) =>
          FavoriteGroupDialog(context: ctx, style: style, animation: animation),
    );
  }

  Widget _buildTile(BuildContext context, Favorite favorite) {
    final meta = ref
        .read(extensionPageProvider)
        .metaData
        .where((e) => e.packageName == favorite.package)
        .firstOrNull;
    final subtitle = meta?.name ?? 'common.package_not_found'.i18n;
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
      child: MiruMobileTile(
        title: favorite.title,
        subtitle: subtitle,
        imageUrl: favorite.cover,
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
      mobile: _FavoriteMobileView(
        favorites: favorites,
        buildTile: _buildTile,
        onManage: () => _manageGroups(context),
      ),
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

class _FavoriteMobileView extends StatelessWidget {
  const _FavoriteMobileView({
    required this.favorites,
    required this.buildTile,
    required this.onManage,
  });

  final List<Favorite> favorites;
  final Widget Function(BuildContext, Favorite) buildTile;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final axisCnt = DeviceUtil.isMobileLayout(context)
        ? (MediaQuery.of(context).size.width ~/ 140).clamp(2, 8)
        : (MediaQuery.of(context).size.width * .875 ~/ 160).clamp(2, 12);

    return MiruScaffold.mobile(
      childPad: true,
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: StaticSliverHeaderDelegate(
            maxExtent: 110,
            minExtent: 110,
            child: _FavoriteHeader(onManage: onManage),
          ),
        ),
        if (favorites.isEmpty)
          SliverFillRemaining(
            child: Center(child: Text('common.no_results'.i18n)),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              8,
              8,
              8,
              DeviceUtil.isMobileLayout(context) ? 190 : 16,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: axisCnt,
                childAspectRatio: 0.65,
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

class _FavoriteHeader extends ConsumerWidget {
  const _FavoriteHeader({required this.onManage});

  final VoidCallback onManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTypes = ref.watch(
      favoritePageProvider.select((s) => s.selectedTypes),
    );
    final typeTabs = <Map<String, dynamic>>[
      {'label': 'common.all'.i18n, 'type': null},
      {'label': 'media.video'.i18n, 'type': ExtensionType.bangumi},
      {'label': 'media.manga'.i18n, 'type': ExtensionType.manga},
      {'label': 'media.novel'.i18n, 'type': ExtensionType.fikushon},
    ];

    return FScaffold(
      childPad: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const HeaderBack(),
                Expanded(
                  child: Text(
                    'favorite.name'.i18n,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _GroupBadgeRow(onManage: onManage),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: typeTabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final tab = typeTabs[index];
                  final type = tab['type'] as ExtensionType?;
                  final isSelected = type == null
                      ? selectedTypes.isEmpty
                      : selectedTypes.contains(type);
                  return FButton(
                    size: .xs,
                    variant: isSelected
                        ? FButtonVariant.primary
                        : FButtonVariant.secondary,
                    onPress: () {
                      ref
                          .read(favoritePageProvider.notifier)
                          .filterWithType(type == null ? {} : {type});
                    },
                    child: Text(tab['label'] as String),
                  );
                },
              ),
            ),
            const FDivider(
              style: FDividerStyleDelta.delta(padding: .value(.only(top: 10))),
            ),
          ],
        ),
      ),
    );
  }
}

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
      badges.add(FBadge(child: Text('common.all'.i18n)));
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
