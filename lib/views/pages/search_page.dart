import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/extension/extension_utils.dart';
import 'package:miru_app_new/views/widgets/homepage/latest.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:moon_design/moon_design.dart';

class SearchPage extends HookWidget {
  const SearchPage({super.key, this.search});
  final String? search;
  static const _categories = ['Type', 'Language', 'Extension'];

  Widget buildCategories(List<String> items, void Function(int) onpress) {
    final selected = useState(0);
    return Column(
      children: [
        const SizedBox(height: 10),
        ...List.generate(
          items.length,
          (index) => SideBarListTile(
            title: items[index],
            selected: selected.value == index,
            onPressed: () {
              selected.value = index;
              onpress(index);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final needRefresh = useState(false);
    final controller = useTabController(
      initialIndex: 0,
      initialLength: _categories.length,
    );
    final editController = useTextEditingController();
    final scrollController = useScrollController();
    final searchValue = useState(search ?? '');
    return MiruScaffold(
      mobileHeader: const SideBarListTitle(title: 'Seach'),
      sidebar: DeviceUtil.device(
        mobile: <Widget>[
          //mobile
          SideBarSearchBar(
            controller: editController,
            onsubmitted: (val) {
              searchValue.value = val;
              needRefresh.value = !needRefresh.value;
            },
            trailing: MoonButton.icon(
              icon: const Icon(MoonIcons.controls_close_24_regular),
              onTap: () {
                editController.clear();
                searchValue.value = '';
                needRefresh.value = !needRefresh.value;
              },
            ),
          ),
          const SizedBox(height: 10),
          MoonTabBar(
            tabController: controller,
            tabs: List.generate(
              _categories.length,
              (index) => MoonTab(
                tabStyle: MoonTabStyle(
                  selectedTextColor:
                      context
                          .moonTheme
                          ?.segmentedControlTheme
                          .colors
                          .backgroundColor,
                ),
                label: Text(_categories[index]),
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: TabBarView(
              controller: controller,
              children: [
                CategoryGroup(
                  items: const ['ALL', 'Video', 'Manga', 'Novel'],
                  onpress: (val) {},
                ),
                CategoryGroup(items: const ['ALL'], onpress: (val) {}),
                CategoryGroup(items: const ['ALL'], onpress: (val) {}),
              ],
            ),
          ),
        ],
        desktop: [
          //desktop
          const SideBarListTitle(title: 'Search'),
          SideBarSearchBar(
            controller: editController,
            onsubmitted: (val) {
              searchValue.value = val;
              needRefresh.value = !needRefresh.value;
            },
            trailing: MoonButton.icon(
              icon: const Icon(MoonIcons.controls_close_24_regular),
              onTap: () {
                editController.clear();
                searchValue.value = '';
                needRefresh.value = !needRefresh.value;
              },
            ),
          ),
          const SizedBox(height: 10),
          SidebarExpander(
            title: "Type",
            expanded: true,
            child: CategoryGroup(
              needSpacer: false,
              items: const ['ALL', 'Video', 'Manga', 'Novel'],
              onpress: (val) {},
            ),
          ),
          const SizedBox(height: 15),
          SidebarExpander(
            title: 'Language',
            child: CategoryGroup(
              needSpacer: false,
              items: const ['ALL'],
              onpress: (val) {},
            ),
          ),
          const SizedBox(height: 15),
          SidebarExpander(
            title: 'Extension',
            child: CategoryGroup(
              needSpacer: false,
              items: const ['ALL'],
              onpress: (val) {},
            ),
          ),
          // MoonButton(
          //   onTap: () {
          //     needRefresh.value = !needRefresh.value;
          //   },
          //   label: const Text('刷新'),
          // )
        ],
        context: context,
      ),
      body: EasyRefresh(
        onRefresh: () {
          debugPrint('refresh');
          needRefresh.value = !needRefresh.value;
        },
        scrollController: scrollController,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final service = ExtensionUtils.runtimes.entries.toList();

            return MiruSingleChildView(
              controller: scrollController,
              child: Column(
                children: List.generate(
                  service.length,
                  (index) => Latest(
                    searchValue: searchValue,
                    needrefresh: needRefresh,
                    extensionService: service[index].value,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
