import 'dart:convert';

import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as ext_model;
import 'package:miru_alpha/miru_core/proto/generate/proto/common.pb.dart'
    as common_model;
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

  Future<void> installExtension(String packageName) async {
    try {
      await MiruGrpcClient.extensionClient.downloadExtension(
        DownloadExtensionRequest(pkg: packageName, repoUrl: ''),
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

  Future<void> updateExtension(String packageName) async {
    try {
      await MiruGrpcClient.extensionClient.downloadExtension(
        DownloadExtensionRequest(pkg: packageName, repoUrl: ''),
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
      // The response.data is a JSON string, need to decode it first
      final Map<String, dynamic> data =
          jsonDecode(response.data) as Map<String, dynamic>;
      return data.entries.map((e) {
        final repoData = e.value as List<dynamic>;
        final extensions = repoData.map((ext) {
          return ext_model.GithubExtension(
            name: ext['name'] as String? ?? '',
            description: ext['description'] as String?,
            license: ext['license'] as String? ?? '',
            version: ext['version'] as String? ?? '',
            author: ext['author'] as String? ?? '',
            icon: ext['icon'] as String?,
            type: ext['type'] as String? ?? '',
            lang: ext['lang'] as String? ?? '',
            webSite: ext['webSite'] as String? ?? '',
            nsfw: ext['nsfw'] as bool? ?? false,
            package: ext['package'] as String? ?? '',
            tags:
                (ext['tags'] as List<dynamic>?)
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
    } catch (e) {
      logger.severe(e.toString());
      return [];
    }
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
                type: _mapExtensionType(e['type'] as String?),
                error: e['error'] as String?,
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  String _mapExtensionType(String? type) {
    if (type == null) return 'all';
    switch (type.toLowerCase()) {
      case 'manga':
        return 'manga';
      case 'bangumi':
      case 'video':
        return 'bangumi';
      case 'fikushon':
      case 'novel':
        return 'fikushon';
      default:
        return 'all';
    }
  }
}
