import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/application_controller_provider.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/theme/theme.dart';
import 'package:miru_app_new/widgets/core/setting_card.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:miru_app_new/utils/index.dart';

class SettingGeneral extends HookConsumerWidget {
  const SettingGeneral({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(applicationControllerProvider.notifier);
    return MiruListView(
      children: [
        SettingCard(
          title: 'content',
          child: Column(
            children: [
              SettingsInputTile(
                title: "tmdb-api-key",
                subtitle: 'tmdb-api-key-subtitle',
                initialValue: MiruStorage.getSettingSync<String>(
                  SettingKey.tmdbKey,
                ),
                onChanged: (value) {
                  MiruStorage.setSettingSync(SettingKey.tmdbKey, value);
                },
              ),
              FDivider(),
              SettingsToggleTile(
                title: 'allow-nsfw',
                subtitle: 'allow-nsfw-subtitle',
                value: MiruStorage.getSettingSync<bool>(SettingKey.enableNSFW),
                onChanged: (value) {
                  MiruStorage.setSettingSync(
                    SettingKey.enableNSFW,
                    value.toString(),
                  );
                },
              ),
            ],
          ),
        ),

        SettingCard(
          title: 'appearance',
          child: Column(
            children: [
              SettingsRadiosTile.detailed(
                title: 'theme',
                subtitle: 'theme-subtitle',
                value: MiruStorage.getSettingSync<String>(SettingKey.theme),
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
                value: MiruStorage.getSettingSync<String>(
                  SettingKey.accentColor,
                ),
                onChanged: (val) {
                  c.changeAccentColor(val);
                  MiruStorage.setSettingSync(SettingKey.accentColor, val);
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
        SettingCard(
          title: 'others',
          child: Column(
            children: [
              SettingsToggleTile(
                title: 'auto-update',
                subtitle: 'auto-update-subtitle',
                value: MiruStorage.getSettingSync<bool>(
                  SettingKey.autoCheckUpdate,
                ),
                onChanged: (value) {
                  MiruStorage.setSettingSync(
                    SettingKey.autoCheckUpdate,
                    value.toString(),
                  );
                },
              ),

              if (DeviceUtil.isMobileLayout(context))
                SettingsToggleTile(
                  title: 'mobile-title-position',
                  subtitle: 'mobile-title-position-subtitle',
                  value: MiruStorage.getSettingSync<bool>(
                    SettingKey.mobiletitleIsonTop,
                  ),
                  onChanged: (value) {
                    MiruStorage.setSettingSync(
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
