import 'package:grpc/grpc.dart';
import 'package:miru_app_new/miru_core/core.dart';
import 'package:miru_app_new/miru_core/proto/miru_core_service.pbgrpc.dart'
    as proto;
import 'package:miru_app_new/miru_core/proto/app_setting.pbgrpc.dart'
    as app_setting;
import 'package:miru_app_new/miru_core/proto/extension.pbgrpc.dart' as ext;
import 'package:miru_app_new/miru_core/proto/repo.pbgrpc.dart' as repo;
import 'package:miru_app_new/miru_core/proto/download.pbgrpc.dart' as download;
import 'package:miru_app_new/miru_core/proto/db.pbgrpc.dart' as db;
import 'package:miru_app_new/miru_core/proto/network.pbgrpc.dart' as network;
import 'package:miru_app_new/miru_core/proto/events.pbgrpc.dart' as events;

class MiruGrpcClient {
  static ClientChannel? _channel;

  static proto.MiruCoreServiceClient? _coreClient;
  static app_setting.AppSettingServiceClient? _appSettingClient;
  static ext.ExtensionServiceClient? _extensionClient;
  static repo.RepoServiceClient? _repoClient;
  static download.DownloadServiceClient? _downloadClient;
  static db.DbServiceClient? _dbClient;
  static network.NetworkServiceClient? _networkClient;
  static events.EventServiceClient? _eventClient;

  static ClientChannel get channel {
    if (_channel == null) {
      _init();
    }
    return _channel!;
  }

  static void _init() {
    final port = int.parse(Core.port) + 1;
    _channel = ClientChannel(
      Core.host,
      port: port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
  }

  static proto.MiruCoreServiceClient get coreClient =>
      _coreClient ??= proto.MiruCoreServiceClient(channel);
  static app_setting.AppSettingServiceClient get appSettingClient =>
      _appSettingClient ??= app_setting.AppSettingServiceClient(channel);
  static ext.ExtensionServiceClient get extensionClient =>
      _extensionClient ??= ext.ExtensionServiceClient(channel);
  static repo.RepoServiceClient get repoClient =>
      _repoClient ??= repo.RepoServiceClient(channel);
  static download.DownloadServiceClient get downloadClient =>
      _downloadClient ??= download.DownloadServiceClient(channel);
  static db.DbServiceClient get dbClient =>
      _dbClient ??= db.DbServiceClient(channel);
  static network.NetworkServiceClient get networkClient =>
      _networkClient ??= network.NetworkServiceClient(channel);
  static events.EventServiceClient get eventClient =>
      _eventClient ??= events.EventServiceClient(channel);

  // For backward compatibility during refactoring
  static proto.MiruCoreServiceClient get client => coreClient;
}
