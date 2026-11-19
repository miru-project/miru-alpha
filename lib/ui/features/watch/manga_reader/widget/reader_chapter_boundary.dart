import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Divider between two chapters of the infinite webtoon.
///
/// Rendered as one list item between the last page of the chapter above and
/// the first page of the chapter below. Carries both chapters' names so the
/// boundary reads as a section break, not as a page.
class ChapterBoundaryTile extends StatelessWidget {
  const ChapterBoundaryTile({
    super.key,
    required this.endedChapterName,
    required this.nextChapterName,
    required this.nextLoading,
    required this.nextFailed,
    required this.onRetry,
  });

  final String endedChapterName;
  final String nextChapterName;

  /// True while the chapter below is being fetched.
  final bool nextLoading;

  /// True when the chapter below failed to load; the tile becomes tappable
  /// and retries it.
  final bool nextFailed;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        children: [
          Text(
            'reader.manga.chapter_end'.i18n,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.theme.typography.body.xs2.copyWith(
              color: colors.mutedForeground,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            endedChapterName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.theme.typography.body.sm.copyWith(
              color: colors.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Divider(color: colors.border, height: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: nextFailed
                    ? Icon(
                        FLucideIcons.circleAlert,
                        size: 18,
                        color: colors.destructive,
                      )
                    : Icon(
                        FLucideIcons.chevronsDown,
                        size: 18,
                        color: colors.mutedForeground,
                      ),
              ),
              Expanded(child: Divider(color: colors.border, height: 1)),
            ],
          ),
          const SizedBox(height: 12),
          if (nextLoading) ...[
            const SizedBox(width: 20, height: 20, child: FCircularProgress()),
            const SizedBox(height: 6),
            Text(
              'reader.manga.loading_chapter'.i18n,
              textAlign: TextAlign.center,
              style: context.theme.typography.body.xs2.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ] else if (nextFailed) ...[
            Text(
              'reader.manga.chapter_load_failed'.i18n,
              textAlign: TextAlign.center,
              style: context.theme.typography.body.xs2.copyWith(
                color: colors.destructive,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'reader.manga.chapter_load_failed_retry'.i18n,
              textAlign: TextAlign.center,
              style: context.theme.typography.body.xs2.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else
            Text(
              'reader.manga.next_chapter'.i18n.fill({'name': nextChapterName}),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.theme.typography.body.sm.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );

    if (!nextFailed) return child;
    return FTappable(onPress: onRetry, child: child);
  }
}

/// Skeleton shown in place of a chapter that has not finished loading.
class ChapterLoadingTile extends StatelessWidget {
  const ChapterLoadingTile({super.key, this.name = ''});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const SizedBox(width: 28, height: 28, child: FCircularProgress()),
          const SizedBox(height: 10),
          Text(
            'reader.manga.loading_chapter'.i18n,
            textAlign: TextAlign.center,
            style: context.theme.typography.body.xs2.copyWith(
              color: colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton/error tile for a chapter that failed to load.
class ChapterLoadErrorTile extends StatelessWidget {
  const ChapterLoadErrorTile({
    super.key,
    required this.name,
    required this.onRetry,
  });

  final String name;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return FTappable(
      onPress: onRetry,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          children: [
            Icon(FLucideIcons.circleAlert, size: 28, color: colors.destructive),
            const SizedBox(height: 10),
            if (name.isNotEmpty) ...[
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.theme.typography.body.sm.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              'reader.manga.chapter_load_failed'.i18n,
              textAlign: TextAlign.center,
              style: context.theme.typography.body.xs2.copyWith(
                color: colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'reader.manga.chapter_load_failed_retry'.i18n,
              textAlign: TextAlign.center,
              style: context.theme.typography.body.xs2.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Absolute series boundary: first / last chapter marker.
class SeriesBoundaryTile extends StatelessWidget {
  const SeriesBoundaryTile({super.key, required this.isStart, this.name = ''});

  final bool isStart;
  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          Icon(
            isStart ? FLucideIcons.chevronsDown : FLucideIcons.flag,
            size: 18,
            color: colors.mutedForeground,
          ),
          const SizedBox(height: 8),
          Text(
            isStart
                ? 'reader.manga.first_chapter'.i18n
                : 'reader.manga.last_chapter'.i18n,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.theme.typography.body.xs2.copyWith(
              color: colors.mutedForeground,
              letterSpacing: 0.6,
            ),
          ),
          if (name.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.theme.typography.body.xs2.copyWith(
                color: colors.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
