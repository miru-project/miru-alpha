import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/views/pages/setting/setting_extension.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'setting_items.dart';

class SettingsPage extends HookWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final select = useState(SideBarName.general);
    Widget sideBarTile(String name, SideBarName selected) {
      return Column(
        children: [
          SideBarListTile(
            title: name,
            selected: select.value == selected,
            onPressed: () {
              select.value = selected;
            },
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    return MiruScaffold(
      mobileHeader: const SideBarListTitle(title: 'Settings'),
      sidebar: DeviceUtil.device(
        mobile: [
          sideBarTile('General', SideBarName.general),
          sideBarTile('Extension', SideBarName.extension),
          sideBarTile('Player', SideBarName.player),
          sideBarTile('BT Server', SideBarName.miruCore),
          sideBarTile('Reader', SideBarName.reader),
          sideBarTile('Advanced', SideBarName.advanced),
          sideBarTile('Download', SideBarName.download),
          sideBarTile('About', SideBarName.about),
        ],
        desktop: [
          const SideBarListTitle(title: 'Settings'),
          sideBarTile('General', SideBarName.general),
          sideBarTile('Extension', SideBarName.extension),
          sideBarTile('Player', SideBarName.player),
          sideBarTile('BT Server', SideBarName.miruCore),
          sideBarTile('Reader', SideBarName.reader),
          sideBarTile('Advanced', SideBarName.advanced),
          sideBarTile('Download', SideBarName.download),
          sideBarTile('About', SideBarName.about),
        ],
        context: context,
      ),
      body: SettingPage(selected: select.value),
    );
  }
}

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key, required this.selected});
  final SideBarName selected;
  @override
  createState() => _SettingItemsState();
}

class _SettingItemsState extends ConsumerState<SettingPage> {
  Widget selected(SideBarName name, BuildContext context) {
    switch (name) {
      case SideBarName.general:
        return SettingGeneral();
      case SideBarName.extension:
        return SettingExtension();
      case SideBarName.player:
        return SettingPlayer();
      case SideBarName.miruCore:
        return SettingMiruCore();
      case SideBarName.reader:
        return SettingReader();
      case SideBarName.advanced:
        return Center();
      case SideBarName.about:
        return Center();
      case SideBarName.tracking:
        return Center();
      case SideBarName.download:
        return SettingDownload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(desktopWidget: selected(widget.selected, context), mobileWidget: Center());
  }
}
