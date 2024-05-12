import 'package:flutter/material.dart';

class SideBarListTile extends StatefulWidget {
  const SideBarListTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onPressed,
  });
  final String title;
  final bool selected;
  final void Function() onPressed;

  @override
  State<SideBarListTile> createState() => _SideBarListTileState();
}

class _SideBarListTileState extends State<SideBarListTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.selected || _hover
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              color: widget.selected || _hover ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
