import 'package:flutter/material.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:miru_app_new/utils/index.dart';

enum SideBarName {
  general,
  extension,
  player,
  btServer,
  reader,
  advanced,
  about,
  tracking
}

class SettingItems extends StatefulWidget {
  const SettingItems({super.key, required this.selected});
  final SideBarName selected;

  @override
  createState() => _SettingItemsState();
}

class _SettingItemsState extends State<SettingItems> {
  final _nameMap = <SideBarName, List<Widget>>{
    SideBarName.general: [
      SettingsRadiosTile(
        title: "Radios Title",
        subtitle: "Radios Subtitle",
        radios: const ["Radio 1", "Radio 2", "Radio 3"],
        value: "Radio 1",
        onChanged: (value) {
          debugPrint(value);
        },
      ),
      const SizedBox(height: 16),
      SettingsInputTile(
          title: "repo-link",
          subtitle: 'repo-link-subtitle',
          initialValue:
              MiruStorage.getSettingSync(SettingKey.miruRepoUrl, String),
          onChanged: (value) {
            MiruStorage.setSettingSync(SettingKey.miruRepoUrl, value);
          }),
      SettingsInputTile(
          title: "tmdb-api-key",
          subtitle: 'tmdb-api-key-subtitle',
          initialValue: MiruStorage.getSettingSync(SettingKey.tmdbKey, String),
          onChanged: (value) {
            MiruStorage.setSettingSync(SettingKey.tmdbKey, value);
          }),
      SettingsToggleTile(
          title: 'auto-update',
          subtitle: 'auto-update-subtitle',
          value: MiruStorage.getSettingSync(SettingKey.autoCheckUpdate, bool),
          onChanged: (value) {
            MiruStorage.setSettingSync(
                SettingKey.autoCheckUpdate, value.toString());
          }),
      SettingsToggleTile(
          title: 'allow-nsfw',
          subtitle: 'allow-nsfw-subtitle',
          value: MiruStorage.getSettingSync(SettingKey.enableNSFW, bool),
          onChanged: (value) {
            MiruStorage.setSettingSync(SettingKey.enableNSFW, value.toString());
          })
    ],
    SideBarName.extension: [
      SettingsInputTile(
          title: 'extension-repo',
          subtitle: 'extension-repo-subtitle',
          initialValue:
              MiruStorage.getSettingSync(SettingKey.miruRepoUrl, String),
          onChanged: (value) {
            MiruStorage.setSettingSync(SettingKey.miruRepoUrl, value);
          }),
    ],
    SideBarName.btServer: [],
    SideBarName.reader: [
      SettingsRadiosTile(
        title: 'deafult-reader',
        subtitle: 'deafult-reader-subtitle',
        value: MiruStorage.getSettingSync(SettingKey.readingMode, String),
        radios: const ['Standard', 'Right to Left', 'Webtoon'],
        onChanged: (value) {
          MiruStorage.setSettingSync(SettingKey.readingMode, value);
        },
      )
    ],
    SideBarName.advanced: [],
    SideBarName.about: [],
    SideBarName.player: [],
    SideBarName.tracking: [],
  };
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MiruListView(children: _nameMap[widget.selected] ?? []);
  }
}
