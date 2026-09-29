import 'package:miru_alpha/data/services/extension_service.dart';
import 'package:miru_alpha/domain/models/detail.dart';
import 'package:miru_alpha/domain/models/extension.dart';

class ExtensionRepository {
  final ExtensionService _extensionService;

  ExtensionRepository(this._extensionService);

  Future<List<DomainExtensionMeta>> getExtensionList() async {
    final items = await _extensionService.getExtensionList();
    return items
        .map(
          (item) => DomainExtensionMeta(
            name: item.name,
            version: item.version,
            author: item.author,
            license: item.license,
            lang: item.lang,
            icon: item.icon,
            packageName: item.package,
            webSite: item.webSite,
            description: item.description,
            tags: item.tags,
            api: item.api,
            type: ExtensionTypeX.fromRaw(item.type),
            error: item.error,
            nsfw: item.nsfw,
          ),
        )
        .toList();
  }

  Future<DomainDetail> getExtensionDetail(String packageName) async {
    final detail = await _extensionService.getExtensionDetail(packageName);
    return DomainDetail(
      title: detail.title,
      cover: detail.cover,
      desc: detail.desc,
      episodes: detail.episodes
          .map((e) => DomainEpisodeGroup.fromProto(e))
          .toList(),
      headers: detail.headers.map((k, v) => MapEntry(k, v)),
      downloaded: const [],
      detailUrl: '',
      package: packageName,
    );
  }

  Future<void> installExtension(String packageName, String repoUrl) async {
    await _extensionService.installExtension(packageName, repoUrl);
  }

  Future<void> uninstallExtension(String packageName) async {
    await _extensionService.uninstallExtension(packageName);
  }

  Future<void> updateExtension(String packageName, String repoUrl) async {
    await _extensionService.updateExtension(packageName, repoUrl);
  }

  Future<List<DomainExtensionRepo>> getRepos() async {
    final repos = await _extensionService.getRepos();
    return repos
        .map(
          (repo) => DomainExtensionRepo(
            name: repo.name,
            url: repo.url,
            extensions: repo.extensions
                .map(
                  (ext) => DomainExtensionMeta(
                    name: ext.name,
                    version: ext.version,
                    author: ext.author,
                    license: ext.license,
                    lang: ext.lang,
                    icon: ext.icon,
                    packageName: ext.package,
                    webSite: ext.webSite,
                    description: ext.description,
                    tags: ext.tags.toList(),
                    api: '',
                    type: ExtensionTypeX.fromRaw(ext.type),
                    error: null,
                    nsfw: ext.nsfw,
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  Future<void> addRepo(String name, String url) async {
    await _extensionService.addRepo(name, url);
  }

  Future<void> removeRepo(String url) async {
    await _extensionService.removeRepo(url);
  }

  Future<List<DomainExtensionMeta>> fetchRepoExtensions(String repoUrl) async {
    final extensions = await _extensionService.fetchRepoExtensions(repoUrl);
    return extensions
        .map(
          (ext) => DomainExtensionMeta(
            name: ext.name,
            version: ext.version,
            author: ext.author,
            license: ext.license,
            lang: ext.lang,
            icon: ext.icon,
            packageName: ext.package,
            webSite: ext.webSite,
            description: ext.description,
            tags: ext.tags,
            api: ext.api,
            type: ExtensionTypeX.fromRaw(ext.type),
            error: ext.error,
            nsfw: ext.nsfw,
          ),
        )
        .toList();
  }
}
