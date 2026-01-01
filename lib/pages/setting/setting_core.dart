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
              title: Text('Address'),
              suffix: Text(Core.host, style: TextStyle(letterSpacing: .5)),
              onPress: () {},
            ),
            FTile(
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
