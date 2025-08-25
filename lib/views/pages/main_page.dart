import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/application_controller_provider.dart';
import 'package:miru_app_new/provider/main_controller_provider.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/views/widgets/index.dart';

import 'package:miru_app_new/views/pages/setting/setting_items.dart';
import 'package:moon_design/moon_design.dart';
import 'package:window_manager/window_manager.dart';

class MainPage extends StatefulHookConsumerWidget {
  final StatefulNavigationShell child;
  const MainPage({super.key, required this.child});

  @override
  createState() => _MainPageState();
}

class FIconNavItem {
  final String text;
  final IconData icon;
  final String? page;
  final bool expaned;
  final List<FIconNavItem>? subItems;
  const FIconNavItem({required this.text, required this.icon, this.page, this.subItems, this.expaned = false});
}

class _MainPageState extends ConsumerState<MainPage> with SingleTickerProviderStateMixin {
  // late TabController _tabController;
  late final MainController c;
  static const List<NavItem> _navItems = [
    NavItem(text: 'Home', icon: Icons.home_outlined, selectIcon: Icons.home_filled),
    NavItem(text: 'Search', icon: Icons.explore_outlined, selectIcon: Icons.explore),
    NavItem(text: 'Extension', icon: Icons.extension_outlined, selectIcon: Icons.extension),
    NavItem(text: 'Settings', icon: Icons.settings_outlined, selectIcon: Icons.settings),
  ];
  static final List<FIconNavItem> _subNavItem = [
    FIconNavItem(text: 'History', icon: FIcons.history, page: "/home/history"),
    FIconNavItem(text: 'Favorite', icon: FIcons.bookHeart, page: "/home/favorite"),
    // FIconNavItem(text: 'Tracking', icon: Icons.extension_outlined, selectIcon: Icons.extension),
    // FIconNavItem(text: 'Settings', icon: FIcons.settings, selectIcon: Icons.settings),
    FIconNavItem(text: 'Download', icon: FIcons.download, page: "/home/download"),
  ];
  static final List<FIconNavItem> _fIconNavItem = [
    FIconNavItem(text: 'Home', icon: FIcons.house, page: "/home", subItems: _subNavItem),
    FIconNavItem(text: 'Search', icon: FIcons.search, page: "/search"),
    FIconNavItem(text: 'Extension', icon: FIcons.blocks, page: "/extension"),
    FIconNavItem(text: 'Settings', icon: FIcons.settings, subItems: _fIconSettingSubItem),
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
      FIconNavItem(text: item.name[0].toUpperCase() + item.name.substring(1), icon: sideBarIconMap[item]!, page: "/settings/${item.name}"),
  ];

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.properties.removeWhere((p) => p.name == 'autofocus');
    properties.add(FlagProperty('autofocus', value: true, ifTrue: 'true', ifFalse: 'false'));
  }

  @override
  Widget build(BuildContext context) {
    final ac = ref.watch(applicationControllerProvider);
    final c = ref.read(mainControllerProvider.notifier);
    final controller = ref.watch(mainControllerProvider);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return PlatformWidget(
      mobileWidget: Scaffold(
        extendBody: true,
        body: SafeArea(child: widget.child),
        bottomNavigationBar: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < _navItems.length; i++) ...[
                    Expanded(
                      child: NavButton(
                        selectIcon: _navItems[i].selectIcon,
                        text: _navItems[i].text,
                        icon: _navItems[i].icon,
                        onPressed: () {
                          widget.child.goBranch(i);
                          c.selectIndex(i);
                        },
                        selected: controller.selectedIndex == i,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      desktopWidget: FTheme(
        data: ac.themeData,
        child: FScaffold(
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
                        Text("Miru", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                        Padding(
                          padding: EdgeInsetsGeometry.directional(start: 10, top: 15),
                          child: Text("Alpha", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                        ),
                      ],
                    ),
                  ),
                  FDivider(),
                ],
              ),
            ),
            footer: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FCard.raw(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    spacing: 10,
                    children: [
                      FAvatar.raw(child: Icon(FIcons.userRound, size: 18, color: context.theme.colors.mutedForeground)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(
                              'WebDav(WIP)',
                              style: context.theme.typography.sm.copyWith(fontWeight: FontWeight.bold, color: context.theme.colors.foreground),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Signin',
                              style: context.theme.typography.xs.copyWith(color: context.theme.colors.mutedForeground),
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
                      children:
                          _fIconNavItem[i].subItems != null
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
              // spacing: 12, // This might be causing issues
              children: [
                DeviceUtil.platformWidgetFunction(
                  context: context,
                  mobile: (buildchild) => buildchild,
                  desktop: (buildchild) => DragToMoveArea(child: buildchild),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FBreadcrumb(
                        children: [
                          FBreadcrumbItem(onPress: () {}, child: const Text('Forui')),
                          FBreadcrumbItem.collapsed(
                            menu: [
                              FItemGroup(children: [FItem(title: const Text('Documentation'), onPress: () {})]),
                            ],
                          ),
                          FBreadcrumbItem(onPress: () {}, child: const Text('Overview')),
                          const FBreadcrumbItem(current: true, child: Text('Installation')),
                        ],
                      ),
                      // ConstrainedBox(
                      //   constraints: BoxConstraints(minWidth: 50, maxWidth: 90),
                      //   child: FTextField(
                      //     clearable: (value) => value.text.isNotEmpty,
                      //     hint: 'Search ...',
                      //     keyboardType: TextInputType.webSearch,
                      //     textCapitalization: TextCapitalization.none,
                      //     maxLines: 1,
                      //   ),
                      // ),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 200, maxHeight: 35),
                        child:
                            Platform.isWindows || Platform.isLinux
                                ? WindowCaption(brightness: Brightness.dark, backgroundColor: context.theme.colors.background)
                                : const Spacer(),
                      ),
                    ],
                  ),
                ),
                FDivider(),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A lightweight replacement for the `forui` package `FSidebar` widget.
class SafeFSidebar extends StatelessWidget {
  final bool? autofocus;
  final Widget? header;
  final Widget? footer;
  final List<Widget>? children;
  final double? width;

  const SafeFSidebar({super.key, this.autofocus, this.header, this.footer, this.children, this.width});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: width ?? 180, maxWidth: width ?? 220),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) header!,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView(padding: EdgeInsets.zero, children: children ?? const []),
            ),
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class BreadCrumb extends StatefulHookWidget {
  const BreadCrumb({super.key});

  @override
  State<BreadCrumb> createState() => _BreadCrumbState();
}

class _BreadCrumbState extends State<BreadCrumb> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Perform any additional initialization after the first frame is rendered
    });
  }

  @override
  Widget build(BuildContext context) {
    return FBreadcrumb(
      children: [
        FBreadcrumbItem(onPress: () {}, child: const Text('Forui')),
        FBreadcrumbItem.collapsed(
          menu: [
            FItemGroup(children: [FItem(title: const Text('Documentation'), onPress: () {})]),
          ],
        ),
        FBreadcrumbItem(onPress: () {}, child: const Text('Overview')),
        const FBreadcrumbItem(current: true, child: Text('Installation')),
      ],
    );
  }
}

