import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_app_new/utils/extension/extension_service.dart';
import 'package:miru_app_new/model/index.dart';

part 'video_provider.g.dart';

@riverpod
Future<ExtensionBangumiWatch> videoLoad(
    VideoLoadRef ref, String url, ExtensionApiV1 service) async {
  final result = await service.watch(url) as ExtensionBangumiWatch;
  return result;
}
