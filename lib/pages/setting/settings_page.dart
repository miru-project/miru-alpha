import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/pages/setting/setting_general.dart';
import 'setting_extension.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'setting_items.dart';

class SettingsPage extends HookWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final select = useState(SideBarName.general);
    // Widget sideBarTile(String name, SideBarName selected) {
    //   return Column(
    //     children: [
    //       SideBarListTile(
    //         title: name,
    //         selected: select.value == selected,
    //         onPressed: () {
    //           select.value = selected;
    //         },
    //       ),
    //       const SizedBox(height: 8),
    //     ],
    //   );
    // }

    return MiruScaffold(
      mobileHeader: const SnapSheetHeader(title: 'Settings'),
      // sidebar: DeviceUtil.device(
      //   mobile: [
      //     sideBarTile('General', SideBarName.general),
      //     sideBarTile('Extension', SideBarName.extension),
      //     sideBarTile('Player', SideBarName.player),
      //     sideBarTile('BT Server', SideBarName.miruCore),
      //     sideBarTile('Reader', SideBarName.reader),
      //     sideBarTile('Advanced', SideBarName.advanced),
      //     sideBarTile('Download', SideBarName.download),
      //     sideBarTile('About', SideBarName.about),
      //   ],
      //   desktop: [
      //     const SideBarListTitle(title: 'Settings'),
      //     sideBarTile('General', SideBarName.general),
      //     sideBarTile('Extension', SideBarName.extension),
      //     sideBarTile('Player', SideBarName.player),
      //     sideBarTile('BT Server', SideBarName.miruCore),
      //     sideBarTile('Reader', SideBarName.reader),
      //     sideBarTile('Advanced', SideBarName.advanced),
      //     sideBarTile('Download', SideBarName.download),
      //     sideBarTile('About', SideBarName.about),
      //   ],
      //   context: context,
      // ),
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
        return SettingDesktopGeneral();
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

  Route<void> _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: Curves.ease));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  void _pushtoPage(BuildContext context, Widget page) =>
      Navigator.of(context).push(_createRoute(page));
  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      desktopWidget: selected(widget.selected, context),
      mobileWidget: FTileGroup(
        label: const Text('Settings'),
        description: const Text('Personalize your experience'),
        children: [
          FTile(
            prefix: Icon(FIcons.menu),
            title: const Text('General'),
            suffix: Icon(FIcons.chevronRight),
            subtitle: Text('Language, Theme, etc.'),
            onPress: () {
              _pushtoPage(context, SettingMobileGeneral());
            },
          ),
          FTile(
            prefix: Icon(FIcons.blocks),
            title: const Text('Extension'),
            subtitle: const Text('repos'),
            // details: const Text('Forus Labs (5G)'),
            suffix: Icon(FIcons.chevronRight),
            onPress: () {},
          ),
          FTile(
            prefix: Icon(FIcons.tv),
            title: const Text('Video Player'),
            subtitle: const Text('player setting'),
            // details: const Text('Forus Labs (5G)'),
            suffix: Icon(FIcons.chevronRight),
            onPress: () {},
          ),
        ],
      ),
    );
  }
}
