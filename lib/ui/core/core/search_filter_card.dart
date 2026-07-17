import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/core/core/blur.dart';

class SearchFilterCard extends StatelessWidget {
  final Widget child;
  const SearchFilterCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Blur(
      borderRadius: context.theme.style.borderRadius.md,
      child: MiruCard(
        style: .delta(
          decoration: .boxDelta(
            borderRadius: context.theme.style.borderRadius.md,
            color: context.theme.colors.background.withAlpha(200),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: child,
        ),
      ),
    );
  }
}