class NavButton extends StatefulWidget {
  const NavButton({super.key, required this.text, required this.icon, required this.selectIcon, required this.onPressed, required this.selected});

  final String text;
  final IconData icon;
  final IconData selectIcon;
  final void Function() onPressed;
  final bool selected;

  @override
  State<NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<NavButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      mobileWidget: GestureDetector(
        onTap: widget.onPressed,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Container(color: Theme.of(context).scaffoldBackgroundColor),
            (Container(
              decoration: BoxDecoration(color: context.moonTheme?.tabBarTheme.colors.selectedPillTabColor.withAlpha(50)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 5),
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color:
                              widget.selected || _hover
                                  ? context.moonTheme?.tabBarTheme.colors.selectedPillTabColor.withAlpha(100)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            widget.selected || _hover ? widget.selectIcon : widget.icon,
                            color:
                                widget.selected || _hover
                                    ? context.moonTheme?.tabBarTheme.colors.textColor
                                    : context.moonTheme?.tabBarTheme.colors.textColor.withAlpha(150),
                          ),
                        ),
                      ),
                      // Text(
                      //   widget.text,
                      //   style: const TextStyle(fontSize: 11),
                      // )
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
      desktopWidget: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: widget.selected || _hover ? context.moonTheme?.tabBarTheme.colors.selectedPillTextColor.withAlpha(20) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.selected || _hover ? widget.selectIcon : widget.icon,
                  color: widget.selected || _hover ? context.moonColors?.bulma : context.moonColors?.bulma.withAlpha(150),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
