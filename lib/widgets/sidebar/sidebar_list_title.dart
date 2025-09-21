import 'package:flutter/material.dart';

class SideBarListTitle extends StatelessWidget {
  const SideBarListTitle({
    super.key,
    required this.title,
    this.trailings,
    this.leading,
  });

  final String title;
  final List<Widget>? leading;
  final List<Widget>? trailings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (leading != null) ...[...leading!, const SizedBox(width: 8)],
          Text(
            title,
            style: TextStyle(
              // color: context.moonTheme?.chipTheme.colors.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              // fontFamily: "HarmonyOS_Sans",
            ),
          ),
          const Spacer(),
          if (trailings != null) ...trailings!,
        ],
      ),
    );
  }
}
