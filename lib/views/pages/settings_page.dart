import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import '../widgets/settings/setting_items.dart';

class SettingsPage extends HookWidget {
  const SettingsPage({super.key});

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
      mobileHeader: const SideBarListTitle(title: 'Settings'),
      sidebar: DeviceUtil.device(mobile: [
        sideBarTile('General', SideBarName.general),
        sideBarTile('Extension', SideBarName.extension),
        sideBarTile('Player', SideBarName.player),
        sideBarTile('BT Server', SideBarName.btServer),
        sideBarTile('Reader', SideBarName.reader),
        sideBarTile('Advanced', SideBarName.advanced),
        sideBarTile('Download', SideBarName.download),
        sideBarTile('About', SideBarName.about),
      ], desktop: [
        const SideBarListTitle(title: 'Settings'),
        sideBarTile('General', SideBarName.general),
        sideBarTile('Extension', SideBarName.extension),
        sideBarTile('Player', SideBarName.player),
        sideBarTile('BT Server', SideBarName.btServer),
        sideBarTile('Reader', SideBarName.reader),
        sideBarTile('Advanced', SideBarName.advanced),
        sideBarTile('Download', SideBarName.download),
        sideBarTile('About', SideBarName.about),
      ], context: context),
      body: SettingItems(selected: select.value),
    );
  }
}
