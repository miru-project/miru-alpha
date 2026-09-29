import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb;

part 'detail.freezed.dart';
part 'detail.g.dart';

@freezed
abstract class DomainDetail with _$DomainDetail {
  const factory DomainDetail({
    int? id,
    required String title,
    String? cover,
    String? desc,
    List<DomainEpisodeGroup>? episodes,
    Map<String, String>? headers,
    @Default([]) List<String> downloaded,
    required String detailUrl,
    required String package,
  }) = _DomainDetail;

  factory DomainDetail.fromJson(Map<String, dynamic> json) =>
      _$DomainDetailFromJson(json);

  factory DomainDetail.fromProto(
    pb.ExtensionDetail extensionDetail, {
    required String detailUrl,
    required String package,
    List<String> downloaded = const [],
    int? id,
  }) {
    return DomainDetail(
      id: id,
      title: extensionDetail.title,
      cover: extensionDetail.cover,
      desc: extensionDetail.desc,
      episodes: extensionDetail.episodes
          .map((e) => DomainEpisodeGroup.fromProto(e))
          .toList(),
      headers: extensionDetail.headers.map((k, v) => MapEntry(k, v)),
      downloaded: downloaded,
      detailUrl: detailUrl,
      package: package,
    );
  }
}

@freezed
abstract class DomainEpisodeGroup with _$DomainEpisodeGroup {
  const factory DomainEpisodeGroup({
    String? name,
    required List<DomainEpisode> episodes,
  }) = _DomainEpisodeGroup;

  factory DomainEpisodeGroup.fromJson(Map<String, dynamic> json) =>
      _$DomainEpisodeGroupFromJson(json);

  factory DomainEpisodeGroup.fromProto(pb.ExtensionEpisodeGroup group) {
    return DomainEpisodeGroup(
      name: group.title,
      episodes: group.urls
          .map((e) => DomainEpisode(name: e.name, url: e.url))
          .toList(),
    );
  }
}

extension DomainEpisodeGroupProto on DomainEpisodeGroup {
  Map<String, dynamic> toProto() => <String, dynamic>{
    'title': name,
    'episodes': episodes.map((e) => e.toProto()).toList(),
  };
}

@freezed
abstract class DomainEpisode with _$DomainEpisode {
  const factory DomainEpisode({String? name, required String url}) =
      _DomainEpisode;

  factory DomainEpisode.fromJson(Map<String, dynamic> json) =>
      _$DomainEpisodeFromJson(json);
}

extension DomainEpisodeProto on DomainEpisode {
  Map<String, dynamic> toProto() => <String, dynamic>{'name': name, 'url': url};
}
