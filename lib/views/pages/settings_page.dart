import 'package:flutter/material.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:miru_app_new/utils/index.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MiruScaffold(
      appBar: const MiruAppBar(
        title: Text('Settings'),
      ),
      sidebar: [
        const SideBarListTitle(title: '设置'),
        SideBarListTile(
          title: '基本',
          selected: true,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        SideBarListTile(
          title: '扩展',
          selected: false,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        SideBarListTile(
          title: '播放器',
          selected: false,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        SideBarListTile(
          title: 'BT Server',
          selected: false,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        SideBarListTile(
          title: '阅读器',
          selected: false,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        SideBarListTile(
          title: '高级',
          selected: false,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        SideBarListTile(
          title: '关于软件',
          selected: false,
          onPressed: () {},
        ),
      ],
      body: MiruListView(
        maxWidth: 1000,
        children: [
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
              initialValue:
                  MiruStorage.getSettingSync(SettingKey.tmdbKey, String),
              onChanged: (value) {
                MiruStorage.setSettingSync(SettingKey.tmdbKey, value);
              }),
          SettingsToggleTile(
              title: 'auto-update',
              subtitle: 'auto-update-subtitle',
              value:
                  MiruStorage.getSettingSync(SettingKey.autoCheckUpdate, bool),
              onChanged: (value) {
                MiruStorage.setSettingSync(
                    SettingKey.autoCheckUpdate, value.toString());
              }),
          SettingsToggleTile(
              title: 'allow-nsfw',
              subtitle: 'allow-nsfw-subtitle',
              value: MiruStorage.getSettingSync(SettingKey.enableNSFW, bool),
              onChanged: (value) {
                MiruStorage.setSettingSync(
                    SettingKey.enableNSFW, value.toString());
              })
        ],
      ),
    );
  }
}
