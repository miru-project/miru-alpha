import 'package:widgetbook/widgetbook.dart';

import 'anilist_logo.dart';
import 'backend_connection_title.dart';
import 'forui_refresh_indicator.dart';
import 'main_page.dart';
import 'miru_expandable_tabs.dart';
import 'morph_icon.dart';
import 'toast.dart';

/// The mirrored-from-tests folder for `test/ui/core/**` plus
/// `test/ui/features/main_page_test.dart` — one component per widget under
/// test, one use-case per visual state the tests pump. The tests stay the
/// assertion gate; this folder is their browsable mirror.
WidgetbookFolder buildCoreMirroredFolder() {
  return WidgetbookFolder(
    name: 'Core (mirrored)',
    children: [
      buildAnilistLogoComponent(),
      buildBackendConnectionTitleComponent(),
      buildForuiRefreshIndicatorComponent(),
      buildMiruExpandableTabsComponent(),
      buildMorphIconComponent(),
      buildToastComponent(),
      buildMainPageComponent(),
    ],
  );
}
