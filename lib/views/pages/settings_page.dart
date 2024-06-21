import 'package:flutter/material.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:moon_design/moon_design.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MiruScaffold(
      appBar: const MiruAppBar(
        title: Text('Settings'),
      ),
      sidebar: [
        const SideBarListTitle(title: '设置'),
        SideBarListTile(
          title: '基本',
          selected: true,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        SideBarListTile(
          title: '扩展',
          selected: false,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        SideBarListTile(
          title: '播放器',
          selected: false,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        SideBarListTile(
          title: 'BT Server',
          selected: false,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        SideBarListTile(
          title: '阅读器',
          selected: false,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        SideBarListTile(
          title: '高级',
          selected: false,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        SideBarListTile(
          title: '关于软件',
          selected: false,
          onPressed: () {},
        ),
      ],
      body: MiruListView(
        maxWidth: 1000,
        children: [
          SettingsToggleTile(
            title: "Toggle Title",
            subtitle: "Toggle Subtitle",
            value: false,
            onChanged: (value) {},
          ),
          const SizedBox(height: 16),
          SettingsInputTile(
            title: "Input Title",
            subtitle: "Input Subtitle",
            initialValue: "Initial Value",
            onChanged: (value) {},
          ),
          const SizedBox(height: 16),
          SettingsRadiosTile(
            title: "Radios Title",
            subtitle: "Radios Subtitle",
            radios: const ["Radio 1", "Radio 2", "Radio 3"],
            value: "Radio 1",
            onChanged: (value) {},
          ),
          const SizedBox(height: 16),
          MoonAccordion(
            showBorder: true,
            hasContentOutside: true,
            label: const Text("Theme"),
            children: [
              MoonMenuItem(
                onTap: () {},
                label: const Text("Menu Item"),
                leading:
                    const Icon(MoonIcons.notifications_activity_32_regular),
                trailing: const Icon(MoonIcons.controls_chevron_right_24_light),
              ),
              MoonMenuItem(
                onTap: () {},
                content: const Text("Content"),
                label: const Text("Menu Item"),
                leading:
                    const Icon(MoonIcons.notifications_activity_32_regular),
                trailing: const MoonSwitch(
                  value: true,
                ),
              ),
              MoonMenuItem(
                  onTap: () {},
                  content: const Text("Content"),
                  label: const Text("Menu Item"),
                  leading:
                      const Icon(MoonIcons.notifications_activity_32_regular),
                  trailing: MoonDropdown(
                      show: false,
                      content: Column(
                        children: [
                          MoonMenuItem(
                            onTap: () {},
                            content: const Text("Content"),
                            label: const Text("Menu Item"),
                            leading: const Icon(
                                MoonIcons.notifications_activity_32_regular),
                            trailing: const MoonSwitch(
                              value: true,
                            ),
                          )
                        ],
                      ),
                      child: const MoonChip(
                        leading: Text("Radio"),
                        label: Icon(MoonIcons.controls_chevron_down_32_regular),
                      )))
            ],
          )
        ],
      ),
    );
  }
}
