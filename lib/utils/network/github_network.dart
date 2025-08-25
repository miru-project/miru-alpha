import 'package:miru_app_new/miru_core/network/network.dart';
import '../../model/index.dart';

class GithubNetwork {
  static Future<List<ExtensionRepo>> fetchRepo() async {
    final List<ExtensionRepo> resList = [];
    final Map<String, dynamic> req = await CoreNetwork.requestJSON("ext/repolist");
    req.forEach((repoUrl, rawList) {
      final List<GithubExtension> repoList = [];
      for (final ext in rawList) {
        repoList.add(GithubExtension.fromJson(ext));
      }
      resList.add(ExtensionRepo(extensions: repoList, name: "", url: repoUrl));
    });
    return resList;
  }
}

class ExtensionRepo {
  final List<GithubExtension> extensions;
  final String name;
  final String url;

  ExtensionRepo({required this.extensions, required this.name, required this.url});
}
