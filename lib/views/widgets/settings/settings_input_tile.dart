import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsInputTile extends StatelessWidget {
  const SettingsInputTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.initialValue,
    required this.onChanged,
  });
  final String title;
  final String subtitle;
  final String initialValue;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: CupertinoTextField(
            controller: TextEditingController(text: initialValue),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
