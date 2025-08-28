import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/utils/database_service.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
import 'package:miru_app_new/utils/watch/watch_entry.dart';
import 'package:miru_app_new/widgets/gridView/index.dart';
import 'home_page.dart';
import 'package:go_router/go_router.dart';

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
  @override
  get wantKeepAlive => true;

  @override
  void initState() {
    _fav.value = DatabaseService.getAllFavorite();
    filterFav = _fav.value;
    _favGroup.value = DatabaseService.getAllFavoriteGroup();

    ref.listen<MainPageState>(mainPageProvider, (prev, next) {
      _fav.value = filterBySearch(filterFav);
    });

    DatabaseService.fav.query().watch().listen((query) {
      _fav.value = filterFavoriteByGroup(_fav.value);
    });

    DatabaseService.favGroup.query().watch().listen((query) {
      _favGroup.value = DatabaseService.getAllFavoriteGroup();
    });

    super.initState();
  }

  List<Favorite> filterBySearch(List<Favorite> fav) {
    final search = ref.read(mainPageProvider).searchText;
    if (search.isEmpty) {
      return fav;
    }
    return filterFav
        .where((element) => element.title.toLowerCase().contains(search))
        .toList();
  }

  List<Favorite> filterFavoriteByGroup(List<Favorite> fav) {
    final selected = ref.read(mainPageProvider).selectedGroups;
    final List<FavoriateGroup> selectedFavGroup =
        selected.map((e) => _favGroup.value[e]).toList();
    final Set<int> favId = {};
    for (final group in selectedFavGroup) {
      favId.addAll(group.favorite.map((e) => e.id).toList());
    }
    final List<Favorite?> result = List.from(
      DatabaseService.fav.getMany(favId.toList()),
      growable: true,
    );
    filterFav = result.whereType<Favorite>().toList();
    final search = ref.read(mainPageProvider).searchText;
    if (search.isNotEmpty) {
      return filterBySearch(filterFav);
    }
    return filterFav;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ValueListenableBuilder(
      valueListenable: _fav,
      builder:
          (context, fav, _) => MiruGridView(
            desktopGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: DeviceUtil.getWidth(context) * .875 ~/ 220,
              childAspectRatio: 0.7,
            ),
            mobileGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: DeviceUtil.getWidth(context) ~/ 150,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              return MiruGridTile(
                title: fav[index].title,
                subtitle: fav[index].package,
                imageUrl: fav[index].cover,
                onTap: () {
                  final extensionIsExist = ExtensionUtils.runtimes.containsKey(
                    fav[index].package,
                  );
                  if (extensionIsExist) {
                    context.push(
                      '/search/detail',
                      extra: DetailParam(
                        service: ExtensionUtils.runtimes[fav[index].package]!,
                        url: fav[index].url,
                      ),
                    );
                  }
                },
              );
            },
            itemCount: fav.length,
          ),
    );
  }
}
