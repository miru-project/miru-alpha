import 'package:miru_app_new/miru_core/grpc_client.dart';
import 'package:miru_app_new/miru_core/proto/proto.dart' as proto;
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/core/log.dart';

class DatabaseService {
  static proto.DbServiceClient get client => MiruGrpcClient.dbClient;

  // Favorites
  static Future<List<Favorite>> getAllFavorite() async {
    final response = await client.getAllFavorite(proto.GetAllFavoriteRequest());
    return response.favorites.map((e) => Favorite.fromProto(e)).toList();
  }

  static Future<Favorite?> getFavoriteByPackageAndUrl(
    String package,
    String url,
  ) async {
    try {
      final response = await client.getFavoriteByPackageAndUrl(
        proto.GetFavoriteByPackageAndUrlRequest()
          ..package = package
          ..url = url,
      );
      return Favorite.fromProto(response.favorite);
    } catch (e) {
      return null;
    }
  }

  static Future<void> putFavoriteByIndex(List<FavoriateGroup> groups) async {
    await client.putFavoriteByIndex(
      proto.PutFavoriteByIndexRequest()
        ..groups.addAll(groups.map((e) => e.toProto())),
    );
  }

  // Favorite Groups
  static Future<List<FavoriateGroup>> getFavoriteGroupsById(int id) async {
    final response = await client.getFavoriteGroupsById(
      proto.GetFavoriteGroupsByIdRequest()..id = id,
    );
    return response.groups.map((e) => FavoriateGroup.fromProto(e)).toList();
  }

  static Future<List<FavoriateGroup>> getAllFavoriteGroup() async {
    final response = await client.getAllFavoriteGroup(
      proto.GetAllFavoriteGroupRequest(),
    );
    return response.groups.map((e) => FavoriateGroup.fromProto(e)).toList();
  }

  static Future<FavoriateGroup> putFavoriteGroup(
    String name, [
    List<int> items = const [],
  ]) async {
    final response = await client.putFavoriteGroup(
      proto.PutFavoriteGroupRequest()
        ..name = name
        ..items.addAll(items),
    );
    return FavoriateGroup.fromProto(response.group);
  }

  static Future<void> renameFavoriteGroup(
    String oldName,
    String newName,
  ) async {
    await client.renameFavoriteGroup(
      proto.RenameFavoriteGroupRequest()
        ..oldName = oldName
        ..newName = newName,
    );
  }

  static Future<void> deleteFavoriteGroup(List<String> names) async {
    await client.deleteFavoriteGroup(
      proto.DeleteFavoriteGroupRequest()..names.addAll(names),
    );
  }

  // History
  static Future<List<History>> getHistoriesByType({String? type}) async {
    final response = await client.getHistoriesByType(
      proto.GetHistoriesByTypeRequest()..type = type ?? '',
    );
    return response.histories.map((e) => History.fromProto(e)).toList();
  }

  static Future<List<History>> getHistoryByPackageAndDetailUrl(
    String package,
    String detailUrl,
  ) async {
    final response = await client.getHistoryByPackageAndDetailUrl(
      proto.GetHistoryByPackageAndDetailUrlRequest()
        ..package = package
        ..detailUrl = detailUrl,
    );
    return response.history.map((e) => History.fromProto(e)).toList();
  }

  // static Future<History?> getHistoryByPackageAndUrl(
  //   String package,
  //   String url,
  // ) async {
  //   try {
  //     final response = await client.getHistoryByPackageAndUrl(
  //       proto.GetHistoryByPackageAndUrlRequest()
  //         ..package = package
  //         ..url = url,
  //     );
  //     return History.fromProto(response.history);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  static Future<void> putHistory(History history) async {
    await client.putHistory(
      proto.PutHistoryRequest()..history = history.toProto(),
    );
  }

  static Future<void> deleteHistoryByPackageAndUrl(
    String package,
    String url,
  ) async {
    await client.deleteHistoryByPackageAndUrl(
      proto.DeleteHistoryByPackageAndUrlRequest()
        ..package = package
        ..url = url,
    );
  }

  static Future<void> deleteAllHistory() async {
    await client.deleteAllHistory(proto.DeleteAllHistoryRequest());
  }

  // Helper methods for compatibility
  static Future<bool> isFavorite({
    required String package,
    required String url,
  }) async {
    final fav = await getFavoriteByPackageAndUrl(package, url);
    return fav != null;
  }

  static Future<List<Favorite>> getFavoritesByType({
    ExtensionType? type,
    int? limit,
  }) async {
    final all = await getAllFavorite();
    var filtered = type == null
        ? all
        : all.where((f) => f.type == type.toString().split('.').last).toList();
    filtered.sort((a, b) => b.date.compareTo(a.date));
    if (limit != null && filtered.length > limit) {
      filtered = filtered.sublist(0, limit);
    }
    return filtered;
  }

  static Future<List<History>> getHistorysFiltered({
    String? type,
    DateTime? beforeDate,
  }) async {
    final response = await client.getHistorysFiltered(
      proto.GetHistorysFilteredRequest()
        ..type = type ?? ''
        ..beforeDate = beforeDate?.toIso8601String() ?? '',
    );
    return response.histories.map((e) => History.fromProto(e)).toList();
  }

  static Future<List<FavoriateGroup>> getFavoriteGroupsByFavorite(
    String package,
    String url,
  ) async {
    final response = await client.getFavoriteGroupsByFavorite(
      proto.GetFavoriteGroupsByFavoriteRequest()
        ..package = package
        ..url = url,
    );
    return response.groups.map((e) => FavoriateGroup.fromProto(e)).toList();
  }

  static Future<Favorite> putFavorite(
    String detailUrl,
    ExtensionDetail? detail,
    String package,
    ExtensionType type,
  ) async {
    logger.info('putFavorite $detailUrl $package $type');
    final response = await client.putFavorite(
      proto.PutFavoriteRequest()
        ..url = detailUrl
        ..cover = detail?.cover ?? ''
        ..package = package
        ..title = detail?.title ?? ''
        ..type = type.toString().split('.').last,
    );
    return Favorite.fromProto(response.favorite);
  }

  static Future<void> deleteFavorite(String detailUrl, String package) async {
    await client.deleteFavorite(
      proto.DeleteFavoriteRequest()
        ..url = detailUrl
        ..package = package,
    );
    logger.info('deleteFavorite $detailUrl $package');
  }
}
