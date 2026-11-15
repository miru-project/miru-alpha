import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_zoom_surface.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// Mirrors test/ui/features/watch/reader_zoom_surface_test.dart states for
/// the catalog.
///
/// The surface's gesture physics — pinch magnify, 1:1 pan, coast, edge
/// clamping, double-tap toggle and tap disambiguation — are behaviour the
/// tests pin, not rendered states, so one representative resting state is
/// mirrored here: the scrollable list at 1x with the double-tap zoom armed
/// (2.5x), as the test's `subject()` builds it. The page items are the
/// suite's fake pages; the tests pump blank harness boxes because they assert
/// transforms, not pixels.

WidgetbookComponent buildReaderZoomSurfaceComponent() {
  return WidgetbookComponent(
    name: 'ReaderZoomSurface',
    useCases: [
      WidgetbookUseCase(
        name: 'Resting at 1x — list keeps its drag (double-tap zooms)',
        builder: (context) => catalogFrame(
          SizedBox(
            width: 400,
            height: 600,
            child: ReaderZoomSurface(
              builder: (context, zoom) => zoom.wrap(
                ListView(
                  children: [
                    for (var i = 0; i < 8; i++)
                      SizedBox(height: 400, child: Text('page $i')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
