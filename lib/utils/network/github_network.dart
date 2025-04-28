import 'package:dio/dio.dart';
import '../../model/index.dart';

class GithubNetwork {
  static const String repoUrl = 'https://miru-repo.0n0.dev/index.json';
  static Future<List<GithubExtension>> fetchRepo() async {
    final req = await Dio().get(repoUrl);
    final List repo = req.data;
    final cast = repo.cast<Map<String, dynamic>>().toList();
    return List<GithubExtension>.from(
      cast.map((x) => GithubExtension.fromJson(x)),
    );
  }
}
