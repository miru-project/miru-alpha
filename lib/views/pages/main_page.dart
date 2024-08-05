import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:miru_app_new/controllers/main_controller.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:moon_design/moon_design.dart';
import 'package:window_manager/window_manager.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final MainController c;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    c = Get.put(MainController(_tabController));
    _tabController.addListener(() {
      c.selectedIndex.value = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return PlatformWidget(
      mobileWidget: Scaffold(
        extendBody: true,
        body: PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;
            if (_NavObserver.isRoot) {
              SystemNavigator.pop();
            } else {
              Get.back(id: 1);
            }
          },
          child: Navigator(
            key: Get.nestedKey(1),
            observers: [_NavObserver()],
            onGenerateRoute: (settings) {
              return GetPageRoute(
                page: () => TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: c.rootPageTabController,
                  children: c.pages,
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: SizedBox(
              // decoration: BoxDecoration(
              //   color: Colors.white.withAlpha(200),
              //   border: const Border(
              //       top: BorderSide(color: Colors.black38, width: 0.5)),
              // ),
              height: 60,
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (var i = 0; i < c.navItems.length; i++) ...[
                      Expanded(
                        child: _NavButton(
                          selectIcon: c.navItems[i].selectIcon,
                          text: c.navItems[i].text,
                          icon: c.navItems[i].icon,
                          onPressed: () => c.selectIndex(i),
                          selected: c.selectedIndex.value == i,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      desktopBuilder: Scaffold(
        body: Obx(() {
          return Stack(
            children: [
              Navigator(
                key: Get.nestedKey(1),
                onGenerateRoute: (settings) {
                  return GetPageRoute(
                    page: () => TabBarView(
                      controller: c.rootPageTabController,
                      children: c.pages,
                    ),
                  );
                },
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: context
                            .moonTheme?.textAreaTheme.colors.backgroundColor,
                        border: const Border(
                          bottom: BorderSide(color: Colors.black38, width: 0.5),
                        ),
                      ),
                      height: 50,
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
                                            Get.back(id: 1);
                                          },
                                          trailing: [
                                            Icon(
                                              Icons.chevron_left,
                                              color: context
                                                  .moonTheme
                                                  ?.textAreaTheme
                                                  .colors
                                                  .textColor,
                                            ),
                                          ],
                                          child: Text(
                                            "Miru",
                                            style: TextStyle(
                                              color: context
                                                  .moonTheme
                                                  ?.textAreaTheme
                                                  .colors
                                                  .textColor,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                                for (var i = 0; i < c.navItems.length; i++) ...[
                                  _NavButton(
                                    selectIcon: c.navItems[i].selectIcon,
                                    text: c.navItems[i].text,
                                    icon: c.navItems[i].icon,
                                    onPressed: () => c.selectIndex(i),
                                    selected: c.selectedIndex.value == i,
                                  ),
                                  const SizedBox(width: 8)
                                ],
                                Expanded(
                                    child: Platform.isWindows
                                        ? const WindowCaption()
                                        : const SizedBox.expand())
                              ],
                            ),
                          ),
                          c.isLoading.value
                              ? const LinearProgressIndicator()
                              : const SizedBox(height: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
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
            color: context.theme.scaffoldBackgroundColor,
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
      desktopBuilder: MouseRegion(
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

class _NavObserver extends NavigatorObserver {
  static bool isRoot = true;

  @override
  void didPop(Route route, Route? previousRoute) {
    isRoot = previousRoute?.settings.name == null;
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    isRoot = route.settings.name == null;
    super.didPush(route, previousRoute);
  }
}
