import 'package:miru_alpha/data/services/favorite_service.dart';
import 'package:miru_alpha/domain/models/favorite.dart';

class FavoriteRepository {
  final FavoriteService _favoriteService;

  FavoriteRepository(this._favoriteService);

  Future<List<DomainFavoriteGroup>> getFavoriteGroups(String type) async {
    final groups = await _favoriteService.getFavoriteGroups(type);
    return groups
        .map(
          (group) => DomainFavoriteGroup(
            id: group.id.toString(),
            name: group.name,
            type: type,
            order: 0,
            createdAt: group.date,
            icon: null,
          ),
        )
        .toList();
  }

  Future<List<DomainFavorite>> getFavoritesByGroup(String groupId) async {
    final favorites = await _favoriteService.getFavoritesByGroup(groupId);
    return favorites
        .map(
          (favorite) => DomainFavorite(
            id: favorite.id.toString(),
            package: favorite.package,
            detailUrl: favorite.url,
            title: favorite.title,
            cover: favorite.cover,
            type: favorite.type,
            groupId: groupId,
            createdAt: favorite.date,
            description: null,
          ),
        )
        .toList();
  }

  Future<void> addFavorite(
    String package,
    String detailUrl,
    String groupId,
    String title,
    String? cover,
    String type,
  ) async {
    await _favoriteService.addFavorite(
      package,
      detailUrl,
      groupId,
      title,
      cover,
      type,
    );
  }

  Future<void> removeFavorite(String favoriteId) async {
    await _favoriteService.removeFavorite(favoriteId);
  }

  Future<void> createFavoriteGroup(String name, String type, int order) async {
    await _favoriteService.createFavoriteGroup(name, type, order);
  }

  Future<void> deleteFavoriteGroup(String groupId) async {
    await _favoriteService.deleteFavoriteGroup(groupId);
  }
}
