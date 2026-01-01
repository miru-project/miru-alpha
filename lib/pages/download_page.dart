import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miru_app_new/miru_core/grpc_client.dart';
import 'package:miru_app_new/miru_core/proto/proto.dart' as proto;
import 'package:miru_app_new/utils/store/miru_settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:miru_app_new/widgets/index.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/widgets/scaffold/miru_scaffold.dart';
import 'package:miru_app_new/provider/application_controller_provider.dart';

import 'package:miru_app_new/provider/download_provider.dart';

class DownloadPage extends ConsumerWidget {
  const DownloadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDownloads = ref.watch(downloadsProvider);
    final allDownloads = ref.watch(allDownloadsProvider);
    final downloadPath = ref.watch(
      applicationControllerProvider.select(
        (v) => MiruSettings.getSettingSync<String>(SettingKey.downloadPath),
      ),
    );

    return MiruScaffold(
      mobileHeader: _buildHeader(context, ref, downloadPath),
      body: _buildBody(context, ref, activeDownloads, allDownloads),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    String downloadPath,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Downloads", style: context.theme.typography.xl2),
            FTooltip(
              tipBuilder: (context, controller) =>
                  const Text("Select Download Directory"),
              child: FButton.icon(
                onPress: () async {
                  String? result = await FilePicker.platform.getDirectoryPath();
                  if (result != null) {
                    MiruSettings.setSettingSync(
                      SettingKey.downloadPath,
                      result,
                    );
                  }
                },
                child: const Icon(Icons.folder_open),
              ),
            ),
          ],
        ),
        if (downloadPath.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Path: $downloadPath",
              style: context.theme.typography.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<proto.DownloadProgress>> active,
    AsyncValue<List<proto.Download>> all,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActiveSection(context, ref, active),
          const SizedBox(height: 24),
          _buildHistorySection(context, ref, all),
        ],
      ),
    );
  }

  Widget _buildActiveSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<proto.DownloadProgress>> active,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Active Tasks",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        const SizedBox(height: 12),
        active.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text("Error: $e"),
          data: (tasks) {
            final activeTasks = tasks
                .where((t) => t.status != 'Completed' && t.status != 'Failed')
                .toList();
            if (activeTasks.isEmpty) return const Text("No active tasks");
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeTasks.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _DownloadProgressCard(task: activeTasks[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<proto.Download>> all,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Downloads History",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        const SizedBox(height: 12),
        all.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text("Error: $e"),
          data: (downloads) {
            if (downloads.isEmpty) return const Text("No download history");
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: downloads.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _DownloadHistoryCard(download: downloads[index]),
            );
          },
        ),
      ],
    );
  }
}

class _DownloadProgressCard extends ConsumerWidget {
  final proto.DownloadProgress task;
  const _DownloadProgressCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double progress = task.total > 0 ? task.progress / task.total : 0.0;

    return FCard(
      title: Text(task.title.isNotEmpty ? task.title : "Unknown"),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Status: ${task.status}"),
          const SizedBox(height: 8),
          FDeterminateProgress(value: progress),
          const SizedBox(height: 4),
          Text(
            "${(progress * 100).toStringAsFixed(1)}% - ${task.progress}/${task.total}",
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FButton.icon(
            style: FButtonStyle.secondary(),
            onPress: () => ref
                .read(downloadsProvider.notifier)
                .sendAction(
                  context,
                  task.taskId.toString(),
                  task.status == 'Paused' ? 'resume' : 'pause',
                ),
            child: Icon(
              task.status == 'Paused' ? Icons.play_arrow : Icons.pause,
            ),
          ),
          const SizedBox(width: 8),
          FButton.icon(
            style: FButtonStyle.destructive(),
            onPress: () => ref
                .read(downloadsProvider.notifier)
                .sendAction(context, task.taskId.toString(), 'cancel'),
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}

class _DownloadHistoryCard extends ConsumerWidget {
  final proto.Download download;
  const _DownloadHistoryCard({required this.download});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FCard(
      title: Text(download.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Package: ${download.package}"),
          Text("Status: ${download.status}"),
          Text("Date: ${download.date}"),
          if (download.savePath.isNotEmpty)
            Text(
              "Saved to: ${download.savePath}",
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FButton.icon(
            style: FButtonStyle.destructive(),
            onPress: () async {
              await MiruGrpcClient.downloadClient.deleteDownload(
                proto.DeleteDownloadRequest()..id = download.id,
              );
              ref.invalidate(allDownloadsProvider);
            },
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
