import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/core/log.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:miru_alpha/utils/download/download_utils.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:collection/collection.dart';
import 'package:miru_alpha/ui/core/dialog/dialog.dart';

/// Whether this platform can reveal a downloaded file in a system file manager.
///
/// Android and iOS expose no launchable file manager through `dart:io`, so the
/// UI hides the action instead of showing a button that silently did nothing.
bool get canRevealDownloadedFile =>
    Platform.isWindows || Platform.isMacOS || Platform.isLinux;

/// The accent colour for [status], resolved against [theme].
///
/// Shared by the status badge and the library bento card's download summary so
/// a given status never renders as two different colours in two places. Lives
/// here (a UI file) rather than in `DownloadUtils`, which is a pure data-layer
/// helper with no Flutter imports.
Color downloadStatusColor(proto.DownloadStatus status, FThemeData theme) {
  return switch (status) {
    proto.DownloadStatus.DOWNLOADING => theme.colors.primary,
    proto.DownloadStatus.CONVERTING => const Color(0xFFD97706),
    proto.DownloadStatus.COMPLETED => const Color(0xFF16A34A),
    proto.DownloadStatus.FAILED => theme.colors.destructive,
    _ => theme.colors.mutedForeground,
  };
}

/// Cross-platform helper that opens [path] in the OS file browser.
///
/// Returns `false` when the platform has no handler or the launch failed, so
/// callers can tell the user rather than appearing to succeed.
Future<bool> openDownloadFile(String path) async {
  if (path.isEmpty) return false;

  final executable = Platform.isWindows
      ? 'explorer.exe'
      : Platform.isMacOS
      ? 'open'
      : Platform.isLinux
      ? 'xdg-open'
      : null;
  if (executable == null) return false;

  try {
    final result = await Process.run(executable, [path]);
    // explorer.exe reports a non-zero exit code even when it opens the folder
    // successfully, so only trust it on the other platforms.
    if (Platform.isWindows) return true;
    return result.exitCode == 0;
  } on ProcessException catch (e) {
    logger.warning('No file manager handler for $path: ${e.message}');
    return false;
  } catch (e) {
    logger.warning('Failed to reveal $path in the file manager: $e');
    return false;
  }
}

/// Reveals [download] in the file manager, explaining why it could not.
Future<void> revealDownload(
  BuildContext context,
  proto.Download download,
) async {
  final opened = await openDownloadFile(download.savePath);
  if (opened) return;
  showSimpleToast(
    download.savePath.isEmpty
        ? 'download.file_missing'.i18n
        : 'download.open_folder_failed'.i18n,
  );
}

/// Opens the detail page for a downloaded item when its source extension is
/// still installed.
void openDownloadDetail(
  BuildContext context,
  WidgetRef ref,
  proto.Download download,
) {
  final meta = ref
      .read(extensionPageProvider)
      .metaData
      .where((e) => e.packageName == download.package)
      .firstOrNull;
  if (meta == null) return;
  context.push(
    '/search/single/detail',
    extra: DetailParam(meta: meta, url: download.detailUrl),
  );
}

/// Outcome of the delete prompt shown for a finished download.
enum DownloadDeleteChoice { cancel, deleteFile, removeRecord }

/// Asks the user what to do with [download], then carries out the choice.
///
/// The backend `DeleteDownload` RPC only removes its own database row, so
/// "delete file" has to happen here on the filesystem. Because the two options
/// have very different consequences (one destroys media, the other only hides
/// the entry), the user is always asked instead of a silent default being
/// picked.
Future<void> confirmDeleteDownload(
  BuildContext context,
  WidgetRef ref,
  proto.Download download,
) async {
  final fileExists = DownloadUtils.existsOnDisk(download.savePath);

  final choice = await showMiruDialog<DownloadDeleteChoice>(
    context: context,
    title: Text('download.delete_title'.i18n),
    body: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('download.delete_message'.i18n.fill({'title': download.title})),
        if (download.savePath.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              download.savePath,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.theme.typography.body.xs.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ),
        if (!fileExists)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(
                  FLucideIcons.circleAlert,
                  size: 14,
                  color: context.theme.colors.mutedForeground,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'download.file_missing'.i18n,
                    style: context.theme.typography.body.xs.copyWith(
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        FTileGroup(
          children: [
            if (fileExists)
              FTile(
                prefix: Icon(
                  FLucideIcons.trash2,
                  color: context.theme.colors.destructive,
                ),
                title: Text('download.delete_file_option'.i18n),
                onPress: () =>
                    Navigator.pop(context, DownloadDeleteChoice.deleteFile),
              ),
            FTile(
              prefix: const Icon(FLucideIcons.bookmarkMinus),
              title: Text('download.remove_record_option'.i18n),
              onPress: () =>
                  Navigator.pop(context, DownloadDeleteChoice.removeRecord),
            ),
            // An explicit escape hatch: relying on a barrier tap is easy to
            // miss, and one of these two options destroys media files.
            FTile(
              prefix: const Icon(FLucideIcons.x),
              title: Text('common.cancel'.i18n),
              onPress: () =>
                  Navigator.pop(context, DownloadDeleteChoice.cancel),
            ),
          ],
        ),
      ],
    ),
  );

  if (choice == null || choice == DownloadDeleteChoice.cancel) return;
  if (!context.mounted) return;

  await ref
      .read(downloadProvider.notifier)
      .removeHistoryEntry(
        download,
        deleteFile: choice == DownloadDeleteChoice.deleteFile,
      );
}

