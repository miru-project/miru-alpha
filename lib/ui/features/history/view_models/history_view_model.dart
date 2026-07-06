import 'package:miru_alpha/data/repositories/history_repository.dart';
import 'package:miru_alpha/data/services/history_service.dart';
import 'package:miru_alpha/domain/models/history.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_view_model.g.dart';

@riverpod
class HistoryViewModel extends _$HistoryViewModel {
  @override
  Future<List<DomainHistoryItem>> build() async {
    final repository = HistoryRepository(HistoryService());
    return await repository.getHistoriesByType('all');
  }

  Future<void> loadHistory(String type) async {
    final repository = HistoryRepository(HistoryService());
    final histories = await repository.getHistoriesByType(type);
    state = AsyncValue.data(histories);
  }

  Future<void> saveHistory(
    String package,
    String detailUrl,
    int episodeIndex,
    int watchedDuration,
    int totalDuration, {
    String? title,
    String? cover,
  }) async {
    final repository = HistoryRepository(HistoryService());
    await repository.saveHistory(
      package,
      detailUrl,
      episodeIndex,
      watchedDuration,
      totalDuration,
    );
    ref.invalidateSelf();
  }

  Future<void> deleteHistory(String historyId) async {
    final repository = HistoryRepository(HistoryService());
    await repository.deleteHistory(historyId);
    ref.invalidateSelf();
  }

  Future<void> clearHistory(String type) async {
    final repository = HistoryRepository(HistoryService());
    await repository.clearHistoryByType(type);
    ref.invalidateSelf();
  }
}
