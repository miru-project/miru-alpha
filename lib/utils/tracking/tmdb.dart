import 'package:dio/dio.dart';
import 'package:miru_alpha/model/tmdb_model.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/widgets/core/toast.dart';

class TMDBProvider {
  static const apiKey = String.fromEnvironment('TMDB_API_KEY');
  static const apiAccessToken = String.fromEnvironment('TMDB_ACCESS_TOKEN');

  static Options get _options => Options(
    headers: {
      'Authorization': 'Bearer $apiAccessToken',
      'accept': 'application/json',
    },
  );

  static Future<TMDBDetail?> apiGetDetail(
    int tmdbId,
    String mediaType, {
    bool isRetry = false,
  }) async {
    final type = mediaType == "tv" ? "tv" : "movie";
    final url =
        "https://api.themoviedb.org/3/$type/$tmdbId?append_to_response=credits,images";

    try {
      final resp = await MiruRequest.get(url, options: _options);
      return TMDBDetail.fromApi(resp, type);
    } catch (e) {
      if (!isRetry && e is DioException && e.response?.statusCode == 404) {
        // Fallback to the other media type since extensions sometimes misclassify
        final otherType = type == "tv" ? "movie" : "tv";
        return apiGetDetail(tmdbId, otherType, isRetry: true);
      }
      showSimpleToast("Failed to fetch TMDB detail: ${e.toString()}");
      return null;
    }
  }

  static String getImageUrl(String path) {
    return "https://image.tmdb.org/t/p/w300$path";
  }

  static Future<TMDBDetail?> apiSearch(String query, String mediaType) async {
    final searchUrl =
        "https://api.themoviedb.org/3/search/multi?query=${Uri.encodeComponent(query)}";

    try {
      final searchResp = await MiruRequest.get(searchUrl, options: _options);
      if (searchResp != null && (searchResp['results'] as List).isNotEmpty) {
        final results = searchResp['results'] as List;
        final targetResult = results.firstWhere(
          (e) => e['media_type'] == 'movie' || e['media_type'] == 'tv',
          orElse: () => null,
        );

        if (targetResult != null) {
          return await apiGetDetail(
            targetResult['id'],
            targetResult['media_type'],
          );
        }
      }
    } catch (e) {
      showSimpleToast(e.toString());
    }
    return null;
  }
}
