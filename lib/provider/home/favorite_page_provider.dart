import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/utils/store/database_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'favorite_page_provider.g.dart';

enum FavoriteFilterMode { and, or }

class FavoritePageState {
  final List<Favorite> favorites;
  final List<Favorite> filteredFavorites;
  final List<FavoriteGroup> favoriteGroups;
  final List<FavoriteGroup> selectedFavoriteGroups;
  final Set<ExtensionType> selectedTypes;
  final FavoriteFilterMode filterMode;
  final String query;
  final String filterSummary;
  FavoritePageState({
    required this.favorites,
    required this.favoriteGroups,
    required this.filteredFavorites,
    required this.selectedFavoriteGroups,
    this.selectedTypes = const {},
    this.filterMode = FavoriteFilterMode.or,
    this.query = '',
    this.filterSummary = '',
  });

  FavoritePageState copyWith({
    List<Favorite>? favorites,
    List<FavoriteGroup>? favoriteGroups,
    List<Favorite>? filteredFavorites,
    List<FavoriteGroup>? selectedFavoriteGroups,
    Set<ExtensionType>? selectedTypes,
    FavoriteFilterMode? filterMode,
    String? query,
    String? filterSummary,
  }) {
    return FavoritePageState(
      filteredFavorites: filteredFavorites ?? this.filteredFavorites,
      favorites: favorites ?? this.favorites,
      favoriteGroups: favoriteGroups ?? this.favoriteGroups,
      selectedFavoriteGroups:
          selectedFavoriteGroups ?? this.selectedFavoriteGroups,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      filterMode: filterMode ?? this.filterMode,
      query: query ?? this.query,
      filterSummary: filterSummary ?? this.filterSummary,
    );
  }
}

@Riverpod(keepAlive: true)
class FavoritePageNotifier extends _$FavoritePageNotifier {
  String cacheKeyword = '';
  Duration cacheDuration = const Duration(days: 36500);
  Set<ExtensionType> cacheType = {};
  List<FavoriteGroup> cacheFavGroup = [];
  FavoriteFilterMode cacheFilterMode = FavoriteFilterMode.or;
  @override
  FavoritePageState build() {
    Future.microtask(init);
    return FavoritePageState(
      favorites: [],
      favoriteGroups: [],
      filteredFavorites: [],
      selectedFavoriteGroups: [],
      selectedTypes: {},
      filterMode: FavoriteFilterMode.or,
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
    final summary = <String>[];
    if (type.isNotEmpty) {
      summary.add('type: ${type.map((e) => e.name).join(',')}');
    }
    if (keyword.isNotEmpty) {
      summary.add('keyword: $keyword');
    }
    state = state.copyWith(
      filteredFavorites: durationResult,
      query: keyword,
      filterSummary: summary.join(' | '),
    );
  }

  void filterWithType(Set<ExtensionType> type) {
    cacheType = type;
    state = state.copyWith(selectedTypes: type);
    filter(type, cacheKeyword, cacheDuration);
  }

  /// Convenience used by the router-driven list views. `null` or
  /// [ExtensionType.all] clears the type filter; otherwise a single type is
  /// applied.
  void setTypeFilter(ExtensionType? type) {
    filterWithType(type == null || type == ExtensionType.all ? {} : {type});
  }

  /// Toggle the AND/OR filtering mode for selected favorite groups.
  void setFilterMode(FavoriteFilterMode mode) {
    cacheFilterMode = mode;
    filterFavoriteGroups(state.selectedFavoriteGroups);
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

    final favs = cacheFilterMode == FavoriteFilterMode.and
        ? _intersectFavorites(favGroup)
        : favGroup.expand((e) => e.favorites).toList();
    state = state.copyWith(
      filteredFavorites: favs,
      selectedFavoriteGroups: favGroups,
    );
  }

  List<Favorite> _intersectFavorites(List<FavoriteGroup> groups) {
    if (groups.isEmpty) return [];
    final first = groups.first.favorites.toSet();
    var result = first;
    for (var i = 1; i < groups.length; i++) {
      result = result.intersection(groups[i].favorites.toSet());
    }
    // Preserve order from the first group
    return groups.first.favorites.where((f) => result.contains(f)).toList();
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
