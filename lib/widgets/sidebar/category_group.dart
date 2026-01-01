import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';

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
  final void Function(String) onpress;
  final int? maxSelected;
  final int? minSelected;
  final String? title;
  @override
  Widget build(BuildContext context) {
    // final selected = useState(0);
    final controller = useFRadioMultiValueNotifier(value: items[0]);
    return FSelectTileGroup<String>(
      control: .managedRadio(
        controller: controller,
        onChange: (value) {
          onpress(value.first);
        },
      ),
      label: title == null ? null : Text(title!),

      children: List.generate(
        items.length,
        (index) =>
            FSelectTile<String>(title: Text(items[index]), value: items[index]),
      ),
    );
  }
}
