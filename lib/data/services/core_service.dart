import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart';

class CoreService {
  Future<bool> isServerHealthy() async {
    try {
      await MiruGrpcClient.coreClient.helloMiru(HelloMiruRequest());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> getVersion() async {
    try {
      await MiruGrpcClient.coreClient.helloMiru(HelloMiruRequest());
      return '';
    } catch (e) {
      return '';
    }
  }
}
