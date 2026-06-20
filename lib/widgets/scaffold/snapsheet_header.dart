import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class SnapSheetHeader extends StatelessWidget {
  const SnapSheetHeader({
    super.key,
    required this.title,
    this.description,
    this.padding,
    this.suffix = const <Widget>[],
  });

  final String title;
  final String? description;
  final EdgeInsetsGeometry? padding;
  final List<Widget> suffix;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: context.theme.scaffoldStyle.headerDecoration,
      child: Padding(
        padding:
            padding ?? EdgeInsetsGeometry.only(left: 0, bottom: 15, right: 10),
        child: FLabel(
          layout: .vertical,
          description: (description != null) ? Text(description!) : null,
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Row(children: suffix),
            ],
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
    this.prefix,
    this.suffix,
  });
  final String title;
  final Widget? prefix;
  final Widget? suffix;

  const SnapSheetNested.back({super.key, required this.title, this.suffix})
    : prefix = const HeaderBack();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: 2, right: 12),
      child: Row(
        children: [
          prefix ?? const SizedBox.shrink(),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          suffix ?? const SizedBox.shrink(),
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
          FLucideIcons.chevronLeft,
          size: 28,
          color: context.theme.colors.primary,
        ),
      ),
    );
  }
}
