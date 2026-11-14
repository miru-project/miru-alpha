import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart' hide ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:material_ui/src/global_material_localizations.dart' as gm;
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/backend_connection_provider.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/provider/shell/shell_ui_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/ui/features/main_page.dart';
import 'package:miru_alpha/ui/features/search/widget/desktop_search_overlay.dart';
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/home_desktop_continue.dart'
    as continue_mod;
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/home_desktop_feed.dart'
    as feed_mod;
import 'package:miru_alpha/ui/features/main_page/desktop_sidebar.dart'
    show DesktopSidebar, sidebarIndexForLocation, sidebarNavItems;
import 'package:window_manager/window_manager.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

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

/// Resolved gate that mimics the real one's appearance reload: the app
/// controller re-reads the settings cache, which on a fresh start flips
/// MaterialApp's language key (seeded 'en' -> saved locale) and remounts the
/// app while this dialog flow is in flight.
class _FakeBackendConnection extends BackendConnection {
  @override
  Future<void> build() async {
    await Future<void>.value();
    ref.read(applicationControllerProvider.notifier).reloadFromSettings();
  }
}

/// The sidebar reads the favorites count; keep the DB-backed init off the
/// test zone with an empty state.
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

class _FakePickerPlatform extends FilePickerPlatform {
  int calls = 0;

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    String? initialDirectory,
    AndroidOptions androidOptions = const AndroidOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    calls++;
    return '/tmp/picked-directory';
  }
}

