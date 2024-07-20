import 'package:flutter/material.dart';
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
    return Column(children: [
      MoonChip(
        width: double.infinity,
        // padding: const EdgeInsets.only(right: 130),
        isActive: _expanded,
        activeBackgroundColor: context
            .moonTheme?.tabBarTheme.colors.selectedPillTabColor
            .withAlpha(100),
        backgroundColor:
            context.moonTheme?.tabBarTheme.colors.selectedPillTabColor,
        activeColor: context.moonTheme?.tabBarTheme.colors.selectedTextColor,
        leading: Icon(
          _expanded
              ? MoonIcons.controls_chevron_down_32_regular
              : MoonIcons.controls_chevron_right_32_regular,
          color: context.moonTheme?.segmentedControlTheme.colors.textColor,
          size: 15,
        ),
        label: Expanded(
            child: Text(
          widget.title,
          style: TextStyle(
            color: context.moonTheme?.segmentedControlTheme.colors.textColor,
            fontWeight: FontWeight.bold,
          ),
        )),
        trailing: widget.actions == null
            ? null
            : Row(
                children: widget.actions!,
              ),
        onTap: () => setState(() => _expanded = !_expanded),
      ),
      if (_expanded) ...widget.children,
    ]);
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     Container(
    //       margin: _expanded ? const EdgeInsets.only(bottom: 10) : null,
    //       decoration: BoxDecoration(
    //         border: _expanded
    //             ? Border(
    //                 bottom: BorderSide(
    //                   color: Colors.black.withAlpha(20),
    //                 ),
    //               )
    //             : null,
    //       ),
    //       child: Row(
    //         children: [
    //           Expanded(
    //             child: Button(
    //               onPressed: () => setState(() => _expanded = !_expanded),
    //               trailing: [
    //                 Icon(
    //                   _expanded
    //                       ? Icons.keyboard_arrow_down
    //                       : Icons.keyboard_arrow_right,
    //                   color: Colors.black54,
    //                   size: 15,
    //                 ),
    //               ],
    //               child: Text(
    //                 widget.title,
    //                 style: const TextStyle(
    //                   color: Colors.black54,
    //                   fontWeight: FontWeight.bold,
    //                 ),
    //               ),
    //             ),
    //           ),
    //           if (widget.actions != null) ...widget.actions!,
    //         ],
    //       ),
    //     ),
    //     if (_expanded) ...widget.children,
    //   ],
    // );
  }
}
