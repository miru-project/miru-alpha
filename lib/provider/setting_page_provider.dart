import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/network.dart';
import 'package:miru_alpha/model/model.dart';

final extensionRepoProvider = FutureProvider.autoDispose<List<RepoConfig>>((
  ref,
) async {
  return await MiruCoreEndpoint.getRepoLists();
});
