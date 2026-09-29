import 'package:miru_alpha/utils/http/request.dart';

class NetworkService {
  Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    try {
      return await MiruRequest.get(url);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(
    String url,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      return await MiruRequest.post(url, data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> rawGet(String url, {Map<String, String>? headers}) async {
    try {
      return await MiruRequest.rawGet(url);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> rawPost(
    String url,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      return await MiruRequest.rawPost(url, data);
    } catch (e) {
      rethrow;
    }
  }
}
