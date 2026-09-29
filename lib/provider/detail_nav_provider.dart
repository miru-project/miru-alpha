import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detail_nav_provider.g.dart';

/// Navigation context of the detail page currently on screen, mirrored here so
/// app-level chrome (the top-bar prev/next buttons) can page through the
/// result list without owning detail state itself.
class DetailNavState {
  const DetailNavState({
    required this.meta,
    required this.url,
    this.items,
    this.index = 0,
  });
  final ExtensionMeta meta;
  final String url;

  /// Result list + tapped index when opened from a search/latest grid.
  final List<ExtensionListItem>? items;
  final int index;
}

/// Mirrors the active [DetailNavState]; null when no detail page has synced.
/// Never cleared on route exit: the top-bar buttons hide themselves off-detail
/// by watching the router, avoiding dispose/initState ordering races between
/// replaced detail routes.
@riverpod
class DetailNav extends _$DetailNav {
  @override
  DetailNavState? build() => null;

  void set(DetailNavState navState) => state = navState;
}
