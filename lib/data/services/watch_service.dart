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
        // V2 golang emits either the source/group list (watch) or the "all"
        // bundle. The load entry unwraps ExtensionAllWatch by declared @type.
        case WatchResponse_Data.watch:
          data = response.watch;
          break;
        case WatchResponse_Data.all:
          data = response.all;
          break;
        // V1 (JS) only — golang V2 never returns these directly.
        case WatchResponse_Data.bangumi:
          data = response.bangumi;
          break;
        case WatchResponse_Data.manga:
          data = response.manga;
          break;
        case WatchResponse_Data.fikushon:
          data = response.fikushon;
          break;
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
