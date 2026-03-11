import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class ClearableSelect extends StatelessWidget {
  const ClearableSelect({
    super.key,
    required this.title,
    required this.items,
    this.hintText,
    this.onChange,
    this.initialValue,
    this.onReset,
  });
  final String title;
  final String? hintText;
  final List<String> items;
  final Function(String? val)? onChange;
  final String? initialValue;
  final VoidCallback? onReset;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 63,
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200, maxHeight: 65),
              child: FSelect.rich(
                label: Text(title),
                control: .managed(initial: initialValue, onChange: onChange),
                hint: hintText,
                onReset: () {
                  throw "s";
                },
                children: items
                    .map((e) => FSelectItem(value: e, title: Text(e)))
                    .toList(),
                format: (value) {
                  return value;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
