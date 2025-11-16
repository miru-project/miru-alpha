import 'package:miru_app_new/miru_core/network.dart';
import '../../model/index.dart';

class GithubNetwork {
  static Future<List<ExtensionRepo>> fetchRepo() async {
    final List<ExtensionRepo> resList = [];
    final repoInfo = await MiruCoreEndpoint.getRepo();
    final Map<String, String> urlToName = {};
    if (repoInfo is List) {
      for (final item in repoInfo) {
        if (item is Map && item.containsKey('url')) {
          final u = item['url']?.toString() ?? '';
          final n = item['name']?.toString() ?? u;
          urlToName[u] = n;
        }
      }
    }

    final Map<String, dynamic> req = await MiruCoreEndpoint.fetchRepo();
    req.forEach((repoUrl, rawList) {
      final List<GithubExtension> repoList = [];
      for (final ext in rawList) {
        repoList.add(GithubExtension.fromJson(ext));
      }
      final name = urlToName[repoUrl] ?? repoUrl;
      resList.add(
        ExtensionRepo(extensions: repoList, name: name, url: repoUrl),
      );
    });

    return resList;
  }
}

class ExtensionRepo {
  final List<GithubExtension> extensions;
  final String name;
  final String url;

  ExtensionRepo({
    required this.extensions,
    required this.name,
    required this.url,
  });
}
