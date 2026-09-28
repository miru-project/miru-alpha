import 'dart:async';

import 'package:miru_alpha/data/repositories/extension_repository.dart';
import 'package:miru_alpha/data/services/extension_service.dart';
import 'package:miru_alpha/domain/models/extension.dart';
import 'package:miru_alpha/domain/models/extension_view.dart';
import 'package:miru_alpha/domain/use_cases/filter_extensions.dart';
import 'package:miru_alpha/miru_core/event_service.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'extension_view_model.g.dart';

@Riverpod(keepAlive: true)
class ExtensionViewModel extends _$ExtensionViewModel {
  StreamSubscription<List<proto.ExtensionMeta>>? _metadataSubscription;

  @override
  DomainExtensionViewState build() {
    _metadataSubscription ??= miruEventService.extensionStream.listen(
      applyMetadataSnapshot,
    );
    ref.onDispose(() => _metadataSubscription?.cancel());
    return const DomainExtensionViewState();
  }

  ExtensionRepository _repository() => ExtensionRepository(ExtensionService());
  FilterExtensionsUseCase get _filterUseCase => FilterExtensionsUseCase();

  Future<void> loadRepos({bool force = false}) async {
    if (!force && state.repos.isNotEmpty) return;

    final current = state;
    state = current.copyWith(isLoading: true);

    try {
      final repos = await _repository().getRepos();

      state = state.copyWith(repos: repos, isLoading: false);

      // The installed set comes from the backend snapshot, never from a local
      // guess, so seed it from the latest one instead of assuming "none".
      applyMetadataSnapshot(miruEventService.latestExtensionMeta);
    } catch (e) {
      logger.warning('failed to load extension repos: $e');
      state = state.copyWith(isLoading: false);
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

  /// Re-applies filters over the already-fetched repos (no refetch). Used
  /// when a display-affecting setting such as Enable NSFW Content changes.
  void refilter() {
    _applyFilters();
  }

  bool isInstalled(String package) {
    return state.installedPackages.contains(package);
  }

  Future<void> installPackage(String package, String repoUrl) async {
    try {
      await _repository().installExtension(package, repoUrl);
    } catch (e) {
      // The installed list is refreshed by the backend snapshot the watcher
      // publishes, so nothing to update locally on failure.
      logger.warning('failed to install $package: $e');
    }
  }

  Future<String?> uninstallPackage(String package) async {
    try {
      await _repository().uninstallExtension(package);
      return null;
    } catch (e) {
      logger.warning('failed to uninstall $package: $e');
      return e.toString();
    }
  }

  /// Apply the installed-extension snapshot miru-core publishes. It arrives on
  /// the initial hello and again whenever the extension folder changes
  /// (install, uninstall, hot reload), and it is the only source of truth for
  /// what is installed.
  void applyMetadataSnapshot(List<proto.ExtensionMeta>? metadata) {
    if (metadata == null) {
      state = state.copyWith(metadata: const [], installedPackages: const []);
    } else {
      final packages = metadata
          .map((e) => e.package)
          .where((p) => p.isNotEmpty)
          .toSet()
          .toList();
      state = state.copyWith(
        metadata: metadata
            .map(DomainExtensionMeta.fromProto)
            .toList(growable: false),
        installedPackages: packages,
      );
    }
    _applyFilters();
  }

  void _applyFilters() {
    final filteredRepos = _filterUseCase(
      repos: state.repos,
      repoName: state.selectedRepoName,
      query: state.query,
      typeFilter: state.typeFilter,
      installFilter: state.installFilter,
      installedPackages: state.installedPackages,
      allowNsfw: MiruSettings.getSettingSync<bool>(SettingKey.enableNSFW),
    );

    state = state.copyWith(extensions: filteredRepos);
  }
}
