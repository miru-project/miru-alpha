import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class SideBarSearchBar extends StatelessWidget {
  final void Function(String)? onChanged;
  final void Function(String)? onsubmitted;
  final Widget? trailing;
  const SideBarSearchBar(
      {super.key, this.onChanged, this.onsubmitted, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: MoonTextInput(
        leading: const Icon(MoonIcons.generic_search_16_regular),
        trailing: trailing,
        textInputSize: MoonTextInputSize.sm,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        onSubmitted: onsubmitted,
        onChanged: onChanged,
        hintText: '搜索',
        style: const TextStyle(
          fontSize: 14,
        ),
      ),

      // Row(
      //   children: [
      //     Icon(
      //       Icons.search,
      //       color: Theme.of(context).textTheme.bodyMedium?.color,
      //       size: 20,
      //     ),
      //     const SizedBox(width: 10),
      //     Expanded(
      //       child: TextField(
      //         onChanged: onChanged,
      //         decoration: const InputDecoration(
      //           border: InputBorder.none,
      //           hintText: '搜索',
      //           isDense: true,
      //           hintStyle: TextStyle(
      //             fontSize: 14,
      //           ),
      //         ),
      //         style: const TextStyle(
      //           fontSize: 14,
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
