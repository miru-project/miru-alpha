import 'package:miru_alpha/domain/models/extension.dart';

class FilterExtensionsUseCase {
  List<DomainExtensionRepo> call({
    required List<DomainExtensionRepo> repos,
    String? repoName,
    String? query,
    String? typeFilter,
    String? installFilter,
    required List<String> installedPackages,
  }) {
    List<DomainExtensionRepo> repoResult = repos;

    if (repoName != null && repoName.isNotEmpty) {
      repoResult = repoResult.where((r) => r.name == repoName).toList();
    }

    final filteredRepos = <DomainExtensionRepo>[];

    for (final repo in repoResult) {
      var exts = repo.extensions;

      if (typeFilter != null && typeFilter.isNotEmpty && typeFilter != 'ALL') {
        exts = exts
            .where(
              (e) =>
                  e.type.name.toLowerCase() == typeFilter.toLowerCase(),
            )
            .toList();
      }

      if (installFilter == 'extension.installed') {
        exts = exts
            .where((e) => installedPackages.contains(e.packageName))
            .toList();
      } else if (installFilter == 'extension.not_installed') {
        exts = exts
            .where((e) => !installedPackages.contains(e.packageName))
            .toList();
      }

      if (query != null && query.isNotEmpty) {
        final lower = query.toLowerCase();
        exts = exts.where((e) => e.name.toLowerCase().contains(lower)).toList();
      }

      if (exts.isNotEmpty ||
          (typeFilter == 'ALL' &&
              installFilter == 'ALL' &&
              (query == null || query.isEmpty))) {
        filteredRepos.add(
          DomainExtensionRepo(name: repo.name, url: repo.url, extensions: exts),
        );
      }
    }

    return filteredRepos;
  }
}
