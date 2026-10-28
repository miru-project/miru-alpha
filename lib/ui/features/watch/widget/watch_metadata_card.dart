import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/utils/core/html_text.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// The reference's metadata card: provider label header, collapsible
/// description (Read more / Show less, like the detail hero) and the
/// extension's tag chips. The mock's external "View" link is omitted — the
/// extension record carries no per-media URL to open.
class WatchMetadataCard extends HookWidget {
  const WatchMetadataCard({super.key, required this.detail});

  /// Collapsed synopsis clamp; the disclosure only appears past it.
  static const _collapsedLines = 4;

  final Detail detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final expanded = useState(false);
    final desc = detail.desc?.trim() ?? '';
    final tags = detail.tags ?? const <String>[];

    // An empty synopsis and no tags leave only the title row — which the
    // viewport header already shows. Hide the whole card instead of
    // rendering a "no description" placeholder (2026-10-24 UI review).
    if (desc.isEmpty && tags.isEmpty) return const SizedBox.shrink();

    return MiruCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    detail.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.body.xs.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (desc.isEmpty)
              // No synopsis: nothing replaces it — the tags below carry the
              // card when they exist.
              const SizedBox.shrink()
            else ...[
              // The disclosure toggle renders only when the collapsed text
              // actually overflows its line clamp (audit fix 4) — a
              // single-line synopsis with a "Read more" chevron is clutter.
              // Once expanded, "Show less" stays so there is a way back.
              LayoutBuilder(
                builder: (context, constraints) {
                  final style = context.theme.typography.body.xs.copyWith(
                    color: colors.mutedForeground,
                    height: 1.45,
                  );
                  final span = htmlToSpan(desc, style: style);
                  final painter = TextPainter(
                    text: span,
                    maxLines: _collapsedLines,
                    textDirection: TextDirection.ltr,
                  )..layout(maxWidth: constraints.maxWidth);
                  final overflows = painter.didExceedMaxLines;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        span,
                        maxLines: expanded.value ? null : _collapsedLines,
                        overflow: expanded.value ? null : TextOverflow.ellipsis,
                      ),
                      if (overflows || expanded.value)
                        FTappable(
                          onPress: () => expanded.value = !expanded.value,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  expanded.value
                                      ? 'media.show_less'.i18n
                                      : 'media.read_more'.i18n,
                                  style: context.theme.typography.body.xs2
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colors.primary,
                                      ),
                                ),
                                Icon(
                                  expanded.value
                                      ? FLucideIcons.chevronUp
                                      : FLucideIcons.chevronDown,
                                  size: 13,
                                  color: colors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in tags)
                    FBadge(
                      variant: .outline,
                      style: .delta(
                        labelTextStyle: TextStyleDelta.delta(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        padding: EdgeInsetsGeometryDelta.value(
                          const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                        ),
                      ),
                      child: Text(tag),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
