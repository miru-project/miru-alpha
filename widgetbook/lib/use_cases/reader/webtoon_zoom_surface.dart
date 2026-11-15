import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/core/scrollable_position_list/scrollable_positioned_list.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/webtoon_zoom_surface.dart';
import 'package:widgetbook/widgetbook.dart';

import '../use_case_harness.dart';

/// Mirrors test/ui/features/watch/webtoon_zoom_surface_test.dart states for
/// the catalog.
///
/// One representative rendered state, as for the paged surface: the strip at
/// 1x over fresh controllers, exactly as the test's `subject()` builds it
/// (10 pages, maxScale 4). The pinch, two-finger pan, paint-only zoom, flick
/// coasting and double-tap toggle are gesture behaviour the tests pin; the
/// 60-item long-strip variant exists only to keep a coast from hitting the
/// list's end while it is measured.

WidgetbookComponent buildWebtoonZoomSurfaceComponent() {
  return WidgetbookComponent(
    name: 'WebtoonZoomSurface',
    useCases: [
      WidgetbookUseCase(
        name: 'Strip at 1x — 10 pages (pinch or double-tap zooms)',
        builder: (context) => catalogFrame(
          SizedBox(
            width: 400,
            height: 600,
            child: WebtoonZoomSurface(
              itemCount: 10,
              itemPositionsListener: ItemPositionsListener.create(),
              scrollOffsetController: ScrollOffsetController(),
              scrollOffsetListener: ScrollOffsetListener.create(),
              itemScrollController: ItemScrollController(),
              itemBuilder: (context, index) =>
                  SizedBox(height: 400, child: Text('page $index')),
            ),
          ),
        ),
      ),
    ],
  );
}
