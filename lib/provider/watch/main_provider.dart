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
  MainPageState({
    this.selectedIndex = 0,
    this.selectedGroups = const [],
    this.searchText = '',
    this.history = const [],
    this.favoriateGroups = const [],
    this.favorites = const [],
  });

  MainPageState copyWith({
    int? selectedIndex,
    List<int>? selectedGroups,
    String? searchText,
    List<History>? history,
    List<FavoriateGroup>? favoriateGroups,
    List<Favorite>? favorites,
  }) {
    return MainPageState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectedGroups: selectedGroups ?? this.selectedGroups,
      searchText: searchText ?? this.searchText,
      history: history ?? this.history,
      favoriateGroups: favoriateGroups ?? this.favoriateGroups,
      favorites: favorites ?? this.favorites,
    );
  }
}

@Riverpod(keepAlive: true)
class MainNotifier extends _$MainNotifier {
  @override
  MainPageState build() {
    Future.microtask(() async {
      await Future.wait([
        DatabaseService.getAllFavoriteGroup(),
        DatabaseService.getAllFavorite(),
        DatabaseService.getHistoriesByType(),
      ]).then((value) {
        state = state.copyWith(
          history: value[2] as List<History>,
          favoriateGroups: value[0] as List<FavoriateGroup>,
          favorites: value[1] as List<Favorite>,
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
    final history = await DatabaseService.getHistoriesByType();
    state = state.copyWith(history: history);
  }
}
