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
import 'package:miru_alpha/widgets/index.dart';

import '../model/setting_items.dart';
import 'package:window_manager/window_manager.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:file_picker/file_picker.dart';

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
    NavItem(text: 'home', icon: Icons.home_outlined),
    NavItem(text: 'search', icon: Icons.explore_outlined),
    NavItem(text: 'extension.name', icon: Icons.extension_outlined),
    NavItem(text: 'settings', icon: Icons.settings_outlined),
  ];

  static final List<FIconNavItem> _fIconNavItem = [
    FIconNavItem(text: 'home', icon: FIcons.house, page: "/home"),
    FIconNavItem(text: 'history', icon: FIcons.history, page: "/home/history"),
    FIconNavItem(
      text: 'favorite.name',
      icon: FIcons.bookHeart,
      page: "/home/favorite",
    ),
    // FIconNavItem(text: 'Tracking', icon: Icons.extension_outlined, selectIcon: Icons.extension),
    // FIconNavItem(text: 'Settings', icon: FIcons.settings, selectIcon: Icons.settings),
    FIconNavItem(
      text: 'download',
      icon: FIcons.download,
      page: "/home/download",
    ),
    FIconNavItem(text: 'search', icon: FIcons.search, page: "/search"),
    FIconNavItem(text: 'extension', icon: FIcons.blocks, page: "/extension"),
    FIconNavItem(
      text: 'settings',
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
  static const sideBarTranslationMap = <SideBarName, String>{
    SideBarName.general: 'general',
    SideBarName.extension: 'extension.name',
    SideBarName.player: 'player',
    SideBarName.miruCore: 'miru_core',
    SideBarName.reader: 'reader',
    SideBarName.advanced: 'advanced',
    SideBarName.about: 'about',
    SideBarName.tracking: 'tracking',
    SideBarName.download: 'download',
  };

  static final List<FIconNavItem> _fIconSettingSubItem = [
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
          showFDialog(
            context: context,
            builder: (context, _, _) => FDialog(
              title: Text('download_directory'.i18n),
              body: Text('select_download_directory'.i18n),
              actions: [
                FButton(
                  onPress: () async {
                    String? result = await FilePicker.platform
                        .getDirectoryPath();
                    if (result != null) {
                      MiruSettings.setSettingSync(
                        SettingKey.downloadPath,
                        result,
                      );
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
                  child: Text('select_directory'.i18n),
                ),
              ],
            ),
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
                    padding: EdgeInsetsGeometry.directional(start: 10),
                    child: Row(
                      children: [
                        Text(
                          "miru".i18n,
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
                            "alpha".i18n,
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
              child: FTappable(
                onPress: () {},
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
                                'webdav'.i18n,
                                style: context.theme.typography.sm.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.theme.colors.foreground,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'signin'.i18n,
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
            children: [
              HookBuilder(
                builder: (context) {
                  final selectedIndex = useState("");
                  return FSidebarGroup(
                    label: Text(
                      'overview'.i18n,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!DeviceUtil.isMobile) ...[
                  const DragWindows(),
                  const FDivider(),
                ],
                FTheme(
                  data: themeData,
                  child: Expanded(child: widget.child ?? const SizedBox()),
                ),
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
