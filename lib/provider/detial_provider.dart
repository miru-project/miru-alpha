import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/network_provider.dart';

final detialProvider = ChangeNotifierProvider<DetialProvider>((ref) {
  return DetialProvider(ref);
});

class DetialProvider with ChangeNotifier {
  // Keep the ref so we can interact with other providers (refresh/invalidate)
  final Ref _ref;

  // ValueNotifier kept for compatibility with widgets that expect a ValueListenable
  final ValueNotifier<int> selectedGroup = ValueNotifier<int>(0);

  History? history;
  Favorite? favorite;

  DetialProvider(this._ref);

  void putHistory(History? h) {
    history = h;
    notifyListeners();
  }

  void putFavorite(Favorite? f) {
    favorite = f;
    notifyListeners();
  }

  void setSelectedGroup(int v) {
    selectedGroup.value = v;
    // notifyListeners so other consumers rebuild when selection changes
    notifyListeners();
  }

  /// Invalidate the fetchExtensionDetail provider so any watchers will refetch.
  void refreshDetail(String pkg, String url) {
    _ref.invalidate(fetchExtensionDetailProvider(pkg, url));
    // notify listeners so UI that depends on this provider object can react
    notifyListeners();
  }

  /// Force reload and return the fetched detail. This uses ref.refresh which
  /// re-evaluates and returns the new Future result.
  Future<ExtensionDetail> reloadDetail(String pkg, String url) async {
    final res = await _ref.refresh(
      fetchExtensionDetailProvider(pkg, url).future,
    );
    notifyListeners();
    return res;
  }

  // Holds the AsyncValue state of the currently fetched ExtensionDetail.
  AsyncValue<ExtensionDetail>? detailState;

  /// Fetch detail (without invalidating). Updates `detailState` and notifies listeners.
  Future<void> fetchDetail(String pkg, String url) async {
    // Set loading state
    detailState = const AsyncValue.loading();
    notifyListeners();
    try {
      final data = await _ref.read(
        fetchExtensionDetailProvider(pkg, url).future,
      );
      detailState = AsyncValue.data(data);
      notifyListeners();
    } catch (e, st) {
      detailState = AsyncValue<ExtensionDetail>.error(e, st);
      notifyListeners();
    }
  }
}
