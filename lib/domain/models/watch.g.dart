// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DomainWatchResult _$DomainWatchResultFromJson(Map<String, dynamic> json) =>
    _DomainWatchResult(
      data: DomainWatchData.fromJson(json['data'] as Map<String, dynamic>),
      v2watch: json['v2watch'] == null
          ? null
          : DomainV2Watch.fromJson(json['v2watch'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DomainWatchResultToJson(_DomainWatchResult instance) =>
    <String, dynamic>{'data': instance.data, 'v2watch': instance.v2watch};

_DomainWatchData _$DomainWatchDataFromJson(Map<String, dynamic> json) =>
    _DomainWatchData(
      bangumi: json['bangumi'] == null
          ? null
          : DomainBangumiWatch.fromJson(
              json['bangumi'] as Map<String, dynamic>,
            ),
      manga: json['manga'] == null
          ? null
          : DomainMangaWatch.fromJson(json['manga'] as Map<String, dynamic>),
      novel: json['novel'] == null
          ? null
          : DomainNovelWatch.fromJson(json['novel'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DomainWatchDataToJson(_DomainWatchData instance) =>
    <String, dynamic>{
      'bangumi': instance.bangumi,
      'manga': instance.manga,
      'novel': instance.novel,
    };

_DomainBangumiWatch _$DomainBangumiWatchFromJson(Map<String, dynamic> json) =>
    _DomainBangumiWatch(
      type: json['type'] as String?,
      url: json['url'] as String?,
      subtitles: (json['subtitles'] as List<dynamic>?)
          ?.map(
            (e) =>
                DomainBangumiWatchSubtitle.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      torrent: json['torrent'] == null
          ? null
          : DomainBangumiTorrent.fromJson(
              json['torrent'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$DomainBangumiWatchToJson(_DomainBangumiWatch instance) =>
    <String, dynamic>{
      'type': instance.type,
      'url': instance.url,
      'subtitles': instance.subtitles,
      'headers': instance.headers,
      'torrent': instance.torrent,
    };

_DomainBangumiWatchSubtitle _$DomainBangumiWatchSubtitleFromJson(
  Map<String, dynamic> json,
) => _DomainBangumiWatchSubtitle(
  language: json['language'] as String?,
  title: json['title'] as String?,
  url: json['url'] as String,
);

Map<String, dynamic> _$DomainBangumiWatchSubtitleToJson(
  _DomainBangumiWatchSubtitle instance,
) => <String, dynamic>{
  'language': instance.language,
  'title': instance.title,
  'url': instance.url,
};

_DomainBangumiTorrent _$DomainBangumiTorrentFromJson(
  Map<String, dynamic> json,
) => _DomainBangumiTorrent(
  infoHash: json['infoHash'] as String,
  detail: DomainBangumiTorrentDetail.fromJson(
    json['detail'] as Map<String, dynamic>,
  ),
  files: (json['files'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$DomainBangumiTorrentToJson(
  _DomainBangumiTorrent instance,
) => <String, dynamic>{
  'infoHash': instance.infoHash,
  'detail': instance.detail,
  'files': instance.files,
};

_DomainBangumiTorrentDetail _$DomainBangumiTorrentDetailFromJson(
  Map<String, dynamic> json,
) => _DomainBangumiTorrentDetail(
  pieceLength: (json['pieceLength'] as num?)?.toInt(),
  pieces: json['pieces'] as String?,
  name: json['name'] as String?,
  nameUtf8: json['nameUtf8'] as String?,
  length: (json['length'] as num?)?.toInt(),
  source: json['source'] as String?,
  metaVersion: (json['metaVersion'] as num?)?.toInt(),
  fileTree: json['fileTree'] == null
      ? null
      : DomainBangumiTorrentFileTree.fromJson(
          json['fileTree'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$DomainBangumiTorrentDetailToJson(
  _DomainBangumiTorrentDetail instance,
) => <String, dynamic>{
  'pieceLength': instance.pieceLength,
  'pieces': instance.pieces,
  'name': instance.name,
  'nameUtf8': instance.nameUtf8,
  'length': instance.length,
  'source': instance.source,
  'metaVersion': instance.metaVersion,
  'fileTree': instance.fileTree,
};

_DomainBangumiTorrentFileTree _$DomainBangumiTorrentFileTreeFromJson(
  Map<String, dynamic> json,
) => _DomainBangumiTorrentFileTree(
  file: json['file'] == null
      ? null
      : DomainBangumiTorrentFileTreeFile.fromJson(
          json['file'] as Map<String, dynamic>,
        ),
  dir: (json['dir'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      k,
      DomainBangumiTorrentFileTree.fromJson(e as Map<String, dynamic>),
    ),
  ),
);

Map<String, dynamic> _$DomainBangumiTorrentFileTreeToJson(
  _DomainBangumiTorrentFileTree instance,
) => <String, dynamic>{'file': instance.file, 'dir': instance.dir};

_DomainBangumiTorrentFileTreeFile _$DomainBangumiTorrentFileTreeFileFromJson(
  Map<String, dynamic> json,
) => _DomainBangumiTorrentFileTreeFile(
  length: (json['length'] as num).toInt(),
  piecesRoot: json['piecesRoot'] as String,
);

Map<String, dynamic> _$DomainBangumiTorrentFileTreeFileToJson(
  _DomainBangumiTorrentFileTreeFile instance,
) => <String, dynamic>{
  'length': instance.length,
  'piecesRoot': instance.piecesRoot,
};

_DomainMangaWatch _$DomainMangaWatchFromJson(Map<String, dynamic> json) =>
    _DomainMangaWatch(
      pages: (json['pages'] as List<dynamic>)
          .map((e) => DomainMangaPage.fromJson(e as Map<String, dynamic>))
          .toList(),
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$DomainMangaWatchToJson(_DomainMangaWatch instance) =>
    <String, dynamic>{'pages': instance.pages, 'headers': instance.headers};

_DomainMangaPage _$DomainMangaPageFromJson(Map<String, dynamic> json) =>
    _DomainMangaPage(name: json['name'] as String?, url: json['url'] as String);

Map<String, dynamic> _$DomainMangaPageToJson(_DomainMangaPage instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};

_DomainNovelWatch _$DomainNovelWatchFromJson(Map<String, dynamic> json) =>
    _DomainNovelWatch(
      chapters: (json['chapters'] as List<dynamic>)
          .map((e) => DomainNovelChapter.fromJson(e as Map<String, dynamic>))
          .toList(),
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$DomainNovelWatchToJson(_DomainNovelWatch instance) =>
    <String, dynamic>{
      'chapters': instance.chapters,
      'headers': instance.headers,
    };

_DomainNovelChapter _$DomainNovelChapterFromJson(Map<String, dynamic> json) =>
    _DomainNovelChapter(
      name: json['name'] as String?,
      url: json['url'] as String,
    );

Map<String, dynamic> _$DomainNovelChapterToJson(_DomainNovelChapter instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};

_DomainV2Watch _$DomainV2WatchFromJson(Map<String, dynamic> json) =>
    _DomainV2Watch(
      groups: (json['groups'] as List<dynamic>)
          .map((e) => DomainV2EpisodeGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      defaultGroup: json['defaultGroup'] as String?,
      defaultIndex: (json['defaultIndex'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DomainV2WatchToJson(_DomainV2Watch instance) =>
    <String, dynamic>{
      'groups': instance.groups,
      'defaultGroup': instance.defaultGroup,
      'defaultIndex': instance.defaultIndex,
    };

_DomainV2EpisodeGroup _$DomainV2EpisodeGroupFromJson(
  Map<String, dynamic> json,
) => _DomainV2EpisodeGroup(
  title: json['title'] as String,
  episodes: (json['episodes'] as List<dynamic>)
      .map((e) => DomainV2Episode.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DomainV2EpisodeGroupToJson(
  _DomainV2EpisodeGroup instance,
) => <String, dynamic>{'title': instance.title, 'episodes': instance.episodes};

_DomainV2Episode _$DomainV2EpisodeFromJson(Map<String, dynamic> json) =>
    _DomainV2Episode(name: json['name'] as String?, url: json['url'] as String);

Map<String, dynamic> _$DomainV2EpisodeToJson(_DomainV2Episode instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};
