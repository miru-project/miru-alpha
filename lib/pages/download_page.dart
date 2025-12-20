import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/widgets/button.dart';
import 'package:miru_app_new/miru_core/grpc_client.dart';
import 'package:miru_app_new/miru_core/proto/miru_core_service.pbgrpc.dart'
    as proto;
import 'package:miru_app_new/utils/download/download_utils.dart';
import 'package:miru_app_new/utils/download/ffmpeg_util.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/widgets/core/toast.dart';
// import 'package:miru_app_new/utils/network/request.dart';

final downloadsProvider =
    NotifierProvider<_DownloadsNotifier, AsyncValue<List<dynamic>>>(
      _DownloadsNotifier.new,
    );

class _DownloadsNotifier extends Notifier<AsyncValue<List<dynamic>>> {
  Timer? _timer;

  @override
  AsyncValue<List<dynamic>> build() {
    // start in loading state and kick off periodic fetch
    _fetchStatus();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _fetchStatus());

    // ensure timer is cancelled when the notifier is disposed
    ref.onDispose(() {
      _timer?.cancel();
    });

    return const AsyncLoading();
  }

  Future<void> _fetchStatus() async {
    try {
      final res = await MiruGrpcClient.client.getDownloadStatus(
        proto.GetDownloadStatusRequest(),
      );
      final downloads = res.downloadStatus.entries.map((e) {
        return {
          'id': e.key,
          'progress': e.value.progress,
          'names': e.value.names,
          'total': e.value.total,
          'status': e.value.status,
          'media_type': e.value.mediaType,
          'current_downloading': e.value.currentDownloading,
        };
      }).toList();
      state = AsyncData(downloads);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      logger.warning('Failed to fetch status: $e');
    }
  }

  Future<void> sendAction(
    BuildContext context,
    String id,
    String action,
  ) async {
    final taskId = int.tryParse(id);
    if (taskId == null) return;

    try {
      switch (action) {
        case 'pause':
          await MiruGrpcClient.client.pauseDownload(
            proto.PauseDownloadRequest()..taskId = taskId,
          );
          break;
        case 'continue':
        case 'resume':
          await MiruGrpcClient.client.resumeDownload(
            proto.ResumeDownloadRequest()..taskId = taskId,
          );
          break;
        case 'cancel':
          await MiruGrpcClient.client.cancelDownload(
            proto.CancelDownloadRequest()..taskId = taskId,
          );
          break;
        default:
          return;
      }
      await _fetchStatus();
    } catch (e) {
      if (!context.mounted) return;
      showSimpleToast('Failed to $action download: $e');
    }
  }

  // dispose logic moved to ref.onDispose in build()
}

class DownloadPage extends ConsumerWidget {
  DownloadPage({super.key});

  final finishedList = <String>[];
  void onComplete(
    List<String> list,
    bool isHls,
    String outputName,
    String taskId,
  ) {
    if (isHls && !finishedList.contains(taskId)) {
      FFMpegUtils.combineTsToMp4(list, outputName);
      finishedList.add(taskId);
    }
    return;
  }

  Widget _buildDownloadItem(
    BuildContext context,
    WidgetRef ref,
    dynamic item,
    bool loading,
  ) {
    final status = item['status'] ?? 'Unknown';
    final progressRaw = item['progress'];
    final totalRaw = item['total'];
    final List<String> names = (item['names'] as List?)?.cast<String>() ?? [];
    double progress = 0.0;

    if (progressRaw is num && totalRaw is num && totalRaw > 0) {
      progress = (progressRaw / totalRaw).clamp(0.0, 1.0);
    }

    final id = item['id']!.toString();
    String buttonLabel;
    String action;
    final name = MiruCoreDownload.tasks[id]?.name ?? 'Download';
    switch (status) {
      case 'Downloading':
        buttonLabel = 'Pause';
        action = 'pause';
        break;
      case 'Paused':
        buttonLabel = 'Continue';
        action = 'continue';
        break;
      case 'Completed':
        buttonLabel = 'Delete';
        action = 'delete';
        onComplete(
          names,
          (item['media_type'] ?? "") == "hls",
          "/storage/emulated/0/Movies/${MiruCoreDownload.tasks[id]?.name ?? 'Download'}.mp4",
          id,
        );
        break;
      case 'Failed':
      case 'Canceled':
        buttonLabel = 'Retry';
        action = 'continue';
        break;
      default:
        buttonLabel = 'Cancel';
        action = 'cancel';
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $status'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 4),
            Text('Progress: ${(progress * 100).toStringAsFixed(0)}%'),
          ],
        ),
        trailing: FButton(
          child: Text(buttonLabel),
          onPress: () => ref
              .read(downloadsProvider.notifier)
              .sendAction(context, id, action),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(downloadsProvider);
    final loading = downloadsAsync is AsyncLoading;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: downloadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (downloads) {
          final filtered = downloads.where((d) => d['status'] != null).toList();
          return filtered.isEmpty
              ? const Center(child: Text('No Download Task '))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildDownloadItem(
                    context,
                    ref,
                    filtered[index],
                    loading,
                  ),
                );
        },
      ),
    );
  }
}
