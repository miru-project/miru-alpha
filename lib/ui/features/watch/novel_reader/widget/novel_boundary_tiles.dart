import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_typography.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Divider between two chained chapters of the infinite webtoon.
///
/// Carries both chapter names so the boundary reads as a section break; when
/// the chapter below is loading or has failed it shows the matching state
/// instead, and the failed state is tappable to retry. The box is exactly
/// [NovelSpacing.boundaryExtent] so measurement and render agree.
class NovelBoundaryTile extends StatelessWidget {
  const NovelBoundaryTile({
    super.key,
    required this.leftChapter,
    required this.rightChapter,
    required this.loading,
    required this.failed,
    required this.onRetry,
    required this.paper,
    required this.typography,
  });

  final String leftChapter;
  final String rightChapter;
  final bool loading;
  final bool failed;
  final VoidCallback onRetry;
  final NovelPaper paper;
  final NovelTypography typography;

  @override
  Widget build(BuildContext context) {
    final body = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'reader.manga.chapter_end'.i18n,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: typography.eyebrow(color: paper.muted),
          ),
          const SizedBox(height: 2),
          Text(
            leftChapter,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: typography.body(color: paper.muted).copyWith(fontSize: 12),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 18,
            child: Row(
              children: [
                Expanded(child: Divider(color: paper.border, height: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: failed
                      ? const Icon(
                          FLucideIcons.circleAlert,
                          size: 18,
                          color: Color(0xFFEF5753),
                        )
                      : Icon(
                          FLucideIcons.chevronsDown,
                          size: 18,
                          color: paper.muted,
                        ),
                ),
                Expanded(child: Divider(color: paper.border, height: 1)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (loading) ...[
            const SizedBox(width: 20, height: 20, child: FCircularProgress()),
            const SizedBox(height: 6),
            Text(
              'reader.manga.loading_chapter'.i18n,
              textAlign: TextAlign.center,
              style: typography.body(color: paper.muted).copyWith(fontSize: 12),
            ),
          ] else if (failed) ...[
            Text(
              'reader.manga.chapter_load_failed'.i18n,
              textAlign: TextAlign.center,
              style: typography
                  .body(color: const Color(0xFFEF5753))
                  .copyWith(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              'reader.manga.chapter_load_failed_retry'.i18n,
              textAlign: TextAlign.center,
              style: typography
                  .body(color: paper.foreground)
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ] else
            Text(
              'reader.manga.next_chapter'.i18n.fill({'name': rightChapter}),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: typography
                  .body(color: paper.foreground)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );

    if (!failed) {
      return SizedBox(height: NovelSpacing.boundaryExtent, child: body);
    }
    return FTappable(
      onPress: onRetry,
      child: SizedBox(height: NovelSpacing.boundaryExtent, child: body),
    );
  }
}

/// Absolute series boundary: first / last chapter marker.
class NovelSeriesBoundaryTile extends StatelessWidget {
  const NovelSeriesBoundaryTile({
    super.key,
    required this.isStart,
    required this.paper,
    required this.typography,
    this.chapterName = '',
  });

  final bool isStart;
  final String chapterName;
  final NovelPaper paper;
  final NovelTypography typography;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: NovelSpacing.boundaryExtent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isStart ? FLucideIcons.chevronsDown : FLucideIcons.flag,
              size: 18,
              color: paper.muted,
            ),
            const SizedBox(height: 8),
            Text(
              isStart
                  ? 'reader.manga.first_chapter'.i18n
                  : 'reader.manga.last_chapter'.i18n,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: typography.eyebrow(color: paper.muted),
            ),
            if (chapterName.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                chapterName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: typography
                    .body(color: paper.muted)
                    .copyWith(fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
