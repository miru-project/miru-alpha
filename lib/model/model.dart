import 'package:json_annotation/json_annotation.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;

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

// Parse a raw extension `@type` string into the canonical ExtensionType.
//
// The supported types are exactly: all, manga, fikushon, bangumi. Any other
// value (including legacy aliases such as "video"/"novel") is treated as
// [ExtensionType.all] so the frontend never fails on an unknown type. Display
// labels are handle by i18n keys, not by these raw strings.
ExtensionType stringToExtensionType(String type) {
  switch (type) {
    case 'bangumi':
      return ExtensionType.bangumi;
    case 'manga':
      return ExtensionType.manga;
    case 'fikushon':
      return ExtensionType.fikushon;
    case 'all':
      return ExtensionType.all;
    default:
      return ExtensionType.all;
  }
}

/// The canonical wire string for a type, accepted by [stringToExtensionType].
///
/// Use this — never an i18n display key such as `media.video` — when building
/// the `?type=` query parameter for the history / favorite list routes, since
/// [stringToExtensionType] deliberately rejects display labels.
extension ExtensionTypeRouteParam on ExtensionType {
  String get routeParam => name;
}

// The content category used for storage grouping. Maps the extension type
// to one of video / manga / novel; [ExtensionType.all] maps to unspecified.
extension ExtensionTypeCategory on ExtensionType {
  /// The content category used for storage grouping, as a proto enum.
  /// [ExtensionType.all] has no category and returns
  /// [proto.DownloadCategory.unspecified].
  proto.DownloadCategory get category {
    switch (this) {
      case ExtensionType.bangumi:
        return proto.DownloadCategory.video;
      case ExtensionType.manga:
        return proto.DownloadCategory.manga;
      case ExtensionType.fikushon:
        return proto.DownloadCategory.novel;
      case ExtensionType.all:
        return proto.DownloadCategory.unspecified;
    }
  }
}

enum ExtensionWatchBangumiType { hls, mp4, torrent, magnet }

// Maps a raw extension watch type string ("hls", "mp4", "torrent", "magnet")
// to the download media type proto enum. Unknown/empty values map to
// [proto.DownloadMediaType.mediaTypeUnspecified] so the backend can infer the
// type from the URL.
proto.DownloadMediaType downloadMediaTypeFromString(String type) {
  switch (type) {
    case 'hls':
      return proto.DownloadMediaType.hls;
    case 'mp4':
      return proto.DownloadMediaType.mp4;
    case 'torrent':
      return proto.DownloadMediaType.torrent;
    case 'magnet':
      return proto.DownloadMediaType.magnet;
    default:
      return proto.DownloadMediaType.media_type_unspecified;
  }
}

// The download media type as a proto enum. This is the single source of truth
// for mapping a fixed set of media types onto the wire enum.
extension ExtensionWatchBangumiTypeMedia on ExtensionWatchBangumiType {
  proto.DownloadMediaType get downloadMedia {
    switch (this) {
      case ExtensionWatchBangumiType.hls:
        return proto.DownloadMediaType.hls;
      case ExtensionWatchBangumiType.mp4:
        return proto.DownloadMediaType.mp4;
      case ExtensionWatchBangumiType.torrent:
        return proto.DownloadMediaType.torrent;
      case ExtensionWatchBangumiType.magnet:
        return proto.DownloadMediaType.magnet;
    }
  }
}

enum ExtensionLogLevel { info, error }

enum MangaReadMode {
  // 标准 从左到右
  standard,
  // 从右到左
  rightToLeft,
  // 条漫
  webToon,
}

/// How a page image is scaled inside the reader canvas.
enum MangaFitMode {
  // Match viewport width, crop or letterbox vertically.
  fitWidth,
  // Match viewport height, scroll horizontally.
  fitHeight,
  // Render at natural pixel size (may overflow, pannable).
  original,
}

/// Canvas colour painted behind the page image.
enum MangaCanvasBackground { black, darkGray, light }

/// Who owns the display brightness while the reader is open.
///
/// [auto] leaves the screen alone and follows the system setting; [manual]
/// makes the reader's own brightness value authoritative for as long as it is
/// open, which is what a reader actually wants in a dark room.
enum MangaBrightnessMode { auto, manual }

/// How novel prose is laid out inside the reader canvas.
///
/// The three selectable modes are the ones the reader settings sheet offers; see
/// `kNovelReadModeOrder` for the display order (which deliberately skips the
/// legacy values below).
enum NovelReadMode {
  /// Fixed-height pages, turned with a tap zone. The book default.
  standard,

  /// One continuous vertical scroll, like a web article.
  webToon,

  /// Two text columns side by side, like a printed book.
  ///
  /// Note the type size this needs. A phone column is roughly half the page
  /// width, so at the default 18px a single paragraph is usually taller than
  /// one column; the reader then gives that paragraph a full-width page of its
  /// own, which is the only honest option short of cutting a paragraph in half.
  /// The mode reads as a single column until the font size is dropped towards
  /// the bottom of its range, where two columns fit. That is typography, not a
  /// layout fault: a book sets two columns in a much smaller face.
  doubleColumn,

  // Legacy page-turn values. Older builds persisted these; they are kept so a
  // stored setting still parses, and [resolved] folds them onto [standard].
  // They are never offered in the UI.
  rightToLeft,
  rightToLeftFlip,
  standardFlip,
}

extension NovelReadModeResolved on NovelReadMode {
  /// The mode the reader actually renders.
  ///
  /// Folds the legacy page-turn values onto [NovelReadMode.standard] so the
  /// canvas only has three cases to handle.
  NovelReadMode get resolved => switch (this) {
    NovelReadMode.webToon => NovelReadMode.webToon,
    NovelReadMode.doubleColumn => NovelReadMode.doubleColumn,
    _ => NovelReadMode.standard,
  };
}

/// Display order of the reading modes, which is the order the settings sheet and
/// the segmented strip render. Excludes the legacy [NovelReadMode] values.
const List<NovelReadMode> kNovelReadModeOrder = [
  NovelReadMode.standard,
  NovelReadMode.webToon,
  NovelReadMode.doubleColumn,
];

/// Reading typeface offered by the novel settings sheet.
///
/// The app bundles no font files, so each value is a *stack* the platform
/// resolves rather than a guaranteed face: see `novelFontFamilyFallback`.
enum NovelFontFamily { serif, sans, mono }

/// Paper colour painted behind novel prose.
enum NovelTheme { midnight, charcoal, sepia, paper }

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
