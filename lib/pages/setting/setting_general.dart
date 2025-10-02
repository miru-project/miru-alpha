import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/application_controller_provider.dart';
import 'package:miru_app_new/utils/core/device_util.dart';
import 'package:miru_app_new/utils/theme/theme.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:miru_app_new/utils/setting_dir_index.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';

class SettingBasedGeneral extends HookConsumerWidget {
  const SettingBasedGeneral({super.key, this.isMobileLayout = false});
  final bool isMobileLayout;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(applicationControllerProvider.notifier);
    return MiruListView(
      children: [
        SettingGroup(
          isMobileLayout: isMobileLayout,
          title: 'Content',
          children: [
            SettingsInputTile(
              isMobileLayout: isMobileLayout,
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
              isMobileLayout: isMobileLayout,
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

        SettingGroup(
          isMobileLayout: isMobileLayout,
          title: 'appearance',
          children: [
            SettingsRadiosTile.detailed(
              isMobileLayout: isMobileLayout,
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
                RadioTileEntry(value: 'dark', title: 'dark', icon: FIcons.moon),
              ],
            ),
            SettingsRadiosTile(
              isMobileLayout: isMobileLayout,
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
        SettingGroup(
          isMobileLayout: isMobileLayout,
          title: 'Others',
          children: [
            SettingsToggleTile(
              isMobileLayout: isMobileLayout,
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
              isMobileLayout: isMobileLayout,
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
    );
  }
}

class SettingGeneral extends StatefulHookConsumerWidget {
  const SettingGeneral({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      SettingMobileGeneralState();
}

class SettingMobileGeneralState extends ConsumerState<SettingGeneral> {
  late final SnappingSheetController snappingSheetController =
      SnappingSheetController();
  @override
  Widget build(BuildContext context) {
    return DeviceUtil.deviceWidget(
      context: context,
      desktop: SettingBasedGeneral(),
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
          Expanded(child: SettingBasedGeneral(isMobileLayout: true)),
        ],
      ),
    );
  }
}
