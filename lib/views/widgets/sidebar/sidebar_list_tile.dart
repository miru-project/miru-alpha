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
    return MoonChip.text(
      width: double.infinity,
      height: 30,
      isActive: widget.selected,
      activeBackgroundColor:
          widget.selected ? Theme.of(context).primaryColor : Colors.transparent,
      activeColor: widget.selected ? Colors.white : Colors.black,
      leading: widget.leading,
      label: Expanded(
          child: Text(
        widget.title,
        style: TextStyle(
          color: widget.selected ? Colors.white : Colors.black,
        ),
      )),
      onTap: widget.onPressed,
      // backgroundColor: Theme.of(context).primaryColor,
    );
    // return MouseRegion(
    //   onEnter: (_) => setState(() => _hover = true),
    //   onExit: (_) => setState(() => _hover = false),
    //   cursor: SystemMouseCursors.click,
    //   child: GestureDetector(
    //     onTap: widget.onPressed,
    //     child: Container(
    //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    //       width: double.infinity,
    //       decoration: BoxDecoration(
    //         color: widget.selected || _hover
    //             ? Theme.of(context).primaryColor
    //             : Colors.transparent,
    //         borderRadius: BorderRadius.circular(10),
    //       ),
    //       child: Text(
    //         widget.title,
    //         style: TextStyle(
    //           color: widget.selected || _hover ? Colors.white : Colors.black,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
