import 'package:flutter/material.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as common;
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/history_page_provider.dart';
import 'package:miru_alpha/widgets/core/image_widget.dart';

class DownloadItem extends ConsumerWidget {
  const DownloadItem({super.key, required this.task});

  final common.DownloadProgress task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = task.total > 0 ? task.progress / task.total : 0.0;
    final isDownloading = task.status != 'Completed' && task.status != 'Failed';

    // Try to find matching history item for cover
    final history = ref.watch(historyPageProvider).history;
    final matchingHistory = history.firstWhere(
      (h) => h.package == task.package && task.title.contains(h.title),
      orElse: () => history.firstWhere(
        (h) => h.package == task.package,
        orElse: () => history.first,
      ),
    );

    return Row(
      children: [
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ImageWidget(
            errChild: Container(
              width: 60,
              height: 60,
              color: context.theme.colors.muted,
              child: const Icon(FIcons.cloudAlert, size: 20),
            ),
            imageUrl: matchingHistory.cover,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(width: 12),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${task.status.toLowerCase().i18n} • ${task.progress}/${task.total}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
              if (isDownloading) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: FDeterminateProgress(value: progress)),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Action button
        FButton.icon(
          onPress: () => ref
              .read(downloadProvider.notifier)
              .sendAction(
                context,
                task.taskId.toString(),
                task.status == 'Paused' ? 'resume' : 'pause',
              ),
          variant: .outline,
          child: Icon(
            task.status == 'Paused'
                ? Icons.play_arrow
                : (isDownloading ? Icons.pause : Icons.check),
            size: 16,
          ),
        ),
      ],
    );
  }
}

class DownloadsList extends ConsumerWidget {
  const DownloadsList({required this.padding, super.key});
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(downloadProvider);

    return downloadState.when(
      data: (data) {
        final activeTasks = data.active;
        if (activeTasks.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text("no_active_downloads".i18n),
            ),
          );
        }
        return SliverPadding(
          padding: padding,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index >= activeTasks.length) return null;
              final task = activeTasks[index];
              return DownloadItem(key: ValueKey(task.key), task: task);
            }, childCount: activeTasks.length > 4 ? 4 : activeTasks.length),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) =>
          SliverToBoxAdapter(child: Text("${'error_loading_downloads'.i18n}: $e")),
    );
  }
}

class DownloadsText extends StatelessWidget {
  const DownloadsText({required this.padding, super.key});
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: padding,
        child: Text(
          'downloads'.i18n,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
