import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miru_app_new/miru_core/event_service.dart';
import 'package:miru_app_new/miru_core/grpc_client.dart';
import 'package:miru_app_new/miru_core/proto/miru_core_service.pbgrpc.dart'
    as proto;
import 'package:miru_app_new/utils/download/download_utils.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/widgets/core/toast.dart';
import 'package:miru_app_new/utils/store/miru_settings.dart';

final downloadsProvider =
    NotifierProvider<
      DownloadsNotifier,
      AsyncValue<List<proto.DownloadProgress>>
    >(DownloadsNotifier.new);

final allDownloadsProvider = FutureProvider<List<proto.Download>>((ref) async {
  final res = await MiruGrpcClient.client.getAllDownloads(
    proto.GetAllDownloadsRequest(),
  );
  return res.downloads;
});

class DownloadsNotifier
    extends Notifier<AsyncValue<List<proto.DownloadProgress>>> {
  StreamSubscription? _subscription;

  @override
  AsyncValue<List<proto.DownloadProgress>> build() {
    _fetchStatus();
    _subscription = miruEventService.downloadStream.listen((status) {
      state = AsyncData(status.values.toList());
      for (final download in status.values) {
        if (download.status == 'Completed') {
          _handleCompletion(download);
        }
      }
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return const AsyncLoading();
  }

  Future<void> _fetchStatus() async {
    try {
      final res = await MiruGrpcClient.client.getDownloadStatus(
        proto.GetDownloadStatusRequest(),
      );
      state = AsyncData(res.downloadStatus.values.toList());

      // Check for completed tasks that haven't been processed
      for (final download in res.downloadStatus.values) {
        if (download.status == 'Completed') {
          _handleCompletion(download);
        }
      }
    } catch (e) {
      if (state is! AsyncError) {
        state = AsyncError(e, StackTrace.current);
      }
    }
  }

  final Set<String> _processedTasks = {};

  Future<void> _handleCompletion(proto.DownloadProgress download) async {
    final key = download.key;
    if (_processedTasks.contains(key)) return;
    _processedTasks.add(key);

    try {
      final downloadPath = MiruSettings.getSettingSync<String>(
        SettingKey.downloadPath,
      );
      if (downloadPath.isEmpty) {
        logger.warning(
          "Download path not set, skipping move for ${download.title}",
        );
        return;
      }

      await DownloadUtils.processFinishedDownload(
        taskId: download.taskId.toString(),
        segments: download.names,
        currentPath: download.currentDownloading,
        targetDir: downloadPath,
        isHls: download.mediaType == 'hls',
        title: download.title,
      );

      showSimpleToast("Finished downloading ${download.title}");

      // Refresh all downloads
      ref.invalidate(allDownloadsProvider);
    } catch (e) {
      logger.severe("Failed to process finished download: $e");
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
}
