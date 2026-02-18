import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/model.dart';
import 'package:miru_app_new/model/user_data.dart';
import 'package:miru_app_new/provider/watch/main_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'favorite_page_provider.g.dart';

class FavoritePageState {
  final List<Favorite> favorites;
  final List<Favorite> filteredFavorites;
  final List<FavoriateGroup> favoriteGroups;

  FavoritePageState({
    required this.favorites,
    required this.favoriteGroups,
    required this.filteredFavorites,
  });

  FavoritePageState copyWith({
    List<Favorite>? favorites,
    List<FavoriateGroup>? favoriteGroups,
    List<Favorite>? filteredFavorites,
  }) {
    return FavoritePageState(
      filteredFavorites: filteredFavorites ?? this.filteredFavorites,
      favorites: favorites ?? this.favorites,
      favoriteGroups: favoriteGroups ?? this.favoriteGroups,
    );
  }
}

@riverpod
class FavoritePageNotifier extends _$FavoritePageNotifier {
  String keyword = '';
  Duration duration = const Duration(days: 36500);
  ExtensionType? type;
  @override
  FavoritePageState build() {
    final favorite = ref.watch(mainProvider.select((e) => e.favorites));
    final favoriteGroups = ref.watch(
      mainProvider.select((e) => e.favoriteGroups),
    );
    return FavoritePageState(
      favorites: favorite,
      favoriteGroups: favoriteGroups,
      filteredFavorites: favorite,
    );
  }

  void removeFavorite(Favorite favorite) {
    ref.read(mainProvider.notifier).removeFavorite(favorite);
    state = state.copyWith(
      favorites: state.favorites.where((e) => e.id != favorite.id).toList(),
    );
  }

  void filterFavorite(ExtensionType? type, String keyword, Duration duration) {
    final now = DateTime.now();
    List<Favorite> typeResult = state.favorites;
    if (type != null) {
      typeResult = state.favorites.where((e) => e.type == type.name).toList();
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

  void filterWithType(ExtensionType? type) {
    this.type = type;
    filterFavorite(type, keyword, duration);
  }

  void filterWithKeyword(String keyword) {
    this.keyword = keyword;
    filterFavorite(type, keyword, duration);
  }

  void filterWithDuration(Duration duration) {
    this.duration = duration;
    filterFavorite(type, keyword, duration);
  }
}
