import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_app_new/utils/btserver.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:miru_app_new/utils/index.dart';
import 'package:moon_design/moon_design.dart';

enum SideBarName {
  general,
  extension,
  player,
  miruCore,
  reader,
  advanced,
  about,
  tracking,
  download,
}

class SettingPlayer extends HookWidget {
  const SettingPlayer({super.key});
  @override
  Widget build(BuildContext context) {
    return MiruListView(
      children: [
        SettingsInputTile(
          title: 'btserver-download-link',
          subtitle: 'btserver-download-link-sub',
          initialValue: MiruStorage.getSettingSync<String>(
            SettingKey.btServerLink,
          ),
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
                      MoonButton(
                        label: Text(
                          '${(btServerNotifier.progress.toStringAsFixed(1))}%',
                        ),
                        onTap: () {},
                      )
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
          initialValue: MiruStorage.getSettingSync(SettingKey.btServerLink),
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
                      MoonButton(
                        label: Text(
                          '${(btServerNotifier.progress.toStringAsFixed(1))}%',
                        ),
                        onTap: () {},
                      )
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
          value:
              MiruStorage.getSettingSync<int>(
                SettingKey.maxConnection,
              ).toString(),
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
          value: MiruStorage.getSettingSync<String>(SettingKey.readingMode),
          radios: const ['Standard', 'Right to Left', 'Webtoon'],
          onChanged: (value) {
            MiruStorage.setSettingSync(SettingKey.readingMode, value);
          },
        ),
      ],
    );
  }
}
