import 'package:miru_app_new/model/index.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'main_provider.g.dart';

class MainPageState {
  int selectedIndex;
  List<int> selectedGroups;
  String searchText;
  MainPageState({
    this.selectedIndex = 0,
    this.selectedGroups = const [],
    this.searchText = '',
  });

  MainPageState copyWith({
    int? selectedIndex,
    List<int>? selectedGroups,
    String? searchText,
    List<History>? history,
    List<FavoriteGroup>? favoriteGroups,
    List<Favorite>? favorites,
  }) {
    return MainPageState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectedGroups: selectedGroups ?? this.selectedGroups,
      searchText: searchText ?? this.searchText,
    );
  }
}

@Riverpod(keepAlive: true)
class MainNotifier extends _$MainNotifier {
  @override
  MainPageState build() {
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
}
