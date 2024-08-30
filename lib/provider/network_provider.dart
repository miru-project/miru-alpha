import 'package:miru_app_new/utils/network/index.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_app_new/utils/extension/extension_service.dart';
import 'package:miru_app_new/model/index.dart';

part 'network_provider.g.dart';

@riverpod
Future<ExtensionBangumiWatch> videoLoad(
    VideoLoadRef ref, String url, ExtensionApiV1 service) async {
  final result = await service.watch(url) as ExtensionBangumiWatch;
  return result;
}

@riverpod
Future<List<GithubExtension>> fetchExtensionRepo(
    FetchExtensionRepoRef ref) async {
  final result = await GithubNetwork.fetchRepo();
  return result;
}

@riverpod
Future<ExtensionDetail> fetchExtensionDetail(FetchExtensionDetailRef ref,
    ExtensionApiV1 extensionService, String url) async {
  final result = await extensionService.detail(url);
  return result;
}

@riverpod
Future<List<ExtensionListItem>> fetchExtensionLatest(
    FetchExtensionLatestRef ref,
    ExtensionApiV1 extensionService,
    int page) async {
  final result = await extensionService.latest(page);
  return result;
}
