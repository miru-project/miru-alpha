import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/backend_connection_provider.dart';

import 'package:miru_alpha/ui/core/widget/miru_dialog.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/features/detail/widget/detail_nav_buttons.dart';
import 'package:miru_alpha/ui/features/search/widget/desktop_search_overlay.dart';
import 'package:miru_alpha/ui/features/setting/settings_dialog.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/provider/shell/shell_ui_provider.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:file_picker/file_picker.dart';

import 'dev_tool/widget/dev_tool_panel.dart';
import 'main_page/desktop_sidebar.dart';
import 'home/widget/dashboard/home_type_switch.dart';

class MainPage extends StatefulHookConsumerWidget {
  final StatefulNavigationShell? child;
  const MainPage({super.key, this.child});

  @override
  createState() => _MainPageState();
}

class NavItem {
  final String text;
  final IconData icon;
  const NavItem({required this.text, required this.icon});
}

/// Header context slot rule: the format switcher scopes the home dashboard,
/// so it renders only on the home route — never over Settings, Extension,
/// Tracking or the home subpages (each owns its own filters). Pure so the
/// scoping contract is unit-testable like [sidebarIndexForLocation].
bool headerShowsFormatPills(String location) =>
    location == '/' || location == '/home' || location.startsWith('/home?');

/// The unified 44px header (refined desktop mock): brand + Desktop tag, the
/// route-scoped context slot, the command search, sync + settings and the
/// window controls — one bar owning window drag (mock Chunk A).
class _UnifiedHeader extends ConsumerWidget {
  const _UnifiedHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    // Context slot: the format pills scope the home dashboard, so they render
    // only on the home route (audit: no media filters over Settings/Extension).
    final showPills = headerShowsFormatPills(
      GoRouterState.of(context).uri.toString(),
    );
    final sidebarCollapsed = ref.watch(sidebarCollapsedProvider);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.fromBorderSide(BorderSide(color: colors.border)),
      ),
      child: DragToMoveArea(
        child: SizedBox(
          height: 44,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // Sidebar collapse toggle (mock: dock_to_left, Ctrl+B) —
                // occupies the slot the old traffic dots held. The key is
                // the tests' tap target: the morphing glyph paints via
                // CustomPaint, so find.byIcon cannot see it.
                Padding(
                  key: const Key('sidebarToggle'),
                  padding: const EdgeInsets.only(right: 4),
                  child: _HeaderIconButton(
                    onTap: () =>
                        ref.read(sidebarCollapsedProvider.notifier).toggle(),
                    child: _PanelToggleIcon(collapsed: sidebarCollapsed),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'common.miru'.i18n,
                      style: context.theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'common.alpha'.i18n,
                      style: context.theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const SmallBadge(label: 'Desktop'),
                const SizedBox(width: 12),
                // Format pills live in the header now (mock: global scope
                // above the canvas, not home-scoped) — but only ON home;
                // elsewhere the center slot is empty.
                if (showPills) ...[
                  const SizedBox(width: 12),
                  const HomeTypeSwitch(dense: true),
                ],
                const Spacer(),
                const SizedBox(width: 12),
                // Compact command search (refined mock): fixed 224x28 input trigger —
                // the overlay it opens is unchanged.
                const SizedBox(width: 224, child: SearchTrigger(compact: true)),
                const SizedBox(width: 12),
                // Sync CTA (mock: library sync moved from the sidebar into
                // the header dock) — the extension store's own refresh.
                _HeaderIconButton(
                  icon: FLucideIcons.refreshCw,
                  semanticLabel: 'home.sync_library'.i18n,
                  onTap: () => ref
                      .read(extensionPageProvider.notifier)
                      .loadRepos(force: true),
                ),
                const SizedBox(width: 4),
                _HeaderIconButton(
                  icon: FLucideIcons.settings,
                  // VSCode-style modal (user directive 2026-11-12) — the
                  // /settings/<name> routes stay as deep-link fallbacks.
                  onTap: () => showSettingsDialog(context),
                ),
                const SizedBox(width: 8),
                _VerticalDivider(),
                const SizedBox(width: 4),
                // Window controls (mock right cluster).
                _WindowDot(
                  color: colors.mutedForeground.withAlpha(179),
                  onTap: () => WindowManager.instance.getCurrent()?.minimize(),
                  square: true,
                  icon: FLucideIcons.minus,
                ),
                _WindowDot(
                  color: colors.mutedForeground.withAlpha(179),
                  onTap: () {
                    final window = WindowManager.instance.getCurrent();
                    if (window == null) return;
                    if (window.isMaximized) {
                      window.unmaximize();
                    } else {
                      window.maximize();
                    }
                  },
                  square: true,
                  icon: FLucideIcons.square,
                ),
                _WindowDot(
                  color: const Color(0xCCC6412F),
                  onTap: () => WindowManager.instance.getCurrent()?.close(),
                  square: true,
                  icon: FLucideIcons.x,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A 1px vertical divider used between header clusters.
class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 16, color: context.theme.colors.border);
  }
}

/// 36px ghost icon button for the header's utility cluster — forui's own
/// hover/press states instead of a hand-rolled container.
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.onTap,
    this.icon,
    this.child,
    this.semanticLabel,
  });

  final VoidCallback onTap;

  /// Glyph used when no custom [child] is supplied.
  final IconData? icon;
  final Widget? child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return FButton.icon(
      variant: .ghost,
      size: .sm,
      onPress: onTap,
      child: child ?? Icon(icon, size: 18, semanticLabel: semanticLabel),
    );
  }
}

