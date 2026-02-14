import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';

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
