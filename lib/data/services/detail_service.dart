import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/db_model.pb.dart'
    as db_model;
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as ext_model;

class DetailService {
  Future<db_model.Detail> getDetail(String package, String detailUrl) async {
    try {
      final response = await MiruGrpcClient.dbClient.getDetail(
        GetDetailRequest(package: package, detailUrl: detailUrl),
      );
      return response.detail;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveDetail(db_model.Detail detail) async {
    try {
      await MiruGrpcClient.dbClient.upsertDetail(
        UpsertDetailRequest(
          title: detail.title,
          cover: detail.cover,
          desc: detail.desc,
          detailUrl: detail.detailUrl,
          package: detail.package,
          downloaded: detail.downloaded,
          episodes: detail.episodes,
          headers: detail.headers,
          trackIds: Map<String, String>.from(detail.trackIds).entries,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ext_model.ExtensionListItem>> searchExtensions(
    String query, {
    String? package,
    String? type,
  }) async {
    try {
      final response = await MiruGrpcClient.extensionClient.search(
        SearchRequest(pkg: package ?? '', kw: query, page: 1),
      );
      return response.items.toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ext_model.ExtensionListItem>> getLatest(String package) async {
    try {
      final response = await MiruGrpcClient.extensionClient.latest(
        LatestRequest(pkg: package, page: 1),
      );
      return response.items.toList();
    } catch (e) {
      return [];
    }
  }
}
