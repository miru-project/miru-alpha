import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../pages/extension/extension_page.dart';
import '../../pages/home/home_page.dart';
import '../../pages/search_page.dart';
import '../../pages/setting/settings_page.dart';

final mainControllerProvider = NotifierProvider<MainController, MainState>(
  MainController.new,
);

class MainState {
  final int selectedIndex;
  final bool isLoading;

  MainState({required this.selectedIndex, required this.isLoading});

  MainState copyWith({int? selectedIndex, bool? isLoading}) {
    return MainState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MainController extends Notifier<MainState> {
  @override
  MainState build() {
    return MainState(selectedIndex: 0, isLoading: false);
  }

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
    // required this.selectIcon,
  });

  final String text;
  final IconData icon;
  // final IconData selectIcon;
}
