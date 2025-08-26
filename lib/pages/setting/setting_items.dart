import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/application_controller_provider.dart';
import 'package:miru_app_new/utils/btserver.dart';
import 'package:miru_app_new/utils/device_util.dart';
import 'package:miru_app_new/utils/theme/theme.dart';
import 'package:miru_app_new/widgets/core/setting_card.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:miru_app_new/utils/index.dart';
import 'package:moon_design/moon_design.dart';

enum SideBarName { general, extension, player, miruCore, reader, advanced, about, tracking, download }

class SettingPlayer extends HookWidget {
  const SettingPlayer({super.key});
  @override
  Widget build(BuildContext context) {
    return MiruListView(
      children: [
        SettingsInputTile(
          title: 'btserver-download-link',
          subtitle: 'btserver-download-link-sub',
          initialValue: MiruStorage.getSettingSync(SettingKey.btServerLink, String),
          onChanged: (val) {
            MiruStorage.setSettingSync(SettingKey.btServerLink, val);
          },
        ),
        ListenableBuilder(
          listenable: btServerNotifier,
          builder:
              (context, child) => MoonMenuItem(
                onTap: () {},
                content: const Text('bt-server-subtitle'),
                label: const Text('bt-server'),
                trailing: Row(
                  children: [
                    if (btServerNotifier.isInstalled)
                      MoonButton(
                        label: const Text('uninstall'),
                        onTap: () {
                          btServerNotifier.uninstallServer();
                        },
                      )
                    else if (btServerNotifier.isDownloading)
                      MoonButton(label: Text('${(btServerNotifier.progress.toStringAsFixed(1))}%'), onTap: () {})
                    else
                      MoonButton(
                        label: const Text('install'),
                        onTap: () {
                          btServerNotifier.downloadOrUpgradeServer(context);
                        },
                      ),
                  ],
                ),
              ),
        ),
      ],
    );
  }
}

class SettingMiruCore extends HookWidget {
  const SettingMiruCore({super.key});
  @override
  Widget build(BuildContext context) {
    return MiruListView(
      children: [
        // FAlert(title: const Text('miru-core-running')),
        SettingsInputTile(
          title: 'btserver-download-link',
          subtitle: 'btserver-download-link-sub',
          initialValue: MiruStorage.getSettingSync(SettingKey.btServerLink, String),
          onChanged: (val) {
            MiruStorage.setSettingSync(SettingKey.btServerLink, val);
          },
        ),
        ListenableBuilder(
          listenable: btServerNotifier,
          builder:
              (context, child) => MoonMenuItem(
                onTap: () {},
                content: const Text('bt-server-subtitle'),
                label: const Text('bt-server'),
                trailing: Row(
                  children: [
                    if (btServerNotifier.isInstalled)
                      MoonButton(
                        label: const Text('uninstall'),
                        onTap: () {
                          btServerNotifier.uninstallServer();
                        },
                      )
                    else if (btServerNotifier.isDownloading)
                      MoonButton(label: Text('${(btServerNotifier.progress.toStringAsFixed(1))}%'), onTap: () {})
                    else
                      MoonButton(
                        label: const Text('install'),
                        onTap: () {
                          btServerNotifier.downloadOrUpgradeServer(context);
                        },
                      ),
                  ],
                ),
              ),
        ),
      ],
    );
  }
}

class SettingDownload extends HookWidget {
  const SettingDownload({super.key});
  @override
  Widget build(BuildContext context) {
    return MiruListView(
      children: [
        SettingsRadiosTile(
          title: 'max-connection',
          subtitle: 'max-connection-subtitle',
          radios: List.generate(3, (i) => (i + 2).toString()),
          value: MiruStorage.getSettingSync(SettingKey.maxConnection, String),
          onChanged: (val) {
            MiruStorage.setSettingSync(SettingKey.maxConnection, val);
          },
        ),
        MoonMenuItem(
          trailing: MoonButton(label: const Text('choose-path'), onTap: () {}),
          label: const Text('download-path-subtitle'),
          content: Text('download-path'),
          onTap: () {},
        ),
      ],
    );
  }
}

class SettingReader extends HookWidget {
  const SettingReader({super.key});
  @override
  Widget build(BuildContext context) {
    return MiruListView(
      children: [
        SettingsRadiosTile(
          title: 'deafult-reader',
          subtitle: 'deafult-reader-subtitle',
          value: MiruStorage.getSettingSync(SettingKey.readingMode, String),
          radios: const ['Standard', 'Right to Left', 'Webtoon'],
          onChanged: (value) {
            MiruStorage.setSettingSync(SettingKey.readingMode, value);
          },
        ),
      ],
    );
  }
}

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
                initialValue: MiruStorage.getSettingSync(SettingKey.tmdbKey, String),
                onChanged: (value) {
                  MiruStorage.setSettingSync(SettingKey.tmdbKey, value);
                },
              ),
              FDivider(),
              SettingsToggleTile(
                title: 'allow-nsfw',
                subtitle: 'allow-nsfw-subtitle',
                value: MiruStorage.getSettingSync(SettingKey.enableNSFW, bool),
                onChanged: (value) {
                  MiruStorage.setSettingSync(SettingKey.enableNSFW, value.toString());
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
                value: MiruStorage.getSettingSync(SettingKey.theme, String),
                onChanged: (val) => c.changeTheme(val),
                entry: const [
                  RadioTileEntry(value: 'system', title: 'system', icon: FIcons.sunMoon),
                  RadioTileEntry(value: 'light', title: 'light', icon: FIcons.sun),
                  RadioTileEntry(value: 'dark', title: 'dark', icon: FIcons.moon),
                ],
              ),
              FDivider(),
              SettingsRadiosTile(
                title: 'accent-color',
                subtitle: 'accent-color-subtitle',
                value: MiruStorage.getSettingSync(SettingKey.accentColor, String),
                onChanged: (val) {
                  c.changeAccentColor(val);
                  MiruStorage.setSettingSync(SettingKey.accentColor, val);
                },
                radios: ThemeUtils.accentToBright.keys.map((e) => e.name).toList(),
                color: ThemeUtils.accentToBright.map((key, value) => MapEntry(key.name, value.colors.primary)),
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
                value: MiruStorage.getSettingSync(SettingKey.autoCheckUpdate, bool),
                onChanged: (value) {
                  MiruStorage.setSettingSync(SettingKey.autoCheckUpdate, value.toString());
                },
              ),

              if (DeviceUtil.isMobileLayout(context))
                SettingsToggleTile(
                  title: 'mobile-title-position',
                  subtitle: 'mobile-title-position-subtitle',
                  value: MiruStorage.getSettingSync(SettingKey.mobiletitleIsonTop, bool),
                  onChanged: (value) {
                    MiruStorage.setSettingSync(SettingKey.mobiletitleIsonTop, value.toString());
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
