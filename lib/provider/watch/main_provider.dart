import 'package:miru_app_new/utils/store/database_service.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'main_provider.g.dart';

class MainPageState {
  int selectedIndex;
  List<int> selectedGroups;
  String searchText;
  List<History> history;

  MainPageState({
    this.selectedIndex = 0,
    this.selectedGroups = const [],
    this.searchText = '',
    this.history = const [],
  });

  MainPageState copyWith({
    int? selectedIndex,
    List<int>? selectedGroups,
    String? searchText,
    List<History>? history,
  }) {
    return MainPageState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectedGroups: selectedGroups ?? this.selectedGroups,
      searchText: searchText ?? this.searchText,
      history: history ?? this.history,
    );
  }
}

@Riverpod(keepAlive: true)
class MainNotifier extends _$MainNotifier {
  @override
  MainPageState build() {
    Future.microtask(() async {
      final history = await DatabaseService.getHistoriesByType();
      state = state.copyWith(history: history);
    });
    return MainPageState();
  }

  void setSelectedIndex(int index) {
    if (state.selectedIndex != index) {
      state = state.copyWith(selectedIndex: index);
    }
  }

  void setSelectedGroups(List<int> groups) {
    state = state.copyWith(selectedGroups: groups);
  }

  void setSearchText(String text) {
    state = state.copyWith(searchText: text);
  }

  void updateHistory(List<History> updateValue) {
    state = state.copyWith(history: updateValue);
  }

  void addHistory(History history) {
    state = state.copyWith(history: [history, ...state.history]);
  }

  Future<void> refreshHistory() async {
    final history = await DatabaseService.getHistoriesByType();
    state = state.copyWith(history: history);
  }
}
