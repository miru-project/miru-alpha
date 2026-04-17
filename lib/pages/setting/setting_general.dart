import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:miru_alpha/utils/setting_dir_index.dart';

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
          title: 'settings_labels.content.name',
          children: [
            SettingsInputTile(
              isMobileLayout: isMobileLayout,
              title: "settings_labels.tmdb_api_key.name",
              subtitle: 'settings_labels.tmdb_api_key.information',
              initialValue: MiruSettings.getSettingSync<String>(
                SettingKey.tmdbKey,
              ),
              hintText: 'enter_tmdb_api_key',
              onChanged: (value) {
                MiruSettings.setSettingSync(SettingKey.tmdbKey, value);
              },
            ),

            SettingsRadiosTile(
              isMobileLayout: isMobileLayout,
              title: "settings_labels.language.name",
              subtitle: 'settings_labels.language.information',
              value: MiruSettings.getSettingSync<String>(SettingKey.language),
              onChanged: (value) {
                c.changeLanguage(value);
                I18nUtils.changeLanguage(value);
              },
              radios: ["en".i18n, "zh".i18n],
            ),

            SettingsToggleTile(
              isMobileLayout: isMobileLayout,
              title: 'settings_labels.allow_nsfw.name',
              subtitle: 'settings_labels.allow_nsfw.information',
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
          title: 'settings_labels.appearance.name',
          children: [
            SettingsRadiosTile.detailed(
              isMobileLayout: isMobileLayout,
              title: 'settings_labels.theme.name',
              subtitle: 'settings_labels.theme.information',
              value: MiruSettings.getSettingSync<String>(SettingKey.theme),
              onChanged: (val) => c.changeTheme(val),
              entry: const [
                RadioTileEntry(
                  value: 'system',
                  title: 'settings_labels.system',
                  icon: FIcons.sunMoon,
                ),
                RadioTileEntry(
                  value: 'light',
                  title: 'settings_labels.light',
                  icon: FIcons.sun,
                ),
                RadioTileEntry(
                  value: 'dark',
                  title: 'settings_labels.dark',
                  icon: FIcons.moon,
                ),
              ],
            ),
            SettingsRadiosTile(
              isMobileLayout: isMobileLayout,
              title: 'settings_labels.accent_color.name',
              subtitle: 'settings_labels.accent_color.information',
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
                (key, value) => MapEntry(
                  key.name,
                  ThemeUtils.getThemeData(value).colors.primary,
                ),
              ),
            ),
          ],
        ),
        SettingGroup(
          isMobileLayout: isMobileLayout,
          title: 'settings_labels.others.name',
          children: [
            SettingsToggleTile(
              isMobileLayout: isMobileLayout,
              title: 'settings_labels.auto_update.name',
              subtitle: 'settings_labels.auto_update.information',
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
              title: 'settings_labels.mobile_header_top.name',
              subtitle: 'settings_labels.mobile_header_top.information',
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
              title: 'settings_labels.show_page_number.name',
              subtitle: 'settings_labels.show_page_number.information',
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
