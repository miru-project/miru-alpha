import 'dart:convert';

import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as ext_model;
import 'package:miru_alpha/miru_core/proto/generate/proto/common.pb.dart'
    as common_model;
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
      final response = await MiruGrpcClient.repoClient.getRepos(
        GetReposRequest(),
      );
      final data = jsonDecode(response.data) as List<dynamic>;
      return data
          .map(
            (e) => ext_model.ExtensionRepo.fromJson(
              jsonEncode(e as Map<String, dynamic>),
            ),
          )
          .toList();
    } catch (e) {
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
              (e) => common_model.ExtensionMeta.fromJson(
                jsonEncode(e as Map<String, dynamic>),
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
