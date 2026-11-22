import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/backend_connection_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/provider/shell/shell_ui_provider.dart';
import 'package:miru_alpha/ui/features/main_page.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:widgetbook/widgetbook.dart';

/// Mirrors test/ui/features/main_page_test.dart states for the catalog.
///
/// The harness replicates the test's pump: seeded settings cache, the three
/// provider overrides (resolving backend gate, stub app controller, empty
/// favorites) and a single-route GoRouter, at the test's desktop window
/// surfaces (1300x800 / 1040x680). i18n renders raw keys — the bare-harness
/// regime (no localizations delegates, detached root navigator key).
///
/// skipped: zh-locale fresh-start remount — behavior (the gate's appearance
/// reload flips MaterialApp's language key and remounts the app while the
/// dialog flow is in flight); needs the delegates the catalog never loads.
/// The dialog state itself is mirrored below.
/// skipped: pick closes the dialog — the select button fires the real
/// file_picker platform channel, and file_picker is not declared in the
/// workspace pubspec so it cannot be faked here.
/// skipped: sidebarIndexForLocation / headerShowsFormatPills / grid
/// columnsFor — pure functions, no visual state; the shell surfaces show
/// what they shape.
/// skipped: Ctrl+B / Ctrl+K / header-toggle collapse-restore cycles —
/// keyboard + tap behavior; the collapsed-rail and open-overlay use-cases
/// are their end states.
class _DesktopFrame extends StatelessWidget {
  const _DesktopFrame({required this.surface, required this.child});

  /// Mirrors the test's `tester.view.physicalSize` (dpr 1.0).
  final Size surface;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: surface.width,
        height: surface.height,
        child: ColoredBox(
          color: context.theme.colors.background,
          child: ClipRect(child: child),
        ),
      ),
    );
  }
}

/// The test's stub: fixed dark-neutral appearance state.
class _StubController extends ApplicationController {
  @override
  ApplicationState build() => ApplicationState(
    themeText: 'dark',
    baseColor: 'zinc',
    primaryColor: 'none',
    themeData: MiruThemes.neutral.light.desktop,
    themeMode: ThemeMode.dark,
    language: 'en',
  );
}

/// Resolves like the test's fake: the gate settles and the appearance
/// reload runs against the seeded settings cache (no zh remount here).
class _FakeBackendConnection extends BackendConnection {
  @override
  Future<void> build() async {
    await Future<void>.value();
    ref.read(applicationControllerProvider.notifier).reloadFromSettings();
  }
}

/// The sidebar reads the favorites count; keep the DB-backed init off with
/// an empty state, like the test.
class _FakeFavoritePageNotifier extends FavoritePageNotifier {
  @override
  FavoritePageState build() => FavoritePageState(
    favorites: const [],
    favoriteGroups: const [],
    filteredFavorites: const [],
    selectedFavoriteGroups: const [],
    selectedTypes: const {},
    filterMode: FavoriteFilterMode.or,
  );
}

/// Search overlay pre-opened — the ctrl+K test's end state.
class _OpenSearchOverlay extends SearchPageNotifier {
  @override
  SearchPageState build() => SearchPageState(
    metaData: const [],
    pinnedExtensions: const {},
    query: '',
    existedPinnedExtensions: const {},
    open: true,
  );
}

/// Collapsed 56px icon rail — the toggle / Ctrl+B end state.
class _CollapsedSidebar extends SidebarCollapsed {
  @override
  bool build() => true;
}

Widget _shellHarness({
  required Size surface,
  bool savedDownloadPath = true,
  bool collapsedSidebar = false,
  bool searchOverlayOpen = false,
}) {
  // The shell reads settings synchronously during build (theme, language,
  // download path); seed the shipped defaults the way bootstrap does.
  MiruSettings.seedDefaults();
  if (savedDownloadPath) {
    MiruSettings.setSettingSync(
      SettingKey.downloadPath,
      '/tmp/saved-directory',
    );
  }
  return _DesktopFrame(
    surface: surface,
    child: ProviderScope(
      overrides: [
        backendConnectionProvider.overrideWith(_FakeBackendConnection.new),
        applicationControllerProvider.overrideWith(_StubController.new),
        favoritePageProvider.overrideWith(_FakeFavoritePageNotifier.new),
        if (collapsedSidebar)
          sidebarCollapsedProvider.overrideWith(_CollapsedSidebar.new),
        if (searchOverlayOpen)
          searchPageProvider.overrideWith(_OpenSearchOverlay.new),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [GoRoute(path: '/', builder: (_, _) => const MainPage())],
        ),
      ),
    ),
  );
}

WidgetbookComponent buildMainPageComponent() {
  return WidgetbookComponent(
    name: 'MainPage (desktop shell)',
    useCases: [
      WidgetbookUseCase(
        name: 'Shell · download path saved (1300x800)',
        builder: (context) => _shellHarness(surface: const Size(1300, 800)),
      ),
      WidgetbookUseCase(
        name: 'Fresh start · download directory dialog',
        builder: (context) => _shellHarness(
          surface: const Size(1300, 800),
          savedDownloadPath: false,
        ),
      ),
      WidgetbookUseCase(
        name: 'Shell · tight window (1040x680)',
        builder: (context) => _shellHarness(surface: const Size(1040, 680)),
      ),
      WidgetbookUseCase(
        name: 'Sidebar · collapsed icon rail (56px)',
        builder: (context) => _shellHarness(
          surface: const Size(1300, 800),
          collapsedSidebar: true,
        ),
      ),
      WidgetbookUseCase(
        name: 'Search overlay open (Ctrl+K state)',
        builder: (context) => _shellHarness(
          surface: const Size(1300, 800),
          searchOverlayOpen: true,
        ),
      ),
    ],
  );
}
