import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_alpha/pages/setting/setting_core.dart';
import 'package:miru_alpha/pages/setting/setting_general.dart';
import 'package:miru_alpha/utils/router/router_util.dart';
import 'setting_extension.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/widgets/index.dart';
import '../../model/setting_items.dart';

class SettingsPage extends HookWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final select = useState(SideBarName.general);
    return MiruScaffold(
      mobileHeader: SnapSheetHeader(title: 'settings'.i18n),
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
        return SettingScaffold(title: 'general'.i18n, child: SettingGeneral());
      case SideBarName.extension:
        return SettingScaffold(
          title: 'repo_settings'.i18n,
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
      mobileHeader: SnapSheetHeader(title: 'settings'.i18n),
      desktopBody: selected(widget.selected, context),
      mobileBody: ListView(
        children: [
          FTileGroup(
            label: Text("general_settings".i18n),
            description: Text('personalize_experience'.i18n),
            children: [
              FTile(
                prefix: Icon(FIcons.menu),
                title: Text('general'.i18n),
                suffix: Icon(FIcons.chevronRight),
                subtitle: Text('language_theme_etc'.i18n),
                onPress: () {
                  _pushtoPage(
                    context,
                    SettingScaffold(
                      title: 'general'.i18n,
                      child: SettingGeneral(isMobileLayout: true),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          FTileGroup(
            label: Text('network_settings'.i18n),
            children: [
              FTile(
                prefix: Icon(FIcons.blocks),
                title: Text('extension'.i18n),
                subtitle: Text('repos'.i18n),
                // details: const Text('Forus Labs (5G)'),
                suffix: Icon(FIcons.chevronRight),
                onPress: () {
                  _pushtoPage(
                    context,
                    SettingScaffold(
                      title: 'repo_settings'.i18n,
                      child: SettingExtension(isMobile: true),
                    ),
                  );
                },
              ),
              FTile(
                prefix: Icon(FIcons.serverCog),
                title: Text('miru_core_settings'.i18n),
                subtitle: Text('network_download'.i18n),
                // details: const Text('Forus Labs (5G)'),
                suffix: Icon(FIcons.chevronRight),
                onPress: () {
                  _pushtoPage(
                    context,
                    SettingScaffold(
                      title: 'miru_core'.i18n,
                      child: SettingMiruCore(isMobileLayout: true),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          FTileGroup(
            label: Text("watch_settings".i18n),
            // description: const Text('Personalize your experience'),
            children: [
              FTile(
                prefix: Icon(FIcons.tv),
                title: Text('video_player'.i18n),
                subtitle: Text('player_setting'.i18n),
                // details: const Text('Forus Labs (5G)'),
                suffix: Icon(FIcons.chevronRight),
                onPress: () {},
              ),
              FTile(
                prefix: Icon(FIcons.bookOpen),
                title: Text('readers'.i18n),
                subtitle: Text('novels_manga'.i18n),
                // details: const Text('Forus Labs (5G)'),
                suffix: Icon(FIcons.chevronRight),
                onPress: () {},
              ),
            ],
          ),
          FTileGroup(
            label: Text("about".i18n),
            // description: const Text('Personalize your experience'),
            children: [
              FTile(
                prefix: Icon(FIcons.code),
                title: Text('licenses'.i18n),
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
