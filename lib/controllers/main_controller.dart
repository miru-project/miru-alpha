import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/views/pages/extension_page.dart';
import 'package:miru_app_new/views/pages/home_page.dart';
import 'package:miru_app_new/views/pages/search_page.dart';
import 'package:miru_app_new/views/pages/settings_page.dart';

final mainControllerProvider = StateNotifierProvider<MainController, MainState>(
  (ref) => MainController(),
);

class MainState {
  final int selectedIndex;
  final bool isLoading;

  MainState({
    required this.selectedIndex,
    required this.isLoading,
  });

  MainState copyWith({
    int? selectedIndex,
    bool? isLoading,
  }) {
    return MainState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MainController extends StateNotifier<MainState> {
  MainController()
      : super(MainState(
          selectedIndex: 0,
          isLoading: false,
        ));

  final List<Widget> pages = const [
    HomePage(),
    SearchPage(),
    ExtensionPage(),
    SettingsPage(),
  ];

  late final TabController rootPageTabController;

  void initTabController(TickerProvider vsync) {
    rootPageTabController = TabController(length: pages.length, vsync: vsync);
  }

  void selectIndex(int index) {
    state = state.copyWith(selectedIndex: index);
    // rootPageTabController.animateTo(index);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
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
