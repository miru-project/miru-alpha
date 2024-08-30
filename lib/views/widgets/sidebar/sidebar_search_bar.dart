import 'package:flutter/material.dart';

class SideBarSearchBar extends StatelessWidget {
  final void Function(String)? onChanged;
  const SideBarSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Theme.of(context).textTheme.bodyMedium?.color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '搜索',
                isDense: true,
                hintStyle: TextStyle(
                  fontSize: 14,
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
