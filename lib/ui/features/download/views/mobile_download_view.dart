import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/core/empty_state.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/download/download_utils.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// Mobile download view based on the Material 3 design reference.
///
/// Features:
/// - Pinned top navigation header (back, title, history, more)
/// - Storage indicator card
/// - Filter tabs using MiruTabs (All / Video / Manga / Novel)
/// - Combined active + completed downloads list
/// - "Delete All Finished" batch action
class MobileDownloadView extends HookConsumerWidget {
  const MobileDownloadView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadAsync = ref.watch(downloadProvider);
    final downloadPath = ref.watch(
      applicationControllerProvider.select(
        (v) => MiruSettings.getSettingSync<String>(SettingKey.downloadPath),
      ),
    );

    return MiruScaffold.mobile(
      childPad: false,
      sliverHeaders: [
        StaticSliverHeaderDelegate(
          maxExtent: 56,
          minExtent: 56,
          child: const _MobileDownloadHeader(),
        ),
      ],
      // MiruTabs contains an Expanded + TabBarView, so it requires a bounded
      // height. Passing it as a plain sliver (e.g. SliverToBoxAdapter) would
      // give it unbounded height and throw a RenderFlex error. Using `body`
      // (the scaffold wraps it in SliverFillRemaining) keeps the header +
      // storage card fixed while the tab content scrolls in its own area.
      body: downloadAsync.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (error, _) => EmptyState(
          icon: FLucideIcons.download,
          message: 'download.error_loading_downloads'.i18n,
        ),
        data: (state) => _buildContentBody(state, downloadPath),
      ),
    );
  }

  Widget _buildContentBody(DownloadState state, String downloadPath) {
    final active = state.active;
    final history = state.history;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Storage indicator card
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _StorageIndicatorCard(
            downloadPath: downloadPath,
            storageStats: state.storageStats,
            history: history,
          ),
        ),
        // Filter tabs using MiruTabs. The tab contents render the filtered
        // active + completed download lists (and their empty states).
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _DownloadFilterTabs(active: active, history: history),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Header
// -----------------------------------------------------------------------------

