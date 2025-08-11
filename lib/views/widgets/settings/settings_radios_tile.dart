import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class SettingsRadiosTile extends StatefulWidget {
  const SettingsRadiosTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.radios,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  final String title;
  final String subtitle;
  final List<String> radios;
  final String value;
  final void Function(String) onChanged;
  final IconData? icon;

  @override
  createState() => _SettingsRadiosTileState();
}

class _SettingsRadiosTileState extends State<SettingsRadiosTile> {
  bool _isToggle = false;
  late String _selected;
  void _showDropdown() {
    setState(() {
      _isToggle = !_isToggle;
    });
  }

  @override
  void initState() {
    _selected = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MoonMenuItem(
        onTap: () {},
        content: Text(widget.title),
        label: Text(widget.subtitle),
        leading: (widget.icon == null)
            ? null
            : Icon(
                widget.icon!,
                size: 20,
              ),
        trailing: MoonDropdown(
            constrainWidthToChild: true,
            onTapOutside: _showDropdown,
            show: _isToggle,
            content: Column(
                children: List<Widget>.generate(widget.radios.length, (index) {
              return MoonMenuItem(
                onTap: () {
                  widget.onChanged(widget.radios[index]);
                  _showDropdown();
                  setState(() {
                    _selected = widget.radios[index];
                  });
                },
                label: Text(widget.radios[index]),
              );
            })),
            child: MoonChip(
              leading: Text(_selected),
              label: const Icon(MoonIcons.controls_chevron_down_32_regular),
              onTap: _showDropdown,
            )));
  }
}
