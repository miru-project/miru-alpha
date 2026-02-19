import 'package:miru_app_new/model/model.dart';
import 'package:miru_app_new/model/user_data.dart';
import 'package:miru_app_new/utils/store/database_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'favorite_page_provider.g.dart';

class FavoritePageState {
  final List<Favorite> favorites;
  final List<Favorite> filteredFavorites;
  final List<FavoriteGroup> favoriteGroups;
  final List<FavoriteGroup> selectedFavoriteGroups;
  FavoritePageState({
    required this.favorites,
    required this.favoriteGroups,
    required this.filteredFavorites,
    required this.selectedFavoriteGroups,
  });

  FavoritePageState copyWith({
    List<Favorite>? favorites,
    List<FavoriteGroup>? favoriteGroups,
    List<Favorite>? filteredFavorites,
    List<FavoriteGroup>? selectedFavoriteGroups,
  }) {
    return FavoritePageState(
      filteredFavorites: filteredFavorites ?? this.filteredFavorites,
      favorites: favorites ?? this.favorites,
      favoriteGroups: favoriteGroups ?? this.favoriteGroups,
      selectedFavoriteGroups:
          selectedFavoriteGroups ?? this.selectedFavoriteGroups,
    );
  }
}

@Riverpod(keepAlive: true)
class FavoritePageNotifier extends _$FavoritePageNotifier {
  String cacheKeyword = '';
  Duration cacheDuration = const Duration(days: 36500);
  Set<ExtensionType> cacheType = {};
  List<FavoriteGroup> cacheFavGroup = [];
  @override
  FavoritePageState build() {
    Future.microtask(init);
    return FavoritePageState(
      favorites: [],
      favoriteGroups: [],
      filteredFavorites: [],
      selectedFavoriteGroups: [],
    );
  }

  // INIT
  Future<void> init() async {
    await refreshFavoritesAndGroup();
    state = state.copyWith(filteredFavorites: state.favorites);
  }

  //REFRESH
  Future<void> refreshFavoritesAndGroup() async {
    final futures = await Future.wait([
      DatabaseService.getAllFavoriteGroup(),
      DatabaseService.getAllFavorite(),
    ]);
    state = state.copyWith(
      favoriteGroups: futures[0] as List<FavoriteGroup>,
      favorites: futures[1] as List<Favorite>,
    );
    filterFavoriteGroups(cacheFavGroup);
    filter(cacheType, cacheKeyword, cacheDuration);
  }

  // DELETE
  void deleteFavorite(Favorite favorite) {
    state = state.copyWith(
      favorites: state.favorites.where((e) => e.id != favorite.id).toList(),
      filteredFavorites: state.filteredFavorites
          .where((e) => e.id != favorite.id)
          .toList(),
    );
    DatabaseService.deleteFavorite(favorite.url, favorite.package);
  }

  void deleteFavoriteGroup(FavoriteGroup favoriateGroup) {
    state = state.copyWith(
      favoriteGroups: state.favoriteGroups
          .where((e) => e.id != favoriateGroup.id)
          .toList(),
    );
    DatabaseService.deleteFavoriteGroup([favoriateGroup.name]);
  }

  // ADD
  void addFavorite(Favorite favorite) {
    state = state.copyWith(favorites: [favorite, ...state.favorites]);
  }

  void addFavoriteGroupbyName(String name) {
    state = state.copyWith(
      favoriteGroups: [
        FavoriteGroup(name: name, date: DateTime.now()),
        ...state.favoriteGroups,
      ],
    );
  }

  // FILTER FAVORITES
  void filter(Set<ExtensionType> type, String keyword, Duration duration) {
    final now = DateTime.now();
    List<Favorite> typeResult = state.favorites;
    if (type.isNotEmpty) {
      typeResult = state.favorites
          .where((e) => type.contains(stringToExtensionType(e.type)))
          .toList();
    }
    List<Favorite> keywordResult = typeResult;
    if (keyword.isNotEmpty) {
      keywordResult = typeResult
          .where((e) => e.title.contains(keyword))
          .toList();
    }
    List<Favorite> durationResult = keywordResult;
    if (duration != const Duration(days: 36500)) {
      durationResult = keywordResult
          .where((e) => now.difference(e.date) <= duration)
          .toList();
    }
    state = state.copyWith(filteredFavorites: durationResult);
  }

  void filterWithType(Set<ExtensionType> type) {
    cacheType = type;
    filter(type, cacheKeyword, cacheDuration);
  }

  void filterWithKeyword(String keyword) {
    cacheKeyword = keyword;
    filter(cacheType, keyword, cacheDuration);
  }

  void filterWithDuration(Duration duration) {
    cacheDuration = duration;
    filter(cacheType, cacheKeyword, duration);
  }

  // FILTER FAVORITE GROUPS
  //  At mobile home favorite page
  void filterFavoriteGroups(List<FavoriteGroup> favGroups) {
    cacheFavGroup = favGroups;
    if (favGroups.isEmpty) {
      state = state.copyWith(
        filteredFavorites: state.favorites,
        selectedFavoriteGroups: [],
      );
      return;
    }
    final favGroup = state.favoriteGroups
        .where((e) => favGroups.contains(e))
        .toList();

    final favs = favGroup.expand((e) => e.favorites).toList();
    state = state.copyWith(
      filteredFavorites: favs,
      selectedFavoriteGroups: favGroups,
    );
  }

  // CREATE FAVORITE GROUP
  Future<void> createFavoriteGroup(String name) async {
    final newGroup = await DatabaseService.putFavoriteGroup(name);
    state = state.copyWith(favoriteGroups: [newGroup, ...state.favoriteGroups]);
  }

  // UPDATE
  void updateFavorites({
    List<FavoriteGroup>? favoriteGroup,
    List<Favorite>? favorites,
  }) {
    state = state.copyWith(
      favoriteGroups: favoriteGroup ?? state.favoriteGroups,
      favorites: favorites ?? state.favorites,
    );
  }
}
