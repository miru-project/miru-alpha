import 'package:grpc/grpc.dart';
import 'package:miru_app_new/miru_core/core.dart';
import 'package:miru_app_new/miru_core/proto/proto.dart';

class MiruGrpcClient {
  static ClientChannel? _channel;

  static MiruCoreServiceClient? _coreClient;
  static AppSettingServiceClient? _appSettingClient;
  static ExtensionServiceClient? _extensionClient;
  static RepoServiceClient? _repoClient;
  static DownloadServiceClient? _downloadClient;
  static DbServiceClient? _dbClient;
  static NetworkServiceClient? _networkClient;
  static EventServiceClient? _eventClient;

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

  static MiruCoreServiceClient get coreClient =>
      _coreClient ??= MiruCoreServiceClient(channel);
  static AppSettingServiceClient get appSettingClient =>
      _appSettingClient ??= AppSettingServiceClient(channel);
  static ExtensionServiceClient get extensionClient =>
      _extensionClient ??= ExtensionServiceClient(channel);
  static RepoServiceClient get repoClient =>
      _repoClient ??= RepoServiceClient(channel);
  static DownloadServiceClient get downloadClient =>
      _downloadClient ??= DownloadServiceClient(channel);
  static DbServiceClient get dbClient => _dbClient ??= DbServiceClient(channel);
  static NetworkServiceClient get networkClient =>
      _networkClient ??= NetworkServiceClient(channel);
  static EventServiceClient get eventClient =>
      _eventClient ??= EventServiceClient(channel);

  // For backward compatibility during refactoring
  static MiruCoreServiceClient get client => coreClient;
}
