import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/utils/store/database_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'history_page_provider.g.dart';

class HistoryPageState {
  final List<History> history;
  final List<History> filteredHistory;
  HistoryPageState({required this.history, required this.filteredHistory});

  HistoryPageState copyWith({
    List<History>? history,
    List<History>? filteredHistory,
  }) {
    return HistoryPageState(
      filteredHistory: filteredHistory ?? this.filteredHistory,
      history: history ?? this.history,
    );
  }
}

@Riverpod(keepAlive: true)
class HistoryPageNotifier extends _$HistoryPageNotifier {
  String keyword = '';
  Duration duration = const Duration(days: 36500);
  Set<ExtensionType> _type = {};
  @override
  HistoryPageState build() {
    Future.microtask(() async {
      final history = await DatabaseService.getHistoriesByType();
      state = state.copyWith(history: history, filteredHistory: history);
    });
    return HistoryPageState(history: [], filteredHistory: []);
  }

  // ADD
  void addHistory(History history) {
    DatabaseService.putHistory(history);
    Future.microtask(() {
      state = state.copyWith(history: [history, ...state.history]);
      logger.info('register history ${history.title}');
    });
  }

  // DELETE
  void deleteHistory(History history) {
    state = state.copyWith(
      history: state.history.where((e) => e.id != history.id).toList(),
      filteredHistory: state.filteredHistory
          .where((e) => e.id != history.id)
          .toList(),
    );
    DatabaseService.deleteHistoryByPackageAndUrl(history.package, history.url);
  }

  // FILTER
  void filterWithDuration(Duration duration) {
    this.duration = duration;
    final history = state.history;
    final filteredHistory = history
        .where((e) => e.date.isAfter(DateTime.now().subtract(duration)))
        .toList();
    state = HistoryPageState(
      history: history,
      filteredHistory: filteredHistory,
    );
  }

  void filterWithType(Set<ExtensionType> type) {
    _type = type;
    final history = state.history;
    final filteredHistory = history
        .where((e) => _type.contains(stringToExtensionType(e.type)))
        .toList();
    state = HistoryPageState(
      history: history,
      filteredHistory: filteredHistory,
    );
  }

  void filter(Set<ExtensionType> type, String keyword, Duration duration) {
    final now = DateTime.now();
    List<History> typeResult = state.history;
    if (type.isNotEmpty) {
      typeResult = state.history
          .where((e) => type.contains(stringToExtensionType(e.type)))
          .toList();
    }
    List<History> keywordResult = typeResult;
    if (keyword.isNotEmpty) {
      keywordResult = typeResult
          .where((e) => e.title.contains(keyword))
          .toList();
    }
    List<History> durationResult = keywordResult;
    if (duration != const Duration(days: 36500)) {
      durationResult = keywordResult
          .where((e) => now.difference(e.date) <= duration)
          .toList();
    }
    state = state.copyWith(filteredHistory: durationResult);
  }

  void filterWithKeyword(String keyword) {
    this.keyword = keyword;
    final history = state.history;
    final filteredHistory = history
        .where((e) => e.title.contains(keyword))
        .toList();
    state = HistoryPageState(
      history: history,
      filteredHistory: filteredHistory,
    );
  }
}
