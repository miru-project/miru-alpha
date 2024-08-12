import 'package:flutter/material.dart';
import 'package:miru_app_new/views/widgets/button.dart';
import 'package:moon_design/moon_design.dart';

class SidebarExpander extends StatefulWidget {
  const SidebarExpander({
    super.key,
    required this.title,
    required this.children,
    this.expanded = false,
    this.actions,
  });
  final String title;
  final List<Widget> children;
  final bool expanded;
  final List<Widget>? actions;

  @override
  State<SidebarExpander> createState() => _SidebarExpanderState();
}

class _SidebarExpanderState extends State<SidebarExpander> {
  late bool _expanded = widget.expanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: _expanded ? const EdgeInsets.only(bottom: 10) : null,
          child: Row(
            children: [
              Expanded(
                child: Button(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  trailing: [
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      color: Brightness.dark == Theme.of(context).brightness
                          ? MoonColors.light.goku
                          : MoonColors.dark.goku,
                      size: 15,
                    ),
                  ],
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: Brightness.dark == Theme.of(context).brightness
                          ? MoonColors.light.goku
                          : MoonColors.dark.goku,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              if (widget.actions != null) ...widget.actions!,
            ],
          ),
        ),
        if (_expanded) ...widget.children,
      ],
    );
  }
}
