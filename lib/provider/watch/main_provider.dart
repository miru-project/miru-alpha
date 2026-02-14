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
  List<FavoriateGroup> favoriateGroups;
  List<Favorite> favorites;
  int historyPage;
  bool historyHasMore;
  MainPageState({
    this.selectedIndex = 0,
    this.selectedGroups = const [],
    this.searchText = '',
    this.history = const [],
    this.favoriateGroups = const [],
    this.favorites = const [],
    this.historyPage = 1,
    this.historyHasMore = true,
  });

  MainPageState copyWith({
    int? selectedIndex,
    List<int>? selectedGroups,
    String? searchText,
    List<History>? history,
    List<FavoriateGroup>? favoriateGroups,
    List<Favorite>? favorites,
    int? historyPage,
    bool? historyHasMore,
  }) {
    return MainPageState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectedGroups: selectedGroups ?? this.selectedGroups,
      searchText: searchText ?? this.searchText,
      history: history ?? this.history,
      favoriateGroups: favoriateGroups ?? this.favoriateGroups,
      favorites: favorites ?? this.favorites,
      historyPage: historyPage ?? this.historyPage,
      historyHasMore: historyHasMore ?? this.historyHasMore,
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
          favoriateGroups: value[0] as List<FavoriateGroup>,
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

  void setSearchText(String text) {
    state = state.copyWith(searchText: text);
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
  }

  void updateFavorite(Favorite favorite) {
    state = state.copyWith(
      favorites: state.favorites.where((e) => e.id != favorite.id).toList(),
    );
  }

  void updateFavoriteGroup(FavoriateGroup favoriateGroup) {
    state = state.copyWith(
      favoriateGroups: state.favoriateGroups
          .where((e) => e.id != favoriateGroup.id)
          .toList(),
    );
  }

  void addFavorite(Favorite favorite) {
    state = state.copyWith(favorites: [favorite, ...state.favorites]);
  }

  void addFavoriteGroup(FavoriateGroup favoriateGroup) {
    state = state.copyWith(
      favoriateGroups: [favoriateGroup, ...state.favoriateGroups],
    );
  }

  void removeFavorite(Favorite favorite) {
    state = state.copyWith(
      favorites: state.favorites.where((e) => e.id != favorite.id).toList(),
    );
  }

  void removeFavoriteGroup(FavoriateGroup favoriateGroup) {
    state = state.copyWith(
      favoriateGroups: state.favoriateGroups
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

  Future<void> loadMoreHistory() async {
    if (!state.historyHasMore) return;
    const pageSize = 20;
    final nextPage = state.historyPage + 1;
    final history = await DatabaseService.getHistoriesByType(
      page: nextPage,
      pageSize: pageSize,
    );
    state = state.copyWith(
      history: [...state.history, ...history],
      historyPage: nextPage,
      historyHasMore: history.length >= pageSize,
    );
  }
}
