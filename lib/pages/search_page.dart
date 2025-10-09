import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_app_new/pages/search/desktop_search_page.dart';
import 'package:miru_app_new/pages/search/mobile_search_page.dart';
import 'package:miru_app_new/utils/core/device_util.dart';

class SearchPage extends HookWidget {
  const SearchPage({super.key, this.search});
  final String? search;
  // static const _categories = ['Type', 'Language', 'Extension'];

  // Widget buildCategories(List<String> items, void Function(int) onpress) {
  //   final selected = useState(0);
  //   return Column(
  //     children: [
  //       const SizedBox(height: 10),
  //       ...List.generate(
  //         items.length,
  //         (index) => SideBarListTile(
  //           title: items[index],
  //           selected: selected.value == index,
  //           onPressed: () {
  //             selected.value = index;
  //             onpress(index);
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // final needRefresh = useState(false);
    // final controller = useTabController(
    //   initialIndex: 0,
    //   initialLength: _categories.length,
    // );
    // final editController = useTextEditingController();
    // final scrollController = useScrollController();
    // final searchValue = useState(search ?? '');
    return DeviceUtil.deviceWidget(
      mobile: MobileSearchPage(),
      desktop: DesktopSearchPage(),
      context: context,
    );
  }
}
