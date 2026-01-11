import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:miru_app_new/utils/download/ffmpeg_util.dart';
import 'package:miru_app_new/utils/core/log.dart';
import 'package:miru_app_new/miru_core/grpc_client.dart';
import 'package:miru_app_new/miru_core/proto/proto.dart';

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
    // updateStatus(taskId: taskId, status: "Completed");

    FFMpegUtils.combineToMp4(segments, targetPath);

    updateStatus(taskId: taskId, status: "Converted");

    // Remove segments after conversion
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

  static Future<String> hadleFile({
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
    required String status,
  }) async {
    try {
      await MiruGrpcClient.downloadClient.updateDownloadStatus(
        UpdateDownloadStatusRequest(taskId: int.parse(taskId), status: status),
      );
    } catch (e) {
      logger.severe("Failed to update status to $status: $e");
    }
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
      final targetPath = await hadleFile(
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
        updateStatus(taskId: taskId, status: "Converted");
      }

      return targetPath;
    } catch (e) {
      logger.severe("Failed to process download: $e");
      rethrow;
    }
  }
}
