import 'package:dio/dio.dart';

class MiruRequest {
  static final _dio = Dio();
  static late final Uri baseHost;
  static late final Uri proxyBaseUrl;

  static void ensureInitalized({required String host}) {
    baseHost = Uri.parse(host);
    proxyBaseUrl = baseHost.replace(path: '/proxy/');
  }

  static Future<dynamic> get(String url, {Options? options}) async {
    final response = await _dio.get(proxyUrl(url).toString(), options: options);
    return response.data;
  }

  static Future<dynamic> post(
    String url,
    Map<String, dynamic> data, {
    Options? options,
  }) async {
    final response = await _dio.post(
      proxyUrl(url).toString(),
      data: data,
      options: options,
    );
    return response.data;
  }

  static Future<dynamic> rawGet(String url, {Options? options}) async {
    final response = await _dio.get(url, options: options);
    return response.data;
  }

  static Future<dynamic> rawPost(
    String url,
    Map<String, dynamic> data, {
    Options? options,
  }) async {
    final response = await _dio.post(url, data: data, options: options);
    return response.data;
  }

  static Uri proxyUrl(String url) {
    return proxyBaseUrl.resolve(Uri.encodeComponent(url));
  }
}
