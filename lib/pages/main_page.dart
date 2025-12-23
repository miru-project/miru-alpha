import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/application_controller_provider.dart';
import 'package:miru_app_new/provider/main_controller_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/utils/core/i18n.dart';
import 'package:miru_app_new/widgets/animted_icon/block.dart';
import 'package:miru_app_new/widgets/animted_icon/compass.dart';
import 'package:miru_app_new/widgets/animted_icon/home.dart';
import 'package:miru_app_new/widgets/animted_icon/settings_cog.dart';
import 'package:miru_app_new/widgets/index.dart';

import 'setting/setting_items.dart';
import 'package:window_manager/window_manager.dart';

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
    NavItem(text: 'Home', icon: Icons.home_outlined),
    NavItem(text: 'Search', icon: Icons.explore_outlined),
    NavItem(text: 'Extension', icon: Icons.extension_outlined),
    NavItem(text: 'Settings', icon: Icons.settings_outlined),
  ];
  static final List<FIconNavItem> _subNavItem = [
    FIconNavItem(text: 'History', icon: FIcons.history, page: "/home/history"),
    FIconNavItem(
      text: 'Favorite',
      icon: FIcons.bookHeart,
      page: "/home/favorite",
    ),
    // FIconNavItem(text: 'Tracking', icon: Icons.extension_outlined, selectIcon: Icons.extension),
    // FIconNavItem(text: 'Settings', icon: FIcons.settings, selectIcon: Icons.settings),
    FIconNavItem(
      text: 'Download',
      icon: FIcons.download,
      page: "/home/download",
    ),
  ];
  static final List<FIconNavItem> _fIconNavItem = [
    FIconNavItem(
      text: 'Home',
      icon: FIcons.house,
      page: "/home",
      subItems: _subNavItem,
    ),
    FIconNavItem(text: 'Search', icon: FIcons.search, page: "/search"),
    FIconNavItem(text: 'Extension', icon: FIcons.blocks, page: "/extension"),
    FIconNavItem(
      text: 'Settings',
      icon: FIcons.settings,
      subItems: _fIconSettingSubItem,
    ),
  ];

  static const sideBarIconMap = <SideBarName, IconData>{
    SideBarName.general: FIcons.menu,
    SideBarName.extension: FIcons.blocks,
    SideBarName.player: FIcons.youtube,
    SideBarName.miruCore: FIcons.server,
    SideBarName.reader: FIcons.bookOpen,
    SideBarName.advanced: FIcons.cog,
    SideBarName.download: FIcons.download,
    SideBarName.about: FIcons.inbox,
    SideBarName.tracking: FIcons.arrowUpDown,
  };

  static final List<FIconNavItem> _fIconSettingSubItem = [
    for (var item in SideBarName.values)
      FIconNavItem(
        text: item.name[0].toUpperCase() + item.name.substring(1),
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return FTheme(
      data: themeData,
      child: PlatformWidget(
        mobileWidget: Column(
          children: [
            if (!DeviceUtil.isMobile) DragWindows(),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
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
                          label: Text(_navItems[0].text),
                          icon: selected.value == 0
                              ? HomeIcon(
                                  color: themeData.colors.primary,
                                  isTriggered: selected.value == 0,
                                )
                              : Icon(FIcons.house),
                        ),
                        FBottomNavigationBarItem(
                          label: Text(_navItems[1].text),
                          icon: selected.value == 1
                              ? CompassIcon(
                                  color: themeData.colors.primary,
                                  isTriggered: selected.value == 1,
                                )
                              : Icon(FIcons.compass),
                        ),
                        FBottomNavigationBarItem(
                          label: Text(_navItems[2].text),
                          icon: selected.value == 2
                              ? BlocksPathLoopIcon(
                                  color: themeData.colors.primary,
                                  isTriggered: selected.value == 2,
                                )
                              : Icon(FIcons.blocks),
                        ),
                        FBottomNavigationBarItem(
                          label: Text(_navItems[3].text),
                          icon: selected.value == 3
                              ? SettingsIcon(
                                  color: themeData.colors.primary,
                                  isTriggered: selected.value == 3,
                                )
                              : Icon(FIcons.settings),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                    padding: EdgeInsetsGeometry.directional(start: 10),
                    child: Row(
                      children: [
                        Text(
                          "Miru",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsGeometry.directional(
                            start: 10,
                            top: 15,
                          ),
                          child: Text(
                            "Alpha",
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
                  FDivider(),
                ],
              ),
            ),
            footer: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                          FIcons.userRound,
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
                              'WebDav(WIP)',
                              style: context.theme.typography.sm.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.theme.colors.foreground,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Signin',
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
            children: [
              FSidebarGroup(
                label: const Text('Overview'),
                children: [
                  for (var i = 0; i < _fIconNavItem.length; i++) ...[
                    FSidebarItem(
                      label: Text(_fIconNavItem[i].text),
                      icon: Icon(_fIconNavItem[i].icon),
                      onPress: () {
                        // widget.child.goBranch(i);
                        if (_fIconNavItem[i].page != null) {
                          context.go(_fIconNavItem[i].page!);
                        }

                        c.selectIndex(i);
                      },
                      initiallyExpanded: _fIconNavItem[i].expaned,
                      selected: controller.selectedIndex == i,
                      children: _fIconNavItem[i].subItems != null
                          ? _fIconNavItem[i].subItems!
                                .map(
                                  (e) => FSidebarItem(
                                    // selected: ,
                                    label: Text(e.text),
                                    icon: Icon(e.icon),
                                    onPress: () {
                                      if (e.page != null) {
                                        context.go(e.page!);
                                      }
                                      c.selectIndex(i);
                                    },
                                  ),
                                )
                                .toList()
                          : [],
                    ),
                  ],
                ],
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!DeviceUtil.isMobile) ...[
                  const DragWindows(),
                  const FDivider(),
                ],
                Expanded(child: widget.child ?? const SizedBox()),
              ],
            ),
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
            child: Text(seg.capitalize()),
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
          if (header != null) header!,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView(
                padding: EdgeInsets.zero,
                children: children ?? const [],
              ),
            ),
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}
