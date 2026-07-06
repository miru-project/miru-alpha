import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/ui/core/grid_view/index.dart';
import 'package:miru_alpha/ui/features/favorite/widget/desktop_favorite_search_bar.dart';
import 'package:miru_alpha/ui/features/favorite/favorite_tab.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';

class DesktopFavoriteLayout extends ConsumerWidget {
  const DesktopFavoriteLayout({super.key, this.filterType, this.searchQuery});
  final String? filterType;
  final String? searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(
      extensionPageProvider.select((state) => state.metaData),
    );
    final fav = ref.watch(
      favoritePageProvider.select((state) => state.filteredFavorites),
    );

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverToBoxAdapter(
            child: Text(
              'common.favorite.name'.i18n,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
          ),
        ),
        SliverToBoxAdapter(child: FavoriteTab()),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverToBoxAdapter(child: DesktopFavoriteSearchBar()),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(15.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: DeviceUtil.getWidth(context) * .875 ~/ 220,
              childAspectRatio: 0.6,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final favorite = fav[index];
              return MiruDesktopGridTile(
                title: favorite.title,
                titleMaxline: 2,
                subtitle:
                    meta
                        .where((e) => e.packageName == favorite.package)
                        .firstOrNull
                        ?.name ??
                    'common.package_not_found'.i18n,
                imageUrl: favorite.cover,
                onTap: () {
                  final extMeta = meta
                      .where((e) => e.packageName == favorite.package)
                      .firstOrNull;
                  if (extMeta == null) return;
                  context.push(
                    '/search/single/detail',
                    extra: DetailParam(meta: extMeta, url: favorite.url),
                  );
                },
              );
            }, childCount: fav.length),
          ),
        ),
      ],
    );
  }
}
