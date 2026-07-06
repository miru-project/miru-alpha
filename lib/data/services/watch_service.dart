import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart';
import 'package:miru_alpha/model/watch_result.dart';

class WatchService {
  Future<WatchResult> getWatchResult(
    String package,
    String detailUrl,
    String episodeUrl,
  ) async {
    try {
      final response = await MiruGrpcClient.extensionClient.watch(
        WatchRequest(pkg: package, url: detailUrl),
      );

      dynamic data;
      switch (response.whichData()) {
        case WatchResponse_Data.bangumi:
          data = response.bangumi;
          break;
        case WatchResponse_Data.manga:
          data = response.manga;
          break;
        case WatchResponse_Data.fikushon:
          data = response.fikushon;
          break;
        case WatchResponse_Data.watch:
        case WatchResponse_Data.raw:
        default:
          break;
      }

      if (data == null) {
        throw StateError('Unsupported watch response type');
      }

      return WatchResult(data: data, v2watch: response.watch);
    } catch (e) {
      rethrow;
    }
  }
}
