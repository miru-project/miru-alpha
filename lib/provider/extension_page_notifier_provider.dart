import 'package:miru_app_new/miru_core/network.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/utils/network/github_network.dart';
import 'package:miru_app_new/model/model.dart';
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
  String get selectedRepoUrl => _selectedRepoUrl;
  String _selectedRepoUrl = '';

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

  Future<void> loadRepos({bool force = false}) async {
    if (!force && state.fetchedRepo.isNotEmpty) return;
    // set loading
    state = state.copyWith(loading: true);
    try {
      final list = await GithubNetwork.fetchRepo();
      state = state.copyWith(
        fetchedRepo: list,
        extensionList: List.from(list),
        loading: false,
        update: DateTime.now(),
      );
    } catch (e) {
      logger.info('failed to load repos: $e');
      state = state.copyWith(loading: false);
    }
  }

  Future<void> reloadRepos() async {
    await loadRepos(force: true);
  }

  void setFetchedRepo(List<ExtensionRepo> list) {
    state = state.copyWith(
      fetchedRepo: list,
      extensionList: List.from(list),
      loading: false,
    );
  }

  /// Return available repo names for UI selects
  List<String> repoNames() => state.fetchedRepo.map((r) => r.name).toList();

  /// Select repository by name (don't refetch), show only that repo's extensions
  void selectRepoByName(String repoName) {
    if (repoName.isEmpty) {
      state = state.copyWith(extensionList: List.from(state.fetchedRepo));
      return;
    }
    final found = state.fetchedRepo.where((r) => r.name == repoName).toList();
    state = state.copyWith(extensionList: found);
  }

  void filterByName(String query) {
    if (query.isEmpty) {
      state = state.copyWith(extensionList: List.from(state.fetchedRepo));
      return;
    }
    final lower = query.toLowerCase();
    // filter repos by name or any extension name
    for (final repo in state.fetchedRepo) {
      if (repo.url == _selectedRepoUrl || _selectedRepoUrl.isEmpty) {
        final filteredExtensions = repo.extensions
            .where((ext) => ext.name.toLowerCase().contains(lower))
            .toList();
        state = state.copyWith(
          extensionList: [
            ExtensionRepo(
              extensions: filteredExtensions,
              name: repo.name,
              url: repo.url,
            ),
          ],
        );
        return;
      }
    }
  }

  void filterByRepo(String repoName) {
    if (repoName.isEmpty) {
      state = state.copyWith(extensionList: List.from(state.fetchedRepo));
      return;
    }
    final filtered = state.fetchedRepo
        .where((repo) => repo.name == repoName)
        .toList();
    _selectedRepoUrl = filtered.isNotEmpty ? filtered.first.url : '';
    state = state.copyWith(extensionList: filtered);
  }

  void filterByInstalled(String status) {
    switch (status) {
      case 'ALL':
        state = state.copyWith(extensionList: List.from(state.fetchedRepo));
        return;
      case 'Installed':
        final filtered = state.fetchedRepo
            .expand((repo) => repo.extensions)
            .where((ext) => state.installedPackages.contains(ext.package))
            .toList();
        state = state.copyWith(
          extensionList: [
            ExtensionRepo(extensions: filtered, name: 'filtered', url: ''),
          ],
        );
        return;
      case 'Not installed':
        final filtered = state.fetchedRepo
            .expand((repo) => repo.extensions)
            .where((ext) => !state.installedPackages.contains(ext.package))
            .toList();
        state = state.copyWith(
          extensionList: [
            ExtensionRepo(extensions: filtered, name: 'filtered', url: ''),
          ],
        );
        return;
      default:
        state = state.copyWith(extensionList: List.from(state.fetchedRepo));
        return;
    }
  }

  void filterByMediaType(String type) {
    if (type.isEmpty || type == 'ALL') {
      state = state.copyWith(extensionList: List.from(state.fetchedRepo));
      return;
    }
    final filteredExtensions = state.fetchedRepo
        .expand((repo) => repo.extensions)
        .where((ext) => ext.type == type.toLowerCase())
        .toList();
    state = state.copyWith(
      extensionList: [
        ExtensionRepo(
          extensions: filteredExtensions,
          name: 'filtered',
          url: '',
        ),
      ],
    );
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
