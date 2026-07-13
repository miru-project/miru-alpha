import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/core/empty_state.dart';
import 'package:miru_alpha/ui/core/loading_state.dart';
import 'package:miru_alpha/ui/core/error_state.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:collection/collection.dart';

class DownloadView extends HookConsumerWidget {
  const DownloadView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadAsync = ref.watch(downloadProvider);
    final scrollController = useScrollController();

    return MiruScaffold.mobile(
      snapSheet: [SnapSheetNested.back(title: 'download.name'.i18n)],
      childPad: true,
      body: downloadAsync.when(
        loading: () => const Center(child: LoadingState()),
        error: (error, _) => Center(
          child: ErrorState(message: 'download.error_loading_downloads'.i18n),
        ),
        data: (state) {
          final active = state.active;
          final history = state.history;

          if (active.isEmpty && history.isEmpty) {
            return Center(
              child: EmptyState(
                icon: FLucideIcons.download,
                message: 'download.no_download_history'.i18n,
              ),
            );
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification &&
                  scrollController.position.pixels >=
                      scrollController.position.maxScrollExtent - 200) {
                ref.read(downloadProvider.notifier).loadMoreHistory();
              }
              return false;
            },
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                if (active.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 4),
                    child: Text(
                      'download.no_active_downloads'.i18n,
                      style: context.theme.typography.body.lg,
                    ),
                  ),
                  ...active.map((task) => _ActiveDownloadTile(task: task)),
                  const SizedBox(height: 16),
                ],
                if (history.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 4),
                    child: Text(
                      'download.downloads_history'.i18n,
                      style: context.theme.typography.body.lg,
                    ),
                  ),
                  ...history.map(
                    (download) => _FinishedDownloadTile(download: download),
                  ),
                  if (state.hasMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActiveDownloadTile extends ConsumerWidget {
  const _ActiveDownloadTile({required this.task});

  final proto.DownloadProgress task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = task.status;
    final isPaused = status == proto.DownloadStatus.PAUSED;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(FLucideIcons.download),
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_statusLabel(status)),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: (task.total > 0 ? task.progress / task.total : 0)
                  .toDouble()
                  .clamp(0.0, 1.0),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(isPaused ? FLucideIcons.play : FLucideIcons.pause),
              onPressed: () {
                ref
                    .read(downloadProvider.notifier)
                    .sendAction(
                      context,
                      task.taskId.toString(),
                      isPaused
                          ? proto.DownloadAction.RESUME
                          : proto.DownloadAction.PAUSE,
                    );
              },
            ),
            IconButton(
              icon: const Icon(FLucideIcons.x),
              onPressed: () {
                ref
                    .read(downloadProvider.notifier)
                    .sendAction(
                      context,
                      task.taskId.toString(),
                      proto.DownloadAction.CANCEL,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(proto.DownloadStatus status) {
    return switch (status) {
      proto.DownloadStatus.DOWNLOADING => 'download.status.downloading'.i18n,
      proto.DownloadStatus.PAUSED => 'download.status.paused'.i18n,
      proto.DownloadStatus.CONVERTING => 'download.status.converting'.i18n,
      _ => 'download.status.unknown'.i18n,
    };
  }
}

class _FinishedDownloadTile extends ConsumerWidget {
  const _FinishedDownloadTile({required this.download});

  final proto.Download download;

  void _openDetail(BuildContext context, WidgetRef ref) {
    final meta = ref
        .read(extensionPageProvider)
        .metaData
        .where((e) => e.packageName == download.package)
        .firstOrNull;
    if (meta == null) return;
    context.push(
      '/detail',
      extra: DetailParam(meta: meta, url: download.detailUrl),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(FLucideIcons.fileCheck),
        title: Text(download.title),
        subtitle: Text(download.savePath),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(FLucideIcons.folderOpen),
              onPressed: () async {
                final path = download.savePath;
                if (path.isEmpty) return;
                try {
                  if (Platform.isWindows) {
                    await Process.run('explorer.exe', [path]);
                  } else if (Platform.isMacOS) {
                    await Process.run('open', [path]);
                  } else if (Platform.isLinux) {
                    await Process.run('xdg-open', [path]);
                  }
                } catch (e) {
                  // ignore
                }
              },
            ),
            IconButton(
              icon: const Icon(FLucideIcons.info),
              onPressed: () => _openDetail(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
