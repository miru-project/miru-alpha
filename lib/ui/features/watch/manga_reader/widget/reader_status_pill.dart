import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/features/watch/manga_reader/widget/reader_top_bar.dart';

/// Minimal progress pill shown when the reader HUD is hidden.
///
/// This is the mock's "Normal Viewing View": no buttons, just where the reader
/// is, plus a one-line hint that the centre tap brings the controls back.
class ReaderStatusPill extends StatelessWidget {
  const ReaderStatusPill({
    super.key,
    required this.chapterLabel,
    required this.page,
    required this.totalPage,
    required this.progress,
  });

  final String chapterLabel;
  final int page;
  final int totalPage;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Center(
      // The pill is content-sized and centred, which means the constraints it is
      // given have to be *loose*. It is positioned with `left`/`right` 0, so a
      // wrapper that passes those through (a clip, a filter, a box) hands the
      // badge a tight full-width constraint and stretches the pill across the
      // screen. The horizontal padding also caps it, so a long chapter name
      // ellipsises instead of running off both edges.
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ReaderSurface(
          // Same frosted surface as the chrome: the pill floats over the
          // artwork while the reader scrolls, so it has to be readable against
          // a page.
          color: colors.background.withValues(alpha: kReaderPillAlpha),
          borderRadius: BorderRadius.circular(16),
          child: FBadge(
            variant: .outline,
            child: Row(
              mainAxisSize: .min,
              children: [
                Flexible(
                  child: Text(
                    chapterLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.body.xs.copyWith(
                      color: colors.foreground,
                    ),
                  ),
                ),
                const _PillDivider(),
                Text(
                  '$page / $totalPage',
                  style: context.theme.typography.body.xs.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const _PillDivider(),
                Text(
                  '${(progress * 100).round()}%',
                  style: context.theme.typography.body.xs.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PillDivider extends StatelessWidget {
  const _PillDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: context.theme.colors.border,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
