import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/core/core/image_widget.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/manag_image.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

/// A valid 1x1 PNG, repeated so the body is a few KB and the stream carries
/// more than one chunk.
final Uint8List _pngBytes = () {
  const onePixel =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
  final single = base64Decode(onePixel);
  return Uint8List.fromList([for (var i = 0; i < 40; i++) ...single]);
}();

/// extended_image's disk cache resolves [getTemporaryDirectory] through the
/// path_provider plugin, which has no implementation under the test binding —
/// without this the load dies on a MissingPluginException before any byte
/// arrives. Pointed at a real temp dir so the cache writes under runAsync.
///
/// The temp dir itself must be created under [tester.runAsync]: inside a
/// `testWidgets` body the FakeAsync zone never delivers real dart:io
/// completions, and an unwrapped `await Directory.createTemp` deadlocks there.
Future<void> _mockPathProvider(WidgetTester tester) async {
  final dir = (await tester.runAsync(
    () => Directory.systemTemp.createTemp('miru-image-cache-test'),
  ))!;
  addTearDown(() => dir.delete(recursive: true).ignore());
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => dir.path);
  addTearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );
}

Widget _wrap(Widget child) => FTheme(
  data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
  child: MaterialApp(home: Scaffold(body: child)),
);

/// Zone-scoped HttpOverrides handing the image provider an HttpClient whose
/// responses stream the PNG body in two chunks.
///
/// A real socket is not an option here: flutter_test installs a 400-mocking
/// HttpOverrides.global (a PROCESS-global, not zone-scoped — it intercepts
/// every HttpClient() even inside runAsync), and a raw socket connect never
/// completes inside a testWidgets body either. The fake client is what
/// flutter_test's own warning prescribes, and it drives the exact production
/// chunk-event path: ExtendedImage.network -> consolidateHttpClientResponseBytes
/// -> ImageChunkEvent -> ExtendedImageState.loadingProgress -> the builder.
class _ChunkedPngHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

class _FakeHttpClient implements HttpClient {
  @override
  bool autoUncompress = false;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _pngBytes.length;

  // consolidateHttpClientResponseBytes nulls the expected total for a
  // decompressed response — this is exactly what makes the progress real.
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    // The second half rides a real timer: a fully synchronous stream would
    // finish the load inside pumpWidget's first microtask flush, and no pump
    // would ever see the intermediate 50% state.
    final controller = StreamController<List<int>>();
    controller.add(_pngBytes.sublist(0, _pngBytes.length ~/ 2));
    Future<void>.delayed(const Duration(milliseconds: 50), () {
      controller.add(_pngBytes.sublist(_pngBytes.length ~/ 2));
      controller.close();
    });
    return controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('the loading placeholder takes the page 2:3 shape', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const SizedBox.expand(child: MobileMangaLoading())),
    );

    final box = tester.getSize(find.byType(AspectRatio));
    // 400x800 surface: the width is capped, so the box is 400x600.
    expect(box.width, 400);
    expect(box.height, 600);
    expect(find.byType(FCircularProgress), findsOneWidget);
  });

  testWidgets('a known progress shows the real percent and bar fill', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const SizedBox.expand(child: MobileMangaLoading(progress: 0.42))),
    );

    expect(find.text('42%'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is FractionallySizedBox &&
            widget.widthFactor != null &&
            (widget.widthFactor! - 0.42).abs() < 0.0001,
      ),
      findsOneWidget,
    );
    // A real value replaces the spinner.
    expect(find.byType(FCircularProgress), findsNothing);
  });

  testWidgets('an unknown total keeps the indeterminate spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const SizedBox.expand(child: MobileMangaLoading())),
    );

    expect(find.byType(FCircularProgress), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
  });

  testWidgets('ImageWidget feeds the builder real download progress', (
    tester,
  ) async {
    await _mockPathProvider(tester);
    final received = <double?>[];

    // ImageWidget routes through MiruRequest's proxy base; keeping the URL
    // production-shaped proves proxyUrl() feeds ExtendedImage.network.
    MiruRequest.ensureInitalized(host: 'http://core.test');

    // runAsync is required for the load's file I/O (the extended_image disk
    // cache): outside it the FakeAsync zone never delivers dart:io
    // completions. The chunk events themselves flow through the fake client
    // scoped by _ChunkedPngHttpOverrides; the interleaved pumps flush their
    // setStates into the builder.
    await tester.runAsync(
      () => HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(
          _wrap(
            SizedBox(
              width: 300,
              height: 450,
              child: ImageWidget(
                imageUrl:
                    'http://origin.test/page-${DateTime.now().microsecondsSinceEpoch}.jpg',
                loadingProgressBuilder: (progress) {
                  received.add(progress);
                  return MobileMangaLoading(progress: progress);
                },
              ),
            ),
          ),
        );
        for (var i = 0; i < 8; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await tester.pump();
        }
      }, _ChunkedPngHttpOverrides()),
    );

    expect(received, isNotEmpty);
    expect(received.whereType<double>(), everyElement(inInclusiveRange(0, 1)));
    // The fake response declares Content-Length = whole body and streams half
    // of it before the rest, so the builder must see that REAL fraction —
    // cumulative bytes / expected total — not a made-up number. The first
    // entry is null: the initial loading build runs before any chunk event,
    // and that frame keeps the indeterminate spinner.
    expect(received.first, isNull);
    expect(received.whereType<double>(), contains(0.5));
    // There is deliberately no `last == 1.0` here: the final chunk event and
    // the load-completed transition are both setStates on the same state, and
    // whichever lands last wins the next build — with a fast decode the
    // completed frame replaces the 100% loading frame, in this test and in
    // production alike. A slow image shows its percentages; a fast one skips
    // straight to the artwork.
  });
}
