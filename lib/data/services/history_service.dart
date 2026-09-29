import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/user_data.dart';

class HistoryService {
  Future<List<History>> getHistoriesByType(String type) async {
    try {
      final response = await MiruGrpcClient.dbClient.getHistoriesByType(
        proto.GetHistoriesByTypeRequest(type: type),
      );
      return response.histories.map((e) => History.fromProto(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> putHistory(History history) async {
    try {
      await MiruGrpcClient.dbClient.putHistory(
        proto.PutHistoryRequest(history: history.toProto()),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHistoryByPackageAndUrl(String package, String url) async {
    try {
      await MiruGrpcClient.dbClient.deleteHistoryByPackageAndUrl(
        proto.DeleteHistoryByPackageAndUrlRequest(package: package, url: url),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearHistoryByType(String type) async {
    try {
      await MiruGrpcClient.dbClient.deleteAllHistory(
        proto.DeleteAllHistoryRequest(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
