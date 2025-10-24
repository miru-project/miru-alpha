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
    // FHeader()
    return DecoratedBox(
      decoration: context.theme.scaffoldStyle.headerDecoration,
      child: FHeader(title: Text(title)),
    );
  }
}

class SnapSheetNested extends StatelessWidget {
  const SnapSheetNested({
    super.key,
    required this.title,
    this.prefix = const <Widget>[],
  });
  final String title;
  final List<Widget> prefix;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...prefix,
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
      ],
    );
  }
}
