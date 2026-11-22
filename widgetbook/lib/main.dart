import 'package:forui/forui.dart';
// Debug-only: initialize the marionette binding so the marionette CLI / MCP
// can drive AND screenshot the catalog. Must run before any other plugin
// touches WidgetsBinding (see marionette_binding.dart). Kept out of release
// builds by the dev_dependency gate.
// ignore: depend_on_referenced_packages
import 'package:marionette_flutter/marionette_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:marionette_logging/marionette_logging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:widgetbook/widgetbook.dart';

import 'catalog_image_proxy.dart';
import 'story_switcher.dart';
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
/// Written by the agent (via `scripts/wb.dart select`), read at startup and
/// on every story switch — a file rather than a Dart constant so a review
/// run can walk the stories without an edit + hot restart per state. The
/// [StorySwitcher] wrapper (story_switcher.dart) polls this file and
/// re-keys the catalog so it re-reads the route.
///
/// Empty or absent falls back to the navigation page. The path format is the
/// one `WidgetbookNode.path` builds: node names joined by `/`, lowercased,
/// spaces to dashes (`Settings` → `SettingsUpdateAlert` → `Downloading`).
///
/// ```sh
/// echo 'settings/settingsupdatealert/downloading-·-42%-+-progress-track' \
///   > /tmp/miru_wb_story
/// ```

void main() async {
  // Marionette binding first: it installs the marionette_flutter VM-service
  // extensions (elements, tap, SCREENSHOT). Must be the first WidgetsBinding
  // installed, so it runs before `ensureInitialized` touches the binding.
  // Debug-only — see the pubspec dev_dependency gate.
  MarionetteBinding.ensureInitialized(
    MarionetteConfiguration(logCollector: LoggingLogCollector()),
  );

  // `runApp` is what normally brings the binding up, and `rootBundle` needs it,
  // so the English table has to be loaded after this line and before the first
  // frame.
  WidgetsFlutterBinding.ensureInitialized();

  // The catalog registers none of the app's localizations delegates (its
  // MaterialApp is built inside the widgetbook package), so `.i18n` would
  // render raw keys. English is loaded up front and resolved without a
  // context — see I18nStatic.
  await I18nStatic.warmUp();
  // Covers in the mirrored screens load through ImageWidget → the app's core
  // proxy. No core runs here, so a loopback stand-in serves the picsum
  // placeholders those stories point at (see catalog_image_proxy.dart).
  await ensureCatalogImageProxy();
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
    // StorySwitcher wraps the whole catalog: it polls /tmp/miru_wb_story and
    // re-keys the widgetbook (re-reading initialRoute) whenever the agent
    // selects a new story — no relaunch, no sidebar tapping. See
    // story_switcher.dart.
    return StorySwitcher(builder: (storyPath) => _catalog(storyPath));
  }

  Widget _catalog(String storyPath) {
    return Widgetbook.material(
      initialRoute: storyPath.isNotEmpty
          // Built through Uri, not string-concatenated: node names carry the
          // catalog's `·` separator, `%` and `+`, which would otherwise
          // truncate the query.
          ? Uri(path: '/', queryParameters: {'path': storyPath}).toString()
          : '/',
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
          // Pin the initial theme to LIGHT (the first entry) so every story
          // renders consistently light by default — the widgetbook was
          // defaulting to dark, which made phone stories look dark and
          // diverged from the real app (light). Dark stays a toggle.
          initialTheme: miruThemeEntries().first,
          themeBuilder: (context, theme, child) =>
              FTheme(data: theme, child: child),
        ),
      ],
      // TreeDumper sits inside WidgetbookState (via home) so the agent can
      // `list` every story path from /tmp/miru_wb_tree.json.
      home: const TreeDumper(child: SizedBox.shrink()),
    );
  }
}
