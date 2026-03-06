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
  });
  final String title;
  final String? hintText;
  final List<String> items;
  final Function(String? val)? onChange;
  final String? initialValue;
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
              child: FSelect(
                label: Text(
                  title,
                  // style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                control: .managed(initial: initialValue, onChange: onChange),
                hint: hintText,
                clearable: true,
                items: {for (final item in items) item: item},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