/// The sidebar toggle's transition (user directive 2026-11-13, revised after
/// live review): a two-phase POP — the outgoing glyph shrinks into its
/// centroid, the incoming one grows back out. The morph engine's path morph
/// is WRONG for this pair: the panel icons' chevron subpath rotates ~180°
/// between them, and the engine's polar interpolation averages both chains
/// rotated ±90° at mid-flight — both glyphs visibly superimposed (the
/// "stacked" render). The pop never overlaps, by construction.
class _PanelToggleIcon extends HookWidget {
  const _PanelToggleIcon({required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 170),
    );
    final armed = useRef(false);
    useEffect(() {
      if (armed.value) {
        controller.forward(from: 0);
      } else {
        armed.value = true;
      }
      return null;
    }, [collapsed]);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final idle = t == 0 && !controller.isAnimating;
        // First half: the OUTGOING glyph (pre-toggle state) shrinks to
        // nothing; second half: the incoming glyph grows back. The two never
        // coexist, so no mid-frame shows both icons.
        final firstHalf = t < 0.5;
        final showOpen = idle
            ? collapsed
            : (firstHalf ? !collapsed : collapsed);
        final phase = idle
            ? 1.0
            : Curves.easeOut.transform(firstHalf ? 1.0 - t * 2 : (t - 0.5) * 2);
        return Transform.scale(
          scale: phase,
          child: Icon(
            showOpen ? FLucideIcons.panelLeftOpen : FLucideIcons.panelLeftClose,
            size: 18,
            semanticLabel: 'sidebar.toggle'.i18n,
          ),
        );
      },
    );
  }
}

/// One header control: either a 12px traffic dot or a square window button
/// (mock: a dot cluster left AND min/max/close buttons right).
class _WindowDot extends StatelessWidget {
  const _WindowDot({
    required this.color,
    this.onTap,
    this.square = false,
    this.icon,
  });

  final Color color;
  final VoidCallback? onTap;
  final bool square;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: square
            ? Container(
                width: 24,
                height: 28,
                alignment: Alignment.center,
                child: Icon(icon, size: 13, color: color),
              )
            : Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
      ),
    );
  }
}

/// The emerald live accent shared by the header pills.
const kHeaderEmerald = Color(0xFF34D399);

