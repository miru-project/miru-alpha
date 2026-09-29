import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/detial_provider.dart';

class WatchParams {
  const WatchParams({
    required this.meta,
    required this.type,
    required this.url,
    required this.selectedGroupIndex,
    required this.selectedEpisodeIndex,
    required this.name,
    required this.detailImageUrl,
    required this.detailUrl,
    required this.savePath,
    required this.epGroup,
    this.detailPr,
  });
  final ExtensionMeta meta;
  // Watch Url
  final String url;
  final List<ExtensionEpisodeGroup>? epGroup;
  final int selectedGroupIndex;
  final String detailImageUrl;
  final int selectedEpisodeIndex;
  final String detailUrl;
  final ExtensionType type;
  final String name;
  final String? savePath;
  final DetialProvider? detailPr;
}

class DetailParam {
  const DetailParam({
    required this.meta,
    required this.url,
    this.items,
    this.index = 0,
  });
  final ExtensionMeta meta;
  final String url;

  /// When the detail page is opened from a search/latest results grid, the full
  /// result list and the tapped index are passed so the desktop header can show
  /// "previous / next" navigation through the result pages.
  final List<ExtensionListItem>? items;
  final int index;
}

class SearchPageParam {
  final String? query;
  final ExtensionMeta meta;
  const SearchPageParam({this.query, required this.meta});
}

class WebviewParam {
  final ExtensionMeta meta;
  final String url;
  const WebviewParam({required this.meta, required this.url});
}

class ExtensionSettingParam {
  final String pkg;
  final String name;
  const ExtensionSettingParam({required this.pkg, required this.name});
}

class AnilistSearchParam {
  final String title;
  final ExtensionType type;
  final String detailUrl;
  final String package;
  final DetialProvider detailPr;
  const AnilistSearchParam({
    required this.title,
    required this.type,
    required this.detailUrl,
    required this.package,
    required this.detailPr,
  });
}

class ListPageParam {
  const ListPageParam({this.type});

  /// Optional [ExtensionType] used to pre-filter the history / favorite list
  /// (e.g. when navigating from the library category tiles). `null` means "all".
  final ExtensionType? type;
}

class AnilistProgressParam {
  final int mediaId;
  final String detailUrl;
  final String package;
  final bool isLinked;
  final DetialProvider? detailPr;
  const AnilistProgressParam({
    required this.mediaId,
    required this.detailUrl,
    required this.package,
    this.isLinked = false,
    this.detailPr,
  });
}
