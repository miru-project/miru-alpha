import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app_new/controllers/main_controller.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:moon_design/moon_design.dart';
import 'package:window_manager/window_manager.dart';

class MainPage extends ConsumerStatefulWidget {
  final StatefulNavigationShell child;
  const MainPage({super.key, required this.child});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage>
    with SingleTickerProviderStateMixin {
  // late TabController _tabController;
  late final MainController c;
  static const List<NavItem> _navItems = [
    NavItem(
      text: 'Home',
      icon: Icons.home_outlined,
      selectIcon: Icons.home_filled,
    ),
    NavItem(
      text: 'Search',
      icon: Icons.explore_outlined,
      selectIcon: Icons.explore,
    ),
    NavItem(
      text: 'Extension',
      icon: Icons.extension_outlined,
      selectIcon: Icons.extension,
    ),
    NavItem(
      text: 'Settings',
      icon: Icons.settings_outlined,
      selectIcon: Icons.settings,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // _tabController = TabController(length: 4, vsync: this);
    // c = Get.put(MainController(_tabController));
    // _tabController.addListener(() {
    //   c.selectedIndex.value = _tabController.index;
    // });
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.read(mainControllerProvider.notifier);
    final controller = ref.watch(mainControllerProvider);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return PlatformWidget(
      mobileWidget: Scaffold(
        extendBody: true,
        body: SafeArea(
          child: widget.child,
        ),
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
                      child: _NavButton(
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
      desktopWidget: Column(children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: context.moonTheme?.textAreaTheme.colors.backgroundColor,
                border: const Border(
                  bottom: BorderSide(color: Colors.black38, width: 0.5),
                ),
              ),
              height: 55,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: Platform.isMacOS ? 70 : 20,
                            ),
                            child: Row(
                              children: [
                                Button(
                                  onPressed: () {
                                    context.pop();
                                  },
                                  trailing: [
                                    Icon(
                                      Icons.chevron_left,
                                      color: context.moonTheme?.textAreaTheme
                                          .colors.textColor,
                                    ),
                                  ],
                                  child: Text(
                                    "Miru",
                                    style: TextStyle(
                                        color: context.moonTheme?.textAreaTheme
                                            .colors.textColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none),
                                  ),
                                ),
                                const Expanded(
                                  child: DragToMoveArea(
                                    child: SizedBox.expand(),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        for (var i = 0; i < _navItems.length; i++) ...[
                          _NavButton(
                            selectIcon: _navItems[i].selectIcon,
                            text: _navItems[i].text,
                            icon: _navItems[i].icon,
                            onPressed: () {
                              widget.child.goBranch(i);
                              c.selectIndex(i);
                            },
                            selected: controller.selectedIndex == i,
                          ),
                          const SizedBox(width: 8)
                        ],
                        Expanded(
                            child: Platform.isWindows || Platform.isLinux
                                ? const WindowCaption()
                                : const SizedBox.expand())
                      ],
                    ),
                  ),
                  controller.isLoading
                      ? const LinearProgressIndicator()
                      : const SizedBox(height: 2),
                ],
              ),
            ),
          ),
        ),
        // TabBarView(
        //   controller: c.rootPageTabController,
        //   children: c.pages,
        // ),
        Expanded(child: widget.child)
      ]),
    );
  }
}

class _NavButton extends StatefulWidget {
  const _NavButton({
    required this.text,
    required this.icon,
    required this.selectIcon,
    required this.onPressed,
    required this.selected,
  });

  final String text;
  final IconData icon;
  final IconData selectIcon;
  final void Function() onPressed;
  final bool selected;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      mobileWidget: GestureDetector(
        onTap: widget.onPressed,
        behavior: HitTestBehavior.translucent,
        child: Stack(children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          (Container(
              color: context.moonTheme?.tabBarTheme.colors.selectedPillTabColor
                  .withAlpha(300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(children: [
                    const SizedBox(height: 5),
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: widget.selected || _hover
                            ? context.moonTheme?.tabBarTheme.colors
                                .selectedPillTabColor
                                .withAlpha(100)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          widget.selected || _hover
                              ? widget.selectIcon
                              : widget.icon,
                          color: widget.selected || _hover
                              ? context.moonTheme?.tabBarTheme.colors.textColor
                              : context.moonTheme?.tabBarTheme.colors.textColor
                                  .withAlpha(150),
                        ),
                      ),
                    ),
                    // Text(
                    //   widget.text,
                    //   style: const TextStyle(fontSize: 11),
                    // )
                  ])
                ],
              ))),
        ]),
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
              color: widget.selected || _hover
                  ? context.moonTheme?.tabBarTheme.colors.selectedPillTextColor
                      .withAlpha(20)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.selected || _hover ? widget.selectIcon : widget.icon,
                  color: widget.selected || _hover
                      ? context.moonColors?.bulma
                      : context.moonColors?.bulma.withAlpha(150),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class _NavObserver extends NavigatorObserver {
//   static bool isRoot = true;

//   @override
//   void didPop(Route route, Route? previousRoute) {
//     isRoot = previousRoute?.settings.name == null;
//     super.didPop(route, previousRoute);
//   }

//   @override
//   void didPush(Route route, Route? previousRoute) {
//     isRoot = route.settings.name == null;
//     super.didPush(route, previousRoute);
//   }
// }
