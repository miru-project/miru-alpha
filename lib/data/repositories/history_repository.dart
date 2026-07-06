import 'package:miru_alpha/data/services/history_service.dart';
import 'package:miru_alpha/domain/models/history.dart';
import 'package:miru_alpha/model/user_data.dart';

class HistoryRepository {
  final HistoryService _historyService;

  HistoryRepository(this._historyService);

  Future<List<DomainHistoryItem>> getHistoriesByType(String type) async {
    final histories = await _historyService.getHistoriesByType(type);
    return histories
        .map(
          (history) => DomainHistoryItem(
            id: history.id.toString(),
            package: history.package,
            detailUrl: history.detailUrl,
            title: history.title,
            cover: history.cover,
            episodeIndex: history.episodeId,
            episodeTitle: history.episodeTitle,
            watchedDuration: history.progress,
            totalDuration: history.totalProgress,
            progress:
                history.progress /
                (history.totalProgress > 0
                    ? history.totalProgress.toDouble()
                    : 1.0),
            watchedAt: history.date,
            lastPosition: null,
          ),
        )
        .toList();
  }

  Future<void> saveHistory(
    String package,
    String detailUrl,
    int episodeIndex,
    int watchedDuration,
    int totalDuration, {
    String? title,
    String? cover,
    String? episodeTitle,
  }) async {
    await _historyService.putHistory(
      History(
        package: package,
        url: detailUrl,
        detailUrl: detailUrl,
        title: title ?? '',
        episodeId: episodeIndex,
        episodeTitle: episodeTitle ?? '',
        progress: watchedDuration,
        totalProgress: totalDuration,
        date: DateTime.now(),
        type: '',
        episodeGroupId: 0,
      ),
    );
  }

  Future<void> deleteHistory(String historyId) async {
    await _historyService.deleteHistoryByPackageAndUrl('', historyId);
  }

  Future<void> clearHistoryByType(String type) async {
    await _historyService.clearHistoryByType(type);
  }
}
