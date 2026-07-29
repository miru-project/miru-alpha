import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:miru_alpha/utils/download/ffmpeg_util.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;

class DownloadUtils {
  static String filter(String path) {
    return path.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '').trim();
  }

  static Future<void> processHLS({
    required String taskId,
    required List<String> segments,
    required String targetPath,
    required String title,
  }) async {
    logger.info("Converting HLS segments to MP4: $targetPath");

    FFMpegUtils.combineToMp4(segments, targetPath);

    // The status update MUST succeed before we delete the source segments.
    // If this call fails and we proceed to delete, the DB stays "Converting"
    // while segments are gone — on restart the task would be stuck at
    // "Paused with zero progress" because Init() cannot recover it.
    await updateStatusOrThrow(
      taskId: taskId,
      status: proto.DownloadStatus.COMPLETED,
      savePath: targetPath,
    );

    // Only remove segments after the backend confirmed the Completed status.
    for (var segment in segments) {
      final file = File(segment);
      if (await file.exists()) {
        await file.delete();
      }
    }
    // Also remove the directory if it's empty
    if (segments.isNotEmpty) {
      final dir = File(segments.first).parent;
      if (await dir.exists() && (await dir.list().isEmpty)) {
        await dir.delete();
      }
    }
  }

  static Future<String> handleFile({
    required String taskId,
    required String currentPath,
    required String targetDir,
    required bool isHls,
    required String title,
  }) async {
    if (targetDir.isEmpty) {
      throw Exception("Target directory is not set");
    }

    final targetDirPath = Directory(targetDir);
    if (!await targetDirPath.exists()) {
      await targetDirPath.create(recursive: true);
    }

    String finalFileName = filter(title);
    if (finalFileName.isEmpty) finalFileName = "download_$taskId";

    String extension = isHls ? ".mp4" : p.extension(currentPath);
    if (extension.isEmpty && !isHls) extension = ".mp4";

    final targetPath = p.join(targetDir, "$finalFileName$extension");
    return targetPath;
  }

  static Future<void> updateStatus({
    required String taskId,
    required proto.DownloadStatus status,
    String? savePath,
  }) async {
    try {
      await MiruGrpcClient.downloadClient.updateDownloadStatus(
        proto.UpdateDownloadStatusRequest(
          taskId: int.parse(taskId),
          status: status,
          savePath: savePath,
        ),
      );
    } catch (e) {
      logger.severe("Failed to update status to $status: $e");
    }
  }

  /// Like [updateStatus] but propagates errors instead of swallowing them.
  /// Use this when the caller MUST know whether the update succeeded (e.g.
  /// before deleting source segments after FFmpeg conversion).
  static Future<void> updateStatusOrThrow({
    required String taskId,
    required proto.DownloadStatus status,
    String? savePath,
  }) async {
    await MiruGrpcClient.downloadClient.updateDownloadStatus(
      proto.UpdateDownloadStatusRequest(
        taskId: int.parse(taskId),
        status: status,
        savePath: savePath,
      ),
    );
  }

  static Future<String> processFinishedDownload({
    required String taskId,
    required List<String> segments,
    required String currentPath,
    required String targetDir,
    required bool isHls,
    required String title,
  }) async {
    try {
      final targetPath = await handleFile(
        taskId: taskId,
        currentPath: currentPath,
        targetDir: targetDir,
        isHls: isHls,
        title: title,
      );

      if (isHls) {
        await processHLS(
          taskId: taskId,
          segments: segments,
          targetPath: targetPath,
          title: title,
        );
      } else {
        logger.info("Moving file to host: $currentPath -> $targetPath");
        final sourceFile = File(currentPath);
        if (await sourceFile.exists()) {
          await sourceFile.copy(targetPath);
          await sourceFile.delete();

          // Try to remove parent dir if empty
          final dir = sourceFile.parent;
          if (await dir.exists() && (await dir.list().isEmpty)) {
            await dir.delete();
          }
        }
        await updateStatus(
          taskId: taskId,
          status: proto.DownloadStatus.COMPLETED,
          savePath: targetPath,
        );
      }

      return targetPath;
    } catch (e) {
      logger.severe("Failed to process download: $e");
      rethrow;
    }
  }

  static String statusToI18N(proto.DownloadStatus status) {
    switch (status) {
      case proto.DownloadStatus.QUEUED:
        return 'download.status.queued';
      case proto.DownloadStatus.DOWNLOADING:
        return 'download.status.downloading';
      case proto.DownloadStatus.PAUSED:
        return 'download.status.paused';
      case proto.DownloadStatus.COMPLETED:
        return 'download.status.completed';
      case proto.DownloadStatus.FAILED:
        return 'download.status.failed';
      case proto.DownloadStatus.CANCELLED:
        return 'download.status.cancelled';
      case proto.DownloadStatus.CONVERTING:
        return 'download.status.converting';
      default:
        return 'download.status.unknown';
    }
  }
}
