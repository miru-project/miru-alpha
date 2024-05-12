import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app_new/views/pages/extension_page.dart';
import 'package:miru_app_new/views/pages/home_page.dart';
import 'package:miru_app_new/views/pages/search_page.dart';
import 'package:miru_app_new/views/pages/settings_page.dart';

class MainController extends GetxController {
  MainController(
    this.rootPageTabController,
  );

  final TabController rootPageTabController;

  static MainController get to => Get.find();

  final List<Widget> pages = const [
    HomePage(),
    SearchPage(),
    ExtensionPage(),
    SettingsPage(),
  ];

  final List<NavItem> navItems = const [
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

  final RxInt selectedIndex = 0.obs;

  void selectIndex(int index) {
    Get.until((route) => route.settings.name == null, id: 1);
    selectedIndex.value = index;
    rootPageTabController.animateTo(index);
  }

  final RxBool isLoading = false.obs;

  Future<void> handleFutureFuture(Future Function() fun) async {
    isLoading.value = true;
    try {
      await fun();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class NavItem {
  const NavItem({
    required this.text,
    required this.icon,
    required this.selectIcon,
  });

  final String text;
  final IconData icon;
  final IconData selectIcon;
}
