import 'dart:convert';

import 'package:miru_app_new/objectbox.g.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/index.dart';

class DatabaseService {
  static final db = MiruStorage.database;
  static final favGroup = MiruStorage.favoriteGroup;
  static final fav = MiruStorage.favorite;
  static final historys = MiruStorage.history;
  static final extensionSettings = MiruStorage.extensionSetting;
  static final mangaSettings = MiruStorage.mangaSetting;
  static final miruDetails = MiruStorage.miruDetail;
  static final tmdb = MiruStorage.tmdb;
  // static toggleFavorite({
  //   required String package,
  //   required String url,
  //   required String name,
  //   String? cover,
  // }) async {
  //   return db.writeTxn(() async {
  //     if (await isFavorite(
  //       package: package,
  //       url: url,
  //     )) {
  //       return db.favorites
  //           .filter()
  //           .packageEqualTo(package)
  //           .and()
  //           .urlEqualTo(url)
  //           .deleteAll();
  //     } else {
  //       final runtime = ExtensionUtils.runtimes[package];
  //       if (runtime == null) {
  //         throw Exception('extension not found');
  //       }
  //       final extension = runtime.extension;
  //       return db.favorites.put(
  //         Favorite()
  //           ..cover = cover
  //           ..title = name
  //           ..package = extension.package
  //           ..type = extension.type
  //           ..url = url,
  //       );
  //     }
  //   });
  // }
  static void deleteFavoriteGroup(List<String> name) {
    final query = favGroup.query(FavoriateGroup_.name.oneOf(name)).build();
    query.remove();
  }

  static void renameFavoriteGroup(String oldName, String newName) {
    final query = favGroup.query(FavoriateGroup_.name.equals(oldName)).build();
    final group = query.findFirst();
    if (group != null) {
      group.name = newName;
      favGroup.put(group);
    }
    throw Exception('group not found');
    // DatabaseService.db.writeTxnSync(() {
    //   final group = DatabaseService.db.favoriateGroups
    //       .filter()
    //       .nameEqualTo(oldName)
    //       .findFirstSync();
    //   group!.name = newName;
    //   DatabaseService.db.favoriateGroups.putSync(group);
    //   // DatabaseService.db.favoriateGroups.delete(group.id);
    // });
  }

  static List<FavoriateGroup> getFavoriteGroupsById(int id) {
    final builder = favGroup.query();
    builder.linkMany(FavoriateGroup_.favorite, Favorite_.id.equals(id));

    return builder.build().find();

    // return DatabaseService.db.favoriateGroups
    //     .filter()
    //     .itemsElementEqualTo(id)
    //     .findAllSync();
  }

  static List<Favorite> getAllFavorite() {
    return fav.getAll();
  }

  static List<FavoriateGroup> getAllFavoriteGroup() {
    return favGroup.getAll();
  }

  static void putFavoriteByIndex(List<FavoriateGroup> result) {
    // return DatabaseService.db.writeTxnSync(() {
    //   DatabaseService.db.favoriateGroups.putAllByIndexSync("name", result);
    // });
    favGroup.putMany(result);
  }

  static FavoriateGroup putFavoriteGroup(String name,
      [List<int> items = const []]) {
    //fetch ids from favorite
    final fetchFav = fav.getMany(items);
    final group = FavoriateGroup(date: DateTime.now(), name: name);
    if (items.isNotEmpty) {
      group.favorite.addAll(fetchFav as List<Favorite>);
    }

    DatabaseService.favGroup.put(group);

    // final group = FavoriateGroup()
    //   ..items = items
    //   ..name = name;
    // DatabaseService.db.writeTxnSync(() {
    //   DatabaseService.db.favoriateGroups.putByIndexSync("name", group);
    // });
    return group;
  }

  // put favorite use, use at detail page
  static Favorite putFavorite(String detailUrl, ExtensionDetail? detail,
      String package, ExtensionType type) {
    final favorite = Favorite(
        cover: detail!.cover,
        package: package,
        type: type.toString().split('.').last,
        date: DateTime.now(),
        title: detail.title,
        url: detailUrl);
    fav.put(favorite);
    return favorite;
    // final fav = Favorite()
    //   ..cover = detail!.cover
    //   ..package = package
    //   ..type = type
    //   ..date = DateTime.now()
    //   ..title = detail.title
    //   ..url = detailUrl;
    // DatabaseService.db.writeTxnSync(() {
    //   DatabaseService.db.favorites.putByIndexSync('package&url', fav);
    // });
    // return fav;
  }

  // delete favorite
  static void deleteFavorite(String detailUrl, String package) {
    final query = fav
        .query(
            Favorite_.url.equals(detailUrl) & Favorite_.package.equals(package))
        .build();
    query.remove();
    // DatabaseService.db.writeTxnSync(() {
    //   DatabaseService.db.favorites
    //       .filter()
    //       .packageEqualTo(package)
    //       .and()
    //       .urlEqualTo(detailUrl)
    //       .deleteFirstSync();
    // });
  }

