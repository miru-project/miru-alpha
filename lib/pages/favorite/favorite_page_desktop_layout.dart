import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
import 'package:miru_app_new/provider/watch/main_provider.dart';
import 'package:miru_app_new/utils/store/database_service.dart';
import 'package:miru_app_new/model/index.dart';
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

class _FavoritePageState extends ConsumerState<FavoritePage>
    with AutomaticKeepAliveClientMixin {
  final ValueNotifier<List<FavoriateGroup>> _favGroup = ValueNotifier([]);
  List<Favorite> filterFav = [];
  final ValueNotifier<List<Favorite>> _fav = ValueNotifier([]);
  List<Favorite> allFav = [];
  @override
  get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refreshGroups();
  }

  Future<void> _refreshGroups() async {
    try {
      final futures = await Future.wait([
        DatabaseService.getAllFavoriteGroup(),
        DatabaseService.getAllFavorite(),
      ]);
      _favGroup.value = futures[0] as List<FavoriateGroup>;
      allFav = futures[1] as List<Favorite>;

      _fav.value = filterFavoriteByGroup(allFav);
      filterFav = _fav.value;
    } catch (e) {
      debugPrint("Error loading favorites: $e");
    }
  }

  List<Favorite> filterBySearch(List<Favorite> fav) {
    final search = ref.read(mainProvider).searchText;
    if (search.isEmpty) {
      return fav;
    }
    return fav
        .where(
          (element) =>
              element.title.toLowerCase().contains(search.toLowerCase()),
        )
        .toList();
  }

  List<Favorite> filterFavoriteByGroup(List<Favorite> fav) {
    final selected = ref.read(mainProvider).selectedGroups;

    // If no group selected, show all favorites
    List<Favorite> result;
    if (selected.isEmpty) {
      result = fav;
    } else {
      final List<FavoriateGroup> selectedFavGroup = [];
      for (int index in selected) {
        if (index < _favGroup.value.length) {
          selectedFavGroup.add(_favGroup.value[index]);
        }
      }

      final Set<int> allowedFavIds = {};
      for (final group in selectedFavGroup) {
        allowedFavIds.addAll(group.favorites.map((e) => e.id));
      }

      result = fav.where((f) => allowedFavIds.contains(f.id)).toList();
    }

    // Apply search filter
    return filterBySearch(result);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MainPageState>(mainProvider, (prev, next) {
      // Re-filter when main page state (selection/search) changes
      _fav.value = filterFavoriteByGroup(allFav);
      filterFav = _fav.value;
    });

    super.build(context);
    final meta = ref.read(extensionPageProvider).metaData;
    return PlatformWidget(
      desktopWidget: MiruScaffold(
        mobileHeader: SnapSheetHeader(title: 'Home'),
        body: Column(
          children: [
            FavoriteTab(onGroupChanged: _refreshGroups),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _fav,
                builder: (context, fav, _) => GridView.builder(
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
            ),
          ],
        ),
      ),
      mobileWidget: ValueListenableBuilder(
        valueListenable: _fav,
        builder: (context, fav, _) => GridView.builder(
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
            );
          },
        ),
      ),
    );
  }
}
