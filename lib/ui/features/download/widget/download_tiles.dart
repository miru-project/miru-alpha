import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/download/download_utils.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:collection/collection.dart';

/// Cross-platform helper that opens [path] in the OS file browser.
///
/// On desktop this reveals the file (or its containing folder) in the native
/// file manager. Failures are intentionally swallowed so a missing handler
/// never crashes the UI.
Future<void> openDownloadFile(String path) async {
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
    // Ignoring: opening the file manager is best-effort.
  }
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
              FButton.icon(
                variant: .ghost,
                onPress: () => openDownloadFile(download.savePath),
                child: const Icon(FLucideIcons.folderOpen),
              ),
              FButton.icon(
                variant: .ghost,
                onPress: () => openDownloadDetail(context, ref, download),
                child: const Icon(FLucideIcons.info),
              ),
              FButton.icon(
                variant: .ghost,
                onPress: () async {
                  await MiruGrpcClient.downloadClient.deleteDownload(
                    proto.DeleteDownloadRequest()..id = download.id,
                  );
                  ref.invalidate(downloadProvider);
                },
                child: const Icon(Icons.delete),
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
    final (label, color) = switch (status) {
      proto.DownloadStatus.DOWNLOADING => (
        'download.status.downloading'.i18n,
        context.theme.colors.primary,
      ),
      proto.DownloadStatus.PAUSED => (
        'download.status.paused'.i18n,
        context.theme.colors.mutedForeground,
      ),
      proto.DownloadStatus.CONVERTING => (
        'download.status.converting'.i18n,
        const Color(0xFFD97706),
      ),
      proto.DownloadStatus.COMPLETED => (
        'download.status.completed'.i18n,
        const Color(0xFF16A34A),
      ),
      proto.DownloadStatus.FAILED => (
        'download.status.failed'.i18n,
        context.theme.colors.destructive,
      ),
      proto.DownloadStatus.CANCELLED => (
        'download.status.cancelled'.i18n,
        context.theme.colors.mutedForeground,
      ),
      proto.DownloadStatus.QUEUED => (
        'download.status.queued'.i18n,
        context.theme.colors.mutedForeground,
      ),
      _ => (
        'download.status.unknown'.i18n,
        context.theme.colors.mutedForeground,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: context.theme.typography.body.xs.copyWith(color: color),
      ),
    );
  }
}