  // static Future<bool> isFavorite({
  //   required String package,
  //   required String url,
  // }) async {
  //   return (await db.favorites
  //           .filter()
  //           .packageEqualTo(package)
  //           .and()
  //           .urlEqualTo(url)
  //           .findFirst()) !=
  //       null;
  // }

  static Future<List<Favorite>> getFavoritesByType({
    ExtensionType? type,
    int? limit,
  }) async {
    if (type == null) {
      final query =
          fav.query().order(Favorite_.date, flags: Order.descending).build();
      if (limit != null) {
        query.limit = limit;
      }
      return query.find();
      // final query = db.favorites.where().sortByDateDesc();
      // if (limit != null) {
      //   return query.limit(limit).findAll();
      // }
      // return query.findAll();
    }
    final query = fav
        .query(Favorite_.type.equals(EnumToString.convertToString(type)))
        .order(Favorite_.date, flags: Order.descending)
        .build();
    if (limit != null) {
      query.limit = limit;
    }
    return query.find();
    // final query = db.favorites.filter().typeEqualTo(type).sortByDateDesc();
    // if (limit != null) {
    //   return query.limit(limit).findAll();
    // }
    // return query.findAll();
  }

  // 历史记录
  static Future<List<History>> getHistorysByType({ExtensionType? type}) async {
    if (type == null) {
      final query = historys
          .query()
          .order(History_.date, flags: Order.descending)
          .build();
      return query.findAsync();
    }
    final query = historys
        .query(History_.type.equals(EnumToString.convertToString(type)))
        .order(History_.date, flags: Order.descending)
        .build();
    return query.findAsync();
    // if (type == null) {
    //   return db.historys.where().sortByDateDesc().findAll();
    // }
    // return db.historys.filter().typeEqualTo(type).sortByDateDesc().findAll();
  }

  static History? getHistoryByPackageAndUrl(String package, String url) {
    final query = historys
        .query(History_.package.equals(package) & History_.url.equals(url))
        .build();
    return query.findFirst();
    // return db.historys
    //     .filter()
    //     .packageEqualTo(package)
    //     .and()
    //     .urlEqualTo(url)
    //     .findFirstSync();
  }

  // 更新历史

  static Future<int> putHistory(History history) async {
    // return db.writeTxn(() => db.historys.putByIndex(r'package&url', history));
    return historys.putAsync(history);
  }

  // 删除历史
  static Future<void> deleteHistoryByPackageAndUrl(
      String package, String url) async {
    historys
        .query(History_.package.equals(package) & History_.url.equals(url))
        .build()
        .remove();
    // return db.writeTxn(
    //   () => db.historys
    //       .filter()
    //       .packageEqualTo(package)
    //       .urlEqualTo(url)
    //       .deleteAll(),
    // );
  }

  // 删除全部历史
  static Future<void> deleteAllHistory() async {
    // return db.writeTxn(() => db.historys.where().deleteAll());
    historys.removeAll();
  }

  // 扩展设置
  // 获取扩展设置
  static Future<List<ExtensionSetting>> getExtensionSettings(String package) {
    final query = extensionSettings
        .query(ExtensionSetting_.package.equals(package))
        .build();
    return query.findAsync();
    // return db.extensionSettings.filter().packageEqualTo(package).findAll();
  }

  // 更新扩展设置
  static int? putExtensionSetting(String package, String key, String value) {
    final extensionSetting = getExtensionSetting(package, key);
    if (extensionSetting == null) {
      return null;
    }
    extensionSetting.value = value;
    // return db
    //     .writeTxnSync(() => db.extensionSettings.putSync(extensionSetting));
    return extensionSettings.put(extensionSetting);
  }

  // 获取扩展设置
  static ExtensionSetting? getExtensionSetting(String package, String key) {
    // db.extensionSettings.getByPackageKeySync(package, key);
    return extensionSettings
        .query(ExtensionSetting_.package.equals(package) &
            ExtensionSetting_.key.equals(key))
        .build()
        .findFirst();
  }

  // 添加扩展设置
  static int registerExtensionSetting(
    ExtensionSetting extensionSetting,
  ) {
    if (EnumToString.convertToEnum(
                extensionSetting.dbType, ExtensionSettingType.values) ==
            ExtensionSettingType.radio &&
        extensionSetting.options == null) {
      throw Exception('options is null');
    }

    final extSetting =
        getExtensionSetting(extensionSetting.package, extensionSetting.key);
    // 如果不存在相同设置，则添加
    if (extSetting == null) {
      return extensionSettings.put(extensionSetting);
      // return db
      //     .writeTxnSync(() => db.extensionSettings.putSync(extensionSetting));
    }

    extSetting.defaultValue = extensionSetting.defaultValue;

    // 如果类型不同，重置值
    if (extSetting.dbType != extensionSetting.dbType) {
      extSetting.dbType = extensionSetting.dbType;
      extSetting.value = extensionSetting.defaultValue;
    }
    extSetting.defaultValue = extensionSetting.defaultValue;
    extSetting.description = extensionSetting.description;
    extSetting.options = extensionSetting.options;
    extSetting.title = extensionSetting.title;
    return extensionSettings.put(extSetting);
    // return db.writeTxnSync(
    //   () => db.extensionSettings.putByIndexSync(r'package&key', extSetting),
    // );
  }

