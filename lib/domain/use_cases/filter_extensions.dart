import 'package:miru_alpha/domain/models/extension.dart';

class FilterExtensionsUseCase {
  List<DomainExtensionRepo> call({
    required List<DomainExtensionRepo> repos,
    String? repoName,
    String? query,
    ExtensionType typeFilter = ExtensionType.all,
    ExtensionInstallStatus installFilter = ExtensionInstallStatus.all,
    required List<String> installedPackages,
  }) {
    List<DomainExtensionRepo> repoResult = repos;

    if (repoName != null && repoName.isNotEmpty) {
      repoResult = repoResult.where((r) => r.name == repoName).toList();
    }

    // `all` means no type restriction.
    final targetType = typeFilter == ExtensionType.all ? null : typeFilter;

    final filteredRepos = <DomainExtensionRepo>[];

    for (final repo in repoResult) {
      var exts = repo.extensions;

      if (targetType != null) {
        exts = exts.where((e) => e.type == targetType).toList();
      }

      switch (installFilter) {
        case ExtensionInstallStatus.installed:
          exts = exts
              .where((e) => installedPackages.contains(e.packageName))
              .toList();
        case ExtensionInstallStatus.notInstalled:
          exts = exts
              .where((e) => !installedPackages.contains(e.packageName))
              .toList();
        case ExtensionInstallStatus.all:
          break;
      }

      if (query != null && query.isNotEmpty) {
        final lower = query.toLowerCase();
        exts = exts.where((e) => e.name.toLowerCase().contains(lower)).toList();
      }

      if (exts.isNotEmpty ||
          (typeFilter == ExtensionType.all &&
              installFilter == ExtensionInstallStatus.all &&
              (query == null || query.isEmpty))) {
        filteredRepos.add(
          DomainExtensionRepo(name: repo.name, url: repo.url, extensions: exts),
        );
      }
    }

    return filteredRepos;
  }
}
