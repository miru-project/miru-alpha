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
  const DetailParam({required this.meta, required this.url});
  final ExtensionMeta meta;
  final String url;
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
  const AnilistSearchParam({
    required this.title,
    required this.type,
    required this.detailUrl,
    required this.package,
  });
}

class AnilistProgressParam {
  final int mediaId;
  final String detailUrl;
  final String package;
  const AnilistProgressParam({
    required this.mediaId,
    required this.detailUrl,
    required this.package,
  });
}
