import 'package:grpc/grpc.dart';
import 'package:miru_app_new/miru_core/core.dart';
import 'package:miru_app_new/miru_core/proto/miru_core_service.pbgrpc.dart';

class MiruGrpcClient {
  static MiruCoreServiceClient? _client;
  static ClientChannel? _channel;

  static MiruCoreServiceClient get client {
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
    _client = MiruCoreServiceClient(_channel!);
  }

  static Future<void> terminate() async {
    await _channel?.terminate();
    _client = null;
    _channel = null;
  }
}
