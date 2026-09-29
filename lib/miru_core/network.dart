import 'package:miru_alpha/miru_core/core.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'dart:async';
import 'dart:convert';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;

/// Endpoint helpers for application settings
class AppSettingEndpoint {
  /// Fetch all application settings from /appSetting
  /// The server returns an array of objects like {"key": "someKey", "value": "someValue"}
  static Future<Map<String, String>> getAll() async {
    try {
      final response = await MiruGrpcClient.appSettingClient.getAppSetting(
        proto.GetAppSettingRequest(),
      );
      final Map<String, String> result = {};
      for (final s in response.settings) {
        result[s.key] = s.value;
      }
      return result;
    } catch (e) {
      logger.info('Failed to fetch app settings via gRPC: $e');
      return {};
    }
  }
}

class CoreMessage {
  final String? msg;
  final dynamic data;

  CoreMessage(this.msg, this.data);
}

class CoreNetwork {
  static String get baseUrl => "http://${Core.host}:${Core.port}";

  static Future<void> waitForServerLoaded() async {
    int failedCount = 0;
    while (true) {
      try {
        await MiruGrpcClient.coreClient.helloMiru(proto.HelloMiruRequest());
        logger.info('Miru core loaded (gRPC)');
        return;
      } catch (e) {
        if (failedCount == 1) {
          await Core.loadMiruCore();
        }
        await Future.delayed(const Duration(milliseconds: 100));
        failedCount++;
      }
    }
  }

  static Future<void> ensureInitialized() async {}
}

class MiruCoreEndpoint {
  static Detail detailFromProto(proto.Detail p) {
    List<ExtensionEpisodeGroup>? episodes;
    if (p.hasEpisodes()) {
      try {
        final decoded = jsonDecode(p.episodes);
        if (decoded is List) {
          episodes = decoded
              .map((e) => ExtensionEpisodeGroup()..mergeFromProto3Json(e))
              .toList();
        }
      } catch (e) {
        logger.warning('Failed to parse episodes JSON: ${p.episodes}');
        episodes = null;
      }
    }

    Map<String, String>? headers;
    if (p.hasHeaders()) {
      try {
        final decoded = jsonDecode(p.headers);
        if (decoded is Map) {
          headers = decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
        }
      } catch (e) {
        logger.warning('Failed to parse headers JSON: ${p.headers}');
        headers = null;
      }
    }

    return Detail(
      id: p.id,
      title: p.hasTitle() ? p.title : "",
      cover: p.hasCover() ? p.cover : null,
      desc: p.hasDesc() ? p.desc : null,
      downloaded: p.downloaded,
      detailUrl: p.detailUrl,
      package: p.package,
      episodes: episodes,
      headers: headers,
    );
  }

  static Future<List<Detail>> getDetailsByPackage(String package) async {
    final response = await MiruGrpcClient.dbClient.getDetail(
      proto.GetDetailRequest()..package = package,
    );
    // This assumes getDetail returns a single response, but the UI expects a list?
    // Actually the original code had getDetailsByPackage returning List<Detail>.
    // Let's check proto service definition.
    return [
      Detail.fromExtensionDetail(
        pb_extension.ExtensionDetail.fromJson(response.detail.episodes),
        detailUrl: response.detail.detailUrl,
        package: response.detail.package,
      ),
    ];
  }

  static Future<Detail?> getDbDetail(String pkg, String url) async {
    final response = await MiruGrpcClient.dbClient.getDetail(
      proto.GetDetailRequest(package: pkg, detailUrl: url),
    );
    if (!response.hasDetail() || response.detail.package.isEmpty) return null;
    return detailFromProto(response.detail);
  }

  static Future<Detail> upsertDbDetail(Detail detail) async {
    final response = await MiruGrpcClient.dbClient.upsertDetail(
      proto.UpsertDetailRequest(
        title: detail.title,
        cover: detail.cover,
        desc: detail.desc,
        detailUrl: detail.detailUrl,
        package: detail.package,
        downloaded: detail.downloaded,
        episodes: detail.episodes != null
            ? jsonEncode(detail.episodes!.map((e) => e.toProto3Json()).toList())
            : null,
        headers: detail.headers != null ? jsonEncode(detail.headers) : null,
      ),
    );
    return detailFromProto(response.detail);
  }

