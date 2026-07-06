import 'package:miru_alpha/data/services/watch_service.dart';
import 'package:miru_alpha/domain/models/watch.dart';

class WatchRepository {
  final WatchService _watchService;

  WatchRepository(this._watchService);

  Future<DomainWatchResult> getWatchResult(
    String package,
    String detailUrl,
    String episodeUrl,
  ) async {
    final result = await _watchService.getWatchResult(
      package,
      detailUrl,
      episodeUrl,
    );
    return DomainWatchResult.fromWatchResult(
      result,
      detailUrl: detailUrl,
      package: package,
    );
  }
}