class _MainPageState extends ConsumerState<MainPage>
    with SingleTickerProviderStateMixin {
  // late TabController _tabController;
  // late final MainController c;
  static const List<NavItem> _navItems = [
    NavItem(text: 'common.home', icon: Icons.home_outlined),
    NavItem(text: 'common.search', icon: Icons.explore_outlined),
    NavItem(text: 'extension.name', icon: Icons.extension_outlined),
    NavItem(text: 'common.settings', icon: Icons.settings_outlined),
  ];

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.properties.removeWhere((p) => p.name == 'autofocus');
    properties.add(
      FlagProperty('autofocus', value: true, ifTrue: 'true', ifFalse: 'false'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(
      applicationControllerProvider.select((s) => s.themeData),
    );
    final selected = useState(0);

    useEffect(() {
      Future.microtask(() async {
        // The dialog reads backend-persisted settings; hold it until the
        // connection gate resolves (the bootstrap seeded synchronous
        // defaults) so an already-chosen directory never re-prompts.
        await ref.read(backendConnectionProvider.future);
        // The gate's appearance reload can flip MaterialApp's language key,
        // which REMOUNTS the whole app. Let that frame land before showing
        // anything: a stale element exits here instead of pushing a dialog
        // onto the navigator that is about to be torn down.
        await WidgetsBinding.instance.endOfFrame;
        if (!context.mounted) return;
        final downloadPath = MiruSettings.getSettingSync<String>(
          SettingKey.downloadPath,
        );
        if (downloadPath.isEmpty) {
          showMiruDialog(
            context: context,
            builder: (dialogContext, style, animation) => FTheme(
              data: dialogContext.theme,
              child: MiruDialog(
                style: style,
                animation: animation,
                title: Text('settings.download_directory'.i18n),
                body: Text('settings.select_download_directory'.i18n),
                actions: [
                  FButton(
                    onPress: () async {
                      final result = await FilePicker.getDirectoryPath();
                      if (result == null) return;
                      MiruSettings.setSettingSync(
                        SettingKey.downloadPath,
                        result,
                      );
                      // Close the DIALOG's route. Popping the page's captured
                      // context resolved to the shell page (the dialog was
                      // already gone after the appearance remount) and
                      // popped the last go_router page — the fresh-start
                      // crash.
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    child: Text('settings.select_directory'.i18n),
                  ),
                ],
              ),
            ),
          );
        }
      });
      return null;
    }, []);

    // The mock's ⌘K / Ctrl+K command-search shortcut: ONE handler owns the
    // key on the shell (rule 21) and opens the same overlay the top-bar
    // trigger opens — identical state, no second search surface. Ctrl+B
    // toggles the sidebar collapse.
    useEffect(() {
      if (DeviceUtil.isMobile) return null;
      bool onKey(KeyEvent event) {
        // addHandler receives keyDown AND keyUp — act on the press only
        // (a toggle would fire twice and cancel itself, exposed by Ctrl+B).
        if (event is! KeyDownEvent) return false;
        final modifier =
            HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed;
        if (modifier && event.logicalKey == LogicalKeyboardKey.keyK) {
          ref.read(searchPageProvider.notifier).setOpen(true);
          return true;
        }
        if (modifier && event.logicalKey == LogicalKeyboardKey.keyB) {
          ref.read(sidebarCollapsedProvider.notifier).toggle();
          return true;
        }
        return false;
      }

      HardwareKeyboard.instance.addHandler(onKey);
      return () => HardwareKeyboard.instance.removeHandler(onKey);
    }, const []);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return FTheme(
      data: themeData,
      child: PlatformWidget(
        mobileWidget: Stack(
          children: [
            Column(
              children: [
                // The window bar owns the top strip of the WINDOW, above every
                // route's content, because the OS title bar is hidden
                // (titleBarStyle: hidden) and nothing else provides one.
                //
                // It is here in the layout flow -- not `Positioned` over the page
                // -- so no page can ever start at y=0 underneath it. Overlaying
                // it let `/search/single`'s own 50px header render *behind* the
                // bar (measured: title at y=35..68, i.e. inside the bar's own
                // 0..35 strip, back button at y=39).
                if (!DeviceUtil.isMobile) ...[
                  const DragWindows(),
                  const FDivider(
                    style: FDividerStyleDelta.delta(
                      padding: EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
                    ),
                  ),
                ],
                Expanded(child: widget.child ?? const SizedBox()),
                // Hide the bottom navigation bar when the keyboard is open to
                // prevent its solid background from appearing as a black box
                // above the keyboard.
                if (MediaQuery.viewInsetsOf(context).bottom == 0)
                  FBottomNavigationBar(
                    // The reference nav scales each item to 95% while
                    // pressed (`active:scale-95`); forui's default bounce
                    // tween only goes to 97%.
                    style: FBottomNavigationBarStyleDelta.delta(
                      itemStyle: FBottomNavigationBarItemStyleDelta.delta(
                        // The reference keeps the label the same color whether
                        // or not the tab is selected; only the icon signals the
                        // active tab. forui's default turns the selected label
                        // primary + bold, so we replace the text style with one
                        // that omits the `.selected` variant (it resolves to the
                        // muted base) and keeps only the hover/pressed feedback.
                        textStyle:
                            FVariants<
                              FTappableVariantConstraint,
                              FTappableVariant,
                              TextStyle,
                              TextStyleDelta
                            >.from(
                              themeData.typography.body.xs3.copyWith(
                                color: themeData.colors.mutedForeground,
                                height: 1.5,
                              ),
                              variants: {
                                [
                                  FTappableVariant.hovered,
                                  FTappableVariant.pressed,
                                ]: TextStyleDelta.delta(
                                  color: themeData.colors.hover(
                                    themeData.colors.mutedForeground,
                                  ),
                                ),
                              },
                            ),
                        tappableStyle: FTappableStyleDelta.delta(
                          motion: FTappableMotionDelta.delta(
                            bounceTween: const FImmutableTween<double>(
                              begin: 1.0,
                              end: 0.95,
                            ),
                          ),
                        ),
                      ),
                    ),
                    index: selected.value,
                    onChange: (value) {
                      if (widget.child != null) {
                        widget.child!.goBranch(value);
                      }
                      selected.value = value;
                    },
                    children: [
                      FBottomNavigationBarItem(
                        label: Text(_navItems[0].text.i18n),
                        icon: HomeIcon(
                          color: selected.value == 0
                              ? themeData.colors.primary
                              : themeData.colors.mutedForeground,
                          isTriggered: selected.value == 0,
                        ),
                      ),
                      FBottomNavigationBarItem(
                        label: Text(_navItems[1].text.i18n),
                        icon: CompassIcon(
                          color: selected.value == 1
                              ? themeData.colors.primary
                              : themeData.colors.mutedForeground,
                          isTriggered: selected.value == 1,
                        ),
                      ),
                      FBottomNavigationBarItem(
                        label: Text(_navItems[2].text.i18n),
                        icon: BlocksPathLoopIcon(
                          color: selected.value == 2
                              ? themeData.colors.primary
                              : themeData.colors.mutedForeground,
                          isTriggered: selected.value == 2,
                        ),
                      ),
                      FBottomNavigationBarItem(
                        label: Text(_navItems[3].text.i18n),
                        icon: SettingsIcon(
                          color: selected.value == 3
                              ? themeData.colors.primary
                              : themeData.colors.mutedForeground,
                          isTriggered: selected.value == 3,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            // Overlay hookup mirrors the desktop branch; a no-op while the
            // mobile SearchTrigger is hidden (open is only set from there).
            if (!DeviceUtil.isMobile) const _DesktopSearchOverlay(),
          ],
        ),
        desktopWidget: Column(
          children: [
            // High-Density rev: ONE unified 44px header owns window controls,
            // identity, the format pills, the command search and telemetry —
            // the old 40+56px double stack is gone (reclaims ~52px).
            const _UnifiedHeader(),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: FScaffold(
                      key: messengerKey,
                      sidebar: const DesktopSidebar(),
                      child: Stack(
                        // Expand: only positioned children + a closed
                        // overlay would otherwise size the Stack to zero
                        // and blank the whole branch (seen live at
                        // 1300x800 after the header merge).
                        fit: StackFit.expand,
                        children: [
                          // Positioned.fill: the routed shell must fill the
                          // canvas — an Expanded here would be a Flex child
                          // inside a Stack (ParentData crash on branch
                          // activation).
                          Positioned.fill(
                            child: FTheme(
                              data: themeData,
                              child: widget.child ?? const SizedBox(),
                            ),
                          ),
                          if (!DeviceUtil.isMobile)
                            const _DesktopSearchOverlay(),
                        ],
                      ),
                    ),
                  ),
                  const DevToolPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DragWindows extends StatelessWidget {
  const DragWindows({super.key});

  @override
  Widget build(BuildContext context) {
    // The top search bar is desktop-layout only: in the mobile layout the
    // page's own search surfaces own the entry point.
    final showSearch = !DeviceUtil.isMobileLayout(context);
    return DragToMoveArea(
      child: Row(
        children: [
          const DetailNavButtons(),
          if (showSearch)
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) => SizedBox(
                    width: constraints.maxWidth * .5,
                    child: const SearchTrigger(),
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 200, maxHeight: 35),
            child: Platform.isWindows || Platform.isLinux || Platform.isMacOS
                ? WindowCaption(
                    brightness: context.theme.colors.brightness,
                    backgroundColor: context.theme.colors.background,
                  )
                : const Spacer(),
          ),
        ],
      ),
    );
  }
}

/// Desktop-only: renders the search overlay popup when the search state is
/// opened from the top-bar [SearchTrigger].
class _DesktopSearchOverlay extends ConsumerWidget {
  const _DesktopSearchOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(searchPageProvider.select((e) => e.open));
    if (!open) return const SizedBox();
    return const SearchOverlayPopup();
  }
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
