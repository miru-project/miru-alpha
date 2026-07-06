import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/index.dart';

class FavoriteService {
  Future<List<FavoriteGroup>> getFavoriteGroups(String type) async {
    try {
      final response = await MiruGrpcClient.dbClient.getAllFavoriteGroup(
        proto.GetAllFavoriteGroupRequest(),
      );
      final groups = response.groups
          .map((e) => FavoriteGroup.fromProto(e))
          .toList();
      if (type.isEmpty) return groups;
      return groups.where((e) => e.name == type).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Favorite>> getFavoritesByGroup(String groupId) async {
    try {
      final response = await MiruGrpcClient.dbClient
          .getFavoriteGroupsByFavorite(
            proto.GetFavoriteGroupsByFavoriteRequest()
              ..package = groupId
              ..url = groupId,
          );
      return response.groups
          .expand((group) => group.favorites.map((f) => Favorite.fromProto(f)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addFavorite(
    String package,
    String detailUrl,
    String groupId,
    String title,
    String? cover,
    String type,
  ) async {
    try {
      await MiruGrpcClient.dbClient.putFavorite(
        proto.PutFavoriteRequest()
          ..package = package
          ..url = detailUrl
          ..title = title
          ..cover = cover ?? '',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFavorite(String favoriteId) async {
    try {
      await MiruGrpcClient.dbClient.deleteFavorite(
        proto.DeleteFavoriteRequest()..url = favoriteId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createFavoriteGroup(String name, String type, int order) async {
    try {
      await MiruGrpcClient.dbClient.putFavoriteGroup(
        proto.PutFavoriteGroupRequest()
          ..name = name
          ..items.add(order),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFavoriteGroup(String groupId) async {
    try {
      await MiruGrpcClient.dbClient.deleteFavoriteGroup(
        proto.DeleteFavoriteGroupRequest()..names.add(groupId),
      );
    } catch (e) {
      rethrow;
    }
  }
}
