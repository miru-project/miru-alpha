import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/miru_core/network/network.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
import 'package:miru_app_new/utils/log.dart';
import 'package:miru_app_new/utils/network/github_network.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

class ExtensionPageModel {
  final List<ExtensionRepo> fetchedRepo;
  final List<ExtensionRepo> extensionList;
  final bool loading;
  final List<String> installedPackages;
  final List<ExtensionMeta> metaData;
  final DateTime? update;

  const ExtensionPageModel({
    required this.fetchedRepo,
    required this.extensionList,
    required this.installedPackages,
    required this.metaData,
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
  }) {
    return ExtensionPageModel(
      fetchedRepo: fetchedRepo ?? this.fetchedRepo,
      extensionList: extensionList ?? this.extensionList,
      loading: loading ?? this.loading,
      installedPackages: installedPackages ?? this.installedPackages,
      metaData: metaData ?? this.metaData,
      update: update ?? this.update,
    );
  }
}

class ExtensionPageState {
  static final ExtensionPageState instance = ExtensionPageState._internal();

  late ExtensionPageModel state;

  ExtensionPageState._internal() {
    state = const ExtensionPageModel(
      fetchedRepo: [],
      extensionList: [],
      installedPackages: [],
      metaData: [],
      update: null,
      loading: false,
    );
  }

  void update(ExtensionPageModel newState) {
    state = newState;
  }
}

class ExtensionPageNotifier extends StateNotifier<ExtensionPageModel> {
  String get selectedRepoUrl => _selectedRepoUrl;
  String _selectedRepoUrl = '';
  ExtensionPageNotifier()
    : snappingController = SnappingSheetController(),
      super(
        ExtensionPageModel(
          fetchedRepo: const [],
          extensionList: const [],
          installedPackages: const [],
          metaData: [],
        ),
      ) {
    // initialize installedPackages from ExtensionUtils.runtimes
    state = state.copyWith(
      installedPackages: ExtensionUtils.runtimes.keys.toList(),
    );
    ExtensionPageState.instance.update(state);
  }

  final SnappingSheetController snappingController;

  Future<void> loadRepos({bool force = false}) async {
    if (!force && state.fetchedRepo.isNotEmpty) return;
    // set loading
    state = state.copyWith(loading: true);
    ExtensionPageState.instance.update(state);
    try {
      final list = await GithubNetwork.fetchRepo();
      // set fetched repos and default extension list (all repos)
      state = state.copyWith(
        fetchedRepo: list,
        extensionList: List.from(list),
        loading: false,
        update: DateTime.now(),
      );
      ExtensionPageState.instance.update(state);
    } catch (e) {
      logger.info('failed to load repos: $e');
      state = state.copyWith(loading: false);
      ExtensionPageState.instance.update(state);
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
    ExtensionPageState.instance.update(state);
  }

  /// Return available repo names for UI selects
  List<String> repoNames() => state.fetchedRepo.map((r) => r.name).toList();

  /// Select repository by name (don't refetch), show only that repo's extensions
  void selectRepoByName(String repoName) {
    if (repoName.isEmpty) {
      state = state.copyWith(extensionList: List.from(state.fetchedRepo));
      ExtensionPageState.instance.update(state);
      return;
    }
    final found = state.fetchedRepo.where((r) => r.name == repoName).toList();
    state = state.copyWith(extensionList: found);
    ExtensionPageState.instance.update(state);
  }

  void filterByName(String query) {
    if (query.isEmpty) {
      state = state.copyWith(extensionList: List.from(state.fetchedRepo));
      ExtensionPageState.instance.update(state);
      return;
    }
    final lower = query.toLowerCase();
    // filter repos by name or any extension name
    for (final repo in state.fetchedRepo) {
      if (repo.url == _selectedRepoUrl || _selectedRepoUrl.isEmpty) {
        final filteredExtensions =
            repo.extensions
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
        ExtensionPageState.instance.update(state);
        return;
      }
    }
    // state = state.copyWith(extensionList: filtered);
    // ExtensionPageState.instance.update(state);
  }

  void filterByRepo(String repoName) {
    if (repoName.isEmpty) {
      state = state.copyWith(extensionList: List.from(state.fetchedRepo));
      ExtensionPageState.instance.update(state);
      return;
    }
    final filtered =
        state.fetchedRepo.where((repo) => repo.name == repoName).toList();
    _selectedRepoUrl = filtered.isNotEmpty ? filtered.first.url : '';
    state = state.copyWith(extensionList: filtered);
    ExtensionPageState.instance.update(state);
  }

  void filterByInstalledIndex(int val) {
    final filteredExtensions =
        state.fetchedRepo
            .expand((repo) => repo.extensions)
            .where(
              (ext) =>
                  (val == 0 && state.installedPackages.contains(ext.package)) ||
                  (val == 1 && !state.installedPackages.contains(ext.package)),
            )
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
    ExtensionPageState.instance.update(state);
  }

  void filterByMediaType(String type) {
    if (type.isEmpty || type == 'ALL') {
      state = state.copyWith(extensionList: List.from(state.fetchedRepo));
      ExtensionPageState.instance.update(state);
      return;
    }
    final filteredExtensions =
        state.fetchedRepo
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
    ExtensionPageState.instance.update(state);
  }

  bool isInstalled(String package) => state.installedPackages.contains(package);

  Future<void> installPackage(String package, String repoUrl) async {
    try {
      await ExtensionEndpoint.downloadExtension(repoUrl, package);
      logger.info('install package $package from $repoUrl');
      final newInstalled = List<String>.from(state.installedPackages)
        ..add(package);
      state = state.copyWith(installedPackages: newInstalled);
      ExtensionPageState.instance.update(state);
    } catch (e) {
      logger.info(e.toString());
    }
  }

  Future<void> uninstallPackage(String package) async {
    try {
      await ExtensionEndpoint.removeExtension(package);
      logger.info('remove package $package ');
      final newInstalled = List<String>.from(state.installedPackages)
        ..remove(package);
      state = state.copyWith(installedPackages: newInstalled);
      ExtensionPageState.instance.update(state);
    } catch (e) {
      logger.info(e.toString());
    }
  }

  /// Update metadata received from miru-core. As requested, metadata may be unused,
  /// but we update installedPackages from metadata.packageName when provided.
  void setMetaData(List<ExtensionMeta>? data) {
    if (data == null) {
      state = state.copyWith(metaData: null, update: DateTime.now());
      return;
    }

    final pkgs =
        data
            .map((e) => e.packageName)
            .where((p) => p.isNotEmpty)
            .toSet()
            .toList();
    state = state.copyWith(
      metaData: data,
      installedPackages: pkgs,
      update: DateTime.now(),
    );
    ExtensionPageState.instance.update(state);
  }
}

final extensionPageControllerProvider =
    StateNotifierProvider<ExtensionPageNotifier, ExtensionPageModel>((ref) {
      return ExtensionPageNotifier();
    });
