import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/widgets/settings/setting_base_tile.dart';

class SettingsToggleTile extends HookWidget {
  const SettingsToggleTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.onTap,
    this.icon,
  });

  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;
  final void Function()? onTap;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final val = useState(value);
    return SettingBaseTile(
      title: title,
      subtitle: subtitle,
      child: FSwitch(
        value: val.value,
        onChange: (value) {
          val.value = value;
          onChanged(value);
        },
      ),
    );
  }
}
