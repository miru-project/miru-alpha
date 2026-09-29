import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb;
import 'package:miru_alpha/model/watch_result.dart';

part 'watch.freezed.dart';
part 'watch.g.dart';

@freezed
abstract class DomainWatchResult with _$DomainWatchResult {
  const factory DomainWatchResult({
    required DomainWatchData data,
    DomainV2Watch? v2watch,
  }) = _DomainWatchResult;

  factory DomainWatchResult.fromJson(Map<String, dynamic> json) =>
      _$DomainWatchResultFromJson(json);

  factory DomainWatchResult.fromWatchResult(
    WatchResult watchResult, {
    required String detailUrl,
    required String package,
  }) {
    final data = DomainWatchData(
      bangumi: watchResult.data is pb.ExtensionBangumiWatch
          ? DomainBangumiWatch.fromProto(
              watchResult.data as pb.ExtensionBangumiWatch,
            )
          : null,
      manga: watchResult.data is pb.ExtensionMangaWatch
          ? DomainMangaWatch.fromProto(
              watchResult.data as pb.ExtensionMangaWatch,
            )
          : null,
      novel: watchResult.data is pb.ExtensionFikushonWatch
          ? DomainNovelWatch.fromProto(
              watchResult.data as pb.ExtensionFikushonWatch,
            )
          : null,
    );

    final v2watch = watchResult.v2watch != null
        ? DomainV2Watch.fromProto(watchResult.v2watch!)
        : null;

    return DomainWatchResult(data: data, v2watch: v2watch);
  }
}

@freezed
abstract class DomainWatchData with _$DomainWatchData {
  const factory DomainWatchData({
    DomainBangumiWatch? bangumi,
    DomainMangaWatch? manga,
    DomainNovelWatch? novel,
  }) = _DomainWatchData;

  factory DomainWatchData.fromJson(Map<String, dynamic> json) =>
      _$DomainWatchDataFromJson(json);
}

@freezed
abstract class DomainBangumiWatch with _$DomainBangumiWatch {
  const factory DomainBangumiWatch({
    String? type,
    String? url,
    List<DomainBangumiWatchSubtitle>? subtitles,
    Map<String, String>? headers,
    DomainBangumiTorrent? torrent,
  }) = _DomainBangumiWatch;

  factory DomainBangumiWatch.fromJson(Map<String, dynamic> json) =>
      _$DomainBangumiWatchFromJson(json);

  factory DomainBangumiWatch.fromProto(pb.ExtensionBangumiWatch bangumi) {
    return DomainBangumiWatch(
      type: bangumi.type,
      url: bangumi.url,
      subtitles: bangumi.subtitles
          .map((e) => DomainBangumiWatchSubtitle.fromProto(e))
          .toList(),
      headers: bangumi.headers.map((k, v) => MapEntry(k, v)),
      torrent: bangumi.hasTorrent()
          ? DomainBangumiTorrent.fromProto(bangumi.torrent)
          : null,
    );
  }
}

@freezed
abstract class DomainBangumiWatchSubtitle with _$DomainBangumiWatchSubtitle {
  const factory DomainBangumiWatchSubtitle({
    String? language,
    String? title,
    required String url,
  }) = _DomainBangumiWatchSubtitle;

  factory DomainBangumiWatchSubtitle.fromJson(Map<String, dynamic> json) =>
      _$DomainBangumiWatchSubtitleFromJson(json);

  factory DomainBangumiWatchSubtitle.fromProto(
    pb.ExtensionBangumiWatchSubtitle subtitle,
  ) {
    return DomainBangumiWatchSubtitle(
      language: subtitle.language,
      title: subtitle.title,
      url: subtitle.url,
    );
  }
}

@freezed
abstract class DomainBangumiTorrent with _$DomainBangumiTorrent {
  const factory DomainBangumiTorrent({
    required String infoHash,
    required DomainBangumiTorrentDetail detail,
    List<String>? files,
  }) = _DomainBangumiTorrent;

  factory DomainBangumiTorrent.fromJson(Map<String, dynamic> json) =>
      _$DomainBangumiTorrentFromJson(json);

  factory DomainBangumiTorrent.fromProto(
    pb.ExtensionBangumiWatchTorrent torrent,
  ) {
    return DomainBangumiTorrent(
      infoHash: torrent.infoHash,
      detail: DomainBangumiTorrentDetail.fromProto(torrent.detail),
      files: torrent.files.isEmpty ? null : torrent.files.toList(),
    );
  }
}

@freezed
abstract class DomainBangumiTorrentDetail with _$DomainBangumiTorrentDetail {
  const factory DomainBangumiTorrentDetail({
    int? pieceLength,
    String? pieces,
    String? name,
    String? nameUtf8,
    int? length,
    String? source,
    int? metaVersion,
    DomainBangumiTorrentFileTree? fileTree,
  }) = _DomainBangumiTorrentDetail;

  factory DomainBangumiTorrentDetail.fromJson(Map<String, dynamic> json) =>
      _$DomainBangumiTorrentDetailFromJson(json);

  factory DomainBangumiTorrentDetail.fromProto(
    pb.ExtensionBangumiWatchTorrentDetail detail,
  ) {
    return DomainBangumiTorrentDetail(
      pieceLength: detail.pieceLength.toInt(),
      pieces: detail.pieces,
      name: detail.name,
      nameUtf8: detail.nameUtf8,
      length: detail.length.toInt(),
      source: detail.source,
      metaVersion: detail.metaVersion.toInt(),
      fileTree: DomainBangumiTorrentFileTree.fromProto(detail.fileTree),
    );
  }
}

