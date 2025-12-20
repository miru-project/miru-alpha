// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Extension _$ExtensionFromJson(Map<String, dynamic> json) => Extension(
  package: json['package'] as String,
  author: json['author'] as String,
  version: json['version'] as String,
  lang: json['lang'] as String,
  license: json['license'] as String,
  type: $enumDecode(_$ExtensionTypeEnumMap, json['type']),
  webSite: json['webSite'] as String,
  name: json['name'] as String,
  nsfw: json['nsfw'] as bool? ?? false,
  icon: json['icon'] as String?,
  url: json['url'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$ExtensionToJson(Extension instance) => <String, dynamic>{
  'nsfw': instance.nsfw,
  'package': instance.package,
  'author': instance.author,
  'version': instance.version,
  'lang': instance.lang,
  'license': instance.license,
  'type': _$ExtensionTypeEnumMap[instance.type]!,
  'webSite': instance.webSite,
  'name': instance.name,
  'icon': instance.icon,
  'url': instance.url,
  'description': instance.description,
};

const _$ExtensionTypeEnumMap = {
  ExtensionType.manga: 'manga',
  ExtensionType.bangumi: 'bangumi',
  ExtensionType.fikushon: 'fikushon',
  ExtensionType.unknown: 'unknown',
};

ExtensionFilter _$ExtensionFilterFromJson(Map<String, dynamic> json) =>
    ExtensionFilter(
      title: json['title'] as String,
      min: (json['min'] as num).toInt(),
      max: (json['max'] as num).toInt(),
      defaultOption: json['default'] as String,
      options: Map<String, String>.from(json['options'] as Map),
    );

Map<String, dynamic> _$ExtensionFilterToJson(ExtensionFilter instance) =>
    <String, dynamic>{
      'title': instance.title,
      'min': instance.min,
      'max': instance.max,
      'default': instance.defaultOption,
      'options': instance.options,
    };

ExtensionListItem _$ExtensionListItemFromJson(Map<String, dynamic> json) =>
    ExtensionListItem(
      title: json['title'] as String,
      url: json['url'] as String,
      cover: json['cover'] as String?,
      update: json['update'] as String?,
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$ExtensionListItemToJson(ExtensionListItem instance) =>
    <String, dynamic>{
      'title': instance.title,
      'url': instance.url,
      'cover': instance.cover,
      'update': instance.update,
      'headers': instance.headers,
    };

ExtensionDetail _$ExtensionDetailFromJson(Map<String, dynamic> json) =>
    ExtensionDetail(
      title: json['title'] as String,
      cover: json['cover'] as String?,
      desc: json['desc'] as String?,
      episodes: (json['episodes'] as List<dynamic>?)
          ?.map(
            (e) => ExtensionEpisodeGroup.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$ExtensionDetailToJson(ExtensionDetail instance) =>
    <String, dynamic>{
      'title': instance.title,
      'cover': instance.cover,
      'desc': instance.desc,
      'episodes': instance.episodes,
      'headers': instance.headers,
    };

ExtensionEpisodeGroup _$ExtensionEpisodeGroupFromJson(
  Map<String, dynamic> json,
) => ExtensionEpisodeGroup(
  title: json['title'] as String,
  urls: (json['urls'] as List<dynamic>)
      .map((e) => ExtensionEpisode.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ExtensionEpisodeGroupToJson(
  ExtensionEpisodeGroup instance,
) => <String, dynamic>{'title': instance.title, 'urls': instance.urls};

ExtensionEpisode _$ExtensionEpisodeFromJson(Map<String, dynamic> json) =>
    ExtensionEpisode(name: json['name'] as String, url: json['url'] as String);

Map<String, dynamic> _$ExtensionEpisodeToJson(ExtensionEpisode instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};

ExtensionBangumiWatch _$ExtensionBangumiWatchFromJson(
  Map<String, dynamic> json,
) => ExtensionBangumiWatch(
  type: $enumDecode(_$ExtensionWatchBangumiTypeEnumMap, json['type']),
  url: json['url'] as String,
  subtitles: (json['subtitles'] as List<dynamic>?)
      ?.map(
        (e) =>
            ExtensionBangumiWatchSubtitle.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  headers: (json['headers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  audioTrack: json['audioTrack'] as String?,
  torrent: json['torrent'] == null
      ? null
      : ExtensionBangumiWatchTorrent.fromJson(
          json['torrent'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ExtensionBangumiWatchToJson(
  ExtensionBangumiWatch instance,
) => <String, dynamic>{
  'type': _$ExtensionWatchBangumiTypeEnumMap[instance.type]!,
  'url': instance.url,
  'subtitles': instance.subtitles,
  'headers': instance.headers,
  'audioTrack': instance.audioTrack,
  'torrent': instance.torrent,
};

const _$ExtensionWatchBangumiTypeEnumMap = {
  ExtensionWatchBangumiType.hls: 'hls',
  ExtensionWatchBangumiType.mp4: 'mp4',
  ExtensionWatchBangumiType.torrent: 'torrent',
};

ExtensionBangumiWatchSubtitle _$ExtensionBangumiWatchSubtitleFromJson(
  Map<String, dynamic> json,
) => ExtensionBangumiWatchSubtitle(
  title: json['title'] as String,
  url: json['url'] as String,
  language: json['language'] as String?,
);

Map<String, dynamic> _$ExtensionBangumiWatchSubtitleToJson(
  ExtensionBangumiWatchSubtitle instance,
) => <String, dynamic>{
  'language': instance.language,
  'title': instance.title,
  'url': instance.url,
};

ExtensionMangaWatch _$ExtensionMangaWatchFromJson(Map<String, dynamic> json) =>
    ExtensionMangaWatch(
      urls: (json['urls'] as List<dynamic>).map((e) => e as String).toList(),
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$ExtensionMangaWatchToJson(
  ExtensionMangaWatch instance,
) => <String, dynamic>{'urls': instance.urls, 'headers': instance.headers};

ExtensionFikushonWatch _$ExtensionFikushonWatchFromJson(
  Map<String, dynamic> json,
) => ExtensionFikushonWatch(
  content: (json['content'] as List<dynamic>).map((e) => e as String).toList(),
  title: json['title'] as String,
  subtitle: json['subtitle'] as String?,
);

Map<String, dynamic> _$ExtensionFikushonWatchToJson(
  ExtensionFikushonWatch instance,
) => <String, dynamic>{
  'content': instance.content,
  'title': instance.title,
  'subtitle': instance.subtitle,
};

ExtensionLog _$ExtensionLogFromJson(Map<String, dynamic> json) => ExtensionLog(
  extension: Extension.fromJson(json['extension'] as Map<String, dynamic>),
  content: json['content'] as String,
  time: DateTime.parse(json['time'] as String),
  level: $enumDecode(_$ExtensionLogLevelEnumMap, json['level']),
);

Map<String, dynamic> _$ExtensionLogToJson(ExtensionLog instance) =>
    <String, dynamic>{
      'time': instance.time.toIso8601String(),
      'extension': instance.extension,
      'content': instance.content,
      'level': _$ExtensionLogLevelEnumMap[instance.level]!,
    };

const _$ExtensionLogLevelEnumMap = {
  ExtensionLogLevel.info: 'info',
  ExtensionLogLevel.error: 'error',
};

ExtensionNetworkLog _$ExtensionNetworkLogFromJson(Map<String, dynamic> json) =>
    ExtensionNetworkLog(
      extension: Extension.fromJson(json['extension'] as Map<String, dynamic>),
      url: json['url'] as String,
      method: json['method'] as String,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      responseBody: json['responseBody'] as String?,
      requestBody: json['requestBody'] as String?,
      requestHeaders: json['requestHeaders'] as Map<String, dynamic>?,
      responseHeaders: json['responseHeaders'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ExtensionNetworkLogToJson(
  ExtensionNetworkLog instance,
) => <String, dynamic>{
  'extension': instance.extension,
  'responseBody': instance.responseBody,
  'requestBody': instance.requestBody,
  'requestHeaders': instance.requestHeaders,
  'responseHeaders': instance.responseHeaders,
  'url': instance.url,
  'method': instance.method,
  'statusCode': instance.statusCode,
};

GithubExtension _$GithubExtensionFromJson(Map<String, dynamic> json) =>
    GithubExtension(
      name: json['name'] as String,
      description: json['description'] as String?,
      license: json['license'] as String,
      version: json['version'] as String,
      author: json['author'] as String,
      package: json['package'] as String,
      icon: json['icon'] as String?,
      type: json['type'] as String,
      language: json['lang'] as String,
      website: json['webSite'] as String,
      isNsfw: _boolFromString(json['nsfw']),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$GithubExtensionToJson(GithubExtension instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'license': instance.license,
      'version': instance.version,
      'author': instance.author,
      'icon': instance.icon,
      'type': instance.type,
      'lang': instance.language,
      'webSite': instance.website,
      'nsfw': instance.isNsfw,
      'package': instance.package,
      'tags': instance.tags,
    };

ExtensionBangumiWatchTorrent _$ExtensionBangumiWatchTorrentFromJson(
  Map<String, dynamic> json,
) => ExtensionBangumiWatchTorrent(
  infoHash: json['infoHash'] as String,
  detail: ExtensionBangumiWatchTorrentDetail.fromJson(
    json['detail'] as Map<String, dynamic>,
  ),
  files: (json['files'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$ExtensionBangumiWatchTorrentToJson(
  ExtensionBangumiWatchTorrent instance,
) => <String, dynamic>{
  'infoHash': instance.infoHash,
  'detail': instance.detail,
  'files': instance.files,
};

ExtensionBangumiWatchTorrentDetail _$ExtensionBangumiWatchTorrentDetailFromJson(
  Map<String, dynamic> json,
) => ExtensionBangumiWatchTorrentDetail(
  pieceLength: (json['PieceLength'] as num?)?.toInt(),
  pieces: json['Pieces'] as String?,
  name: json['Name'] as String?,
  nameUtf8: json['NameUtf8'] as String?,
  length: (json['Length'] as num?)?.toInt(),
  private: json['Private'],
  source: json['Source'] as String?,
  files: json['Files'] as List<dynamic>?,
  metaVersion: (json['MetaVersion'] as num?)?.toInt(),
  fileTree: json['FileTree'] == null
      ? null
      : ExtensionBangumiWatchTorrentFileTree.fromJson(
          json['FileTree'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ExtensionBangumiWatchTorrentDetailToJson(
  ExtensionBangumiWatchTorrentDetail instance,
) => <String, dynamic>{
  'PieceLength': instance.pieceLength,
  'Pieces': instance.pieces,
  'Name': instance.name,
  'NameUtf8': instance.nameUtf8,
  'Length': instance.length,
  'Private': instance.private,
  'Source': instance.source,
  'Files': instance.files,
  'MetaVersion': instance.metaVersion,
  'FileTree': instance.fileTree,
};

ExtensionBangumiWatchTorrentFileTree
_$ExtensionBangumiWatchTorrentFileTreeFromJson(Map<String, dynamic> json) =>
    ExtensionBangumiWatchTorrentFileTree(
      file: json['File'] == null
          ? null
          : ExtensionBangumiWatchTorrentFileTreeFile.fromJson(
              json['File'] as Map<String, dynamic>,
            ),
      dir: json['Dir'],
    );

Map<String, dynamic> _$ExtensionBangumiWatchTorrentFileTreeToJson(
  ExtensionBangumiWatchTorrentFileTree instance,
) => <String, dynamic>{'File': instance.file, 'Dir': instance.dir};

ExtensionBangumiWatchTorrentFileTreeFile
_$ExtensionBangumiWatchTorrentFileTreeFileFromJson(Map<String, dynamic> json) =>
    ExtensionBangumiWatchTorrentFileTreeFile(
      length: (json['Length'] as num?)?.toInt(),
      piecesRoot: json['PiecesRoot'] as String?,
    );

Map<String, dynamic> _$ExtensionBangumiWatchTorrentFileTreeFileToJson(
  ExtensionBangumiWatchTorrentFileTreeFile instance,
) => <String, dynamic>{
  'Length': instance.length,
  'PiecesRoot': instance.piecesRoot,
};
