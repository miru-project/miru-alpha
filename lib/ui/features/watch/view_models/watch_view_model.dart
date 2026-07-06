import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_alpha/data/repositories/watch_repository.dart';
import 'package:miru_alpha/data/services/watch_service.dart';
import 'package:miru_alpha/domain/models/watch.dart';

part 'watch_view_model.g.dart';

@riverpod
class WatchViewModel extends _$WatchViewModel {
  @override
  Future<DomainWatchResult?> build(String package, String detailUrl) async {
    final repository = WatchRepository(WatchService());
    try {
      return await repository.getWatchResult(package, detailUrl, '');
    } catch (e) {
      return null;
    }
  }

  Future<void> refresh(String package, String detailUrl) async {
    final repository = WatchRepository(WatchService());
    final result = await repository.getWatchResult(package, detailUrl, '');
    state = AsyncValue.data(result);
  }
}
