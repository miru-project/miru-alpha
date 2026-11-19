import 'package:widgetbook/widgetbook.dart';

import 'settings_update_alert.dart';

/// The settings folder: the auto-update banner's states plus the settings
/// tiles it sits with. New use-cases go here first when a settings component
/// changes shape.
WidgetbookFolder buildSettingsFolder() {
  return WidgetbookFolder(
    name: 'Settings',
    children: [
      WidgetbookComponent(
        name: 'SettingsUpdateAlert',
        useCases: settingsUpdateAlertUseCases(),
      ),
    ],
  );
}
