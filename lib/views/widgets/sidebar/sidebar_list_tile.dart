import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class SideBarListTile extends StatefulWidget {
  const SideBarListTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onPressed,
    this.leading,
  });
  final String title;
  final bool selected;
  final void Function() onPressed;
  final Widget? leading;
  @override
  State<SideBarListTile> createState() => _SideBarListTileState();
}

class _SideBarListTileState extends State<SideBarListTile> {
  @override
  Widget build(BuildContext context) {
    return MoonChip(
      width: double.infinity,
      height: 30,
      isActive: widget.selected,
      activeBackgroundColor:
          context.moonTheme?.tabBarTheme.colors.selectedPillTabColor,
      backgroundColor: Colors.transparent,
      leading: widget.leading,
      activeColor: context.moonTheme?.tabBarTheme.colors.selectedTextColor,
      label: Expanded(
          child: Text(
        widget.title,
      )),
      onTap: widget.onPressed,
      // backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