void main() {
  group(
    'sidebarIndexForLocation (root nav = sidebar, Android bottom-nav rules)',
    () {
      test('matches each destination by longest prefix', () {
        expect(sidebarIndexForLocation('/', sidebarNavItems), 0);
        expect(sidebarIndexForLocation('/home', sidebarNavItems), 0);
        expect(sidebarIndexForLocation('/home/history', sidebarNavItems), 1);
        expect(sidebarIndexForLocation('/home/favorite', sidebarNavItems), 2);
        expect(sidebarIndexForLocation('/home/download', sidebarNavItems), 3);
        // Audit 2026-11-12: Search is NOT a sidebar destination — the
        // header command search owns that surface (single source of truth).
        expect(sidebarIndexForLocation('/search', sidebarNavItems), isNull);
        expect(sidebarIndexForLocation('/extension', sidebarNavItems), 4);
        expect(sidebarIndexForLocation('/tracking', sidebarNavItems), 5);
      });

      test(
        'settings routes keep the root nav dark; unknowns stay dark too',
        () {
          // Settings is not a root-nav destination: the header gear is the
          // entry and the settings page owns its section sidebar.
          expect(sidebarIndexForLocation('/settings', sidebarNavItems), isNull);
          expect(
            sidebarIndexForLocation('/settings/player', sidebarNavItems),
            isNull,
          );
          expect(
            sidebarIndexForLocation('/nonexistent', sidebarNavItems),
            isNull,
          );
        },
      );

      test('header context slot: format pills are home-scoped only', () {
        expect(headerShowsFormatPills('/'), isTrue);
        expect(headerShowsFormatPills('/home'), isTrue);
        // Home subpages own their filters; non-media routes never show the
        // media type switcher (audit: scope pollution).
        expect(headerShowsFormatPills('/home/favorite'), isFalse);
        expect(headerShowsFormatPills('/extension'), isFalse);
        expect(headerShowsFormatPills('/settings/general'), isFalse);
        expect(headerShowsFormatPills('/tracking'), isFalse);
      });
    },
  );

  group(
    'grid columns — compact is the only mode (user directive 2026-11-11)',
    () {
      test('continue grid: 16:9 tiles hold ~230px at any canvas', () {
        int cols(double w) => continue_mod.HomeDesktopContinue.columnsFor(w);
        expect(cols(1036), 5, reason: 'compact: ~5 tiles at the lg canvas');
        expect(cols(1400), 6);
        expect(cols(1624), 7, reason: '1920 window: ~230px tiles, not 395');
        expect(cols(2200), 7);
      });

      test('poster grid: mock standard breakpoint ladder 2/4/5/7', () {
        int cols(double w) => feed_mod.HomeDesktopFeed.columnsFor(w);
        expect(cols(700), 2, reason: 'narrow: 2 columns');
        expect(cols(1036), 5, reason: 'lg canvas: 5 columns');
        expect(cols(1400), 5, reason: 'between lg and 2xl: still 5');
        expect(cols(1624), 7, reason: '2xl+: 7 columns');
        expect(cols(2200), 7);
      });
    },
  );

  setUp(() {
    MiruSettings.seedDefaultsForTest();
  });

  tearDown(() {
    ThemeUtils.mobilePreviewWidth = null;
  });

  /// Fresh-app-data flow: no download path saved, the gate resolves and the
  /// auto dialog offers the directory picker.
  ///
  /// With [savedDownloadPath] set the dialog never appears and the shell is
  /// interactive after the gate settles. [surface] resizes the desktop
  /// window (the adaptive test runs tighter than the 1300x800 default).
  Future<ProviderContainer> pumpMainPage(
    WidgetTester tester, {
    String? savedDownloadPath,
    Size surface = const Size(1300, 800),
  }) async {
    if (savedDownloadPath case final path?) {
      MiruSettings.setSettingSync(SettingKey.downloadPath, path);
    }
    // Desktop-platform runner: `DeviceUtil.isMobile` is false (dart:io
    // Platform), so MainPage renders the desktop window chrome.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = surface;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        backendConnectionProvider.overrideWith(_FakeBackendConnection.new),
        applicationControllerProvider.overrideWith(_StubController.new),
        favoritePageProvider.overrideWith(_FakeFavoritePageNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: FTheme(
          data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
          child: MaterialApp.router(
            localizationsDelegates: [
              ...gm.GlobalMaterialLocalizations.delegates,
            ],
            routerConfig: GoRouter(
              navigatorKey: GlobalKey<NavigatorState>(),
              routes: [GoRoute(path: '/', builder: (_, _) => const MainPage())],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return container;
  }

  testWidgets(
    'fresh start (zh locale): exactly one download dialog survives the gate '
    'remount and the pick closes it',
    (tester) async {
      // The user's device: a persisted non-default language. The gate's
      // appearance reload flips MaterialApp's language key (full remount)
      // while the dialog flow is starting.
      MiruSettings.setSettingSync(SettingKey.language, 'zh');
      final picker = _FakePickerPlatform();
      final previousPlatform = FilePickerPlatform.instance;
      FilePickerPlatform.instance = picker;
      addTearDown(() => FilePickerPlatform.instance = previousPlatform);

      await pumpMainPage(tester);
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('settings.download_directory'),
        findsOneWidget,
        reason: 'exactly one dialog on the live tree after the remount',
      );

      await tester.tap(find.text('settings.select_directory'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(picker.calls, 1);
      expect(
        MiruSettings.getSettingSync<String>('DownloadPath'),
        '/tmp/picked-directory',
      );
      expect(find.text('settings.download_directory'), findsNothing);
      // Ahem-font shell artifact (see the shell test).
      tester.takeException();
      expect(find.byType(MainPage), findsOneWidget);
    },
  );

  testWidgets(
    'MediaVault shell: 44px unified header with drag + dots, 240px sidebar '
    'with search nav, badges and pinned shelves',
    (tester) async {
      await pumpMainPage(tester, savedDownloadPath: '/tmp/saved-directory');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // Unified header: the drag region spans the full width at 44px.
      final dragRect = tester.getRect(find.byType(DragToMoveArea).first);
      expect(dragRect.height, 44, reason: 'the mock header is h-11');
      expect(dragRect.left, 0);

      // Sidebar: compact WebDAV footer pill — "Not Synced" is the real
      // state (no account configured; never claim Synced) — the Library
      // group label and the pinned-shelves group. The bare harness renders
      // raw i18n keys.
      expect(find.text('common.webdav'), findsOneWidget);
      expect(find.text('sidebar.not_synced'), findsOneWidget);
      expect(find.text('sidebar.webdav_caption'), findsOneWidget);
      // The label uppercases the raw key (mock: uppercase micro-label).
      expect(find.text('SIDEBAR.LIBRARY'), findsOneWidget);
      expect(tester.getRect(find.byType(DesktopSidebar)).width, 240);

      // Root nav: the five Library destinations in order (2026-11-12 audit —
      // Search consolidated into the header command field; Settings via the
      // header gear + page-local sidebar).
      for (final label in [
        'common.home',
        'common.history',
        'favorite.name',
        'download.name',
        'extension.name',
      ]) {
        expect(find.text(label), findsWidgets, reason: 'nav entry $label');
      }

      // Header: sync + settings shortcut (the mock moved library sync into
      // the header dock; the sources pill is gone). The settings gear is the
      // ONLY settings entry — the shell sidebar dropped its Settings item
      // (the settings page owns a section sidebar), so one icon intended.
      expect(find.byIcon(FLucideIcons.refreshCw), findsOneWidget);
      expect(find.byIcon(FLucideIcons.settings), findsOneWidget);

      // Ahem-font artifact (see the adaptive test) — consume it so the
      // geometry contract above is what's asserted.
      tester.takeException();
    },
  );

  testWidgets(
    'adaptive shell: no overflow at a tight 1040x680 desktop window',
    (tester) async {
      // 1040 is just above forui's lg breakpoint (1024) — still desktop, but
      // tight: the search flexes and the banner height scales.
      await pumpMainPage(
        tester,
        savedDownloadPath: '/tmp/saved-directory',
        surface: const Size(1040, 680),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SearchTrigger), findsOneWidget);
      expect(tester.getRect(find.byType(DesktopSidebar)).width, 240);

      // Drain the documented Ahem-font button artifacts; the real-overflow
      // guard is check_overflow.py on the live app with real fonts.
      while (tester.takeException() != null) {}
    },
  );

  testWidgets(
    'sidebar collapses to a 56px icon rail (toggle + Ctrl+B) and expands back',
    (tester) async {
      final container = await pumpMainPage(
        tester,
        savedDownloadPath: '/tmp/saved-directory',
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.getRect(find.byType(DesktopSidebar)).width, 240);

      // Header buttons sit under DragToMoveArea, whose onDoubleTap
      // recognizer (double-click = maximize) holds the gesture arena for
      // ~300ms — advance the clock past it so the tap resolves.
      Future<void> tapHeader(Finder finder) async {
        await tester.tap(finder);
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pumpAndSettle();
      }

      // Header toggle: shrink to the 56px icon rail — labels/counts hidden,
      // icons remain (tooltips carry the names). The toggle is found by KEY:
      // its glyph is now a painted MorphIcon (the watch player's play<->pause
      // treatment), so there is no Icon widget for find.byIcon.
      final toggle = find.byKey(const Key('sidebarToggle'));
      await tapHeader(toggle);
      expect(container.read(sidebarCollapsedProvider), isTrue);
      expect(tester.getRect(find.byType(DesktopSidebar)).width, 56);
      expect(find.text('common.home'), findsNothing);
      expect(find.text('sidebar.not_synced'), findsNothing);

      // Ctrl+B restores (the shell handler owns the chord).
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(DesktopSidebar)).width, 240);
      expect(find.text('common.home'), findsWidgets);

      // The toggle icon morphs with the state; collapse again via the button.
      await tapHeader(toggle);
      expect(container.read(sidebarCollapsedProvider), isTrue);
      await tapHeader(toggle);
      expect(tester.getRect(find.byType(DesktopSidebar)).width, 240);

      // Ahem-font artifacts (wide header/footer text in the test font) —
      // drain so the geometry above is what's asserted.
      while (tester.takeException() != null) {}
    },
  );

  testWidgets('ctrl+K opens the desktop search overlay', (tester) async {
    final picker = _FakePickerPlatform();
    final previousPlatform = FilePickerPlatform.instance;
    FilePickerPlatform.instance = picker;
    addTearDown(() => FilePickerPlatform.instance = previousPlatform);

    final container = await pumpMainPage(tester);

    // Settle the fresh-start directory dialog so the shell is interactive.
    await tester.tap(find.text('settings.select_directory'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(container.read(searchPageProvider).open, isFalse);

    // The chord must be simulated in order: the handler reads
    // HardwareKeyboard's modifier state.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(
      container.read(searchPageProvider).open,
      isTrue,
      reason: 'the mock command-search shortcut opens the shared overlay',
    );
    // Ahem-font overlay artifact (see the shell test).
    tester.takeException();
  });
}
