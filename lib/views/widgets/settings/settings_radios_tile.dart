import 'package:flutter/material.dart';

class SettingsRadiosTile extends StatelessWidget {
  const SettingsRadiosTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.radios,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final String subtitle;
  final List<String> radios;
  final String value;
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
        PopupMenuButton<String>(
          onSelected: onChanged,
          position: PopupMenuPosition.under,
          padding: EdgeInsets.zero,
          surfaceTintColor: Colors.white,
          shape: ShapeBorder.lerp(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            1,
          ),
          itemBuilder: (BuildContext context) {
            return radios.map((String radio) {
              return PopupMenuItem<String>(
                value: radio,
                height: 40,
                child: Text(radio),
              );
            }).toList();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: Row(
              children: [
                Text(value),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
