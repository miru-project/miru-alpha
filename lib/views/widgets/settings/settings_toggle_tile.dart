import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class SettingsToggleTile extends StatefulWidget {
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
  createState() => _SettingsToggleTileState();
}

class _SettingsToggleTileState extends State<SettingsToggleTile> {
  late bool value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  void _changeFunc(bool newValue) {
    setState(() {
      value = newValue;
    });
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return MoonMenuItem(
      onTap: widget.onTap ?? () {},
      content: Text(widget.subtitle),
      label: Text(widget.title),
      leading: (widget.icon == null)
          ? null
          : Icon(
              widget.icon!,
              size: 20,
            ),
      trailing: MoonSwitch(
        value: value,
        onChanged: _changeFunc,
      ),
    );
  }
}
