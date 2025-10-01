import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/application_controller_provider.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/theme/theme.dart';
import 'package:miru_app_new/widgets/core/outter_card.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:miru_app_new/utils/index.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

// abstract class SettingEntry {
//   final String key;
//   final List options;
//   SettingEntry(this.key,this.options);
// }

// class SingleOptionEntry extends SettingEntry {
//   SingleOptionEntry(super.key,super.options);
//   get setting => MiruSettings.ge
// }

class SettingDesktopGeneral extends HookConsumerWidget {
  const SettingDesktopGeneral({super.key});

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
                radios: ThemeUtils.accentToBright.keys
                    .map((e) => e.name)
                    .toList(),
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

class SettingMobileGeneral extends StatefulHookConsumerWidget {
  const SettingMobileGeneral({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      SettingMobileGeneralState();
}

class SettingMobileGeneralState extends ConsumerState<SettingMobileGeneral> {
  late final SnappingSheetController snappingSheetController =
      SnappingSheetController();
  @override
  Widget build(BuildContext context) {
    // Auto switch to desktop layout if has met layout condition

    final c = ref.read(applicationControllerProvider.notifier);
    return DeviceUtil.deviceWidget(
      context: context,
      desktop: SettingDesktopGeneral(),
      mobile: Column(
        children: [
          FHeader.nested(
            title: const Text('General'),
            titleAlignment: Alignment.center,
            prefixes: [
              FHeaderAction.back(
                onPress: () {
                  Navigator.of(context).pop();
                },
                onHoverChange: (hovered) {},
                onStateChange: (delta) {},
              ),
            ],
          ),
          Expanded(
            child: MiruListView(
              children: [
                FTileGroup(
                  label: const Text('Content'),
                  // description: const Text('Personalize your experience'),
                  // maxHeight: 200,
                  children: [
                    SettingsInputTile(
                      ismobile: true,
                      title: "tmdb-api-key",
                      subtitle: 'tmdb-api-key-subtitle',
                      initialValue: MiruSettings.getSettingSync<String>(
                        SettingKey.tmdbKey,
                      ),
                      onChanged: (value) {
                        MiruSettings.setSettingSync(SettingKey.tmdbKey, value);
                      },
                    ),

                    SettingsToggleTile(
                      ismobile: true,
                      title: 'allow-nsfw',
                      subtitle: 'allow-nsfw-subtitle',
                      value: MiruSettings.getSettingSync<bool>(
                        SettingKey.enableNSFW,
                      ),
                      onChanged: (value) {
                        MiruSettings.setSettingSync(
                          SettingKey.enableNSFW,
                          value.toString(),
                        );
                      },
                    ),
                  ],
                ),

                FTileGroup(
                  label: Text('appearance'),
                  children: [
                    SettingsRadiosTile.detailed(
                      isMobileLayout: true,
                      title: 'theme',
                      subtitle: 'theme-subtitle',
                      value: MiruSettings.getSettingSync<String>(
                        SettingKey.theme,
                      ),
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
                    SettingsRadiosTile(
                      isMobileLayout: true,
                      title: 'accent-color',
                      subtitle: 'accent-color-subtitle',
                      value: MiruSettings.getSettingSync<String>(
                        SettingKey.accentColor,
                      ),
                      onChanged: (val) {
                        c.changeAccentColor(val);
                        MiruSettings.setSettingSync(
                          SettingKey.accentColor,
                          val,
                        );
                      },
                      radios: ThemeUtils.accentToBright.keys
                          .map((e) => e.name)
                          .toList(),
                      color: ThemeUtils.accentToBright.map(
                        (key, value) =>
                            MapEntry(key.name, value.colors.primary),
                      ),
                    ),
                  ],
                ),
                FTileGroup(
                  label: Text('Others'),
                  children: [
                    SettingsToggleTile(
                      ismobile: true,
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
                      ismobile: true,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
