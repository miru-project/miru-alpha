import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/core/log_export.dart';
import 'package:miru_alpha/utils/store/storage_index.dart';
import 'package:miru_alpha/ui/features/setting/widget/setting_group.dart';
import 'package:miru_alpha/ui/features/setting/widget/setting_press_tile.dart';
import 'package:miru_alpha/ui/features/setting/widget/settings_toggle_tile.dart';

class SettingLog extends HookConsumerWidget {
  const SettingLog({super.key, this.isMobileLayout = false});
  final bool isMobileLayout;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: .all(0),
      children: [
        SettingGroup(
          isMobileLayout: isMobileLayout,
          title: 'settings.logging.capture.name',
          children: [
            SettingsToggleTile(
              isMobileLayout: isMobileLayout,
              title: 'settings.logging.capture_crash.name',
              subtitle: 'settings.logging.capture_crash.information',
              value: MiruSettings.getSettingSync<bool>(
                SettingKey.captureCrash,
              ),
              onChanged: (value) {
                MiruSettings.setSettingSync(
                  SettingKey.captureCrash,
                  value.toString(),
                );
              },
            ),
            SettingsToggleTile(
              isMobileLayout: isMobileLayout,
              title: 'settings.logging.save_log.name',
              subtitle: 'settings.logging.save_log.information',
              value: MiruSettings.getSettingSync<bool>(SettingKey.saveLog),
              onChanged: (value) {
                MiruSettings.setSettingSync(
                  SettingKey.saveLog,
                  value.toString(),
                );
              },
            ),
          ],
        ),
        SettingGroup(
          isMobileLayout: isMobileLayout,
          title: 'settings.logging.export.name',
          children: [
            SettingPressTile(
              isMobileLayout: isMobileLayout,
              title: 'settings.logging.export_alpha.name',
              subtitle: 'settings.logging.export_alpha.information',
              prefix: Icon(FLucideIcons.fileText),
              onPress: exportMiruAlphaLog,
            ),
            SettingPressTile(
              isMobileLayout: isMobileLayout,
              title: 'settings.logging.export_core.name',
              subtitle: 'settings.logging.export_core.information',
              prefix: Icon(FLucideIcons.server),
              onPress: exportMiruCoreLog,
            ),
            SettingPressTile(
              isMobileLayout: isMobileLayout,
              title: 'settings.logging.export_core_crash.name',
              subtitle: 'settings.logging.export_core_crash.information',
              prefix: Icon(FLucideIcons.triangleAlert),
              onPress: exportMiruCoreCrashLog,
            ),
            SettingPressTile(
              isMobileLayout: isMobileLayout,
              title: 'settings.logging.export_crash.name',
              subtitle: 'settings.logging.export_crash.information',
              prefix: Icon(FLucideIcons.triangleAlert),
              onPress: exportCrashLog,
            ),
            SettingPressTile(
              isMobileLayout: isMobileLayout,
              title: 'settings.logging.export_all.name',
              subtitle: 'settings.logging.export_all.information',
              prefix: Icon(FLucideIcons.download),
              onPress: exportAllLogs,
            ),
          ],
        ),
      ],
    );
  }
}
