import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:miru_app_new/views/widgets/index.dart';
import 'package:moon_design/moon_design.dart';

class CategoryGroup extends HookWidget {
  const CategoryGroup(
      {required this.items,
      required this.onpress,
      this.needSpacer = true,
      this.maxSelected,
      this.minSelected,
      super.key});
  final List<String> items;
  final bool needSpacer;
  final void Function(int) onpress;
  final int? maxSelected;
  final int? minSelected;
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

class CatergoryGroupChip extends StatefulHookWidget {
  const CatergoryGroupChip(
      {required this.items,
      required this.onpress,
      this.needSpacer = true,
      required this.intitSelected,
      this.maxSelected,
      this.minSelected,
      super.key});
  final List<String> items;
  final List<int> intitSelected;
  final bool needSpacer;
  final void Function(List<int>) onpress;
  final int? maxSelected;
  final int? minSelected;
  @override
  createState() => _CatergoryGroupChipState();
}

class _CatergoryGroupChipState extends State<CatergoryGroupChip>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late ValueNotifier<List<int>> selected;
  @override
  void initState() {
    selected = ValueNotifier(widget.intitSelected);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.needSpacer)
          const SizedBox(
            height: 10,
          ),
        Wrap(
          // crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 5,
          runSpacing: 10,
          children: (List.generate(
              widget.items.length,
              (index) => ValueListenableBuilder(
                  valueListenable: selected,
                  builder: (context, val, _) => MoonChip(
                        isActive: selected.value.contains(index),
                        label: Text(
                          widget.items[index],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "HarmonyOS_Sans"),
                        ),
                        onTap: () {
                          final newSelected = List<int>.from(selected.value);
                          if (newSelected.contains(index) &&
                              newSelected.length >
                                  1 + (widget.minSelected ?? 0)) {
                            newSelected.remove(index);
                          } else {
                            if (newSelected.length >=
                                (widget.maxSelected ?? widget.items.length)) {
                              newSelected.removeAt(0);
                            }
                            newSelected.add(index);
                          }
                          selected.value = newSelected;
                          widget.onpress(selected.value);
                        },
                      )))),
        )
      ],
    );
  }
}
