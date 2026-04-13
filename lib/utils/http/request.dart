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
    final qIndex = url.indexOf('?');
    if (qIndex != -1) {
      final pathPart = url.substring(0, qIndex);
      final queryPart = url.substring(qIndex + 1);
      return proxyBaseUrl.replace(path: '/proxy/$pathPart', query: queryPart);
    }
    return proxyBaseUrl.replace(path: '/proxy/$url');
  }
}
