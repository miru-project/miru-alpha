import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:miru_alpha/utils/core/log.dart';

/// Recovers isolates a debugger left paused at start.
///
/// IDE-launched debug sessions run the VM with the `pause_isolates_on_start`
/// flag set. Isolates spawned AFTER the debugger's initial resume also start
/// paused (`PauseStart`) and nothing resumes them for the rest of the
/// session: the miru core isolate then never runs, the Go runtime never
/// boots, and every gRPC call fails with connection refused. dart:isolate
/// cannot clear a service-level pause — a spawner-side
/// `Isolate.resume(pauseCapability)` does not unstick one (verified against
/// the VM) — so the only recovery is the service protocol `resume` call this
/// helper issues against the app's own VM service.
class VmServiceRescue {
  VmServiceRescue._();

  /// Resumes every isolate whose pause event is `PauseStart`, optionally
  /// restricted to those whose name contains [nameContains]. Returns how many
  /// isolates were resumed; 0 also covers "no VM service exposed" (release
  /// builds, where the pause cannot occur) and any transport failure — this
  /// is a best-effort rescue, never a throwing path.
  static Future<int> resumePausedIsolates({String? nameContains}) async {
    WebSocket? ws;
    try {
      final uri = (await developer.Service.getInfo()).serverWebSocketUri;
      if (uri == null) {
        logger.fine('No VM service exposed, pause rescue unavailable');
        return 0;
      }
      ws = await WebSocket.connect(
        uri.toString(),
      ).timeout(const Duration(seconds: 5));
      final responses = <int, Map<String, dynamic>>{};
      var nextId = 0;
      ws.listen((data) {
        final message = jsonDecode(data as String) as Map<String, dynamic>;
        if (message['id'] is int) {
          responses[message['id'] as int] = message;
        }
      });

      Future<Map<String, dynamic>> call(
        String method, [
        Map<String, dynamic>? params,
      ]) async {
        final callId = ++nextId;
        ws!.add(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': callId,
            'method': method,
            'params': params ?? const {},
          }),
        );
        final deadline = DateTime.now().add(const Duration(seconds: 5));
        while (!responses.containsKey(callId)) {
          if (DateTime.now().isAfter(deadline)) {
            throw TimeoutException('VM service $method timed out');
          }
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        final response = responses.remove(callId)!;
        if (response.containsKey('error')) {
          throw Exception('VM service $method error: ${response['error']}');
        }
        return response;
      }

      final vm = await call('getVM');
      final isolates = vm['result']?['isolates'] as List? ?? const [];
      var resumed = 0;
      for (final entry in isolates) {
        final isolateId = entry['id'] as String?;
        final name = entry['name'] as String? ?? '';
        if (isolateId == null) continue;
        if (nameContains != null && !name.contains(nameContains)) continue;
        final info = await call('getIsolate', {'isolateId': isolateId});
        final pauseEvent = info['result']?['pauseEvent'];
        if (pauseEvent is! Map<String, dynamic>) continue;
        if (pauseEvent['kind'] != 'PauseStart') continue;
        await call('resume', {'isolateId': isolateId});
        resumed += 1;
        logger.info('Resumed debugger-paused isolate "$name" ($isolateId)');
      }
      return resumed;
    } catch (error) {
      logger.warning('VM service pause rescue failed: $error');
      return 0;
    } finally {
      unawaited(ws?.close());
    }
  }
}
