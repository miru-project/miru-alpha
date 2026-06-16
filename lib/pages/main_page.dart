import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/main_controller_provider.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/widgets/animted_icon/block.dart';
import 'package:miru_alpha/widgets/animted_icon/compass.dart';
import 'package:miru_alpha/widgets/animted_icon/home.dart';
import 'package:miru_alpha/widgets/animted_icon/settings_cog.dart';
import 'package:miru_alpha/widgets/core/toast.dart';
import 'package:miru_alpha/widgets/dialog/dialog.dart';
import 'package:miru_alpha/widgets/index.dart';

import '../model/setting_items.dart';
import 'package:window_manager/window_manager.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:file_picker/file_picker.dart';
import 'dev_tool/widget/dev_tool_panel.dart';

class MainPage extends StatefulHookConsumerWidget {
  final StatefulNavigationShell? child;
  const MainPage({super.key, this.child});

  @override
  createState() => _MainPageState();
}

class FIconNavItem {
  final String text;
  final IconData icon;
  final String? page;
  final bool expaned;
  final List<FIconNavItem>? subItems;
  const FIconNavItem({
    required this.text,
    required this.icon,
    this.page,
    this.subItems,
    this.expaned = false,
  });
}

class _MainPageState extends ConsumerState<MainPage>
    with SingleTickerProviderStateMixin {
  // late TabController _tabController;
  late final MainController c;
  static const List<NavItem> _navItems = [
    NavItem(text: 'common.home', icon: Icons.home_outlined),
    NavItem(text: 'common.search', icon: Icons.explore_outlined),
    NavItem(text: 'extension.name', icon: Icons.extension_outlined),
    NavItem(text: 'common.settings', icon: Icons.settings_outlined),
  ];

  static final List<FIconNavItem> _fIconNavItem = [
    FIconNavItem(text: 'common.home', icon: FLucideIcons.house, page: "/home"),
    FIconNavItem(
      text: 'common.history',
      icon: FLucideIcons.history,
      page: "/home/history",
    ),
    FIconNavItem(
      text: 'common.favorite.name',
      icon: FLucideIcons.bookHeart,
      page: "/home/favorite",
    ),
    FIconNavItem(
      text: 'common.download',
      icon: FLucideIcons.download,
      page: "/home/download",
    ),
    FIconNavItem(
      text: 'common.search',
      icon: FLucideIcons.search,
      page: "/search",
    ),
    FIconNavItem(
      text: 'extension.name',
      icon: FLucideIcons.blocks,
      page: "/extension",
    ),
    FIconNavItem(
      text: 'tracking.name',
      icon: FLucideIcons.clipboardClock,
      page: "/tracking",
    ),
    FIconNavItem(
      text: 'common.settings',
      icon: FLucideIcons.settings,
      subItems: _fLucideIconsettingSubItem,
    ),
  ];

  static const sideBarIconMap = <SideBarName, IconData>{
    SideBarName.general: FLucideIcons.menu,
    SideBarName.extension: FLucideIcons.blocks,
    SideBarName.player: FLucideIcons.play,
    SideBarName.network: FLucideIcons.server,
    SideBarName.reader: FLucideIcons.bookOpen,
    SideBarName.advanced: FLucideIcons.cog,
    SideBarName.download: FLucideIcons.download,
    SideBarName.about: FLucideIcons.inbox,
    SideBarName.tracking: FLucideIcons.arrowUpDown,
    SideBarName.developer: FLucideIcons.code,
  };
  static const sideBarTranslationMap = <SideBarName, String>{
    SideBarName.general: 'common.general',
    SideBarName.extension: 'extension.name',
    SideBarName.player: 'common.player',
    SideBarName.network: 'common.network',
    SideBarName.reader: 'common.reader',
    SideBarName.advanced: 'common.advanced',
    SideBarName.about: 'common.about',
    SideBarName.tracking: 'tracking.name',
    SideBarName.download: 'common.download',
    SideBarName.developer: 'common.developer',
  };

  static final List<FIconNavItem> _fLucideIconsettingSubItem = [
    for (var item in SideBarName.values)
      FIconNavItem(
        text: sideBarTranslationMap[item]!,
        icon: sideBarIconMap[item]!,
        page: "/settings/${item.name}",
      ),
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
    final c = ref.read(mainControllerProvider.notifier);
    final controller = ref.watch(mainControllerProvider);
    final selected = useState(controller.selectedIndex);

    useEffect(() {
      Future.microtask(() async {
        final downloadPath = MiruSettings.getSettingSync<String>(
          SettingKey.downloadPath,
        );
        if (downloadPath.isEmpty && context.mounted) {
          showMiruDialog(
            context: context,
            actions: [
              FButton(
                onPress: () async {
                  String? result = await FilePicker.getDirectoryPath();
                  if (result != null) {
                    MiruSettings.setSettingSync(
                      SettingKey.downloadPath,
                      result,
                    );
                    if (context.mounted) Navigator.of(context).pop();
                  }
                },
                child: Text('settings.select_directory'.i18n),
              ),
            ],
            title: Text('settings.download_directory'.i18n),
            body: Text('settings.select_download_directory'.i18n),
          );
        }
      });
      return null;
    }, []);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return FTheme(
      data: themeData,
      child: PlatformWidget(
        mobileWidget: Column(
          children: [
            Expanded(child: widget.child ?? const SizedBox()),
            FBottomNavigationBar(
              index: controller.selectedIndex,
              onChange: (value) {
                if (widget.child != null) {
                  widget.child!.goBranch(value);
                }
                c.selectIndex(value);
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
        desktopWidget: FScaffold(
          key: messengerKey,
          sidebar: SafeFSidebar(
            autofocus: true,
            header: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: .symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Text(
                          "common.miru".i18n,
                          style: context.theme.typography.xl3.copyWith(
                            fontWeight: .bold,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsGeometry.directional(
                            start: 10,
                            top: 15,
                          ),
                          child: Text(
                            "common.alpha".i18n,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FDivider(
                    style: FDividerStyleDelta.delta(
                      padding: EdgeInsetsGeometryDelta.value(.only(bottom: 5)),
                    ),
                  ),
                ],
              ),
            ),
            footer: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: FTappable(
                onPress: () {},
                child: FTappable(
                  onPress: () {
                    iconsMessageToast(
                      title: 'common.wip'.i18n,
                      icon: FLucideIcons.construction,
                    );
                  },
                  child: FCard.raw(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        spacing: 10,
                        children: [
                          FAvatar.raw(
                            child: Icon(
                              FLucideIcons.userRound,
                              size: 18,
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 2,
                              children: [
                                Text(
                                  'common.webdav'.i18n,
                                  style: context.theme.typography.sm.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'common.signin'.i18n,
                                  style: context.theme.typography.xs.copyWith(
                                    color: context.theme.colors.mutedForeground,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            children: [
              HookBuilder(
                builder: (context) {
                  final selectedIndex = useState("");
                  return FSidebarGroup(
                    label: Text(
                      'common.overview'.i18n,
                      style: TextStyle(
                        // fontFamily: 'Noto Sans CJK TC', // Be explicit
                        fontWeight: FontWeight.w400,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                    children: [
                      for (var i = 0; i < _fIconNavItem.length; i++) ...[
                        FSidebarItem(
                          initiallyExpanded: true,
                          label: Text(_fIconNavItem[i].text.i18n),
                          icon: Icon(_fIconNavItem[i].icon),
                          onPress: () {
                            // widget.child.goBranch(i);
                            if (_fIconNavItem[i].page != null) {
                              context.go(_fIconNavItem[i].page!);
                            }

                            c.selectIndex(i);
                          },
                          selected: controller.selectedIndex == i,
                          children: _fIconNavItem[i].subItems != null
                              ? _fIconNavItem[i].subItems!
                                    .map(
                                      (e) => FSidebarItem(
                                        selected: e.text == selectedIndex.value,
                                        label: Text(e.text.i18n),
                                        icon: Icon(e.icon),
                                        onPress: () {
                                          if (e.page != null) {
                                            context.go(e.page!);
                                          }
                                          c.selectIndex(i);
                                          selectedIndex.value = e.text;
                                        },
                                      ),
                                    )
                                    .toList()
                              : [],
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!DeviceUtil.isMobile) ...[
                        const DragWindows(),
                        const FDivider(
                          style: FDividerStyleDelta.delta(
                            padding: EdgeInsetsGeometryDelta.value(
                              EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                      FTheme(
                        data: themeData,
                        child: Expanded(
                          child: widget.child ?? const SizedBox(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const DevToolPanel(),
            ],
          ),
        ),
      ),
    );
  }
}

class DragWindows extends StatelessWidget {
  const DragWindows({super.key});

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BreadCrumb(),
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

class BreadCrumb extends HookWidget {
  const BreadCrumb({super.key});

  @override
  Widget build(BuildContext context) {
    final routeInfoProvider = GoRouter.of(context).routeInformationProvider;
    useListenable(routeInfoProvider);

    final currentLocation =
        GoRouter.of(context).routerDelegate.state.fullPath ??
        GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;

    final segments = currentLocation
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();

    return FBreadcrumb(
      children: [
        for (final seg in segments)
          FBreadcrumbItem(
            onPress: () {
              if (seg == segments.last) return;
              if (!context.canPop()) return;
              if (seg == 'search' && segments.last == 'detail') {
                context.pop();
                context.pop();
                return;
              }
              if ((seg == 'single' && segments.last == 'detail') ||
                  (seg == 'search' && segments.last == 'single')) {
                context.pop();
                return;
              }
            },
            child: Text(seg.i18n),
          ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}

class SafeFSidebar extends StatelessWidget {
  final bool? autofocus;
  final Widget? header;
  final Widget? footer;
  final List<Widget>? children;
  final double? width;

  const SafeFSidebar({
    super.key,
    this.autofocus,
    this.header,
    this.footer,
    this.children,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: width ?? 160,
        maxWidth: width ?? 200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header ?? SizedBox(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView(
                padding: EdgeInsets.zero,
                children: children ?? const [],
              ),
            ),
          ),
          footer ?? SizedBox(),
        ],
      ),
    );
  }
}