@freezed
abstract class DomainBangumiTorrentFileTree
    with _$DomainBangumiTorrentFileTree {
  const factory DomainBangumiTorrentFileTree({
    DomainBangumiTorrentFileTreeFile? file,
    Map<String, DomainBangumiTorrentFileTree>? dir,
  }) = _DomainBangumiTorrentFileTree;

  factory DomainBangumiTorrentFileTree.fromJson(Map<String, dynamic> json) =>
      _$DomainBangumiTorrentFileTreeFromJson(json);

  factory DomainBangumiTorrentFileTree.fromProto(
    pb.ExtensionBangumiWatchTorrentFileTree tree,
  ) {
    return DomainBangumiTorrentFileTree(
      file: DomainBangumiTorrentFileTreeFile.fromProto(tree.file),
      dir: tree.dir.isEmpty
          ? null
          : Map.fromEntries(
              tree.dir.entries.map(
                (e) => MapEntry(
                  e.key,
                  DomainBangumiTorrentFileTree.fromProto(e.value),
                ),
              ),
            ),
    );
  }
}

@freezed
abstract class DomainBangumiTorrentFileTreeFile
    with _$DomainBangumiTorrentFileTreeFile {
  const factory DomainBangumiTorrentFileTreeFile({
    required int length,
    required String piecesRoot,
  }) = _DomainBangumiTorrentFileTreeFile;

  factory DomainBangumiTorrentFileTreeFile.fromJson(
    Map<String, dynamic> json,
  ) => _$DomainBangumiTorrentFileTreeFileFromJson(json);

  factory DomainBangumiTorrentFileTreeFile.fromProto(
    pb.ExtensionBangumiWatchTorrentFileTreeFile file,
  ) {
    return DomainBangumiTorrentFileTreeFile(
      length: file.length.toInt(),
      piecesRoot: file.piecesRoot,
    );
  }
}

@freezed
abstract class DomainMangaWatch with _$DomainMangaWatch {
  const factory DomainMangaWatch({
    required List<DomainMangaPage> pages,
    Map<String, String>? headers,
  }) = _DomainMangaWatch;

  factory DomainMangaWatch.fromJson(Map<String, dynamic> json) =>
      _$DomainMangaWatchFromJson(json);

  factory DomainMangaWatch.fromProto(pb.ExtensionMangaWatch manga) {
    return DomainMangaWatch(
      pages: manga.urls.map((e) => DomainMangaPage(url: e)).toList(),
      headers: manga.headers.map((k, v) => MapEntry(k, v)),
    );
  }
}

@freezed
abstract class DomainMangaPage with _$DomainMangaPage {
  const factory DomainMangaPage({String? name, required String url}) =
      _DomainMangaPage;

  factory DomainMangaPage.fromJson(Map<String, dynamic> json) =>
      _$DomainMangaPageFromJson(json);
}

@freezed
abstract class DomainNovelWatch with _$DomainNovelWatch {
  const factory DomainNovelWatch({
    required List<DomainNovelChapter> chapters,
    Map<String, String>? headers,
  }) = _DomainNovelWatch;

  factory DomainNovelWatch.fromJson(Map<String, dynamic> json) =>
      _$DomainNovelWatchFromJson(json);

  factory DomainNovelWatch.fromProto(pb.ExtensionFikushonWatch novel) {
    return DomainNovelWatch(
      chapters: novel.content
          .map((e) => DomainNovelChapter(name: novel.title, url: e))
          .toList(),
      headers: const {},
    );
  }
}

@freezed
abstract class DomainNovelChapter with _$DomainNovelChapter {
  const factory DomainNovelChapter({String? name, required String url}) =
      _DomainNovelChapter;

  factory DomainNovelChapter.fromJson(Map<String, dynamic> json) =>
      _$DomainNovelChapterFromJson(json);
}

@freezed
abstract class DomainV2Watch with _$DomainV2Watch {
  const factory DomainV2Watch({
    required List<DomainV2EpisodeGroup> groups,
    String? defaultGroup,
    int? defaultIndex,
  }) = _DomainV2Watch;

  factory DomainV2Watch.fromJson(Map<String, dynamic> json) =>
      _$DomainV2WatchFromJson(json);

  factory DomainV2Watch.fromProto(pb.ExtensionWatch v2watch) {
    return DomainV2Watch(
      groups: v2watch.groups
          .map((e) => DomainV2EpisodeGroup.fromProto(e))
          .toList(),
      defaultGroup: v2watch.defaultGroup,
      defaultIndex: v2watch.defaultIndex,
    );
  }
}

@freezed
abstract class DomainV2EpisodeGroup with _$DomainV2EpisodeGroup {
  const factory DomainV2EpisodeGroup({
    required String title,
    required List<DomainV2Episode> episodes,
  }) = _DomainV2EpisodeGroup;

  factory DomainV2EpisodeGroup.fromJson(Map<String, dynamic> json) =>
      _$DomainV2EpisodeGroupFromJson(json);

  factory DomainV2EpisodeGroup.fromProto(pb.ExtensionMirrorGroup group) {
    return DomainV2EpisodeGroup(
      title: group.title,
      episodes: group.mirrors
          .map((e) => DomainV2Episode(name: e.name, url: e.url))
          .toList(),
    );
  }
}

@freezed
abstract class DomainV2Episode with _$DomainV2Episode {
  const factory DomainV2Episode({String? name, required String url}) =
      _DomainV2Episode;

  factory DomainV2Episode.fromJson(Map<String, dynamic> json) =>
      _$DomainV2EpisodeFromJson(json);
}
