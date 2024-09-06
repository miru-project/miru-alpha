import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class SideBarListTitle extends StatelessWidget {
  const SideBarListTitle({
    super.key,
    required this.title,
    this.actions,
    this.trailing,
  });

  final String title;
  final List<Widget>? trailing;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (trailing != null) ...[
            ...trailing!,
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
                color: context.moonTheme?.chipTheme.colors.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: "HarmonyOS_Sans"),
          ),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
