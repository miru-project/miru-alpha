// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:miru_app_new/utils/btserver.dart';
// import 'package:miru_app_new/widgets/index.dart';
// import 'package:miru_app_new/utils/setting_dir_index.dart';
// import 'package:moon_design/moon_design.dart';

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

// class SettingPlayer extends HookWidget {
//   const SettingPlayer({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MiruListView(
//       children: [
//         SettingsInputTile(
//           title: 'btserver-download-link',
//           subtitle: 'btserver-download-link-sub',
//           initialValue: MiruSettings.getSettingSync<String>(
//             SettingKey.btServerLink,
//           ),
//           onChanged: (val) {
//             MiruSettings.setSettingSync(SettingKey.btServerLink, val);
//           },
//         ),
//         ListenableBuilder(
//           listenable: btServerNotifier,
//           builder: (context, child) => MoonMenuItem(
//             onTap: () {},
//             content: const Text('bt-server-subtitle'),
//             label: const Text('bt-server'),
//             trailing: Row(
//               children: [
//                 if (btServerNotifier.isInstalled)
//                   MoonButton(
//                     label: const Text('uninstall'),
//                     onTap: () {
//                       btServerNotifier.uninstallServer();
//                     },
//                   )
//                 else if (btServerNotifier.isDownloading)
//                   MoonButton(
//                     label: Text(
//                       '${(btServerNotifier.progress.toStringAsFixed(1))}%',
//                     ),
//                     onTap: () {},
//                   )
//                 else
//                   MoonButton(
//                     label: const Text('install'),
//                     onTap: () {
//                       btServerNotifier.downloadOrUpgradeServer(context);
//                     },
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class SettingDownload extends HookWidget {
//   const SettingDownload({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MiruListView(
//       children: [
//         SettingsRadiosTile(
//           title: 'max-connection',
//           subtitle: 'max-connection-subtitle',
//           radios: List.generate(3, (i) => (i + 2).toString()),
//           value: MiruSettings.getSettingSync<int>(
//             SettingKey.maxConnection,
//           ).toString(),
//           onChanged: (val) {
//             MiruSettings.setSettingSync(SettingKey.maxConnection, val);
//           },
//         ),
//         MoonMenuItem(
//           trailing: MoonButton(label: const Text('choose-path'), onTap: () {}),
//           label: const Text('download-path-subtitle'),
//           content: Text('download-path'),
//           onTap: () {},
//         ),
//       ],
//     );
//   }
// }

// class SettingReader extends HookWidget {
//   const SettingReader({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MiruListView(
//       children: [
//         SettingsRadiosTile(
//           title: 'deafult-reader',
//           subtitle: 'deafult-reader-subtitle',
//           value: MiruSettings.getSettingSync<String>(SettingKey.readingMode),
//           radios: const ['Standard', 'Right to Left', 'Webtoon'],
//           onChanged: (value) {
//             MiruSettings.setSettingSync(SettingKey.readingMode, value);
//           },
//         ),
//       ],
//     );
//   }
// }
