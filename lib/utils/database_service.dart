import 'dart:convert';

import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/miru_core/network/network.dart';

class DatabaseService {
  // Favorites
  static Future<List<Favorite>> getAllFavorite() async {
    final response = await dio.get(
      '${CoreNetwork.baseUrl}/db/favorite',
      queryParameters: {'function': 'GetAllFavorite'},
    );
    final data = response.data['data'] as List;
    return data.map((e) => Favorite.fromJson(e)).toList();
  }

  static Future<Favorite?> getFavoriteByPackageAndUrl(
    String package,
    String url,
  ) async {
    final response = await dio.get(
      '${CoreNetwork.baseUrl}/db/favorite',
      queryParameters: {
        'function': 'GetFavoriteByPackageAndUrl',
        'package': package,
        'url': url,
      },
    );
    final data = response.data['data'];
    if (data == null) return null;
    return Favorite.fromJson(data);
  }

  static Future<void> putFavoriteByIndex(List<FavoriateGroup> groups) async {
    final body = groups.map((e) => e.toJson()).toList();
    await dio.post(
      '${CoreNetwork.baseUrl}/db/favorite',
      queryParameters: {'function': 'PutFavoriteByIndex'},
      data: jsonEncode(body),
    );
  }

  // Favorite Groups
  static Future<List<FavoriateGroup>> getFavoriteGroupsById(int id) async {
    final response = await dio.get(
      '${CoreNetwork.baseUrl}/db/favoriteGroup',
      queryParameters: {
        'function': 'GetFavoriteGroupsById',
        'id': id.toString(),
      },
    );
    final data = response.data['data'] as List;
    return data.map((e) => FavoriateGroup.fromJson(e)).toList();
  }

  static Future<List<FavoriateGroup>> getAllFavoriteGroup() async {
    final response = await dio.get(
      '${CoreNetwork.baseUrl}/db/favoriteGroup',
      queryParameters: {'function': 'GetAllFavoriteGroup'},
    );
    final data = response.data['data'] as List;
    return data.map((e) => FavoriateGroup.fromJson(e)).toList();
  }

  static Future<FavoriateGroup> putFavoriteGroup(
    String name, [
    List<int> items = const [],
  ]) async {
    final body = {'name': name, 'items': items};
    final response = await dio.post(
      '${CoreNetwork.baseUrl}/db/favoriteGroup',
      queryParameters: {'function': 'PutFavoriteGroup'},
      data: jsonEncode(body),
    );
    return FavoriateGroup.fromJson(response.data['data']);
  }

  static Future<void> renameFavoriteGroup(
    String oldName,
    String newName,
  ) async {
    await dio.post(
      '${CoreNetwork.baseUrl}/db/favoriteGroup',
      queryParameters: {
        'function': 'RenameFavoriteGroup',
        'oldName': oldName,
        'newName': newName,
      },
    );
  }

  static Future<void> deleteFavoriteGroup(List<String> names) async {
    final body = {'names': names};
    await dio.post(
      '${CoreNetwork.baseUrl}/db/favoriteGroup',
      queryParameters: {'function': 'DeleteFavoriteGroup'},
      data: jsonEncode(body),
    );
  }

  // History
  static Future<List<History>> getHistorysByType({String? type}) async {
    final params = {'function': 'GetHistorysByType'};
    if (type != null) {
      params['type'] = type;
    }
    final response = await dio.get(
      '${CoreNetwork.baseUrl}/db/history',
      queryParameters: params,
    );
    final data = response.data['data'] as List;
    return data.map((e) => History.fromJson(e)).toList();
  }

  static Future<History?> getHistoryByPackageAndUrl(
    String package,
    String url,
  ) async {
    final response = await dio.get(
      '${CoreNetwork.baseUrl}/db/history',
      queryParameters: {
        'function': 'GetHistoryByPackageAndUrl',
        'package': package,
        'url': url,
      },
    );
    final data = response.data['data'];
    if (data == null) return null;
    return History.fromJson(data);
  }

  static Future<History> putHistory(History history) async {
    final response = await dio.post(
      '${CoreNetwork.baseUrl}/db/history',
      queryParameters: {'function': 'PutHistory'},
      data: jsonEncode(history.toJson()),
    );
    return History.fromJson(response.data['data']);
  }

  static Future<void> deleteHistoryByPackageAndUrl(
    String package,
    String url,
  ) async {
    await dio.post(
      '${CoreNetwork.baseUrl}/db/history',
      queryParameters: {
        'function': 'DeleteHistoryByPackageAndUrl',
        'package': package,
        'url': url,
      },
    );
  }

  static Future<void> deleteAllHistory() async {
    await dio.post(
      '${CoreNetwork.baseUrl}/db/history',
      queryParameters: {'function': 'DeleteAllHistory'},
    );
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
    var filtered =
        type == null
            ? all
            : all
                .where((f) => f.type == type.toString().split('.').last)
                .toList();
    filtered.sort((a, b) => b.date.compareTo(a.date));
    if (limit != null && filtered.length > limit) {
      filtered = filtered.sublist(0, limit);
    }
    return filtered;
  }

  // Note: Other methods for extension settings, manga settings, etc. have been temporarily removed as per requirements

  static Future<List<History>> getHistorysFiltered({
    String? type,
    DateTime? beforeDate,
  }) async {
    final params = {'function': 'GetHistorysFiltered'};
    if (type != null) params['type'] = type;
    if (beforeDate != null) params['beforeDate'] = beforeDate.toIso8601String();
    final response = await dio.get(
      '${CoreNetwork.baseUrl}/db/history',
      queryParameters: params,
    );
    final data = response.data['data'] as List;
    return data.map((e) => History.fromJson(e)).toList();
  }

  static Future<List<FavoriateGroup>> getFavoriteGroupsByFavorite(
    String package,
    String url,
  ) async {
    final response = await dio.get(
      '${CoreNetwork.baseUrl}/db/favoriteGroup',
      queryParameters: {
        'function': 'GetFavoriteGroupsByFavorite',
        'package': package,
        'url': url,
      },
    );
    final data = response.data['data'] as List;
    return data.map((e) => FavoriateGroup.fromJson(e)).toList();
  }

  static Future<Favorite> putFavorite(
    String detailUrl,
    ExtensionDetail? detail,
    String package,
    ExtensionType type,
  ) async {
    final favorite = Favorite(
      package: package,
      url: detailUrl,
      type: type.toString().split('.').last,
      title: detail!.title,
      cover: detail.cover,
      date: DateTime.now(),
    );
    final response = await dio.post(
      '${CoreNetwork.baseUrl}/db/favorite',
      queryParameters: {'function': 'PutFavorite'},
      data: jsonEncode(favorite.toJson()),
    );
    return Favorite.fromJson(response.data['data']);
  }

  static Future<void> deleteFavorite(String detailUrl, String package) async {
    await dio.post(
      '${CoreNetwork.baseUrl}/db/favorite',
      queryParameters: {
        'function': 'DeleteFavorite',
        'url': detailUrl,
        'package': package,
      },
    );
  }
}
