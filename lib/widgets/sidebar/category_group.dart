import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:moon_design/moon_design.dart';

class CategoryGroup extends HookWidget {
  const CategoryGroup({
    required this.items,
    required this.onpress,
    this.needSpacer = true,
    this.maxSelected,
    this.minSelected,
    this.title,
    super.key,
  });
  final List<String> items;
  final bool needSpacer;
  final void Function(int) onpress;
  final int? maxSelected;
  final int? minSelected;
  final String? title;
  @override
  Widget build(BuildContext context) {
    // final selected = useState(0);
    final controller = FSelectTileGroupController<String>.radio(items[0]);
    return FSelectTileGroup<String>(
      label: title == null ? null : Text(title!),
      selectController: controller,
      children: List.generate(
        items.length,
        (index) =>
            FSelectTile<String>(title: Text(items[index]), value: items[index]),
      ),
    );
    // Column(
    //   children: [
    //     if (needSpacer) const SizedBox(height: 10),
    //     ...List.generate(
    //       items.length,
    //       (index) => SideBarListTile(
    //         title: items[index],
    //         selected: selected.value == index,
    //         onPressed: () {
    //           selected.value = index;
    //           onpress(index);
    //         },
    //       ),
    //     ),
    //   ],
    // );
  }
}

class CatergoryGroupChip extends StatefulHookWidget {
  const CatergoryGroupChip({
    required this.items,
    required this.onpress,
    this.needSpacer = true,
    required this.initSelected,
    this.onLongPress,
    this.trailing,
    this.setSelected,
    this.leading,
    this.setLongPress,
    this.maxSelected,
    this.minSelected,
    this.customOnTap = defaultCallBack,
    this.customOnLongPress = defaultCallBack,
    super.key,
  });
  final List<String> items;
  final List<int> initSelected;
  final bool needSpacer;
  final void Function(List<int>) onpress;
  final void Function(List<int>)? onLongPress;
  final List<int> Function(List<int>) customOnTap;
  final List<int> Function(List<int>) customOnLongPress;
  final int? maxSelected;
  final int? minSelected;
  final Widget? trailing;
  final Widget? leading;
  //listen to
  final ValueNotifier<List<int>>? setSelected;
  final ValueNotifier<List<int>>? setLongPress;
  @override
  createState() => _CatergoryGroupChipState();
  static List<int> defaultCallBack(List<int> val) {
    return val;
  }
}

class _CatergoryGroupChipState extends State<CatergoryGroupChip>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late ValueNotifier<List<int>> selected;
  late ValueNotifier<List<int>> longPress;

  @override
  void initState() {
    selected = ValueNotifier(widget.initSelected);
    longPress = ValueNotifier([]);
    //listen to changes and force update
    if (widget.setSelected != null) {
      widget.setSelected!.addListener(() {
        selected.value = widget.setSelected!.value;
      });
    }
    if (widget.setLongPress != null) {
      widget.setLongPress!.addListener(() {
        longPress.value = widget.setLongPress!.value;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    selected.dispose();
    longPress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        if (widget.needSpacer) const SizedBox(height: 10),
        Wrap(
          // crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 5,
          runSpacing: 10,
          children: [
            if (widget.leading != null) widget.leading!,
            ...(List.generate(
              widget.items.length,
              (index) => ValueListenableBuilder(
                valueListenable: selected,
                builder: (context, val, _) => ValueListenableBuilder(
                  valueListenable: longPress,
                  builder: (context, press, _) => Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: press.contains(index)
                            ? Colors.white
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: GestureDetector(
                      onSecondaryTap: widget.onLongPress == null
                          ? null
                          : () {
                              final newlongPress = List<int>.from(
                                longPress.value,
                              );
                              if (newlongPress.contains(index)) {
                                newlongPress.remove(index);
                              } else {
                                newlongPress.add(index);
                              }
                              longPress.value = widget.customOnLongPress(
                                newlongPress,
                              );
                              widget.onLongPress!(newlongPress);
                            },
                      child: MoonChip(
                        borderWidth: 2,
                        onLongPress: widget.onLongPress == null
                            ? null
                            : () {
                                final newlongPress = List<int>.from(
                                  longPress.value,
                                );
                                if (newlongPress.contains(index)) {
                                  newlongPress.remove(index);
                                } else {
                                  newlongPress.add(index);
                                }
                                longPress.value = widget.customOnLongPress(
                                  newlongPress,
                                );
                                widget.onLongPress!(newlongPress);
                              },
                        isActive: selected.value.contains(index),
                        label: Text(
                          widget.items[index],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          final newSelected = List<int>.from(selected.value);
                          if (newSelected.contains(index) &&
                              newSelected.length > (widget.minSelected ?? 0)) {
                            newSelected.remove(index);
                          } else {
                            if (newSelected.length >=
                                (widget.maxSelected ?? widget.items.length)) {
                              newSelected.removeAt(0);
                            }
                            newSelected.add(index);
                          }
                          selected.value = widget.customOnTap(newSelected);
                          widget.onpress(selected.value);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            )),
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
      ],
    );
  }
}
