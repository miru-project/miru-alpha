import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/miru_core/network.dart';

final extensionRepoProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final response = await MiruCoreEndpoint.getRepo();
  if (response == null) return <dynamic>[];
  if (response is List) return response;
  return <dynamic>[response];
});
