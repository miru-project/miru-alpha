import 'package:flutter/material.dart';

class SnapSheetHeader extends StatelessWidget {
  const SnapSheetHeader({
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (leading != null) ...[...leading!, const SizedBox(width: 8)],
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          const Spacer(),
          if (trailings != null) ...trailings!,
        ],
      ),
    );
  }
}
