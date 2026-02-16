import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app_new/pages/setting/setting_core.dart';
import 'package:miru_app_new/pages/setting/setting_general.dart';
import 'package:miru_app_new/pages/setting/widget/setting_scaffold.dart';
import 'package:miru_app_new/utils/router/router_util.dart';
import 'setting_extension.dart';
import 'package:miru_app_new/widgets/index.dart';
import '../../model/setting_items.dart';

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
        return SettingScaffold(title: 'General', child: SettingGeneral());
      case SideBarName.extension:
        return SettingScaffold(
          title: 'Repo Settings',
          child: SettingExtension(),
        );
      case SideBarName.player:
        // return SettingPlayer();
        return Center();
      case SideBarName.miruCore:
        return SettingMiruCore();
      case SideBarName.reader:
        // return SettingReader();
        return Center();
      case SideBarName.advanced:
        return Center();
      case SideBarName.about:
        return Center();
      case SideBarName.tracking:
        return Center();
      case SideBarName.download:
        // return SettingDownload();
        return Center();
    }
  }

  void _pushtoPage(BuildContext context, Widget page) =>
      Navigator.of(context).push(RouterUtil.createRoute(page));
  @override
  Widget build(BuildContext context) {
    return MiruScaffold(
      mobileHeader: SnapSheetHeader(title: 'Settings'),
      desktopBody: selected(widget.selected, context),
      mobileBody: ListView(
        children: [
          FTileGroup(
            label: Text("General Settings"),
            description: const Text('Personalize your experience'),
            children: [
              FTile(
                prefix: Icon(FIcons.menu),
                title: const Text('General'),
                suffix: Icon(FIcons.chevronRight),
                subtitle: Text('Language, Theme, etc.'),
                onPress: () {
                  _pushtoPage(
                    context,
                    SettingScaffold(
                      title: 'General',
                      child: SettingGeneral(isMobileLayout: true),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          FTileGroup(
            label: Text('Network Settings'),
            children: [
              FTile(
                prefix: Icon(FIcons.blocks),
                title: const Text('Extension'),
                subtitle: const Text('repos'),
                // details: const Text('Forus Labs (5G)'),
                suffix: Icon(FIcons.chevronRight),
                onPress: () {
                  _pushtoPage(
                    context,
                    SettingScaffold(
                      title: 'Repo Settings',
                      child: SettingExtension(isMobile: true),
                    ),
                  );
                },
              ),
              FTile(
                prefix: Icon(FIcons.serverCog),
                title: const Text('Miru Core Settings'),
                subtitle: const Text('network, download'),
                // details: const Text('Forus Labs (5G)'),
                suffix: Icon(FIcons.chevronRight),
                onPress: () {
                  _pushtoPage(
                    context,
                    SettingScaffold(
                      title: 'Miru Core',
                      child: SettingMiruCore(isMobileLayout: true),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          FTileGroup(
            label: Text("Watch Settings"),
            // description: const Text('Personalize your experience'),
            children: [
              FTile(
                prefix: Icon(FIcons.tv),
                title: const Text('Video Player'),
                subtitle: const Text('player setting'),
                // details: const Text('Forus Labs (5G)'),
                suffix: Icon(FIcons.chevronRight),
                onPress: () {},
              ),
              FTile(
                prefix: Icon(FIcons.bookOpen),
                title: const Text('Readers'),
                subtitle: const Text('Novels, Manga ...'),
                // details: const Text('Forus Labs (5G)'),
                suffix: Icon(FIcons.chevronRight),
                onPress: () {},
              ),
            ],
          ),
          FTileGroup(
            label: Text("About"),
            // description: const Text('Personalize your experience'),
            children: [
              FTile(
                prefix: Icon(FIcons.code),
                title: const Text('Licenses'),
                // details: const Text('Forus Labs (5G)'),
                suffix: Icon(FIcons.chevronRight),
                onPress: () {
                  context.push('/license');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
