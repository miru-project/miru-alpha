import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class SettingSegmentControll extends StatelessWidget {
  const SettingSegmentControll({
    required this.onchange,
    required this.segments,
    required this.title,
    required this.subtitle,
    this.initValue = 0,
    this.icon,
    super.key,
  });
  final Function(int) onchange;
  final List<Widget> segments;
  final int initValue;
  final String title;
  final String subtitle;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    // MoonSquircleBorder();

    return MoonMenuItem(
      onTap: () {},
      content: Text(subtitle),
      label: Text(title),
      leading: (icon == null) ? null : Icon(icon!, size: 20),
      trailing: MoonSegmentedControl(
        initialIndex: initValue,
        onSegmentChanged: onchange,
        segments: List.generate(
          segments.length,
          (index) => Segment(leading: segments[index]),
        ),
      ),
    );
  }
}
