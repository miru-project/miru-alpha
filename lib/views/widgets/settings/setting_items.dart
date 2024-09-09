import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/controllers/application_controller.dart';
import 'package:miru_app_new/utils/theme/theme.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:miru_app_new/utils/index.dart';
import 'package:moon_design/moon_design.dart';

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

// class SettingItems extends StatefulWidget {
//   const SettingItems({super.key, required this.selected});
//   final SideBarName selected;

//   @override
//   createState() => _SettingItemsState();
// }

class SettingItems extends ConsumerWidget {
  const SettingItems({super.key, required this.selected});
  final SideBarName selected;
  @override
  Widget build(BuildContext context, ref) {
    final c = ref.read(applicationControllerProvider.notifier);
    final nameMap = <SideBarName, List<Widget>>{
      SideBarName.general: [
        // SettingsRadiosTile(
        //   title: "Radios Title",
        //   subtitle: "Radios Subtitle",
        //   radios: const ["Radio 1", "Radio 2", "Radio 3"],
        //   value: "Radio 1",
        //   onChanged: (value) {
        //     debugPrint(value);
        //   },
        // ),
        // const SizedBox(height: 16),
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
              MiruStorage.setSettingSync(
                  SettingKey.enableNSFW, value.toString());
            }),
        SettingsToggleTile(
            title: 'mobile-title-position',
            subtitle: 'mobile-title-position-subtitle',
            value:
                MiruStorage.getSettingSync(SettingKey.mobiletitleIsonTop, bool),
            onChanged: (value) {
              MiruStorage.setSettingSync(
                  SettingKey.mobiletitleIsonTop, value.toString());
            }),
        SettingSegmentControll(
          title: 'theme',
          subtitle: 'theme-subtitle',
          onchange: (value) {
            c.changeTheme(c.themeList[value]);
          },
          initValue: c.themeList
              .indexOf(MiruStorage.getSettingSync(SettingKey.theme, String)),
          segments: const [
            Icon(MoonIcons.generic_settings_24_regular),
            Icon(MoonIcons.other_moon_24_regular),
            Icon(MoonIcons.other_sun_24_regular),
          ],
        ),
        MoonAccordion(
          accordionSize: MoonAccordionSize.md,
          hasContentOutside: true,
          showBorder: false,
          shadows: const [],
          initiallyExpanded: true,
          backgroundColor: Colors.transparent,
          // childrenPadding: const EdgeInsets.only(top: 8, bottom: 8, left: 24),
          label: const Text('accent-color'),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                  ThemeUtils.accentToMoonColorBright.keys.length,
                  (index) => GestureDetector(
                      onTap: () {
                        final color =
                            ThemeUtils.settingToAccentColor.keys.toList();
                        c.changeAccentColor(color[index]);
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: c.theme == ThemeMode.light
                                ? ThemeUtils.accentToMoonColorBright.values
                                    .elementAt(index)
                                : ThemeUtils.accentToMoonColorDark.values
                                    .elementAt(index)),
                      ))),
            )
          ],
        )
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
    return MiruListView(children: nameMap[selected] ?? []);
  }
}
