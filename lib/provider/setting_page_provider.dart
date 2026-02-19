import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/miru_core/network.dart';
import 'package:miru_app_new/model/model.dart';

final extensionRepoProvider = FutureProvider.autoDispose<List<RepoConfig>>((
  ref,
) async {
  return await MiruCoreEndpoint.getRepoLists();
});
