import 'dart:io';

import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:widgetbook/widgetbook.dart';

import 'use_cases/core/components.dart';
import 'use_cases/core_tests/core_tests_folder.dart';
import 'use_cases/home/home_folder.dart';
import 'use_cases/library/library_folder.dart';
import 'use_cases/prototyping/prototyping_folder.dart';
import 'use_cases/reader/reader_folder.dart';
import 'use_cases/search/search_folder.dart';
import 'use_cases/settings/settings_folder.dart';
import 'use_cases/watch_page/watch_page_folder.dart';

/// The use case the catalog opens on.
///
/// Written by the screenshot pass, read at startup — a file rather than a
/// Dart constant so a review run can walk the stories without an edit + hot
/// restart per state:
///
/// ```sh
/// echo 'settings/settingsupdatealert/downloading-·-42%-+-progress-track' \
///   > /tmp/miru_wb_story
/// ```
///
/// Empty or absent falls back to the navigation page. The path format is the
/// one `WidgetbookNode.path` builds: node names joined by `/`, lowercased,
/// spaces to dashes (`Settings` → `SettingsUpdateAlert` → `Downloading`).
const String _storyFile = '/tmp/miru_wb_story';

String _initialRoute() {
  try {
    final story = File(_storyFile).readAsStringSync().trim();
    // Built through Uri, not string-concatenated: node names carry the catalog's
    // `·` separator, `%` and `+`, which would otherwise truncate the query.
    if (story.isNotEmpty) {
      return Uri(path: '/', queryParameters: {'path': story}).toString();
    }
  } catch (_) {
    // No file yet — a normal first run.
  }
  return '/';
}

void main() async {
  // `runApp` is what normally brings the binding up, and `rootBundle` needs it,
  // so the English table has to be loaded after this line and before the first
  // frame.
  WidgetsFlutterBinding.ensureInitialized();

  // The catalog registers none of the app's localizations delegates (its
  // MaterialApp is built inside the widgetbook package), so `.i18n` would
  // render raw keys. English is loaded up front and resolved without a
  // context — see I18nStatic.
  await I18nStatic.warmUp();
  runApp(const DesignSystemCatalog());
}

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
      initialRoute: _initialRoute(),
      directories: [
        buildDesignSystemFolder(),
        buildCoreMirroredFolder(),
        buildHomeMirroredFolder(),
        buildSearchMirroredFolder(),
        buildSettingsFolder(),
        buildWatchMirroredFolder(),
        buildReaderMirroredFolder(),
        buildLibraryMirroredFolder(),
        buildPrototypingFolder(),
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
