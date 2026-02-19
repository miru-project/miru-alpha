import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
import 'package:miru_app_new/provider/favorite_page_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';
import 'package:miru_app_new/widgets/grid_view/index.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app_new/pages/favorite/favorite_tab.dart';

class FavoritePage extends ConsumerStatefulWidget {
  const FavoritePage({super.key});
  @override
  createState() => _FavoritePageState();
}

class _FavoritePageState extends ConsumerState<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    final meta = ref.watch(
      extensionPageProvider.select((state) => state.metaData),
    );
    final fav = ref.watch(
      favoritePageProvider.select((state) => state.filteredFavorites),
    );
    return PlatformWidget(
      desktopWidget: MiruScaffold(
        mobileHeader: SnapSheetHeader(title: 'Home'),
        body: Column(
          children: [
            FavoriteTab(),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: DeviceUtil.getWidth(context) * .875 ~/ 220,
                  childAspectRatio: 0.6,
                ),

                itemBuilder: (context, index) {
                  final favorite = fav[index];
                  return MiruDesktopGridTile(
                    title: favorite.title,
                    titleMaxline: 2,
                    subtitle:
                        meta
                            .where((e) => e.packageName == favorite.package)
                            .firstOrNull
                            ?.name ??
                        'Package Not Found',
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
                },
                itemCount: fav.length,
              ),
            ),
          ],
        ),
      ),
      mobileWidget: GridView.builder(
        padding: EdgeInsets.fromLTRB(
          8,
          8 + MediaQuery.of(context).padding.top,
          8,
          190,
        ),
        itemCount: fav.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: DeviceUtil.getWidth(context) ~/ 150,
          childAspectRatio: 0.65,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final favorite = fav[index];
          final ExtensionMeta? ext = meta.firstWhereOrNull(
            (element) => element.packageName == favorite.package,
          );
          return MiruMobileTile(
            title: favorite.title,
            subtitle: ext?.name ?? 'Package Not Found',
            imageUrl: favorite.cover,
            onTap: () {
              if (ext == null) return;
              context.push(
                '/search/single/detail',
                extra: DetailParam(meta: ext, url: favorite.url),
              );
            },
            onLongPress: () {
              showFSheet(
                context: context,
                style: .delta(
                  barrierFilter: (value) =>
                      ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                ),
                builder: (context) => Consumer(
                  builder: (context, ref, child) => FCard.raw(
                    child: Padding(
                      padding: .only(top: 10, left: 10, right: 10, bottom: 20),
                      child: FTileGroup(
                        label: Padding(
                          padding: .only(left: 6),
                          child: Text(favorite.title),
                        ),
                        children: [
                          FTile(
                            prefix: Icon(FIcons.heartMinus),
                            title: Text('Remove  Favorite'),
                            onPress: () {
                              ref
                                  .read(favoritePageProvider.notifier)
                                  .deleteFavorite(favorite);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                side: .btt,
              );
            },
          );
        },
      ),
    );
  }
}
