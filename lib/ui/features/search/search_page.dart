import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_alpha/ui/features/search/desktop_search_page.dart';
import 'package:miru_alpha/ui/features/search/mobile_search_page.dart';
import 'package:miru_alpha/utils/core/device_util.dart';

class SearchPage extends HookWidget {
  const SearchPage({super.key, this.search});
  final String? search;
  @override
  Widget build(BuildContext context) {
    return DeviceUtil.deviceWidget(
      mobile: MobileSearchPage(),
      desktop: DesktopSearchPage(search: search),
      context: context,
    );
  }
}
