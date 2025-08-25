import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/views/widgets/settings/setting_base_tile.dart';

class SettingsRadiosTile extends HookWidget {
  const SettingsRadiosTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.radios,
    required this.value,
    required this.onChanged,
    this.icon,
    this.color,
  }) : entry = null;

  const SettingsRadiosTile.detailed({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.entry,
    this.icon,
    this.color,
  }) : radios = const [];

  final String title;
  final Map<String, Color>? color;
  final String subtitle;
  final List<String> radios;
  final String value;
  final void Function(String) onChanged;
  final IconData? icon;
  final List<RadioTileEntry>? entry;

  @override
  Widget build(BuildContext context) {
    final selected = useState(value);

    return SettingBaseTile(
      title: title,
      subtitle: subtitle,
      child: FSelect<String>(
        initialValue: selected.value,
        onChange: (value) {
          if (value == null) return;
          selected.value = value;
          onChanged(value);
        },
        items: (entry == null) ? {for (final item in radios) item: item} : {for (final e in entry!) e.value: e.title},
        // children:
        //     (entry == null)
        //         ? radios.map((e) => FSelectItem.from(value: e, title: Text(e))).toList()
        //         : entry!
        //             .map(
        //               (e) => FSelectItem.from(
        //                 value: e.value,
        //                 title: Text(e.title, style: TextStyle(color: color?[e.title])),
        //                 subtitle: e.subtitle,
        //                 prefix: e.icon != null ? Icon(e.icon) : null,
        //               ),
        //             )
        //             .toList(),
      ),
    );
  }
}

class RadioTileEntry {
  const RadioTileEntry({required this.value, required this.title, this.subtitle, this.icon});

  final String value;
  final String title;
  final Widget? subtitle;
  final IconData? icon;
}
