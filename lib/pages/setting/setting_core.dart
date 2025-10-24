import 'package:flutter/material.dart';
import 'package:miru_app_new/miru_core/core.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingMiruCore extends HookConsumerWidget {
  const SettingMiruCore({super.key, this.isMobileLayout = false});
  final bool isMobileLayout;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MiruListView(
      children: [
        SettingGroup(
          isMobileLayout: isMobileLayout,
          title: 'Information',
          children: [
            FTile(
              // style: (style) => context.theme.itemStyle.copyWith(
              //   // margin: EdgeInsets.symmetric(vertical: 10),
              //   tappableStyle: (style) =>
              //       context.theme.tappableStyle.copyWith(),
              //   contentStyle: (style) => context.theme.itemStyle.contentStyle
              //       .copyWith(padding: EdgeInsets.symmetric(vertical: 10)),
              // ),
              title: Text('Address'),
              suffix: Text(Core.host, style: TextStyle(letterSpacing: .5)),
              onPress: () {},
            ),
            FTile(
              // style: (style) => context.theme.itemStyle.copyWith(
              //   // margin: EdgeInsets.symmetric(vertical: 10),
              //   tappableStyle: (style) =>
              //       context.theme.tappableStyle.copyWith(),
              //   contentStyle: (style) => context.theme.itemStyle.contentStyle
              //       .copyWith(padding: EdgeInsets.symmetric(vertical: 10)),
              // ),
              title: Text('Port'),
              suffix: Text(Core.port, style: TextStyle(letterSpacing: .5)),
              onPress: () {},
            ),
          ],
        ),
      ],
    );
  }
}

// class SettingMiruCore extends HookWidget {
//   const SettingMiruCore({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MiruListView(
//       children: [
//         // FAlert(title: const Text('miru-core-running')),
//         SettingsInputTile(
//           title: 'btserver-download-link',
//           subtitle: 'btserver-download-link-sub',
//           initialValue: MiruSettings.getSettingSync(SettingKey.btServerLink),
//           onChanged: (val) {
//             MiruSettings.setSettingSync(SettingKey.btServerLink, val);
//           },
//         ),
//         // ListenableBuilder(
//         //   listenable: btServerNotifier,
//         //   builder: (context, child) => MoonMenuItem(
//         //     onTap: () {},
//         //     content: const Text('bt-server-subtitle'),
//         //     label: const Text('bt-server'),
//         //     trailing: Row(
//         //       children: [
//         //         if (btServerNotifier.isInstalled)
//         //           MoonButton(
//         //             label: const Text('uninstall'),
//         //             onTap: () {
//         //               btServerNotifier.uninstallServer();
//         //             },
//         //           )
//         //         else if (btServerNotifier.isDownloading)
//         //           MoonButton(
//         //             label: Text(
//         //               '${(btServerNotifier.progress.toStringAsFixed(1))}%',
//         //             ),
//         //             onTap: () {},
//         //           )
//         //         else
//         //           MoonButton(
//         //             label: const Text('install'),
//         //             onTap: () {
//         //               btServerNotifier.downloadOrUpgradeServer(context);
//         //             },
//         //           ),
//         //       ],
//         //     ),
//         //   ),
//         // ),
//       ],
//     );
//   }
// }
