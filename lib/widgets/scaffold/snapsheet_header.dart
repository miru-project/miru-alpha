import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class SnapSheetHeader extends StatelessWidget {
  const SnapSheetHeader({
    super.key,
    required this.title,
    this.trailings,
    this.leading,
    this.description,
    this.padding,
  });

  final String title;
  final String? description;
  final List<Widget>? leading;
  final List<Widget>? trailings;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: context.theme.scaffoldStyle.headerDecoration,
      child: Padding(
        padding: padding ?? EdgeInsetsGeometry.only(left: 12, bottom: 6),
        child: FLabel(
          axis: .vertical,
          description: (description != null) ? Text(description!) : null,
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          ),
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

  const SnapSheetNested.back({
    super.key,
    required this.title,
    this.suffix = const <Widget>[],
  }) : prefix = const <Widget>[HeaderBack()];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: 10, right: 12),
      child: Row(
        children: [
          ...prefix,
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              overflow: .ellipsis,
            ),
          ),
          if (suffix.isNotEmpty) const Spacer(),
          ...suffix,
        ],
      ),
    );
  }
}

class HeaderBack extends StatelessWidget {
  const HeaderBack({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0, top: 4, left: 10),
        child: Icon(
          FIcons.chevronLeft,
          size: 28,
          color: context.theme.colors.primary,
        ),
      ),
    );
  }
}
