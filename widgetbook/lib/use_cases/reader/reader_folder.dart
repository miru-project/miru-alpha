import 'package:widgetbook/widgetbook.dart';

import 'manga_reader_hud.dart';
import 'manga_reader_sheets.dart';
import 'manag_image.dart';
import 'novel_reading_view.dart';
import 'reader_zoom_surface.dart';
import 'webtoon_zoom_surface.dart';

/// Mirrored use-cases for `test/ui/features/watch` — the manga / webtoon /
/// novel reader area: one component per widget under test, one use-case per
/// visual state its widget tests pump.
WidgetbookFolder buildReaderMirroredFolder() {
  return WidgetbookFolder(
    name: 'Reader (mirrored)',
    children: [
      buildMangaReaderComponent(),
      buildReaderSettingsSheetComponent(),
      buildChapterDrawerComponent(),
      buildReaderZoomSurfaceComponent(),
      buildWebtoonZoomSurfaceComponent(),
      buildNovelReadingViewComponent(),
      buildMobileMangaLoadingComponent(),
      buildImageWidgetComponent(),
    ],
  );
}
