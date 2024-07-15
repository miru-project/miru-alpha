import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import '../widgets/settings/setting_items.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Rx<SideBarName> select = SideBarName.general.obs;
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

    return Obx(() => MiruScaffold(
          appBar: const MiruAppBar(
            title: Text('Settings'),
          ),
          sidebar: [
            sideBarTile('General', SideBarName.general),
            sideBarTile('Extension', SideBarName.extension),
            sideBarTile('Player', SideBarName.player),
            sideBarTile('BT Server', SideBarName.btServer),
            sideBarTile('Reader', SideBarName.reader),
            sideBarTile('Advanced', SideBarName.advanced),
            sideBarTile('About', SideBarName.about),
          ],
          body: SettingItems(selected: select.value),
        ));
  }
}
