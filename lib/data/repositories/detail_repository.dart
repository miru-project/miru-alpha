import 'dart:convert';

import 'package:miru_alpha/data/services/detail_service.dart';
import 'package:miru_alpha/domain/models/detail.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/db_model.pb.dart'
    as db_model;
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as ext_model;

class DetailRepository {
  final DetailService _detailService;

  DetailRepository(this._detailService);

  Future<DomainDetail> getDetail(String package, String detailUrl) async {
    final detail = await _detailService.getDetail(package, detailUrl);
    final episodes = detail.episodes.isEmpty
        ? <DomainEpisodeGroup>[]
        : (jsonDecode(detail.episodes) as List<dynamic>)
              .map(
                (e) => DomainEpisodeGroup.fromProto(
                  ext_model.ExtensionEpisodeGroup.fromJson(jsonEncode(e)),
                ),
              )
              .toList();
    final headers = detail.headers.isEmpty
        ? null
        : (jsonDecode(detail.headers) as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, v.toString()),
          );
    return DomainDetail(
      title: detail.title,
      cover: detail.cover,
      desc: detail.desc,
      episodes: episodes,
      headers: headers,
      downloaded: detail.downloaded.toList(),
      detailUrl: detail.detailUrl,
      package: detail.package,
    );
  }

  Future<void> saveDetail(DomainDetail detail) async {
    await _detailService.saveDetail(
      db_model.Detail(
        title: detail.title,
        cover: detail.cover ?? '',
        desc: detail.desc ?? '',
        detailUrl: detail.detailUrl,
        package: detail.package,
        downloaded: detail.downloaded,
        episodes: detail.episodes == null
            ? ''
            : jsonEncode(detail.episodes!.map((e) => e.toProto()).toList()),
        headers: detail.headers == null ? '' : jsonEncode(detail.headers),
        trackIds: const {},
      ),
    );
  }

  Future<List<DomainDetail>> searchExtensions(
    String query, {
    String? package,
    String? type,
  }) async {
    final results = await _detailService.searchExtensions(
      query,
      package: package,
      type: type,
    );
    return results
        .map(
          (result) => DomainDetail(
            title: result.title,
            cover: result.cover,
            desc: '',
            episodes: const [],
            headers: result.headers.isEmpty
                ? null
                : Map<String, String>.from(result.headers),
            downloaded: const [],
            detailUrl: result.url,
            package: package ?? '',
          ),
        )
        .toList();
  }

  Future<List<DomainDetail>> getLatest(String package) async {
    final results = await _detailService.getLatest(package);
    return results
        .map(
          (result) => DomainDetail(
            title: result.title,
            cover: result.cover,
            desc: '',
            episodes: const [],
            headers: result.headers.isEmpty
                ? null
                : Map<String, String>.from(result.headers),
            downloaded: const [],
            detailUrl: result.url,
            package: package,
          ),
        )
        .toList();
  }
}
