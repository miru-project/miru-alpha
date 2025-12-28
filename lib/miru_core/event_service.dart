import 'dart:async';
import 'package:miru_app_new/miru_core/grpc_client.dart';
import 'package:miru_app_new/miru_core/proto/miru_core_service.pbgrpc.dart'
    as proto;
import 'package:miru_app_new/utils/core/log.dart';

class MiruEventService {
  static final MiruEventService _instance = MiruEventService._internal();
  factory MiruEventService() => _instance;
  MiruEventService._internal();

  StreamSubscription<proto.WatchEventsResponse>? _subscription;
  final _downloadController =
      StreamController<Map<int, proto.DownloadProgress>>.broadcast();
  final _extensionController =
      StreamController<List<proto.ExtensionMeta>>.broadcast();

  Stream<Map<int, proto.DownloadProgress>> get downloadStream =>
      _downloadController.stream;
  Stream<List<proto.ExtensionMeta>> get extensionStream =>
      _extensionController.stream;

  Future<void> start() async {
    _subscription?.cancel();

    // Fetch initial state
    try {
      final hello = await MiruGrpcClient.client.helloMiru(
        proto.HelloMiruRequest(),
      );
      if (hello.downloadStatus.isNotEmpty) {
        _downloadController.add(hello.downloadStatus);
      }
      if (hello.extensionMeta.isNotEmpty) {
        _extensionController.add(hello.extensionMeta);
      }
    } catch (e) {
      logger.warning('Failed to fetch initial state: $e');
    }

    _subscription = MiruGrpcClient.client
        .watchEvents(proto.WatchEventsRequest())
        .listen(
          (event) {
            if (event.hasDownloadEvent()) {
              _downloadController.add(event.downloadEvent.downloadStatus);
            } else if (event.hasExtensionEvent()) {
              _extensionController.add(event.extensionEvent.extensionMeta);
            }
          },
          onError: (e) {
            logger.severe('Event stream error: $e');
            // Retry after delay
            Future.delayed(const Duration(seconds: 5), start);
          },
          onDone: () {
            logger.info('Event stream closed, reconnecting...');
            Future.delayed(const Duration(seconds: 5), start);
          },
          cancelOnError: true,
        );
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }
}

final miruEventService = MiruEventService();
