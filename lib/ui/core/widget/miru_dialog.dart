import 'package:flutter/widgets.dart';

import 'package:forui/forui.dart';

/// A convenience dialog that mirrors the old `FDialog` ergonomics
/// (title / body / actions / direction) on top of the new Forui 0.24
/// `FDialog` widget, which now requires a `builder`.
class MiruDialog extends StatelessWidget {
  final FDialogStyleDelta style;
  final Animation<double>? animation;
  final String? semanticsLabel;
  final BoxConstraints? constraints;
  final bool resizeToAvoidInsets;
  final Clip clipBehavior;
  final Widget? title;
  final Widget? body;
  final List<Widget>? actions;
  final Axis direction;

  const MiruDialog({
    super.key,
    this.style = const FDialogStyleDelta.context(),
    this.animation,
    this.semanticsLabel,
    this.constraints,
    this.resizeToAvoidInsets = false,
    this.clipBehavior = Clip.none,
    this.title,
    this.body,
    this.actions,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) => FDialog(
    style: style,
    animation: animation,
    semanticsLabel: semanticsLabel,
    constraints:
        constraints ?? const BoxConstraints(minWidth: 280, maxWidth: 560),
    resizeToAvoidInsets: resizeToAvoidInsets,
    clipBehavior: clipBehavior,
    builder: (context, dialogStyle) {
      final touch = context.platformVariant.touch;
      return Padding(
        padding: switch (touch) {
          true => const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          false => const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: switch (touch) {
                  true => const EdgeInsets.only(left: 8, right: 8, bottom: 20),
                  false => const EdgeInsets.only(bottom: 16),
                },
                child: DefaultTextStyle.merge(
                  style: dialogStyle.titleTextStyle,
                  child: title!,
                ),
              ),
            if (body != null) body!, // ignore: use_null_aware_elements
            if (actions case final a? when a.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Flex(
                  direction: direction,
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: touch ? 10 : 8,
                  children: touch
                      ? [for (final action in a) Expanded(child: action)]
                      : a,
                ),
              ),
          ],
        ),
      );
    },
  );
}
