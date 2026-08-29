import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:easy_refresh/easy_refresh.dart';
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
      body: EasyRefresh(
        header: const ForuiHeader(),
        onRefresh: () async {
          await ref.read(downloadProvider.notifier).refreshStorageStats();
          await ref.read(downloadProvider.notifier).refreshActiveStatus();
        },
        child: downloadAsync.when(
          loading: () => const Center(child: FCircularProgress()),
          error: (error, _) => EmptyState(
            icon: FLucideIcons.download,
            message: 'download.error_loading_downloads'.i18n,
          ),
          data: (state) => _buildContentBody(state, downloadPath),
        ),
      ),
    );
  }

  Widget _buildContentBody(DownloadState state, String downloadPath) {
    final active = state.active;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Storage indicator card with live progress
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _StorageIndicatorCard(
            downloadPath: downloadPath,
            storageStats: state.storageStats,
            active: active,
            tempStorageBytes: state.tempStorageBytes,
          ),
        ),
        // Filter tabs - only active downloads
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _DownloadFilterTabs(active: active),
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

/// Per-category storage breakdown shown on the mobile storage card.
class _StorageBreakdown {
  const _StorageBreakdown({
    required this.video,
    required this.manga,
    required this.novel,
    required this.temp,
  });
  final int video;
  final int manga;
  final int novel;
  final int temp;
  int get total => video + manga + novel + temp;
}

/// Computes the storage breakdown for the mobile card.
///
/// The backend [proto.StorageStats] is the source of truth for completed
/// files per category. For the in-progress (temp) slice we combine the
/// backend's reported `temp_bytes` with the live bytes reported by active
/// tasks: `max(backendTemp, liveTemp)`. This keeps the Temp slice accurate
/// when the backend under-reports (or zeroes out) temp bytes while downloads
/// are actively progressing, instead of showing 0B for occupied space.
_StorageBreakdown _computeStorageBreakdown(
  proto.StorageStats? stats,
  int tempStorageBytes,
) {
  final video = stats?.videoBytes.toInt() ?? 0;
  final manga = stats?.mangaBytes.toInt() ?? 0;
  final novel = stats?.novelBytes.toInt() ?? 0;
  // Authoritative mobile temp: the actual on-disk size of the temp download
  // directory (scanned by the provider). This avoids treating progress values
  // (segment counts for HLS, percentages for MP4) as byte sizes.
  final int temp = tempStorageBytes;
  return _StorageBreakdown(
    video: video,
    manga: manga,
    novel: novel,
    temp: temp,
  );
}

class _StorageIndicatorCard extends StatelessWidget {
  const _StorageIndicatorCard({
    required this.downloadPath,
    required this.storageStats,
    required this.active,
    required this.tempStorageBytes,
  });

  final String downloadPath;

  /// Per-category storage usage from the backend (video/manga/novel + temp),
  /// or null when it has not loaded yet.
  final proto.StorageStats? storageStats;

  /// Active downloads, used to calculate live progress for in-progress items.
  final List<proto.DownloadProgress> active;

  /// Actual on-disk size of the temp download directory (scanned from disk).
  final int tempStorageBytes;

  @override
  Widget build(BuildContext context) {
    final breakdown = _computeStorageBreakdown(storageStats, tempStorageBytes);

    final total = breakdown.total;
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
                        flex: breakdown.video,
                        color: const Color(0xFF3B82F6),
                      ),
                      _storageSegment(
                        flex: breakdown.manga,
                        color: const Color(0xFFEC4899),
                      ),
                      _storageSegment(
                        flex: breakdown.novel,
                        color: const Color(0xFFF59E0B),
                      ),
                      _storageSegment(
                        flex: breakdown.temp,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Compact legend: per-category occupied size (video / manga / novel / temp).
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _StorageLegendItem(
                  color: const Color(0xFF3B82F6),
                  label: 'media.video'.i18n,
                  size: _formatBytes(breakdown.video),
                ),
                _StorageLegendItem(
                  color: const Color(0xFFEC4899),
                  label: 'media.manga'.i18n,
                  size: _formatBytes(breakdown.manga),
                ),
                _StorageLegendItem(
                  color: const Color(0xFFF59E0B),
                  label: 'media.novel'.i18n,
                  size: _formatBytes(breakdown.novel),
                ),
                _StorageLegendItem(
                  color: const Color(0xFF64748B),
                  label: 'download.temp'.i18n,
                  size: _formatBytes(breakdown.temp),
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

// -----------------------------------------------------------------------------
// Filter tabs — MiruExpandableTabs bar + one filtered content area
// -----------------------------------------------------------------------------

class _DownloadFilterTabs extends ConsumerStatefulWidget {
  const _DownloadFilterTabs({required this.active});

  final List<proto.DownloadProgress> active;

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
    required this.categoryFilter,
  });

  final List<proto.DownloadProgress> active;
  final proto.DownloadCategory? categoryFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredActive = categoryFilter == null
        ? active
        : active.where((t) => t.category == categoryFilter).toList();
    final hasItems = filteredActive.isNotEmpty;

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
      children: _buildActiveItems(filteredActive),
    );
  }

  List<Widget> _buildActiveItems(List<proto.DownloadProgress> items) => [
    for (var i = 0; i < items.length; i++) ...[
      if (i > 0) const SizedBox(height: 8),
      _MobileActiveDownloadItem(task: items[i]),
    ],
    const SizedBox(height: 16),
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
