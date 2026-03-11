import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/network/github_network.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'extension_page_notifier_provider.g.dart';

class ExtensionPageModel {
  final List<ExtensionRepo> fetchedRepo;
  final List<ExtensionRepo> extensionList;
  final bool loading;
  final List<String> installedPackages;
  final List<ExtensionMeta> metaData;
  final DateTime? update;
  final int sourceIndex;

  const ExtensionPageModel({
    required this.fetchedRepo,
    required this.extensionList,
    required this.installedPackages,
    required this.metaData,
    required this.sourceIndex,
    this.update,
    this.loading = false,
  });

  ExtensionPageModel copyWith({
    List<ExtensionRepo>? fetchedRepo,
    List<ExtensionRepo>? extensionList,
    bool? loading,
    List<String>? installedPackages,
    List<ExtensionMeta>? metaData,
    DateTime? update,
    int? sourceIndex,
  }) {
    return ExtensionPageModel(
      fetchedRepo: fetchedRepo ?? this.fetchedRepo,
      extensionList: extensionList ?? this.extensionList,
      loading: loading ?? this.loading,
      installedPackages: installedPackages ?? this.installedPackages,
      metaData: metaData ?? this.metaData,
      update: update ?? this.update,
      sourceIndex: sourceIndex ?? this.sourceIndex,
    );
  }
}

@Riverpod(keepAlive: true)
class ExtensionPageNotifier extends _$ExtensionPageNotifier {
  List<ExtensionMeta> get extMeta => state.metaData;

  String cacheRepoName = '';
  String cacheQuery = '';
  String cacheType = 'ALL';
  String cacheInstalled = 'ALL';

  @override
  ExtensionPageModel build() {
    final initial = ExtensionPageModel(
      fetchedRepo: const [],
      extensionList: const [],
      installedPackages: const [],
      metaData: const [],
      update: null,
      loading: false,
      sourceIndex: 0,
    );
    return initial;
  }

  // Fetch
  Future<void> loadRepos({bool force = false}) async {
    if (!force && state.fetchedRepo.isNotEmpty) return;
    // set loading
    state = state.copyWith(loading: true);
    try {
      final list = await GithubNetwork.fetchRepo();
      state = state.copyWith(
        fetchedRepo: list,
        loading: false,
        update: DateTime.now(),
      );
      filter();
    } catch (e) {
      logger.info('failed to load repos: $e');
      state = state.copyWith(loading: false);
    }
  }

  Future<void> reloadRepos() async {
    await loadRepos(force: true);
  }

  /// Return available repo names for UI selects
  List<String> getRepoNames() => state.fetchedRepo.map((r) => r.name).toList();

  /// FILTER
  void filter() {
    List<ExtensionRepo> repoResult = state.fetchedRepo;

    if (cacheRepoName.isNotEmpty) {
      repoResult = repoResult.where((r) => r.name == cacheRepoName).toList();
    }

    List<ExtensionRepo> finalResult = [];

    for (var repo in repoResult) {
      var exts = repo.extensions;

      if (cacheType.isNotEmpty && cacheType != 'ALL') {
        exts = exts.where((e) => e.type == cacheType.toLowerCase()).toList();
      }

      if (cacheInstalled == 'Installed') {
        exts = exts
            .where((e) => state.installedPackages.contains(e.package))
            .toList();
      } else if (cacheInstalled == 'Not installed') {
        exts = exts
            .where((e) => !state.installedPackages.contains(e.package))
            .toList();
      }

      if (cacheQuery.isNotEmpty) {
        final lower = cacheQuery.toLowerCase();
        exts = exts.where((e) => e.name.toLowerCase().contains(lower)).toList();
      }

      if (exts.isNotEmpty ||
          (cacheType == 'ALL' &&
              cacheInstalled == 'ALL' &&
              cacheQuery.isEmpty)) {
        finalResult.add(
          ExtensionRepo(name: repo.name, url: repo.url, extensions: exts),
        );
      }
    }

    state = state.copyWith(extensionList: finalResult);
  }

  /// Select repository by name (don't refetch), show only that repo's extensions
  void filterRepoByName(String repoName) {
    cacheRepoName = repoName;
    filter();
  }

  void filterByName(String query) {
    cacheQuery = query;
    filter();
  }

  void filterByRepo(String repoName) {
    cacheRepoName = repoName;
    filter();
  }

  void filterByInstalled(String status) {
    cacheInstalled = status;
    filter();
  }

  void filterByMediaType(String type) {
    cacheType = type;
    filter();
  }

  bool isInstalled(String package) => state.installedPackages.contains(package);

  Future<void> installPackage(String package, String repoUrl) async {
    try {
      await MiruCoreEndpoint.downloadExtension(repoUrl, package);
      logger.info('install package $package from $repoUrl');
      final newInstalled = List<String>.from(state.installedPackages)
        ..add(package);
      state = state.copyWith(installedPackages: newInstalled);
    } catch (e) {
      logger.info(e.toString());
    }
  }

  Future<String?> uninstallPackage(String package) async {
    try {
      await MiruCoreEndpoint.removeExtension(package);
      logger.info('remove package $package ');
      final newInstalled = List<String>.from(state.installedPackages)
        ..remove(package);
      state = state.copyWith(installedPackages: newInstalled);
      return null;
    } catch (e) {
      logger.info(e.toString());
      return e.toString();
    }
  }

  /// Update metadata received from miru-core. As requested, metadata may be unused,
  /// but we update installedPackages from metadata.packageName when provided.
  void setMetaData(List<ExtensionMeta>? data) {
    if (data == null) {
      state = state.copyWith(metaData: null, update: DateTime.now());
      return;
    }

    final pkgs = data
        .map((e) => e.packageName)
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList();
    state = state.copyWith(
      metaData: data,
      installedPackages: pkgs,
      update: DateTime.now(),
    );
  }
}
