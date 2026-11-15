import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import 'use_cases/core/components.dart';
import 'use_cases/core_tests/core_tests_folder.dart';
import 'use_cases/home/home_folder.dart';
import 'use_cases/library/library_folder.dart';
import 'use_cases/reader/reader_folder.dart';
import 'use_cases/search/search_folder.dart';
import 'use_cases/watch_page/watch_page_folder.dart';

void main() => runApp(const DesignSystemCatalog());

/// Miru's component catalog (Widgetbook workspace app).
///
/// A separate Flutter app depending on miru_alpha via a path dependency —
/// the root app's dependency graph (and therefore its release binaries)
/// never see widgetbook. Launch is human-owned like the main app
/// (rules.md #25): `cd widgetbook && flutter run -d linux`.
///
/// Folder layout: `Design system` holds the hand-curated primitive demos;
/// the mirrored folders (one per area of `test/ui/`) render the same widget
/// states the widget tests exercise — the tests stay the assertion gate,
/// the catalog is their browsable mirror (design.md §7).
class DesignSystemCatalog extends StatelessWidget {
  const DesignSystemCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        buildDesignSystemFolder(),
        buildCoreMirroredFolder(),
        buildHomeMirroredFolder(),
        buildSearchMirroredFolder(),
        buildWatchMirroredFolder(),
        buildReaderMirroredFolder(),
        buildLibraryMirroredFolder(),
      ],
      addons: [
        ViewportAddon(Viewports.all),
        AlignmentAddon(),
        ThemeAddon<FThemeData>(
          themes: miruThemeEntries(),
          themeBuilder: (context, theme, child) =>
              FTheme(data: theme, child: child),
        ),
      ],
    );
  }
}
