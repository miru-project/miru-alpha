import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;

part 'home_view_model.g.dart';

class HomeViewState {
  final List<Favorite> favorites;
  final List<History> history;
  final List<proto.Download> downloads;
  final int selectedTab;

  const HomeViewState({
    required this.favorites,
    required this.history,
    required this.downloads,
    required this.selectedTab,
  });

  HomeViewState copyWith({
    List<Favorite>? favorites,
    List<History>? history,
    List<proto.Download>? downloads,
    int? selectedTab,
  }) {
    return HomeViewState(
      favorites: favorites ?? this.favorites,
      history: history ?? this.history,
      downloads: downloads ?? this.downloads,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeViewState build() {
    final favorites = ref.watch(favoritePageProvider);
    final history = ref.watch(historyPageProvider);
    final downloads = ref.watch(downloadProvider);

    return HomeViewState(
      favorites: favorites.filteredFavorites,
      history: history.filteredHistory,
      downloads: downloads.value?.history ?? const [],
      selectedTab: 0,
    );
  }

  void refresh() {
    ref.invalidate(favoritePageProvider);
    ref.invalidate(historyPageProvider);
    ref.invalidate(downloadProvider);
  }

  void selectTab(int index) {
    final current = state;
    state = current.copyWith(selectedTab: index);
  }
}

@riverpod
class SelectedHomeTab extends _$SelectedHomeTab {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}