class DownloadProcessTile extends ConsumerWidget {
  const DownloadProcessTile({super.key, required this.progress});

  final proto.DownloadProgress progress;

  double get _ratio =>
      (progress.total > 0 ? progress.progress / progress.total : 0)
          .toDouble()
          .clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = progress.status;
    final isPaused = status == proto.DownloadStatus.PAUSED;
    final isFailed = status == proto.DownloadStatus.FAILED;

    return MiruCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle for reordering
              Padding(
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: Icon(
                  FLucideIcons.gripVertical,
                  size: 20,
                  color: context.theme.colors.mutedForeground,
                ),
              ),
              MiruCard(
                child: const SizedBox.square(
                  dimension: 40,
                  child: Icon(FLucideIcons.filePlay, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DownloadUtils.statusToI18N(status).i18n,
                      style: context.theme.typography.body.sm.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                    // Surface why a task failed — the backend carries the
                    // reason on the live progress object.
                    if (isFailed && progress.error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'download.error_reason'.i18n.fill({
                            'reason': progress.error,
                          }),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.theme.typography.body.xs.copyWith(
                            color: context.theme.colors.destructive,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${(_ratio * 100).toStringAsFixed(0)}%',
                  style: context.theme.typography.body.sm,
                ),
              ),
              FButton.icon(
                variant: .ghost,
                onPress: () => ref
                    .read(downloadProvider.notifier)
                    .sendAction(
                      context,
                      progress.taskId.toString(),
                      isPaused
                          ? proto.DownloadAction.RESUME
                          : proto.DownloadAction.PAUSE,
                    ),
                child: Icon(isPaused ? FLucideIcons.play : FLucideIcons.pause),
              ),
              FButton.icon(
                variant: .ghost,
                onPress: () => ref
                    .read(downloadProvider.notifier)
                    .sendAction(
                      context,
                      progress.taskId.toString(),
                      proto.DownloadAction.CANCEL,
                    ),
                child: const Icon(FLucideIcons.x),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FDeterminateProgress(value: _ratio),
        ],
      ),
    );
  }
}

class DownloadHistoryTile extends ConsumerWidget {
  const DownloadHistoryTile({super.key, required this.download});

  final proto.Download download;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = download.status;
    return MiruCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MiruCard(
                child: const SizedBox.square(
                  dimension: 40,
                  child: Icon(FLucideIcons.filePlay, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      download.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (download.savePath.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          download.savePath,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.theme.typography.body.sm.copyWith(
                            color: context.theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (canRevealDownloadedFile)
                FButton.icon(
                  variant: .ghost,
                  onPress: () => revealDownload(context, download),
                  child: const Icon(FLucideIcons.folderOpen),
                ),
              FButton.icon(
                variant: .ghost,
                onPress: () => openDownloadDetail(context, ref, download),
                child: const Icon(FLucideIcons.info),
              ),
              FButton.icon(
                variant: .ghost,
                onPress: () => confirmDeleteDownload(context, ref, download),
                child: const Icon(FLucideIcons.trash2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final proto.DownloadStatus status;

  @override
  Widget build(BuildContext context) {
    final label = DownloadUtils.statusToI18N(status).i18n;
    final color = downloadStatusColor(status, context.theme);

    // The badge is inflexible inside its Row, so an unbounded label (a long
    // translation, or an untranslated fallback key) would overflow the card on
    // narrow phones. Cap it and let the text ellipsize instead.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.theme.typography.body.xs.copyWith(color: color),
        ),
      ),
    );
  }
}
