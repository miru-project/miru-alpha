import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:miru_alpha/data/repositories/favorite_repository.dart';
import 'package:miru_alpha/data/services/favorite_service.dart';
import 'package:miru_alpha/domain/models/favorite.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_view_model.freezed.dart';
part 'favorite_view_model.g.dart';

@freezed
abstract class FavoriteViewState with _$FavoriteViewState {
  const factory FavoriteViewState({
    required List<DomainFavoriteGroup> groups,
    required List<DomainFavorite> favorites,
    String? selectedGroupId,
  }) = _FavoriteViewState;
}

@riverpod
class FavoriteViewModel extends _$FavoriteViewModel {
  @override
  Future<FavoriteViewState> build() async {
    final repository = FavoriteRepository(FavoriteService());
    final groups = await repository.getFavoriteGroups('all');
    final favorites = groups.isEmpty
        ? <DomainFavorite>[]
        : await repository.getFavoritesByGroup(groups.first.id);

    return FavoriteViewState(
      groups: groups,
      favorites: favorites,
      selectedGroupId: groups.isNotEmpty ? groups.first.id : null,
    );
  }

  Future<void> loadGroups(String type) async {
    final repository = FavoriteRepository(FavoriteService());
    final groups = await repository.getFavoriteGroups(type);
    final favorites = groups.isEmpty
        ? <DomainFavorite>[]
        : await repository.getFavoritesByGroup(groups.first.id);

    state = AsyncValue.data(
      FavoriteViewState(
        groups: groups,
        favorites: favorites,
        selectedGroupId: groups.isNotEmpty ? groups.first.id : null,
      ),
    );
  }

  Future<void> selectGroup(String groupId) async {
    final repository = FavoriteRepository(FavoriteService());
    final favorites = await repository.getFavoritesByGroup(groupId);

    state = AsyncValue.data(
      FavoriteViewState(
        groups: state.value?.groups ?? [],
        favorites: favorites,
        selectedGroupId: groupId,
      ),
    );
  }

  Future<void> addFavorite(
    String package,
    String detailUrl,
    String groupId,
    String title,
    String? cover,
    String type,
  ) async {
    final repository = FavoriteRepository(FavoriteService());
    await repository.addFavorite(
      package,
      detailUrl,
      groupId,
      title,
      cover,
      type,
    );
    ref.invalidateSelf();
  }

  Future<void> removeFavorite(String favoriteId) async {
    final repository = FavoriteRepository(FavoriteService());
    await repository.removeFavorite(favoriteId);
    ref.invalidateSelf();
  }

  Future<void> createGroup(String name, String type, int order) async {
    final repository = FavoriteRepository(FavoriteService());
    await repository.createFavoriteGroup(name, type, order);
    ref.invalidateSelf();
  }

  Future<void> deleteGroup(String groupId) async {
    final repository = FavoriteRepository(FavoriteService());
    await repository.deleteFavoriteGroup(groupId);
    ref.invalidateSelf();
  }
}
