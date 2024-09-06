import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import '../widgets/settings/setting_items.dart';

class SettingsPage extends HookWidget {
  const SettingsPage({super.key});
  // static const _categories = [
  //   'General',
  //   'Extension',
  //   'Player',
  //   'BT Server',
  //   'Reader',
  //   'Advanced',
  //   'About'
  // ];
  // static const _icon = [
  //   MoonIcons.generic_menu_32_regular,
  //   MoonIcons.software_puzzle_24_regular,
  //   MoonIcons.media_play_24_regular,
  //   Icons.polyline_rounded,
  //   Icons.book_rounded,
  //   MoonIcons.software_settings_24_regular,
  //   MoonIcons.generic_about_24_regular,
  // ];
  @override
  Widget build(BuildContext context) {
    final select = useState(SideBarName.general);
    Widget sideBarTile(String name, SideBarName selected) {
      return Column(children: [
        SideBarListTile(
          title: name,
          selected: select.value == selected,
          onPressed: () {
            select.value = selected;
          },
        ),
        const SizedBox(height: 8),
      ]);
    }

    return MiruScaffold(
      sidebar: [
        const SideBarListTitle(title: 'Settings'),
        // (MoonTabBar(
        //   tabs: List.generate(
        //       _categories.length,
        //       (index) => MoonTab(
        //           tabStyle:
        //               MoonTabStyle(tabPadding: EdgeInsets.all(10), tabGap: 0),
        //           label: Icon(size: 35, _icon[index]))),
        // ))
        sideBarTile('General', SideBarName.general),
        sideBarTile('Extension', SideBarName.extension),
        sideBarTile('Player', SideBarName.player),
        sideBarTile('BT Server', SideBarName.btServer),
        sideBarTile('Reader', SideBarName.reader),
        sideBarTile('Advanced', SideBarName.advanced),
        sideBarTile('About', SideBarName.about),
        // Row(
        //   children: List.generate(
        //       _icon.length,
        //       (index) => Icon(
        //             _icon[index],
        //             size: 50,
        //           )),
        // )
      ],
      body: SettingItems(selected: select.value),
    );
  }
}
