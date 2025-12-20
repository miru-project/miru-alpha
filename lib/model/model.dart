import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

enum ExtensionType { manga, bangumi, fikushon, unknown }

enum ExtensionWatchBangumiType { hls, mp4, torrent }

enum ExtensionLogLevel { info, error }

enum MangaReadMode {
  // 标准 从左到右
  standard,
  // 从右到左
  rightToLeft,
  // 条漫
  webTonn,
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

@JsonSerializable()
class ExtensionFilter {
  ExtensionFilter({
    required this.title,
    required this.min,
    required this.max,
    required this.defaultOption,
    required this.options,
  });
  final String title;
  final int min;
  final int max;
  @JsonKey(name: "default")
  final String defaultOption;
  final Map<String, String> options;

  factory ExtensionFilter.fromJson(Map<String, dynamic> json) =>
      _$ExtensionFilterFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionFilterToJson(this);
}

@JsonSerializable()
class ExtensionListItem {
  ExtensionListItem({
    required this.title,
    required this.url,
    this.cover,
    this.update,
    this.headers,
  });

  final String title;
  final String url;
  final String? cover;
  final String? update;
  late Map<String, String>? headers;

  factory ExtensionListItem.fromJson(Map<String, dynamic> json) =>
      _$ExtensionListItemFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionListItemToJson(this);
}

@JsonSerializable()
class ExtensionDetail {
  ExtensionDetail({
    required this.title,
    this.cover,
    this.desc,
    this.episodes,
    this.headers,
  });

  final String title;
  final String? cover;
  final String? desc;
  final List<ExtensionEpisodeGroup>? episodes;
  late Map<String, String>? headers;

  factory ExtensionDetail.fromJson(Map<String, dynamic> json) =>
      _$ExtensionDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionDetailToJson(this);
}

@JsonSerializable()
class ExtensionEpisodeGroup {
  ExtensionEpisodeGroup({required this.title, required this.urls});
  final String title;
  final List<ExtensionEpisode> urls;

  factory ExtensionEpisodeGroup.fromJson(Map<String, dynamic> json) =>
      _$ExtensionEpisodeGroupFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionEpisodeGroupToJson(this);
}

@JsonSerializable()
class ExtensionEpisode {
  ExtensionEpisode({required this.name, required this.url});
  final String name;
  final String url;

  factory ExtensionEpisode.fromJson(Map<String, dynamic> json) =>
      _$ExtensionEpisodeFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionEpisodeToJson(this);
}

@JsonSerializable()
class ExtensionBangumiWatch extends BaseWatch {
  ExtensionBangumiWatch({
    required this.type,
    required this.url,
    this.subtitles,
    this.headers,
    this.audioTrack,
    this.torrent,
  });
  final ExtensionWatchBangumiType type;
  final String url;
  final List<ExtensionBangumiWatchSubtitle>? subtitles;
  late Map<String, String>? headers;
  late String? audioTrack;
  final ExtensionBangumiWatchTorrent? torrent;
  factory ExtensionBangumiWatch.fromJson(Map<String, dynamic> json) =>
      _$ExtensionBangumiWatchFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionBangumiWatchToJson(this);
}

@JsonSerializable()
class ExtensionBangumiWatchSubtitle {
  final String? language;
  final String title;
  final String url;
  ExtensionBangumiWatchSubtitle({
    required this.title,
    required this.url,
    this.language,
  });

  factory ExtensionBangumiWatchSubtitle.fromJson(Map<String, dynamic> json) =>
      _$ExtensionBangumiWatchSubtitleFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionBangumiWatchSubtitleToJson(this);
}

abstract class BaseWatch {}

@JsonSerializable()
class ExtensionMangaWatch extends BaseWatch {
  ExtensionMangaWatch({required this.urls, this.headers});

  final List<String> urls;
  late Map<String, String>? headers;

  factory ExtensionMangaWatch.fromJson(Map<String, dynamic> json) =>
      _$ExtensionMangaWatchFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionMangaWatchToJson(this);
}

@JsonSerializable()
class ExtensionFikushonWatch extends BaseWatch {
  final List<String> content;
  final String title;
  final String? subtitle;
  ExtensionFikushonWatch({
    required this.content,
    required this.title,
    this.subtitle,
  });

  factory ExtensionFikushonWatch.fromJson(Map<String, dynamic> json) =>
      _$ExtensionFikushonWatchFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionFikushonWatchToJson(this);
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
class ExtensionBangumiWatchTorrent {
  ExtensionBangumiWatchTorrent({
    required this.infoHash,
    required this.detail,
    required this.files,
  });

  final String infoHash;
  final ExtensionBangumiWatchTorrentDetail detail;
  final List<String> files;

  factory ExtensionBangumiWatchTorrent.fromJson(Map<String, dynamic> json) =>
      _$ExtensionBangumiWatchTorrentFromJson(json);

  Map<String, dynamic> toJson() => _$ExtensionBangumiWatchTorrentToJson(this);
}

@JsonSerializable()
class ExtensionBangumiWatchTorrentDetail {
  ExtensionBangumiWatchTorrentDetail({
    required this.pieceLength,
    required this.pieces,
    required this.name,
    this.nameUtf8,
    required this.length,
    this.private,
    this.source,
    this.files,
    this.metaVersion,
    this.fileTree,
  });

  @JsonKey(name: "PieceLength")
  final int? pieceLength;
  @JsonKey(name: "Pieces")
  final String? pieces;
  @JsonKey(name: "Name")
  final String? name;
  @JsonKey(name: "NameUtf8")
  final String? nameUtf8;
  @JsonKey(name: "Length")
  final int? length;
  @JsonKey(name: "Private")
  final dynamic private;
  @JsonKey(name: "Source")
  final String? source;
  @JsonKey(name: "Files")
  final List<dynamic>? files;
  @JsonKey(name: "MetaVersion")
  final int? metaVersion;
  @JsonKey(name: "FileTree")
  final ExtensionBangumiWatchTorrentFileTree? fileTree;

  factory ExtensionBangumiWatchTorrentDetail.fromJson(
    Map<String, dynamic> json,
  ) => _$ExtensionBangumiWatchTorrentDetailFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ExtensionBangumiWatchTorrentDetailToJson(this);
}

@JsonSerializable()
class ExtensionBangumiWatchTorrentFileTree {
  ExtensionBangumiWatchTorrentFileTree({this.file, this.dir});

  @JsonKey(name: "File")
  final ExtensionBangumiWatchTorrentFileTreeFile? file;
  @JsonKey(name: "Dir")
  final dynamic dir;

  factory ExtensionBangumiWatchTorrentFileTree.fromJson(
    Map<String, dynamic> json,
  ) => _$ExtensionBangumiWatchTorrentFileTreeFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ExtensionBangumiWatchTorrentFileTreeToJson(this);
}

@JsonSerializable()
class ExtensionBangumiWatchTorrentFileTreeFile {
  ExtensionBangumiWatchTorrentFileTreeFile({this.length, this.piecesRoot});

  @JsonKey(name: "Length")
  final int? length;
  @JsonKey(name: "PiecesRoot")
  final String? piecesRoot;

  factory ExtensionBangumiWatchTorrentFileTreeFile.fromJson(
    Map<String, dynamic> json,
  ) => _$ExtensionBangumiWatchTorrentFileTreeFileFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ExtensionBangumiWatchTorrentFileTreeFileToJson(this);
}
