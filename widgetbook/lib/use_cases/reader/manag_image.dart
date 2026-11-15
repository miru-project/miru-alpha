import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/core/core/image_widget.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/manag_image.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// Mirrors test/ui/features/watch/manag_image_test.dart states for the
/// catalog.
///
/// Skipped: the chunked-download integration ('ImageWidget feeds the builder
/// real download progress') — it needs the test's fake HttpClient streaming a
/// PNG body through HttpOverrides. With no live endpoint the catalog renders
/// the widget's first loading frame, which is the same placeholder the
/// MobileMangaLoading use-cases show; the 50% frame is the determinate
/// use-case's ring.

/// The tests point the image proxy at a port nothing listens on, so the load
/// never completes inside the test's FakeAsync zone. The catalog runs a real
/// event loop, where a closed port fails instantly — so the mirror points at
/// a non-routable black hole instead: the request never completes and the
/// loading state the tests pump stays on screen. No request reaches a real
/// site either way.
void _ensureProxyFixture() {
  try {
    MiruRequest.proxyUrl('https://example.com/p1.png');
  } on Error {
    MiruRequest.ensureInitalized(host: 'http://10.255.255.1:9');
  }
}

WidgetbookComponent buildMobileMangaLoadingComponent() {
  return WidgetbookComponent(
    name: 'MobileMangaLoading',
    useCases: [
      WidgetbookUseCase(
        name: 'Indeterminate spinner in a 2:3 page slot',
        builder: (context) => catalogFrame(
          const SizedBox(width: 300, height: 450, child: MobileMangaLoading()),
        ),
      ),
      WidgetbookUseCase(
        name: 'Determinate ring at 42%',
        builder: (context) => catalogFrame(
          const SizedBox(
            width: 300,
            height: 450,
            child: MobileMangaLoading(progress: 0.42),
          ),
        ),
      ),
    ],
  );
}

WidgetbookComponent buildImageWidgetComponent() {
  return WidgetbookComponent(
    name: 'ImageWidget',
    useCases: [
      WidgetbookUseCase(
        name: 'Loading placeholder (live progress builder)',
        builder: (context) {
          _ensureProxyFixture();
          return catalogFrame(
            SizedBox(
              width: 300,
              height: 450,
              child: ImageWidget(
                imageUrl: 'http://origin.test/page.jpg',
                loadingProgressBuilder: (progress) =>
                    MobileMangaLoading(progress: progress),
              ),
            ),
          );
        },
      ),
    ],
  );
}
