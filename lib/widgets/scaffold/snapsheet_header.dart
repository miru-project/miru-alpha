import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class SnapSheetHeader extends StatelessWidget {
  const SnapSheetHeader({
    super.key,
    required this.title,
    this.trailings,
    this.leading,
  });

  final String title;
  final List<Widget>? leading;
  final List<Widget>? trailings;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: context.theme.scaffoldStyle.headerDecoration,
      child: Padding(
        padding: EdgeInsetsGeometry.only(left: 12, bottom: 6),
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
      ),
    );
  }
}

class SnapSheetNested extends StatelessWidget {
  const SnapSheetNested({
    super.key,
    required this.title,
    this.prefix = const <Widget>[],
    this.suffix = const <Widget>[],
  });
  final String title;
  final List<Widget> prefix;
  final List<Widget> suffix;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...prefix,
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        if (suffix.isNotEmpty) const Spacer(),
        ...suffix,
      ],
    );
  }
}
