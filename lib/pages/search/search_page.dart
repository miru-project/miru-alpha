import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_app_new/pages/search/desktop_search_page.dart';
import 'package:miru_app_new/pages/search/mobile_search_page.dart';
import 'package:miru_app_new/utils/core/device_util.dart';

class SearchPage extends HookWidget {
  const SearchPage({super.key, this.search});
  final String? search;
  @override
  Widget build(BuildContext context) {
    return DeviceUtil.deviceWidget(
      mobile: MobileSearchPage(),
      desktop: DesktopSearchPage(),
      context: context,
    );
  }
}
