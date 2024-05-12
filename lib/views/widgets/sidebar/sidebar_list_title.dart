import 'package:flutter/material.dart';

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
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withAlpha(20),
          ),
        ),
      ),
      child: Row(
        children: [
          if (trailing != null) ...[
            ...trailing!,
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
