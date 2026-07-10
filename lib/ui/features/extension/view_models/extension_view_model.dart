import 'package:miru_alpha/data/repositories/extension_repository.dart';
import 'package:miru_alpha/data/services/extension_service.dart';
import 'package:miru_alpha/domain/models/extension.dart';
import 'package:miru_alpha/domain/models/extension_view.dart';
import 'package:miru_alpha/domain/use_cases/filter_extensions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'extension_view_model.g.dart';

@riverpod
class ExtensionViewModel extends _$ExtensionViewModel {
  @override
  DomainExtensionViewState build() {
    return const DomainExtensionViewState();
  }

  ExtensionRepository _repository() => ExtensionRepository(ExtensionService());
  FilterExtensionsUseCase get _filterUseCase => FilterExtensionsUseCase();

  Future<void> loadRepos({bool force = false}) async {
    if (!force && state.repos.isNotEmpty) return;

    final current = state;
    state = current.copyWith(isLoading: true);

    try {
      final extensionRepository = _repository();
      final repos = await extensionRepository.getRepos();
      final installed = <String>[];

      state = current.copyWith(
        repos: repos,
        installedPackages: installed,
        isLoading: false,
      );

      _applyFilters();
    } catch (e) {
      state = current.copyWith(isLoading: false);
    }
  }

  void filterByRepo(String? repoName) {
    final current = state;
    state = current.copyWith(selectedRepoName: repoName ?? '');
    _applyFilters();
  }

  void filterByQuery(String query) {
    final current = state;
    state = current.copyWith(query: query);
    _applyFilters();
  }

  void filterByType(ExtensionType type) {
    final current = state;
    state = current.copyWith(typeFilter: type);
    _applyFilters();
  }

  void filterByInstallStatus(String status) {
    final current = state;
    state = current.copyWith(
      installFilter: ExtensionInstallStatusX.fromRaw(status),
    );
    _applyFilters();
  }

  bool isInstalled(String package) {
    return state.installedPackages.contains(package);
  }

  Future<void> installPackage(String package, String repoUrl) async {
    try {
      final extensionRepository = _repository();
      await extensionRepository.installExtension(package);

      final installed = List<String>.from(state.installedPackages)
        ..add(package);
      state = state.copyWith(installedPackages: installed);
    } catch (e) {
      // Handle error
    }
  }

  Future<String?> uninstallPackage(String package) async {
    try {
      final extensionRepository = _repository();
      await extensionRepository.uninstallExtension(package);

      final installed = List<String>.from(state.installedPackages)
        ..remove(package);
      state = state.copyWith(installedPackages: installed);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void setMetadata(List<DomainExtensionMeta>? metadata) {
    if (metadata == null) {
      state = state.copyWith(metadata: []);
      return;
    }

    final packages = metadata
        .map((e) => e.packageName)
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList();

    state = state.copyWith(metadata: metadata, installedPackages: packages);
  }

  void _applyFilters() {
    final filteredRepos = _filterUseCase(
      repos: state.repos,
      repoName: state.selectedRepoName,
      query: state.query,
      typeFilter: state.typeFilter,
      installFilter: state.installFilter,
      installedPackages: state.installedPackages,
    );

    state = state.copyWith(extensions: filteredRepos);
  }
}
