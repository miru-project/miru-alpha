import 'package:flutter/material.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/miru_core/core.dart';
import 'package:miru_alpha/widgets/index.dart';
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
          title: 'information',
          children: [
            SettingBaseTile(
              isMobileLayout: isMobileLayout,
              title: 'address'.i18n,
              child: Text(
                Core.host,
                style: TextStyle(fontWeight: .bold, letterSpacing: .5),
              ),
            ),
            SettingBaseTile(
              isMobileLayout: isMobileLayout,
              title: 'port'.i18n,
              child: Text(
                Core.port,
                style: TextStyle(letterSpacing: .5, fontWeight: .bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
