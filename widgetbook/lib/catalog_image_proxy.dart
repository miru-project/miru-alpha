import 'dart:async';
import 'dart:io';

import 'package:miru_alpha/utils/http/request.dart';

/// Loopback proxy that lets mirrored screens render real cover images (picsum)
/// without a running Miru core.
///
/// [ImageWidget] never loads a URL directly — it always goes through
/// `MiruRequest.proxyUrl`, the app's core proxy (`{host}/proxy/{encodedUrl}`).
/// The catalog has no core, so this server plays that role: it decodes the
/// original URL back out of the request path and streams the bytes when the
/// response is an image.
///
/// Non-image responses (the reader stories' `example.com` fixtures) are left
/// unanswered on purpose: those stories assert a *loading* placeholder, and a
/// real fetch of `example.com` returns HTML, which would flip them to an error
/// child. Holding the request open keeps their loading state intact.
///
/// Idempotent and process-global: [MiruRequest] keeps its base URL in a
/// `late final`, so the first caller wins and every later story reuses it.
/// Call once from `main()` before `runApp`.
HttpServer? _server;

/// Binds the loopback proxy and points [MiruRequest] at it. Safe to call more
/// than once — later calls are no-ops.
Future<void> ensureCatalogImageProxy() async {
  if (_server != null) return;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  _server = server;
  server.listen(_serve);
  MiruRequest.ensureInitalized(host: 'http://127.0.0.1:${server.port}');
}

Future<void> _serve(HttpRequest request) async {
  // `request.uri.path` is percent-decoded, so a request for
  // `/proxy/https%3A%2F%2Fpicsum.photos%2F200%2F300` arrives here as
  // `/proxy/https://picsum.photos/200/300` — everything after the prefix is
  // the original URL.
  const prefix = '/proxy/';
  final path = request.uri.path;
  var raw = path.startsWith(prefix) ? path.substring(prefix.length) : '';
  if (raw.contains('%')) raw = Uri.decodeComponent(raw);
  final target = Uri.tryParse(raw);
  if (target == null || !target.hasScheme) {
    request.response.statusCode = HttpStatus.badRequest;
    await request.response.close();
    return;
  }

  final client = HttpClient();
  try {
    final upstream = await client.getUrl(target).then((req) => req.close());
    final contentType = upstream.headers.contentType?.mimeType ?? '';
    if (!contentType.startsWith('image/')) {
      // Deliberately never respond: leave image-loading stories in their
      // loading state rather than flipping them to an error child.
      await Completer<void>().future;
      return;
    }
    final bytes = await upstream.fold<List<int>>(
      <int>[],
      (buffer, chunk) => buffer..addAll(chunk),
    );
    request.response
      ..statusCode = upstream.statusCode
      ..headers.contentType = ContentType.parse(contentType)
      ..add(bytes);
    await request.response.close();
  } catch (_) {
    request.response.statusCode = HttpStatus.badGateway;
    await request.response.close();
  } finally {
    client.close(force: true);
  }
}
