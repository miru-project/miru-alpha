import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/utils/theme/theme.dart';
import 'package:miru_app_new/widgets/blur.dart';

class SearchFilterCard extends StatelessWidget {
  final Widget child;
  const SearchFilterCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Blur(
      child: FCard(
        style:
            FCardStyle.inherit(
              colors: context.theme.colors.copyWith(
                background: context.theme.colors.background.withAlpha(200),
              ),
              typography: overrideTheme.typography,
              style: context.theme.style,
            ).call,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: child,
        ),
      ),
    );
  }
}