  static Future<dynamic> watch(
    String url,
    String pkg,
    ExtensionMeta meta,
  ) async {
    final response = await MiruGrpcClient.extensionClient.watch(
      proto.WatchRequest(pkg: pkg, url: url),
    );

    // The golang (Scriggo) V2 backend only ever emits ExtensionWatch (the V2
    // source/group list) or ExtensionAllWatch (the "all" bundle) from watch().
    // The per-type bangumi/manga/fikushon oneof variants are produced by the
    // legacy V1 (JS) runtime only; they are kept here purely so the switch stays
    // exhaustive and V1 extensions keep working.
    switch (response.whichData()) {
      // V2 golang: source/group list. The resolved stream is fetched via
      // mirror(), which returns an ExtensionAllWatch.
      case proto.WatchResponse_Data.watch:
        return response.watch;
      // V2 golang: "all" extension. The bundle carries every shape; pick the
      // one matching the extension's declared @type.
      case proto.WatchResponse_Data.all:
        final all = response.all;
        switch (meta.type) {
          case ExtensionType.bangumi:
            return all.bangumi;
          case ExtensionType.manga:
            return all.manga;
          case ExtensionType.fikushon:
            return all.fikushon;
          case ExtensionType.all:
            return all;
        }
      // V1 (JS) only — golang V2 never returns these directly.
      case proto.WatchResponse_Data.bangumi:
        return response.bangumi;
      case proto.WatchResponse_Data.manga:
        return response.manga;
      case proto.WatchResponse_Data.fikushon:
        return response.fikushon;
      case proto.WatchResponse_Data.notSet:
        throw Exception("Watch response data not set");
    }
  }

  static Future<dynamic> mirror(String pkg, String url) async {
    final response = await MiruGrpcClient.extensionClient.mirror(
      proto.MirrorRequest(pkg: pkg, url: url),
    );

    switch (response.whichData()) {
      case proto.MirrorResponse_Data.bangumi:
        return response.bangumi;
      case proto.MirrorResponse_Data.manga:
        return response.manga;
      case proto.MirrorResponse_Data.fikushon:
        return response.fikushon;
      case proto.MirrorResponse_Data.all:
        final all = response.all;
        // A mirror resolves a single stream, so the extension populates exactly
        // one of the bundled watch shapes. Return whichever was set.
        if (all.hasBangumi()) return all.bangumi;
        if (all.hasManga()) return all.manga;
        if (all.hasFikushon()) return all.fikushon;
        return all;
      case proto.MirrorResponse_Data.notSet:
        throw Exception("Mirror response data not set");
    }
  }

  static Future<Map<String, pb_extension.ExtensionFilter>> createFilter(
    String pkg, {
    proto.FilterSelection? filter,
  }) async {
    final response = await MiruGrpcClient.extensionClient.createFilter(
      proto.CreateFilterRequest(
        pkg: pkg,
        filter: filter ?? proto.FilterSelection(),
      ),
    );
    return response.filters;
  }

  static Future<Detail> detail(String pkg, String url) async {
    final response = await MiruGrpcClient.extensionClient.detail(
      proto.DetailRequest(pkg: pkg, url: url),
    );

    return Detail.fromExtensionDetail(
      response.data,
      detailUrl: url,
      package: pkg,
    );
  }

  static Future<List<pb_extension.ExtensionListItem>> search(
    String pkg,
    String kw,
    int page, {
    proto.FilterSelection? filter,
  }) async {
    final response = await MiruGrpcClient.extensionClient.search(
      proto.SearchRequest(
        pkg: pkg,
        kw: kw,
        page: page,
        filter: filter ?? proto.FilterSelection(),
      ),
    );

    return response.items;
  }

  static Future<List<pb_extension.ExtensionListItem>> latest(
    String pkg,
    int page,
  ) async {
    final response = await MiruGrpcClient.extensionClient.latest(
      proto.LatestRequest(pkg: pkg, page: page),
    );

    return response.items;
  }

  static Future<void> setRepo(String repoUrl, String name) async {
    await MiruGrpcClient.repoClient.setRepo(
      proto.SetRepoRequest(repoUrl: repoUrl, name: name),
    );
  }

  static Future<List<RepoConfig>> getRepoLists() async {
    final response = await MiruGrpcClient.repoClient.getRepos(
      proto.GetReposRequest(),
    );
    final List<dynamic> data = jsonDecode(response.data);
    return data
        .map((e) => RepoConfig.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<dynamic> fetchRepos() async {
    final response = await MiruGrpcClient.repoClient.fetchRepoList(
      proto.FetchRepoListRequest(),
    );
    return jsonDecode(response.data);
  }

  static Future<String?> deleteRepo(String repoUrl) async {
    final response = await MiruGrpcClient.repoClient.deleteRepo(
      proto.DeleteRepoRequest(repoUrl: repoUrl),
    );
    return response.message;
  }

  static Future<void> downloadExtension(String repoUrl, String package) async {
    await MiruGrpcClient.extensionClient.downloadExtension(
      proto.DownloadExtensionRequest(repoUrl: repoUrl, pkg: package),
    );
  }

  static Future<void> removeExtension(String package) async {
    await MiruGrpcClient.extensionClient.removeExtension(
      proto.RemoveExtensionRequest(pkg: package),
    );
  }

  static Future<void> setCookie(String cookie, String url) async {
    await MiruGrpcClient.networkClient.setCookie(
      proto.SetCookieRequest(cookie: cookie, url: url),
    );
  }
}

class DownloadController {
  static final StreamController<String> _downloadController =
      StreamController<String>.broadcast();
  static Stream<String> get downloadStream => _downloadController.stream;
}
