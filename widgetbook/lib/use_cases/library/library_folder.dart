/// Mirrors test/ui/features/detail + download + extension + favorite +
/// history widget tests for the catalog — one component per widget under
/// test, one use-case per visual state each test pumps.
library;

import 'package:widgetbook/widgetbook.dart';

import 'desktop_download_page.dart';
import 'detail_loading_skeleton.dart';
import 'detail_skeleton_parity.dart';
import 'detail_tag_chips.dart';
import 'download_history_page.dart';
import 'download_view_widget.dart';
import 'extension_store_header.dart';
import 'extension_store_i18n.dart';
import 'extension_text_cover.dart';
import 'favorite_view_widget.dart';
import 'history_view_widget.dart';
import 'mobile_detail_cards.dart';
import 'mobile_detail_selectable.dart';
import 'mobile_download_view_widget.dart';

WidgetbookFolder buildLibraryMirroredFolder() {
  return WidgetbookFolder(
    name: 'Detail & library (mirrored)',
    children: [
      buildDetailLoadingSkeletonComponent(),
      buildDetailSkeletonParityComponent(),
      buildDetailTagChipsComponent(),
      ...buildMobileDetailCardComponents(),
      ...buildMobileDetailSelectableComponents(),
      buildDesktopDownloadPageComponent(),
      buildDesktopFinishedDownloadComponent(),
      buildDownloadHistoryPageComponent(),
      buildDownloadViewComponent(),
      buildMobileDownloadViewComponent(),
      // Both extension store files test the same widget: one component, the
      // header states first, then the i18n canary's states.
      WidgetbookComponent(
        name: 'ExtensionListView',
        useCases: [
          ...extensionStoreHeaderUseCases(),
          ...extensionStoreI18nUseCases(),
        ],
      ),
      buildTextCoverComponent(),
      buildFavoriteViewComponent(),
      buildHistoryViewComponent(),
    ],
  );
}
