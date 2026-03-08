import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/pages/setting/widget/setting_base_tile.dart';

class SettingsRadiosTile extends HookWidget with FTileMixin {
  const SettingsRadiosTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.radios,
    required this.value,
    required this.onChanged,
    this.icon,
    this.color,
    this.isMobileLayout = false,
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
    this.isMobileLayout = false,
  }) : radios = const [];

  final String title;
  final Map<String, Color>? color;
  final String subtitle;
  final List<String> radios;
  final String value;
  final void Function(String) onChanged;
  final IconData? icon;
  final List<RadioTileEntry>? entry;
  final bool isMobileLayout;
  @override
  Widget build(BuildContext context) {
    final selected = useState(value);
    if (isMobileLayout) {
      return FSelectMenuTile(
        selectControl: FMultiValueControl<String>.managedRadio(
          onChange: (value) {
            onChanged(value.first);
          },
        ),

        detailsBuilder: (_, val, _) {
          if (val.isEmpty) {
            val.add(selected.value);
          }
          return Text(val.first.toString().i18n);
        },
        subtitle: Text(subtitle.i18n),
        menu: (entry == null)
            ? radios
                  .map((e) => FSelectTile(title: Text(e.i18n), value: e))
                  .toList()
            : entry!
                  .map(
                    (e) => FSelectTile(title: Text(e.title.i18n), value: e.value),
                  )
                  .toList(),
        title: Text(title.i18n),
      );
    }
    return SettingBaseTile(
      title: title,
      subtitle: subtitle,
      child: FSelect<String>(
        control: FSelectControl.managed(
          initial: selected.value,
          onChange: (value) {
            if (value == null) return;
            selected.value = value;
            onChanged(value);
          },
        ),
        items: (entry == null)
            ? {for (final item in radios) item.i18n: item}
            : {for (final e in entry!) e.title.i18n: e.value},
      ),
    );
  }
}

class RadioTileEntry {
  const RadioTileEntry({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
  });

  final String value;
  final String title;
  final Widget? subtitle;
  final IconData? icon;
}
