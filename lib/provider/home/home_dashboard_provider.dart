import 'package:miru_alpha/model/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_dashboard_provider.g.dart';

/// Dashboard-scoped view state: the media type its sections filter by.
///
/// The favorite-group selection deliberately does NOT live here — the tag
/// strip, the manager sheet and the Dynamic Feed share ONE selection on
/// [favoritePageProvider] (`selectedFavoriteGroups` + `filterMode`), so
/// picking a group in the manager sheet updates the homepage's strip and
/// feed live.
class HomeDashboardState {
  const HomeDashboardState({this.type = ExtensionType.all});

  /// [ExtensionType.all] shows every type.
  final ExtensionType type;

  bool get filtersByType => type != ExtensionType.all;
}

@riverpod
class HomeDashboard extends _$HomeDashboard {
  @override
  HomeDashboardState build() => const HomeDashboardState();

  void setType(ExtensionType type) => state = HomeDashboardState(type: type);
}
