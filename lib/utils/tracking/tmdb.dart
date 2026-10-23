import 'package:dio/dio.dart';
import 'package:miru_alpha/model/tmdb_model.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';

class TMDBProvider {
  static const apiKey = String.fromEnvironment('TMDB_API_KEY');
  static const apiAccessToken = String.fromEnvironment('TMDB_ACCESS_TOKEN');

  /// Credential from Settings → "TMDB api key": a v4 read access token when
  /// it looks like a JWT, a v3 api key otherwise. Missing settings storage
  /// (tests) counts as empty rather than throwing.
  static String get _settingCredential {
    try {
      return MiruSettings.getSettingSync<String>(SettingKey.tmdbKey).trim();
    } catch (_) {
      return '';
    }
  }

  /// Auth attempts for [url], most preferred first. The `--dart-define`
  /// values (dev launch configs) beat the Settings entry; a v4 bearer token
  /// beats a v3 api key. A 401 then falls through to the next variant.
  static List<({Options options, String url})> _authVariants(String url) {
    final setting = _settingCredential;
    final isJwt = setting.split('.').length == 3;
    return [
      for (final token in [
        if (apiAccessToken.isNotEmpty) apiAccessToken,
        if (setting.isNotEmpty && isJwt) setting,
      ])
        (
          url: url,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'accept': 'application/json',
            },
          ),
        ),
      for (final key in [
        if (apiKey.isNotEmpty) apiKey,
        if (setting.isNotEmpty && !isJwt) setting,
      ])
        (
          url: url.contains('?') ? '$url&api_key=$key' : '$url?api_key=$key',
          options: Options(headers: {'accept': 'application/json'}),
        ),
    ];
  }

  /// GET [url] trying each credential variant in turn: a 401 (expired or
  /// wrong key) falls back to the next one. Returns null without hitting
  /// the network when no key is configured at all, so detail pages stay
  /// quiet instead of toasting a 401 on every entry.
  static Future<dynamic> _authGet(String url) async {
    final variants = _authVariants(url);
    if (variants.isEmpty) {
      logger.warning('TMDB call skipped: no api key configured');
      return null;
    }
    DioException? unauthorized;
    for (final variant in variants) {
      try {
        return await MiruRequest.get(variant.url, options: variant.options);
      } on DioException catch (e) {
        if (e.response?.statusCode != 401) rethrow;
        unauthorized = e;
      }
    }
    throw unauthorized!;
  }

  static Future<TMDBDetail?> apiGetDetail(
    int tmdbId,
    String mediaType, {
    bool isRetry = false,
  }) async {
    final type = mediaType == "tv" ? "tv" : "movie";
    final url =
        "https://api.themoviedb.org/3/$type/$tmdbId?append_to_response=credits,images";

    try {
      final resp = await _authGet(url);
      if (resp == null) return null;
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
      final searchResp = await _authGet(searchUrl);
      if (searchResp == null) return null;
      if ((searchResp['results'] as List).isNotEmpty) {
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
