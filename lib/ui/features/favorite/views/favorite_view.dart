import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/features/favorite/widget/favorite_group_dialog.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';

class FavoriteView extends ConsumerStatefulWidget {
  const FavoriteView({super.key});

  @override
  ConsumerState<FavoriteView> createState() => _FavoriteViewState();
}

class _FavoriteViewState extends ConsumerState<FavoriteView> {
  void _openDetail(BuildContext context, Favorite favorite) {
    final meta = ref
        .read(extensionPageProvider)
        .metaData
        .where((e) => e.packageName == favorite.package)
        .firstOrNull;
    if (meta == null) return;
    context.push(
      '/search/single/detail',
      extra: DetailParam(meta: meta, url: favorite.url),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Favorite favorite) async {
    final confirmed = await showMiruDialog<bool>(
      context: context,
      title: Text('common.remove_favorite'.i18n),
      body: Text('common.favorite.remove_favorite_confirm'.i18n),
      actions: [
        FButton(
          variant: FButtonVariant.secondary,
          onPress: () => Navigator.pop(context, false),
          child: Text('common.cancel'.i18n),
        ),
        FButton(
          variant: FButtonVariant.destructive,
          onPress: () => Navigator.pop(context, true),
          child: Text('common.delete'.i18n),
        ),
      ],
    );
    if (confirmed == true) {
      ref.read(favoritePageProvider.notifier).deleteFavorite(favorite);
    }
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
          showFSheet(
            context: context,
            side: .btt,
            builder: (context) => FCard.raw(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10,
                  bottom: 20,
                ),
                child: FTileGroup(
                  label: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(favorite.title),
                  ),
                  children: [
                    FTile(
                      prefix: Icon(FLucideIcons.heartMinus),
                      title: Text('common.remove_favorite'.i18n),
                      onPress: () {
                        Navigator.pop(context);
                        _confirmDelete(context, favorite);
                      },
                    ),
                  ],
                ),
              ),
            ),
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
            child: _FavoriteHeader(onManage: () => _manageGroups(context)),
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
                (context, index) => _buildTile(context, favorites[index]),
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
