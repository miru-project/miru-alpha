import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_setting.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/widgets/index.dart';

class ExtensionSettingPage extends HookConsumerWidget {
  final String pkg;
  final String name;
  const ExtensionSettingPage({
    super.key,
    required this.pkg,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsFuture = useMemoized(
      () => ExtensionSetting.getSettings(pkg),
      [pkg],
    );
    final snapshot = useFuture(settingsFuture);

    if (snapshot.connectionState == ConnectionState.waiting) {
      return MiruScaffold(
        mobileHeader: SnapSheetNested.back(title: name),
        body: const Center(child: FCircularProgress()),
      );
    }

    if (snapshot.hasError) {
      return MiruScaffold(
        mobileHeader: SnapSheetNested.back(title: name),
        body: Center(child: Text('Error: ${snapshot.error}')),
      );
    }

    final settings = snapshot.data ?? [];
    final isMobile = DeviceUtil.isMobileLayout(context);

    return MiruScaffold(
      mobileHeader: SnapSheetNested.back(title: name),
      body: MiruListView(
        children: [
          SettingGroup(
            isMobileLayout: isMobile,
            title: name,
            children: settings
                .map((s) => _buildSettingItem(context, s, isMobile))
                .cast<FTileMixin>()
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    ExtensionSetting setting,
    bool isMobile,
  ) {
    switch (setting.type) {
      case ExtensionSettingType.input:
        return _InputSetting(setting: setting, isMobile: isMobile);
      case ExtensionSettingType.radio:
        return _RadioSetting(setting: setting, isMobile: isMobile);
      case ExtensionSettingType.toggle:
        return _ToggleSetting(setting: setting, isMobile: isMobile);
    }
  }
}

class _InputSetting extends HookWidget with FTileMixin {
  final ExtensionSetting setting;
  final bool isMobile;
  const _InputSetting({required this.setting, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    // final controller = useTextEditingController(
    //   text: setting.value ?? setting.defaultValue,
    // );
    final timer = useState<Timer?>(null);

    void saveWithTimer(String value) {
      timer.value?.cancel();
      timer.value = Timer(const Duration(milliseconds: 500), () {
        setting.value = value;
        ExtensionSetting.saveSettings(setting.package, [setting]);
      });
    }

    return SettingsInputTile(
      defaultValue: setting.defaultValue,
      description: setting.description,
      isMobileLayout: isMobile,
      title: setting.title,
      subtitle: setting.description,
      initialValue: setting.value ?? setting.defaultValue,
      onChanged: saveWithTimer,
    );
  }
}

class _RadioSetting extends HookWidget with FTileMixin {
  final ExtensionSetting setting;
  final bool isMobile;
  const _RadioSetting({required this.setting, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final options = useMemoized(() {
      try {
        if (setting.options != null && setting.options!.isNotEmpty) {
          final decoded = json.decode(setting.options!);
          if (decoded is Map) {
            return decoded
                .map(
                  (key, value) =>
                      MapEntry(key.toString().i18n, value.toString()),
                )
                .cast<String, String>();
          } else if (decoded is List) {
            return <String, String>{
              for (var e in decoded) e.toString().i18n: e.toString(),
            };
          }
        }
      } catch (e) {
        logger.severe("Error parsing extension setting options: $e");
      }
      return <String, String>{};
    }, [setting.options]);

    final value = useState(setting.value ?? setting.defaultValue);

    // Ensure initial value is present in options to prevent FSelect from crashing
    final safeOptions = useMemoized(() {
      final items = options;
      final current = value.value;
      if (items.values.every((v) => v != current)) {
        return {...items, current: current};
      }
      return items;
    }, [options, value.value]);

    return SettingsRadiosTile(
      isMobileLayout: isMobile,
      title: setting.title,
      subtitle: setting.description,
      radios: safeOptions.keys.toList(),
      value: value.value,
      onChanged: (val) {
        value.value = val;
        setting.value = val;
        ExtensionSetting.saveSettings(setting.package, [setting]);
      },
    );
  }
}

class _ToggleSetting extends HookWidget with FTileMixin {
  final ExtensionSetting setting;
  final bool isMobile;
  const _ToggleSetting({required this.setting, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final isSwitched = useState(
      (setting.value ?? setting.defaultValue) == 'true',
    );

    return SettingsToggleTile(
      title: setting.title,
      subtitle: setting.description,
      value: isSwitched.value,
      onChanged: (val) {
        isSwitched.value = val;
        setting.value = val.toString();
        ExtensionSetting.saveSettings(setting.package, [setting]);
      },
    );
    // SettingBaseTile(
    //   isMobileLayout: isMobile,
    //   title: setting.title,
    //   subtitle: setting.description,
    //   child: FSwitch(
    //     value: isSwitched.value,
    //     onChange: (val) {
    //       isSwitched.value = val;
    //       setting.value = val.toString();
    //       ExtensionSetting.saveSettings(setting.package, [setting]);
    //     },
    //   ),
    // );
  }
}
