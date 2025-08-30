import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/utils/theme/theme.dart';

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
            Padding(
              padding: EdgeInsetsGeometry.only(left: 5),
              child: Text(
                title,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200, maxHeight: 50),
              child: FSelect(
                initialValue: initialValue,
                onChange: onChange,
                style:
                    FSelectStyle.inherit(
                      colors: context.theme.colors,
                      typography: overrideTheme.typography,
                      style: context.theme.style,
                    ).call,
                hint: hintText,
                clearable: true,
                items: {for (final item in items) item: item},
                // children: [for (final item in items) FSelectItem(item, item)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
