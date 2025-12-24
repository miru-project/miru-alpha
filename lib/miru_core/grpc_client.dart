import 'dart:convert';
import 'package:grpc/grpc.dart';
import 'package:miru_app_new/miru_core/core.dart';
import 'package:miru_app_new/miru_core/proto/miru_core_service.pbgrpc.dart'
    as proto;
import 'package:miru_app_new/model/model.dart';

class MiruGrpcClient {
  static proto.MiruCoreServiceClient? _client;
  static ClientChannel? _channel;

  static proto.MiruCoreServiceClient get client {
    if (_client == null) {
      _init();
    }
    return _client!;
  }

  static void _init() {
    final port = int.parse(Core.port) + 1;
    _channel = ClientChannel(
      Core.host,
      port: port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    _client = proto.MiruCoreServiceClient(_channel!);
  }

  static Detail _fromProto(proto.Detail p) {
    return Detail(
      id: p.id,
      title: p.hasTitle() ? p.title : "",
      cover: p.hasCover() ? p.cover : null,
      desc: p.hasDesc() ? p.desc : null,
      downloaded: p.downloaded,
      detailUrl: p.detailUrl,
      package: p.package,
      episodes: p.hasEpisodes()
          ? (jsonDecode(p.episodes) as List)
                .map((e) => ExtensionEpisodeGroup.fromJson(e))
                .toList()
          : null,
      headers: p.hasHeaders()
          ? (jsonDecode(p.headers) as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, v.toString()),
            )
          : null,
    );
  }

  static Future<Detail?> getDetail(String pkg, String url) async {
    final response = await client.getDetail(
      proto.GetDetailRequest(package: pkg, detailUrl: url),
    );
    if (!response.hasDetail() || response.detail.package.isEmpty) return null;
    return _fromProto(response.detail);
  }

  static Future<Detail> upsertDetail(Detail detail) async {
    final response = await client.upsertDetail(
      proto.UpsertDetailRequest(
        title: detail.title,
        cover: detail.cover,
        desc: detail.desc,
        detailUrl: detail.detailUrl,
        package: detail.package,
        downloaded: detail.downloaded,
        episodes: detail.episodes != null ? jsonEncode(detail.episodes) : null,
        headers: detail.headers != null ? jsonEncode(detail.headers) : null,
      ),
    );
    return _fromProto(response.detail);
  }
}
