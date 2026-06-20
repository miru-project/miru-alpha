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
    return ListView(
      padding: .all(0),
      children: [
        SettingGroup(
          isMobileLayout: isMobileLayout,
          title: 'settings.labels.content.name',
          children: [
            SettingsInputTile(
              isMobileLayout: isMobileLayout,
              title: "settings.labels.tmdb_api_key.name",
              subtitle: 'settings.labels.tmdb_api_key.information',
              initialValue: MiruSettings.getSettingSync<String>(
                SettingKey.tmdbKey,
              ),
              hintText: 'settings.labels.tmdb_api_key.hint',
              onChanged: (value) {
                MiruSettings.setSettingSync(SettingKey.tmdbKey, value);
              },
            ),

            SettingsRadiosTile.detailed(
              isMobileLayout: isMobileLayout,
              title: "settings.labels.language.name",
              subtitle: 'settings.labels.language.information',
              value: MiruSettings.getSettingSync<String>(SettingKey.language),
              onChanged: (value) {
                c.changeLanguage(value);
                I18nUtils.changeLanguage(value);
              },
              entry: const [
                RadioTileEntry(value: 'en', title: 'settings.labels.en'),
                RadioTileEntry(value: 'zh', title: 'settings.labels.zh'),
              ],
            ),

            SettingsToggleTile(
              isMobileLayout: isMobileLayout,
              title: 'settings.labels.allow_nsfw.name',
              subtitle: 'settings.labels.allow_nsfw.information',
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
          title: 'settings.labels.appearance.name',
          children: [
            SettingsRadiosTile.detailed(
              isMobileLayout: isMobileLayout,
              title: 'settings.labels.theme.name',
              subtitle: 'settings.labels.theme.information',
              value: MiruSettings.getSettingSync<String>(SettingKey.theme),
              onChanged: (val) => c.changeTheme(val),
              entry: const [
                RadioTileEntry(
                  value: 'system',
                  title: 'settings.labels.system',
                  icon: FLucideIcons.sunMoon,
                ),
                RadioTileEntry(
                  value: 'light',
                  title: 'settings.labels.light',
                  icon: FLucideIcons.sun,
                ),
                RadioTileEntry(
                  value: 'dark',
                  title: 'settings.labels.dark',
                  icon: FLucideIcons.moon,
                ),
              ],
            ),
            SettingsRadiosTile.detailed(
              isMobileLayout: isMobileLayout,
              title: 'settings.labels.accent_color.name',
              subtitle: 'settings.labels.accent_color.information',
              value: MiruSettings.getSettingSync<String>(
                SettingKey.accentColor,
              ),
              onChanged: (val) {
                c.changeAccentColor(val);
                MiruSettings.setSettingSync(SettingKey.accentColor, val);
              },
              entry: ThemeUtils.accentToBright.keys
                  .map(
                    (e) => RadioTileEntry(
                      value: e.name,
                      title: 'settings.labels.${e.name}',
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        SettingGroup(
          isMobileLayout: isMobileLayout,
          title: 'settings.labels.others.name',
          children: [
            SettingsToggleTile(
              isMobileLayout: isMobileLayout,
              title: 'settings.labels.auto_update.name',
              subtitle: 'settings.labels.auto_update.information',
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
              title: 'settings.labels.mobile_header_top.name',
              subtitle: 'settings.labels.mobile_header_top.information',
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
              title: 'settings.labels.show_page_number.name',
              subtitle: 'settings.labels.show_page_number.information',
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
