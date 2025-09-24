import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/application_controller_provider.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/theme/theme.dart';
import 'package:miru_app_new/widgets/core/outter_card.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:miru_app_new/utils/index.dart';

class SettingGeneral extends HookConsumerWidget {
  const SettingGeneral({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(applicationControllerProvider.notifier);
    return MiruListView(
      children: [
        OutterCard(
          title: 'content',
          child: Column(
            children: [
              SettingsInputTile(
                title: "tmdb-api-key",
                subtitle: 'tmdb-api-key-subtitle',
                initialValue: MiruSettings.getSettingSync<String>(
                  SettingKey.tmdbKey,
                ),
                onChanged: (value) {
                  MiruSettings.setSettingSync(SettingKey.tmdbKey, value);
                },
              ),
              FDivider(),
              SettingsToggleTile(
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
        ),

        OutterCard(
          title: 'appearance',
          child: Column(
            children: [
              SettingsRadiosTile.detailed(
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
                  RadioTileEntry(
                    value: 'dark',
                    title: 'dark',
                    icon: FIcons.moon,
                  ),
                ],
              ),
              FDivider(),
              SettingsRadiosTile(
                title: 'accent-color',
                subtitle: 'accent-color-subtitle',
                value: MiruSettings.getSettingSync<String>(
                  SettingKey.accentColor,
                ),
                onChanged: (val) {
                  c.changeAccentColor(val);
                  MiruSettings.setSettingSync(SettingKey.accentColor, val);
                },
                radios:
                    ThemeUtils.accentToBright.keys.map((e) => e.name).toList(),
                color: ThemeUtils.accentToBright.map(
                  (key, value) => MapEntry(key.name, value.colors.primary),
                ),
              ),
            ],
          ),
        ),
        OutterCard(
          title: 'others',
          child: Column(
            children: [
              SettingsToggleTile(
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

              if (DeviceUtil.isMobileLayout(context))
                SettingsToggleTile(
                  title: 'mobile-title-position',
                  subtitle: 'mobile-title-position-subtitle',
                  value: MiruSettings.getSettingSync<bool>(
                    SettingKey.mobiletitleIsonTop,
                  ),
                  onChanged: (value) {
                    MiruSettings.setSettingSync(
                      SettingKey.mobiletitleIsonTop,
                      value.toString(),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
