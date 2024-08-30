import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_app_new/views/widgets/index.dart';

class CategoryGroup extends HookWidget {
  const CategoryGroup(
      {required this.items,
      required this.onpress,
      this.needSpacer = true,
      super.key});
  final List<String> items;
  final bool needSpacer;
  final void Function(int) onpress;
  @override
  Widget build(BuildContext context) {
    final selected = useState(0);
    return Column(
      children: [
        if (needSpacer)
          const SizedBox(
            height: 10,
          ),
        ...List.generate(
          items.length,
          (index) => SideBarListTile(
              title: items[index],
              selected: selected.value == index,
              onPressed: () {
                selected.value = index;
                onpress(index);
              }),
        )
      ],
    );
  }
}
