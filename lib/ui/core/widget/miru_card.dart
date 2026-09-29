import 'package:flutter/widgets.dart';

import 'package:forui/forui.dart';

/// A convenience card that mirrors the old `FCard.raw` ergonomics
/// (title / subtitle / body / child / actions / direction) on top of the
/// new Forui 0.24 `FCard` widget, which no longer provides those named
/// parameters directly.
class MiruCard extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? body;
  final Widget? child;
  final List<Widget>? actions;
  final Axis direction;
  final FCardStyleDelta style;
  final Clip clipBehavior;

  const MiruCard({
    super.key,
    this.title,
    this.subtitle,
    this.body,
    this.child,
    this.actions,
    this.direction = Axis.horizontal,
    this.style = const FCardStyleDelta.context(),
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    final cardStyle = context.theme.cardStyle;
    final hasRichContent =
        title != null || subtitle != null || body != null || actions != null;

    final Widget content;
    if (hasRichContent) {
      // Rich layout — mirrors the old `FCard(title/subtitle/body/actions)`,
      // which applied `cardStyle.padding` around its content.
      content = Padding(
        padding: cardStyle.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              DefaultTextStyle.merge(
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: cardStyle.titleTextStyle,
                child: title!,
              ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              DefaultTextStyle.merge(
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: cardStyle.subtitleTextStyle,
                child: subtitle!,
              ),
            ],
            if (body != null) ...[const SizedBox(height: 6), body!],
            if (actions case final a? when a.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Flex(
                  direction: direction,
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 8,
                  children: a,
                ),
              ),
          ],
        ),
      );
    } else {
      // Plain container card — mirrors old `FCard.raw`, which had NO padding
      // (it was just a decorated container, like a `Container`).
      content = child ?? const SizedBox.shrink();
    }

    return FCard(style: style, clipBehavior: clipBehavior, child: content);
  }
}
