import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/utils/store/database_service.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'main_provider.g.dart';

class MainPageState {
  int selectedIndex;
  List<int> selectedGroups;
  String searchText;
  List<History> history;
  List<FavoriateGroup> favoriteGroups;
  List<Favorite> favorites;
  int historyPage;
  MainPageState({
    this.selectedIndex = 0,
    this.selectedGroups = const [],
    this.searchText = '',
    this.history = const [],
    this.favoriteGroups = const [],
    this.favorites = const [],
    this.historyPage = 1,
  });

  MainPageState copyWith({
    int? selectedIndex,
    List<int>? selectedGroups,
    String? searchText,
    List<History>? history,
    List<FavoriateGroup>? favoriteGroups,
    List<Favorite>? favorites,
    int? historyPage,
    bool? historyHasMore,
  }) {
    return MainPageState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectedGroups: selectedGroups ?? this.selectedGroups,
      searchText: searchText ?? this.searchText,
      history: history ?? this.history,
      favoriteGroups: favoriteGroups ?? this.favoriteGroups,
      favorites: favorites ?? this.favorites,
      historyPage: historyPage ?? this.historyPage,
    );
  }
}

@Riverpod(keepAlive: true)
class MainNotifier extends _$MainNotifier {
  @override
  MainPageState build() {
    Future.microtask(() async {
      const pageSize = 20;
      await Future.wait([
        DatabaseService.getAllFavoriteGroup(),
        DatabaseService.getAllFavorite(),
        DatabaseService.getHistoriesByType(page: 1, pageSize: pageSize),
      ]).then((value) {
        final history = value[2] as List<History>;
        state = state.copyWith(
          history: history,
          favoriteGroups: value[0] as List<FavoriateGroup>,
          favorites: value[1] as List<Favorite>,
          historyPage: 1,
          historyHasMore: history.length >= pageSize,
        );
      });
    });
    return MainPageState();
  }

  void setSelectedIndex(int index) {
    if (state.selectedIndex != index) {
      state = state.copyWith(selectedIndex: index);
    }
  }

  void setSelectedGroups(List<int> groups) {
    state = state.copyWith(selectedGroups: groups);
  }

  void updateHistory(List<History> updateValue) {
    state = state.copyWith(history: updateValue);
  }

  void registerHistory(History history) {
    DatabaseService.putHistory(history);
    Future.microtask(() {
      state = state.copyWith(history: [history, ...state.history]);
      logger.info('register history ${history.title}');
    });
  }

  void removeHistory(History history) {
    state = state.copyWith(
      history: state.history.where((e) => e.id != history.id).toList(),
    );
    DatabaseService.deleteHistoryByPackageAndUrl(history.package, history.url);
  }

  void updateFavorite(Favorite favorite) {
    state = state.copyWith(
      favorites: state.favorites.where((e) => e.id != favorite.id).toList(),
    );
  }

  void updateFavoriteGroup(FavoriateGroup favoriateGroup) {
    state = state.copyWith(
      favoriteGroups: state.favoriteGroups
          .where((e) => e.id != favoriateGroup.id)
          .toList(),
    );
  }

  void addFavorite(Favorite favorite) {
    state = state.copyWith(favorites: [favorite, ...state.favorites]);
  }

  void addFavoriteGroup(FavoriateGroup favoriateGroup) {
    state = state.copyWith(
      favoriteGroups: [favoriateGroup, ...state.favoriteGroups],
    );
  }

  void removeFavorite(Favorite favorite) {
    state = state.copyWith(
      favorites: state.favorites.where((e) => e.id != favorite.id).toList(),
    );
    DatabaseService.deleteFavorite(favorite.url, favorite.package);
  }

  void removeFavoriteGroup(FavoriateGroup favoriateGroup) {
    state = state.copyWith(
      favoriteGroups: state.favoriteGroups
          .where((e) => e.id != favoriateGroup.id)
          .toList(),
    );
  }

  Future<void> refreshHistory() async {
    const pageSize = 20;
    final history = await DatabaseService.getHistoriesByType(
      page: 1,
      pageSize: pageSize,
    );
    state = state.copyWith(
      history: history,
      historyPage: 1,
      historyHasMore: history.length >= pageSize,
    );
  }

  void refreshFavoritesAndGroup() async {
    final futures = await Future.wait([
      DatabaseService.getAllFavoriteGroup(),
      DatabaseService.getAllFavorite(),
    ]);
    state = state.copyWith(
      favoriteGroups: futures[0] as List<FavoriateGroup>,
      favorites: futures[1] as List<Favorite>,
    );
  }

  List<Favorite> filterBySearch(List<Favorite> fav) {
    final search = state.searchText;
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
    final selected = state.selectedGroups;

    // If no group selected, show all favorites
    List<Favorite> result;
    if (selected.isEmpty) {
      result = fav;
    } else {
      final List<FavoriateGroup> selectedFavGroup = [];
      for (int index in selected) {
        if (index < state.favoriteGroups.length) {
          selectedFavGroup.add(state.favoriteGroups[index]);
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
}
