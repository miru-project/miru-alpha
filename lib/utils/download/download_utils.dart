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

  /// Maps a content category to its top-level folder name under the download
  /// root, matching the user-facing labels (Bangumi / Manga / Fikushon).
  static const Map<proto.DownloadCategory, String> _categoryFolderName = {
    proto.DownloadCategory.video: 'Bangumi',
    proto.DownloadCategory.manga: 'Manga',
    proto.DownloadCategory.novel: 'Fikushon',
    proto.DownloadCategory.unspecified: 'Other',
  };

  /// Returns the sanitized top-level folder name for [category].
  static String categoryFolder(proto.DownloadCategory category) =>
      _categoryFolderName[category] ?? 'Other';

  /// Builds the on-disk path for a completed download following the layout:
  /// `$root/<Category>/<package>/<title>/<epGroup>/<epName><ext>`.
  ///
  /// [epGroup] is optional; when empty it is omitted so the episode file sits
  /// directly under the title folder. Every produced segment is sanitized via
  /// [filter] so it is a safe, filesystem-friendly name.
  static String buildTargetPath({
    required String root,
    required proto.DownloadCategory category,
    required String package,
    required String title,
    String? epGroup,
    required String epKey,
    required String extension,
  }) {
    final parts = <String>[
      root,
      categoryFolder(category),
      filter(package),
      filter(title),
    ];
    if (epGroup != null && epGroup.trim().isNotEmpty) {
      parts.add(filter(epGroup));
    }
    final epName = filter(epKey).isNotEmpty ? filter(epKey) : 'episode';
    parts.add('$epName$extension');
    return p.joinAll(parts);
  }

  /// Deletes [path], which may be a regular file or a directory (recursively).
  /// Safe to call on a missing path. Used for best-effort cleanup of temporary
  /// download artifacts so a directory (e.g. the HLS segment folder) is not
  /// silently skipped the way [File.deleteSync] would on a directory.
  static void safeDeletePath(String path) {
    if (path.isEmpty) return;
    try {
      final type = FileSystemEntity.typeSync(path);
      if (type == FileSystemEntityType.directory) {
        final dir = Directory(path);
        if (dir.existsSync()) dir.deleteSync(recursive: true);
      } else if (type == FileSystemEntityType.file) {
        final file = File(path);
        if (file.existsSync()) {
          final parent = file.parent;
          file.deleteSync();
          // Remove the parent only if it is now empty.
          if (parent.existsSync() && parent.listSync().isEmpty) {
            parent.deleteSync();
          }
        }
      }
    } catch (e) {
      logger.warning('Failed to clean up temp path $path: $e');
    }
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
    required proto.DownloadCategory category,
    required String package,
    required String epKey,
    String? epGroup,
  }) async {
    if (targetDir.isEmpty) {
      throw Exception("Target directory is not set");
    }

    String extension = isHls ? ".mp4" : p.extension(currentPath);
    if (extension.isEmpty && !isHls) extension = ".mp4";

    final targetPath = buildTargetPath(
      root: targetDir,
      category: category,
      package: package,
      title: title,
      epGroup: epGroup,
      epKey: epKey,
      extension: extension,
    );

    // Ensure the (possibly nested) parent directory exists.
    final parent = Directory(p.dirname(targetPath));
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }

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
    required proto.DownloadCategory category,
    required String package,
    required String epKey,
    String? epGroup,
  }) async {
    try {
      final targetPath = await handleFile(
        taskId: taskId,
        currentPath: currentPath,
        targetDir: targetDir,
        isHls: isHls,
        title: title,
        category: category,
        package: package,
        epKey: epKey,
        epGroup: epGroup,
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