class _MobileDownloadHeader extends ConsumerWidget {
  const _MobileDownloadHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.theme.colors.background,
        border: Border(bottom: BorderSide(color: context.theme.colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const HeaderBack(),
                  Text(
                    'download.name'.i18n,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FButton.icon(
                  variant: FButtonVariant.ghost,
                  size: .sm,
                  onPress: () => context.push('/home/download/history'),
                  child: const Icon(FLucideIcons.clock),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Storage indicator
// -----------------------------------------------------------------------------

class _StorageIndicatorCard extends StatelessWidget {
  const _StorageIndicatorCard({
    required this.downloadPath,
    required this.storageStats,
    required this.history,
  });

  final String downloadPath;

  /// Per-category storage usage from the backend (video/manga/novel + temp),
  /// or null when it has not loaded yet.
  final proto.StorageStats? storageStats;

  /// Completed downloads, used as a fallback when [storageStats] is null.
  final List<proto.Download> history;

  @override
  Widget build(BuildContext context) {
    final stats = storageStats;
    late final int video;
    late final int manga;
    late final int novel;
    late final int temp;
    if (stats != null) {
      video = stats.videoBytes.toInt();
      manga = stats.mangaBytes.toInt();
      novel = stats.novelBytes.toInt();
      temp = stats.tempBytes.toInt();
    } else {
      // Fallback: measure each finished download's save_path live, grouped by
      // its content category (the DB stores category, not media mechanism).
      final counts = _computeCategorySizes(history);
      video = counts[0];
      manga = counts[1];
      novel = counts[2];
      temp = 0;
    }
    final total = video + manga + novel + temp;
    final hasAny = total > 0;

    return MiruCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row: "Device Storage" on the left, occupied total on the
            // upper right, aligned with the title.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'download.device_storage'.i18n,
                  style: context.theme.typography.body.sm.copyWith(
                    color: context.theme.colors.mutedForeground,
                    fontWeight: .w600,
                  ),
                ),
                Text(
                  _formatBytes(total),
                  style: context.theme.typography.body.sm.copyWith(
                    color: context.theme.colors.foreground,
                    fontWeight: .w600,
                  ),
                ),
              ],
            ),
            Text(
              downloadPath.isNotEmpty ? downloadPath : 'common.path'.i18n,
              style: context.theme.typography.body.sm.copyWith(
                color: Color.lerp(
                  context.theme.colors.primary,
                  context.theme.colors.foreground,
                  .5,
                ),
                fontWeight: .w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Stacked line graph: proportionally sized Video / Manga / Novel /
            // Temp segments over a muted track.
            ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: Container(
                height: 8,
                color: context.theme.colors.muted,
                child: Row(
                  children: [
                    if (hasAny) ...[
                      _storageSegment(
                        flex: video,
                        color: const Color(0xFF3B82F6),
                      ),
                      _storageSegment(
                        flex: manga,
                        color: const Color(0xFFEC4899),
                      ),
                      _storageSegment(
                        flex: novel,
                        color: const Color(0xFFF59E0B),
                      ),
                      _storageSegment(
                        flex: temp,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Compact legend: each media type (and temp) with its occupied size.
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _StorageLegendItem(
                  color: const Color(0xFF3B82F6),
                  label: 'media.video'.i18n,
                  size: _formatBytes(video),
                ),
                _StorageLegendItem(
                  color: const Color(0xFFEC4899),
                  label: 'media.manga'.i18n,
                  size: _formatBytes(manga),
                ),
                _StorageLegendItem(
                  color: const Color(0xFFF59E0B),
                  label: 'media.novel'.i18n,
                  size: _formatBytes(novel),
                ),
                _StorageLegendItem(
                  color: const Color(0xFF64748B),
                  label: 'download.temp'.i18n,
                  size: _formatBytes(temp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A proportionally sized segment of the stacked storage bar.
  ///
  /// [flex] is the raw byte count for this media type; it doubles as the
  /// [Expanded.flex] weight, so the visual width is proportional to how much
  /// space that type occupies. Zero-byte types contribute nothing.
  Widget _storageSegment({required int flex, required Color color}) {
    if (flex <= 0) return const SizedBox.shrink();
    return Expanded(
      flex: flex,
      child: Container(color: color),
    );
  }
}

class _StorageLegendItem extends StatelessWidget {
  const _StorageLegendItem({
    required this.color,
    required this.label,
    required this.size,
  });

  final Color color;
  final String label;
  final String size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: context.theme.typography.body.xs.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          size,
          style: context.theme.typography.body.xs.copyWith(
            color: context.theme.colors.mutedForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Fallback summary of on-disk size for finished downloads, grouped by the
/// content [category] stored on each row (video / manga / novel). Returns
/// `[video, manga, novel]`. Sizes are measured live from each download's
/// `savePath`; a missing file contributes 0 instead of throwing.
List<int> _computeCategorySizes(List<proto.Download> history) {
  var video = 0;
  var manga = 0;
  var novel = 0;

  for (final download in history) {
    final size = _fileSizeOnDisk(download.savePath);
    switch (download.category) {
      case proto.DownloadCategory.video:
        video += size;
      case proto.DownloadCategory.manga:
        manga += size;
      case proto.DownloadCategory.novel:
        novel += size;
      case proto.DownloadCategory.unspecified:
        break;
    }
  }
  return [video, manga, novel];
}

/// Size of a finished download's file or directory on disk, in bytes.
///
/// Returns 0 if the path is empty or no longer exists (e.g. the user deleted
/// it outside the app). All filesystem access is guarded so this never throws.
int _fileSizeOnDisk(String path) {
  if (path.isEmpty) return 0;
  try {
    final entity = FileSystemEntity.typeSync(path);
    if (entity == FileSystemEntityType.file) {
      return File(path).lengthSync();
    } else if (entity == FileSystemEntityType.directory) {
      return _directorySizeSync(Directory(path));
    }
  } catch (_) {
    return 0;
  }
  return 0;
}

int _directorySizeSync(Directory dir) {
  var total = 0;
  try {
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File) {
        total += entity.lengthSync();
      }
    }
  } catch (_) {
    // Ignore entries we cannot read; the partial total is still useful.
  }
  return total;
}

// -----------------------------------------------------------------------------
// Filter tabs — MiruExpandableTabs bar + one filtered content area
// -----------------------------------------------------------------------------

class _DownloadFilterTabs extends ConsumerStatefulWidget {
  const _DownloadFilterTabs({required this.active, required this.history});

  final List<proto.DownloadProgress> active;
  final List<proto.Download> history;

  @override
  ConsumerState<_DownloadFilterTabs> createState() =>
      _DownloadFilterTabsState();
}

class _DownloadFilterTabsState extends ConsumerState<_DownloadFilterTabs> {
  int _filterIndex = 0;

  static const _filters = <proto.DownloadCategory?>[
    null,
    proto.DownloadCategory.video,
    proto.DownloadCategory.manga,
    proto.DownloadCategory.novel,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MiruExpandableTabs(
          selectedIndex: _filterIndex,
          onIndexChanged: (i) => setState(() => _filterIndex = i),
          children: [
            MiruExpandableTabEntry(
              icon: const Icon(FLucideIcons.download),
              label: Text('download.all_downloads'.i18n),
            ),
            MiruExpandableTabEntry(
              icon: const Icon(FLucideIcons.clapperboard),
              label: Text('media.video'.i18n),
            ),
            MiruExpandableTabEntry(
              icon: const Icon(FLucideIcons.bookOpen),
              label: Text('media.manga'.i18n),
            ),
            MiruExpandableTabEntry(
              icon: const Icon(FLucideIcons.scrollText),
              label: Text('media.novel'.i18n),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _DownloadTabContent(
            active: widget.active,
            history: widget.history,
            categoryFilter: _filters[_filterIndex],
          ),
        ),
      ],
    );
  }
}

class _DownloadTabContent extends ConsumerWidget {
  const _DownloadTabContent({
    required this.active,
    required this.history,
    required this.categoryFilter,
  });

  final List<proto.DownloadProgress> active;
  final List<proto.Download> history;
  final proto.DownloadCategory? categoryFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredActive = categoryFilter == null
        ? active
        : active.where((t) => t.category == categoryFilter).toList();
    final filteredHistory = categoryFilter == null
        ? history
        : history.where((t) => t.category == categoryFilter).toList();
    final hasItems = filteredActive.isNotEmpty || filteredHistory.isNotEmpty;

    if (!hasItems) {
      return Center(
        child: EmptyState(
          icon: FLucideIcons.download,
          message: 'download.no_active_downloads'.i18n,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 100),
      children: [
        if (filteredActive.isNotEmpty) ..._buildActiveItems(filteredActive),
        if (filteredHistory.isNotEmpty) ..._buildHistoryItems(filteredHistory),
      ],
    );
  }

  List<Widget> _buildActiveItems(List<proto.DownloadProgress> items) => [
    for (var i = 0; i < items.length; i++) ...[
      if (i > 0) const SizedBox(height: 8),
      _MobileActiveDownloadItem(task: items[i]),
    ],
    const SizedBox(height: 16),
  ];

  List<Widget> _buildHistoryItems(List<proto.Download> items) => [
    for (var i = 0; i < items.length; i++) ...[
      if (i > 0) const SizedBox(height: 8),
      _MobileCompletedDownloadItem(download: items[i]),
    ],
    const SizedBox(height: 16),
    _DeleteAllFinishedButton(history: items),
  ];
}

// -----------------------------------------------------------------------------
// Active download item
// -----------------------------------------------------------------------------

class _MobileActiveDownloadItem extends ConsumerWidget {
  const _MobileActiveDownloadItem({required this.task});

  final proto.DownloadProgress task;

  double get _ratio => (task.total > 0 ? task.progress / task.total : 0)
      .toDouble()
      .clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = task.status;
    final isPaused = status == proto.DownloadStatus.PAUSED;
    final isFailed = status == proto.DownloadStatus.FAILED;
    final isQueued = status == proto.DownloadStatus.QUEUED;

    return MiruCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Drag handle
            Icon(
              FLucideIcons.gripVertical,
              size: 20,
              color: context.theme.colors.mutedForeground,
            ),
            const SizedBox(width: 8),
            // Title + info + progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_fromProgress(task.progress, task.mediaType)} / ${_fromProgress(task.total, task.mediaType)} • ${DownloadUtils.statusToI18N(status).i18n}',
                    style: context.theme.typography.body.sm.copyWith(
                      fontSize: 12,
                      color: context.theme.colors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  FDeterminateProgress(value: _ratio),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Pause / resume
            FButton.icon(
              variant: FButtonVariant.ghost,
              size: .sm,
              onPress: () => ref
                  .read(downloadProvider.notifier)
                  .sendAction(
                    context,
                    task.taskId.toString(),
                    isFailed || isPaused || isQueued
                        ? proto.DownloadAction.RESUME
                        : proto.DownloadAction.PAUSE,
                  ),
              child: Icon(
                isFailed || isPaused || isQueued
                    ? FLucideIcons.play
                    : FLucideIcons.pause,
              ),
            ),
            // Cancel
            FButton.icon(
              variant: FButtonVariant.ghost,
              size: .sm,
              onPress: () => ref
                  .read(downloadProvider.notifier)
                  .sendAction(
                    context,
                    task.taskId.toString(),
                    proto.DownloadAction.CANCEL,
                  ),
              child: const Icon(FLucideIcons.x),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Completed download item
// -----------------------------------------------------------------------------

class _MobileCompletedDownloadItem extends ConsumerWidget {
  const _MobileCompletedDownloadItem({required this.download});

  final proto.Download download;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MiruCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Drag handle (visual only for completed items)
            Icon(
              FLucideIcons.gripVertical,
              size: 20,
              color: context.theme.colors.mutedForeground,
            ),
            const SizedBox(width: 8),
            // Title + path
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    download.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (download.savePath.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      download.savePath,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.typography.body.sm.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status badge (capped so it can shrink instead of overflowing the
            // row on narrow screens or with long translations)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: _StatusBadge(status: download.status),
            ),
            const SizedBox(width: 4),
            // Delete
            FButton.icon(
              variant: FButtonVariant.ghost,
              size: .sm,
              onPress: () async {
                await MiruGrpcClient.downloadClient.deleteDownload(
                  proto.DeleteDownloadRequest()..id = download.id,
                );
                ref.invalidate(downloadProvider);
              },
              child: Icon(
                FLucideIcons.trash2,
                color: context.theme.colors.destructive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Status badge
// -----------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final proto.DownloadStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      proto.DownloadStatus.DOWNLOADING => (
        'download.status.downloading'.i18n,
        context.theme.colors.primary,
      ),
      proto.DownloadStatus.PAUSED => (
        'download.status.paused'.i18n,
        context.theme.colors.mutedForeground,
      ),
      proto.DownloadStatus.CONVERTING => (
        'download.status.converting'.i18n,
        const Color(0xFFD97706),
      ),
      proto.DownloadStatus.COMPLETED => (
        'download.status.completed'.i18n,
        const Color(0xFF16A34A),
      ),
      proto.DownloadStatus.FAILED => (
        'download.status.failed'.i18n,
        context.theme.colors.destructive,
      ),
      proto.DownloadStatus.CANCELLED => (
        'download.status.cancelled'.i18n,
        context.theme.colors.mutedForeground,
      ),
      proto.DownloadStatus.QUEUED => (
        'download.status.queued'.i18n,
        context.theme.colors.mutedForeground,
      ),
      _ => (
        'download.status.unknown'.i18n,
        context.theme.colors.mutedForeground,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.theme.typography.body.xs.copyWith(color: color),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Delete All Finished button
// -----------------------------------------------------------------------------

class _DeleteAllFinishedButton extends ConsumerWidget {
  const _DeleteAllFinishedButton({required this.history});

  final List<proto.Download> history;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: FButton(
        variant: FButtonVariant.outline,
        onPress: () async {
          for (final download in history) {
            await MiruGrpcClient.downloadClient.deleteDownload(
              proto.DeleteDownloadRequest()..id = download.id,
            );
          }
          ref.invalidate(downloadProvider);
        },
        // The default content builder lays its child out at intrinsic width,
        // which overflows the button on narrow screens or with long labels.
        // A custom builder keeps the label a flex child so it can ellipsize
        // instead of overflowing the button's content row.
        builder: (context, _, _, _, _, child) {
          return Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FLucideIcons.trash2,
                  size: 18,
                  color: context.theme.colors.mutedForeground,
                ),
                const SizedBox(width: 8),
                Flexible(child: child!),
              ],
            ),
          );
        },
        child: Text(
          'download.delete_all_finished'.i18n,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------

String _formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var unitIndex = 0;
  var size = bytes.toDouble();
  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }
  return '${size.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
}

String _fromProgress(int progress, proto.DownloadMediaType mediaType) {
  switch (mediaType) {
    case proto.DownloadMediaType.hls:
      return progress.toString();
    default:
      return _formatBytes(progress);
  }
}
