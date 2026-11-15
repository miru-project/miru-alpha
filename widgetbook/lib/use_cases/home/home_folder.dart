import 'package:widgetbook/widgetbook.dart';

import 'home_banner.dart';
import 'home_banner_skeleton.dart';
import 'home_dashboard.dart';
import 'home_desktop_dashboard.dart';
import 'home_view.dart';

/// The mirrored folder for `test/ui/features/home/*`: one component per
/// widget under test (banner, skeleton parity, mobile bento, desktop
/// dashboard, HomeView shell), each use-case a state the widget tests pump.
WidgetbookFolder buildHomeMirroredFolder() {
  return WidgetbookFolder(
    name: 'Home (mirrored)',
    children: [
      buildHomeBannerComponent(),
      buildHomeBannerSkeletonComponent(),
      buildHomeMobileBentoComponent(),
      buildHomeDesktopDashboardComponent(),
      buildHomeViewComponent(),
    ],
  );
}