  // 删除扩展设置
  static Future<void> deleteExtensionSetting(String package) async {
    extensionSettings
        .query(ExtensionSetting_.package.equals(package))
        .build()
        .remove();
    // return db.writeTxn(
    //   () => db.extensionSettings.filter().packageEqualTo(package).deleteAll(),
    // );
  }

  // 清理不需要的扩展设置
  static Future<int> cleanExtensionSettings(
    String package,
    List<String> keys,
  ) async {
    // 需要删除的 id;
    final ids = <int>[];

    // final extSettings =
    //     await db.extensionSettings.filter().packageEqualTo(package).findAll();
    final extSettings = await extensionSettings
        .query(ExtensionSetting_.package.equals(package))
        .build()
        .findAsync();

    for (final extSetting in extSettings) {
      if (!keys.contains(extSetting.key)) {
        ids.add(extSetting.id);
      }
    }

    // return db.writeTxn(() => db.extensionSettings.deleteAll(ids));
    return extensionSettings.removeAll();
  }

  // 获取漫画阅读模式
  static Future<MangaReadMode> getMnagaReaderType(
      String url, MangaReadMode defaultMode) async {
    // return db.mangaSettings.filter().urlEqualTo(url).findFirst().then(
    //       (value) => value?.readMode ?? defaultMode,
    //     );
    final setting = await mangaSettings
        .query(MangaSetting_.url.equals(url))
        .build()
        .findFirstAsync();

    return setting?.mangaReadMode ?? defaultMode;
  }

  // 设置漫画阅读模式
  static Future<int> setMangaReaderType(
    String url,
    MangaReadMode readMode,
  ) {
    return mangaSettings.putAsync(MangaSetting(
        url: url, readMode: EnumToString.convertToString(readMode)));
    // return db.writeTxn(
    //   () => db.mangaSettings.putByUrl(
    //     MangaSetting()
    //       ..url = url
    //       ..readMode = readMode,
    //   ),
    // );
  }

  // 存储 MiruDetail
  static Future<int> putMiruDetail(
    String package,
    String url,
    ExtensionDetail extensionDetail, {
    int? tmdbID,
    String? anilistID,
  }) {
    return miruDetails.putAsync(MiruDetail(
        package: package,
        url: url,
        data: jsonEncode(extensionDetail.toJson()),
        updateTime: DateTime.now(),
        tmdbID: tmdbID,
        aniListID: anilistID));
    // return db.writeTxn(
    //   () => db.miruDetails.putByIndex(
    //     r'package&url',
    //     MiruDetail()
    //       ..data = jsonEncode(extensionDetail.toJson())
    //       ..package = package
    //       ..tmdbID = tmdbID
    //       ..url = url
    //       ..aniListID = anilistID,
    //   ),
    // );
  }

  // 获取 MiruDetail
  static Future<MiruDetail?> getMiruDetail(
    String package,
    String url,
  ) async {
    return await miruDetails
        .query(
            MiruDetail_.package.equals(package) & MiruDetail_.url.equals(url))
        .build()
        .findFirstAsync();
    // return await db.miruDetails
    //     .filter()
    //     .packageEqualTo(package)
    //     .and()
    //     .urlEqualTo(url)
    //     .findFirst();
  }

  // 更新 TMDB 数据
  // static Future<int> putTMDBDetail(
  //   int tmdbID,
  //   TMDBDetail tmdbDetail,
  //   String mediaType,
  // ) {
  //   return tmdb.putAsync(
  //     TMDB()
  //       ..data = jsonEncode(tmdbDetail.toJson())
  //       ..tmdbID = tmdbID
  //       ..mediaType = mediaType,
  //   );
  //   // return db.writeTxn(
  //   //   () => db.tMDBs.putByTmdbID(
  //   //     TMDB()
  //   //       ..data = jsonEncode(tmdbDetail.toJson())
  //   //       ..tmdbID = tmdbID
  //   //       ..mediaType = mediaType,
  //   //   ),
  //   // );
  // }

  // 获取 TMDB 数据
  static Future<TMDBDetail?> getTMDBDetail(int tmdbID) async {
    // final tmdb = await db.tMDBs.filter().idEqualTo(tmdbID).findFirst();
    final tmdbData =
        await tmdb.query(TMDB_.tmdbID.equals(tmdbID)).build().findFirstAsync();
    if (tmdbData == null) {
      return null;
    }
    try {
      return TMDBDetail.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(tmdbData.data),
        ),
      );
    } catch (e) {
      return null;
    }
  }
}
