import 'dart:convert';

import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as ext_model;
import 'package:miru_alpha/miru_core/proto/generate/proto/common.pb.dart'
    as common_model;
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/http/request.dart';

class ExtensionService {
  Future<List<common_model.ExtensionMeta>> getExtensionList() async {
    return [];
  }

  Future<ext_model.ExtensionDetail> getExtensionDetail(
    String packageName,
  ) async {
    try {
      final response = await MiruGrpcClient.extensionClient.detail(
        DetailRequest(pkg: packageName),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> installExtension(String packageName, String repoUrl) async {
    try {
      await MiruGrpcClient.extensionClient.downloadExtension(
        DownloadExtensionRequest(pkg: packageName, repoUrl: repoUrl),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uninstallExtension(String packageName) async {
    try {
      await MiruGrpcClient.extensionClient.removeExtension(
        RemoveExtensionRequest(pkg: packageName),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateExtension(String packageName, String repoUrl) async {
    try {
      await MiruGrpcClient.extensionClient.downloadExtension(
        DownloadExtensionRequest(pkg: packageName, repoUrl: repoUrl),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ext_model.ExtensionRepo>> getRepos() async {
    try {
      final response = await MiruGrpcClient.repoClient.fetchRepoList(
        FetchRepoListRequest(),
      );
      // The response.data is a JSON string, need to decode it first. The
      // fetch is keyed by repo URL; the configured records carry the human
      // names the repo picker must show, so they are joined here.
      List<RepoConfig> configs;
      try {
        configs = await MiruCoreEndpoint.getRepoLists();
      } catch (e) {
        logger.warning('failed to load repo configs', e);
        configs = const [];
      }
      return applyRepoNames(parseRepoIndex(response.data), configs: configs);
    } catch (e) {
      logger.severe(e.toString());
      return [];
    }
  }

  /// Joins the fetched index entries with the configured repo records so each
  /// repo carries the human name shown in the picker instead of its URL.
  ///
  /// A configured repo missing from [fetched] failed to fetch its index; it is
  /// appended with no extensions so it stays visible and selectable instead of
  /// silently disappearing from the picker.
  static List<ext_model.ExtensionRepo> applyRepoNames(
    List<ext_model.ExtensionRepo> fetched, {
    required List<RepoConfig> configs,
  }) {
    final nameByLink = {for (final config in configs) config.link: config.name};
    final usedNames = <String>{};
    String uniqueName(String name) {
      var candidate = name;
      var suffix = 2;
      while (usedNames.contains(candidate)) {
        candidate = '$name ($suffix)';
        suffix++;
      }
      usedNames.add(candidate);
      return candidate;
    }

    String configuredName(RepoConfig config) => uniqueName(
      config.name.isEmpty ? repoDisplayLabel(config.link) : config.name,
    );

    final fetchedUrls = <String>{};
    final repos = <ext_model.ExtensionRepo>[];
    for (final repo in fetched) {
      fetchedUrls.add(repo.url);
      final configured = nameByLink[repo.url];
      repos.add(
        ext_model.ExtensionRepo(
          extensions: repo.extensions,
          name: uniqueName(
            (configured == null || configured.isEmpty)
                ? repoDisplayLabel(repo.url)
                : configured,
          ),
          url: repo.url,
        ),
      );
    }
    for (final config in configs) {
      if (fetchedUrls.contains(config.link)) continue;
      repos.add(
        ext_model.ExtensionRepo(
          extensions: <ext_model.GithubExtension>[],
          name: configuredName(config),
          url: config.link,
        ),
      );
    }
    return repos;
  }

  /// Human label for a repo whose configured name is unavailable, so the
  /// picker never has to print a URL: a github.com link becomes owner/repo
  /// and any other host its hostname.
  static String repoDisplayLabel(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasAuthority) return url;
    final host = uri.host.replaceFirst(RegExp(r'^www\.'), '');
    const githubHosts = {'github.com', 'raw.githubusercontent.com'};
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (githubHosts.contains(host) && segments.length >= 2) {
      return '${segments[0]}/${segments[1]}';
    }
    return host.isEmpty ? url : host;
  }

  /// Parse the repo index payload the backend fetched: repo url -> extension
  /// entries. Every field, including `nsfw`, comes from this single response,
  /// so no extra per-extension request is needed.
  static List<ext_model.ExtensionRepo> parseRepoIndex(String data) {
    final Map<String, dynamic> decoded =
        jsonDecode(data) as Map<String, dynamic>;
    return decoded.entries.map((e) {
      final extensions = (e.value as List<dynamic>).map((ext) {
        final item = ext as Map<String, dynamic>;
        return ext_model.GithubExtension(
          name: item['name'] as String? ?? '',
          description: item['description'] as String?,
          license: item['license'] as String? ?? '',
          version: item['version'] as String? ?? '',
          author: item['author'] as String? ?? '',
          icon: item['icon'] as String?,
          type: item['type'] as String? ?? '',
          lang: item['lang'] as String? ?? '',
          webSite: item['webSite'] as String? ?? '',
          nsfw: parseNsfw(item['nsfw']),
          package: item['package'] as String? ?? '',
          tags:
              (item['tags'] as List<dynamic>?)
                  ?.map((t) => t as String)
                  .toList() ??
              [],
        );
      }).toList();

      return ext_model.ExtensionRepo(
        extensions: extensions,
        name: e.key,
        url: e.key,
      );
    }).toList();
  }

  /// nsfw as published by a repo index entry. Repos send either a JSON bool or
  /// the string `true`/`1`; an absent flag reads as false.
  static bool parseNsfw(Object? value) {
    final raw = value?.toString().toLowerCase();
    return raw == 'true' || raw == '1';
  }

  Future<void> addRepo(String name, String url) async {
    try {
      await MiruGrpcClient.repoClient.setRepo(
        SetRepoRequest(repoUrl: url, name: name),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeRepo(String url) async {
    try {
      await MiruGrpcClient.repoClient.deleteRepo(
        DeleteRepoRequest(repoUrl: url),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<common_model.ExtensionMeta>> fetchRepoExtensions(
    String repoUrl,
  ) async {
    try {
      final response = await MiruRequest.get(repoUrl);
      if (response is List) {
        return response
            .map(
              (e) => common_model.ExtensionMeta(
                name: e['name'] as String? ?? '',
                version: e['version'] as String? ?? '',
                author: e['author'] as String? ?? '',
                license: e['license'] as String? ?? '',
                lang: e['lang'] as String? ?? '',
                icon: e['icon'] as String?,
                package: e['package'] as String? ?? '',
                webSite: e['webSite'] as String? ?? '',
                description: e['description'] as String?,
                tags:
                    (e['tags'] as List<dynamic>?)
                        ?.map((t) => t as String)
                        .toList() ??
                    [],
                api: e['api'] as String? ?? '',
                type: e['type'] as String? ?? '',
                error: e['error'] as String?,
                nsfw: parseNsfw(e['nsfw']),
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
