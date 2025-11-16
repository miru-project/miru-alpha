import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/application_controller_provider.dart';
import 'package:miru_app_new/utils/theme/theme.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:miru_app_new/utils/setting_dir_index.dart';

class SettingGeneral extends HookConsumerWidget {
  const SettingGeneral({super.key, this.isMobileLayout = false});
  final bool isMobileLayout;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(applicationControllerProvider.notifier);
    return MiruListView(
      children: [
        SettingGroup(
          isMobileLayout: isMobileLayout,
          title: 'Content',
          children: [
            SettingsInputTile(
              isMobileLayout: isMobileLayout,
              title: "TMDB api key",
              subtitle: 'api for tmdb-api',
              initialValue: MiruSettings.getSettingSync<String>(
                SettingKey.tmdbKey,
              ),
              onChanged: (value) {
                MiruSettings.setSettingSync(SettingKey.tmdbKey, value);
              },
            ),

            SettingsToggleTile(
              isMobileLayout: isMobileLayout,
              title: 'allow-nsfw',
              subtitle: 'allow-nsfw-subtitle',
              value: MiruSettings.getSettingSync<bool>(SettingKey.enableNSFW),
              onChanged: (value) {
                MiruSettings.setSettingSync(
                  SettingKey.enableNSFW,
                  value.toString(),
                );
              },
            ),
          ],
        ),

        SettingGroup(
          isMobileLayout: isMobileLayout,
          title: 'Appearance',
          children: [
            SettingsRadiosTile.detailed(
              isMobileLayout: isMobileLayout,
              title: 'theme',
              subtitle: 'theme-subtitle',
              value: MiruSettings.getSettingSync<String>(SettingKey.theme),
              onChanged: (val) => c.changeTheme(val),
              entry: const [
                RadioTileEntry(
                  value: 'system',
                  title: 'system',
                  icon: FIcons.sunMoon,
                ),
                RadioTileEntry(
                  value: 'light',
                  title: 'light',
                  icon: FIcons.sun,
                ),
                RadioTileEntry(value: 'dark', title: 'dark', icon: FIcons.moon),
              ],
            ),
            SettingsRadiosTile(
              isMobileLayout: isMobileLayout,
              title: 'accent-color',
              subtitle: 'accent-color-subtitle',
              value: MiruSettings.getSettingSync<String>(
                SettingKey.accentColor,
              ),
              onChanged: (val) {
                c.changeAccentColor(val);
                MiruSettings.setSettingSync(SettingKey.accentColor, val);
              },
              radios: ThemeUtils.accentToBright.keys
                  .map((e) => e.name)
                  .toList(),
              color: ThemeUtils.accentToBright.map(
                (key, value) => MapEntry(key.name, value.colors.primary),
              ),
            ),
          ],
        ),
        SettingGroup(
          isMobileLayout: isMobileLayout,
          title: 'Others',
          children: [
            SettingsToggleTile(
              isMobileLayout: isMobileLayout,
              title: 'auto-update',
              subtitle: 'auto-update-subtitle',
              value: MiruSettings.getSettingSync<bool>(
                SettingKey.autoCheckUpdate,
              ),
              onChanged: (value) {
                MiruSettings.setSettingSync(
                  SettingKey.autoCheckUpdate,
                  value.toString(),
                );
              },
            ),

            SettingsToggleTile(
              isMobileLayout: isMobileLayout,
              title: 'Mobile header always on top',
              subtitle: 'make the app bar header always on top in mobile',
              value: MiruSettings.getSettingSync<bool>(
                SettingKey.mobiletitleIsonTop,
              ),
              onChanged: (value) {
                ref
                    .read(applicationControllerProvider.notifier)
                    .updateMobileTitleOnTop(value);
              },
            ),
            SettingsToggleTile(
              isMobileLayout: isMobileLayout,
              title: 'Show page number',
              subtitle: 'Show page number in Search / Latest',
              value: MiruSettings.getSettingSync<bool>(
                SettingKey.showPageNumber,
              ),
              onChanged: (value) {
                MiruSettings.setSettingSync(
                  SettingKey.showPageNumber,
                  value.toString(),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
