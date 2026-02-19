import 'package:miru_app_new/miru_core/network.dart';
import '../../model/index.dart';

class GithubNetwork {
  static Future<List<ExtensionRepo>> fetchRepo() async {
    final repoInfo = await MiruCoreEndpoint.getRepoLists();
    final urlToName = {for (final config in repoInfo) config.link: config.name};

    final Map<String, dynamic> req = await MiruCoreEndpoint.fetchRepos();
    return req.entries
        .map(
          (e) => ExtensionRepo.fromJson({
            'extensions': e.value,
            'name': urlToName[e.key] ?? e.key,
            'url': e.key,
          }),
        )
        .toList();
  }
}
