import 'package:flutter/material.dart';
import 'package:forui/widgets/label.dart';

class SettingBaseTile extends StatelessWidget {
  const SettingBaseTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: FLabel(
              axis: Axis.vertical,
              description: Text(subtitle),
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            constraints: const BoxConstraints(maxWidth: 300),
            height: 40,
            child: child,
          ),
        ],
      ),
    );
  }
}
