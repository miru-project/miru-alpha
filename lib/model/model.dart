import 'package:json_annotation/json_annotation.dart';
import 'package:miru_app_new/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;

part 'model.g.dart';

typedef ExtensionListItem = pb_extension.ExtensionListItem;
typedef ExtensionDetail = pb_extension.ExtensionDetail;
typedef ExtensionFilter = pb_extension.ExtensionFilter;
typedef ExtensionEpisodeGroup = pb_extension.ExtensionEpisodeGroup;
typedef ExtensionEpisode = pb_extension.ExtensionEpisode;
typedef ExtensionBangumiWatch = pb_extension.ExtensionBangumiWatch;
typedef ExtensionMangaWatch = pb_extension.ExtensionMangaWatch;
typedef ExtensionFikushonWatch = pb_extension.ExtensionFikushonWatch;
typedef ExtensionBangumiWatchTorrent =
    pb_extension.ExtensionBangumiWatchTorrent;
typedef ExtensionBangumiWatchSubtitle =
    pb_extension.ExtensionBangumiWatchSubtitle;

enum ExtensionType { manga, bangumi, fikushon, all }

ExtensionType? stringToExtensionType(String type) {
  switch (type) {
    case 'bangumi' || 'video' || 'Bangumi' || 'Video':
      return ExtensionType.bangumi;
    case 'manga' || 'Manga':
      return ExtensionType.manga;
    case 'fikushon' || 'novel' || 'Fikushon' || 'Novel':
      return ExtensionType.fikushon;
    case 'all':
      return ExtensionType.all;
    default:
      return null;
  }
}

enum ExtensionWatchBangumiType { hls, mp4, torrent, magnet }

enum ExtensionLogLevel { info, error }

enum MangaReadMode {
  // 标准 从左到右
  standard,
  // 从右到左
  rightToLeft,
  // 条漫
  webTonn,
}

enum NovelReadMode {
  // 标准 从左到右
  standard,
  // 从右到左
  rightToLeft,
  webToon,
  rightToLeftFlip,
  standardFlip,
}

@JsonSerializable()
class Extension {
  Extension({
    required this.package,
    required this.author,
    required this.version,
    required this.lang,
    required this.license,
    required this.type,
    required this.webSite,
    required this.name,
    this.nsfw = false,
    this.icon,
    this.url,
    this.description,
  });

  final bool nsfw;
  final String package;
  final String author;
  final String version;
  final String lang;
  final String license;
  final ExtensionType type;
  final String webSite;
  final String name;
  String? icon;
  String? url;
  String? description;

  factory Extension.fromJson(Map<String, dynamic> json) =>
      _$ExtensionFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionToJson(this);
}

// Redundant models removed. Use generated proto models instead.

class Detail {
  final int? id;
  final String title;
  final String? cover;
  final String? desc;
  final List<ExtensionEpisodeGroup>? episodes;
  final Map<String, String>? headers;
  final List<String> downloaded;
  final String detailUrl;
  final String package;

  Detail({
    this.id,
    required this.title,
    this.cover,
    this.desc,
    this.episodes,
    this.headers,
    this.downloaded = const [],
    required this.detailUrl,
    required this.package,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      id: json['id'] as int?,
      title: json['title'] as String,
      cover: json['cover'] as String?,
      desc: json['desc'] as String?,
      episodes: json['episodes'] != null
          ? (json['episodes'] as List)
                .map((e) => ExtensionEpisodeGroup()..mergeFromProto3Json(e))
                .toList()
          : null,
      headers: json['headers'] != null
          ? (json['headers'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, v.toString()),
            )
          : null,
      downloaded:
          (json['downloaded'] as List?)?.map((e) => e as String).toList() ??
          const [],
      detailUrl: json['detailUrl'] as String,
      package: json['package'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cover': cover,
      'desc': desc,
      'episodes': episodes?.map((e) => e.toProto3Json()).toList(),
      'headers': headers,
      'downloaded': downloaded,
      'detailUrl': detailUrl,
      'package': package,
    };
  }

  factory Detail.fromExtensionDetail(
    ExtensionDetail extensionDetail, {
    required String detailUrl,
    required String package,
    List<String> downloaded = const [],
    int? id,
  }) {
    return Detail(
      id: id,
      title: extensionDetail.title,
      cover: extensionDetail.cover,
      desc: extensionDetail.desc,
      episodes: extensionDetail.episodes,
      headers: extensionDetail.headers,
      downloaded: downloaded,
      detailUrl: detailUrl,
      package: package,
    );
  }
}

@JsonSerializable()
class ExtensionLog {
  ExtensionLog({
    required this.extension,
    required this.content,
    required this.time,
    required this.level,
  });

  final DateTime time;
  final Extension extension;
  final String content;
  final ExtensionLogLevel level;

  factory ExtensionLog.fromJson(Map<String, dynamic> json) =>
      _$ExtensionLogFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionLogToJson(this);
}

@JsonSerializable()
class ExtensionNetworkLog {
  final Extension extension;
  String? responseBody;
  String? requestBody;
  Map<String, dynamic>? requestHeaders;
  Map<String, dynamic>? responseHeaders;
  String url;
  String method;
  int? statusCode;

  ExtensionNetworkLog({
    required this.extension,
    required this.url,
    required this.method,
    this.statusCode,
    this.responseBody,
    this.requestBody,
    this.requestHeaders,
    this.responseHeaders,
  });

  factory ExtensionNetworkLog.fromJson(Map<String, dynamic> json) =>
      _$ExtensionNetworkLogFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionNetworkLogToJson(this);
}

@JsonSerializable()
class GithubExtension {
  final String name;
  final String? description;
  final String license;
  final String version;
  final String author;
  final String? icon;
  final String type;
  @JsonKey(name: 'lang')
  final String language;
  @JsonKey(name: 'webSite')
  final String website;
  @JsonKey(name: 'nsfw', fromJson: _boolFromString)
  final bool isNsfw;
  final String package;
  final List<String>? tags;
  GithubExtension({
    required this.name,
    this.description,
    required this.license,
    required this.version,
    required this.author,
    required this.package,
    this.icon,
    required this.type,
    required this.language,
    required this.website,
    required this.isNsfw,
    this.tags,
  });

  factory GithubExtension.fromJson(Map<String, dynamic> json) =>
      _$GithubExtensionFromJson(json);

  Map<String, dynamic> toJson() => _$GithubExtensionToJson(this);
}

bool _boolFromString(dynamic value) {
  return value.toString() == "true";
}

@JsonSerializable()
class ExtensionRepo {
  final List<GithubExtension> extensions;
  final String name;
  final String url;

  ExtensionRepo({
    required this.extensions,
    required this.name,
    required this.url,
  });

  factory ExtensionRepo.fromJson(Map<String, dynamic> json) =>
      _$ExtensionRepoFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionRepoToJson(this);
}

@JsonSerializable()
class RepoConfig {
  final String link;
  final String name;
  final int id;

  RepoConfig({required this.link, required this.name, required this.id});

  factory RepoConfig.fromJson(Map<String, dynamic> json) =>
      _$RepoConfigFromJson(json);

  Map<String, dynamic> toJson() => _$RepoConfigToJson(this);
}
