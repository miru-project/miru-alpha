import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

List<Widget> buildSeparators(List<Widget> items, {Widget separator = const FDivider()}) {
  if (items.isEmpty) return <Widget>[];
  final List<Widget> out = <Widget>[];
  for (var i = 0; i < items.length; i++) {
    out.add(items[i]);
    if (i != items.length - 1) out.add(separator);
  }
  return out;
}
