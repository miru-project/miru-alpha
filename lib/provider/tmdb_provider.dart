import 'dart:convert';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/tmdb_model.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/tracking/tmdb.dart';
import 'package:miru_alpha/widgets/core/toast.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tmdb_provider.g.dart';

@riverpod
class TMDBNotifier extends _$TMDBNotifier {
  @override
  FutureOr<TMDBDetail?> build() {
    return null;
  }

  Future<TMDBDetail?> getDetail(int tmdbId, String mediaType) async {
    // 1. Check Backend
    try {
      final cache = await MiruGrpcClient.dbClient.getTrack(
        proto.GetTrackRequest()
          ..trackingId = tmdbId.toString()
          ..provider = "TMDB",
      );
      if (cache.hasTrack() && cache.track.data.isNotEmpty) {
        return TMDBDetail.fromJson(jsonDecode(cache.track.data));
      }
    } catch (e) {
      logger.info(e);
      showSimpleToast(e.toString());
    }

    // 2. Fetch from TMDB API
    final detail = await TMDBProvider.apiGetDetail(tmdbId, mediaType);
    if (detail == null) return null;

    // 3. Save to Backend
    try {
      await MiruGrpcClient.dbClient.putTrack(
        proto.PutTrackRequest()
          ..trackingId = tmdbId.toString()
          ..data = jsonEncode(detail.toJson())
          ..mediaType = mediaType
          ..provider = "TMDB",
      );
    } catch (e) {
      // Ignore save error
    }

    return detail;
  }

  Future<TMDBDetail?> searchAndGetDetail(String query, String mediaType) async {
    return await TMDBProvider.apiSearch(query, mediaType);
  }
}
