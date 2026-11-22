import 'dart:convert';

import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/tmdb_model.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/tracking/tmdb.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tmdb_provider.g.dart';

@riverpod
class TMDBNotifier extends _$TMDBNotifier {
  @override
  FutureOr<TMDBDetail?> build() {
    return null;
  }

  Future<TMDBDetail?> getDetail(int tmdbId, String mediaType) async {
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

    final detail = await TMDBProvider.apiGetDetail(tmdbId, mediaType);
    if (detail == null) return null;

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

  /// Store a detail we already fetched (e.g. from a search) so the next
  /// [getDetail] for this id is a backend-cache hit instead of an API call.
  Future<void> cacheDetail(TMDBDetail detail, String mediaType) async {
    try {
      await MiruGrpcClient.dbClient.putTrack(
        proto.PutTrackRequest()
          ..trackingId = detail.id.toString()
          ..data = jsonEncode(detail.toJson())
          ..mediaType = mediaType
          ..provider = "TMDB",
      );
    } catch (e) {
      // A cache miss must never break the detail page.
      logger.info('TMDB cache write failed: $e');
    }
  }
}
