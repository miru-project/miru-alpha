import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/core/empty_state.dart';
import 'package:miru_alpha/ui/core/loading_state.dart';
import 'package:miru_alpha/ui/core/error_state.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

class DownloadView extends HookConsumerWidget {
  const DownloadView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadAsync = ref.watch(downloadProvider);

    return MiruScaffold.mobile(
      snapSheet: [SnapSheetNested.back(title: 'download.name'.i18n)],
      childPad: false,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: .symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    'download.name'.i18n,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  FButton(
                    prefix: Icon(FLucideIcons.history),
                    variant: .secondary,
                    onPress: () => context.push('/home/download/history'),
                    child: Text('download.downloads_history'.i18n),
                  ),
                ],
              ),
            ),
          ),
          downloadAsync.when(
            loading: () =>
                const SliverFillRemaining(child: Center(child: LoadingState())),
            error: (error, _) => SliverFillRemaining(
              child: Center(
                child: ErrorState(
                  message: 'download.error_loading_downloads'.i18n,
                ),
              ),
            ),
            data: (state) {
              final active = state.active;

              if (active.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: EmptyState(
                      icon: FLucideIcons.download,
                      message: 'download.no_active_downloads'.i18n,
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverReorderableList(
                  itemCount: active.length,
                  onReorderItem: (oldIndex, newIndex) {
                    final tasks = List<proto.DownloadProgress>.from(active);
                    tasks.insert(newIndex, tasks.removeAt(oldIndex));
                    ref
                        .read(downloadProvider.notifier)
                        .reorderActive(tasks.map((t) => t.taskId).toList());
                  },
                  onReorderStart: (_) {
                    ref.read(downloadProvider.notifier).setDragging(true);
                  },
                  onReorderEnd: (_) {
                    ref.read(downloadProvider.notifier).setDragging(false);
                  },
                  itemBuilder: (context, index) => _ActiveDownloadTile(
                    key: ValueKey(active[index].taskId),
                    task: active[index],
                    index: index,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActiveDownloadTile extends ConsumerWidget {
  const _ActiveDownloadTile({
    super.key,
    required this.task,
    required this.index,
  });

  final proto.DownloadProgress task;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = task.status;
    final isPaused = status == proto.DownloadStatus.PAUSED;
    final isFailed = status == proto.DownloadStatus.FAILED;
    final isQueued = status == proto.DownloadStatus.QUEUED;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MiruCard(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ReorderableDragStartListener(
                  index: index,
                  child: Row(
                    crossAxisAlignment: .center,
                    children: [
                      Icon(
                        FLucideIcons.download,
                        size: 24,
                        color: isFailed
                            ? context.theme.colors.destructive
                            : context.theme.colors.mutedForeground,
                      ),
                      const SizedBox(width: 12),
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
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _statusLabel(status),
                              style: context.theme.typography.body.sm.copyWith(
                                color: isFailed
                                    ? context.theme.colors.destructive
                                    : context.theme.colors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FDeterminateProgress(
                              value:
                                  (task.total > 0
                                          ? task.progress / task.total
                                          : 0)
                                      .toDouble()
                                      .clamp(0.0, 1.0),
                            ),
                          ],
                        ),
                      ),
                      FButton.icon(
                        variant: FButtonVariant.ghost,
                        size: .sm,
                        onPress: () {
                          ref
                              .read(downloadProvider.notifier)
                              .sendAction(
                                context,
                                task.taskId.toString(),
                                isFailed || isPaused || isQueued
                                    ? proto.DownloadAction.RESUME
                                    : proto.DownloadAction.PAUSE,
                              );
                        },
                        child: Icon(
                          isFailed || isPaused || isQueued
                              ? FLucideIcons.play
                              : FLucideIcons.pause,
                        ),
                      ),
                      FButton.icon(
                        variant: FButtonVariant.ghost,
                        size: .sm,
                        onPress: () {
                          ref
                              .read(downloadProvider.notifier)
                              .sendAction(
                                context,
                                task.taskId.toString(),
                                proto.DownloadAction.CANCEL,
                              );
                        },
                        child: const Icon(FLucideIcons.x),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(proto.DownloadStatus status) {
    return switch (status) {
      proto.DownloadStatus.DOWNLOADING => 'download.status.downloading'.i18n,
      proto.DownloadStatus.PAUSED => 'download.status.paused'.i18n,
      proto.DownloadStatus.CONVERTING => 'download.status.converting'.i18n,
      proto.DownloadStatus.FAILED => 'download.status.failed'.i18n,
      proto.DownloadStatus.QUEUED => 'download.status.queued'.i18n,
      _ => 'download.status.unknown'.i18n,
    };
  }
}
