import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/features/download/widget/download_tiles.dart';
import 'package:miru_alpha/ui/features/history_favorite/shared/list_helpers.dart';

/// A finished download as shown in the mobile history list.
///
/// Deliberately compact: there is no "open folder" action because `dart:io`
/// cannot launch a file manager on Android/iOS, so the button would silently
/// do nothing — the row instead navigates back to its source detail page when
/// the extension is still installed.
class MobileCompletedDownloadTile extends ConsumerWidget {
  const MobileCompletedDownloadTile({super.key, required this.download});

  final proto.Download download;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MiruCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 36,
              child: Icon(
                FLucideIcons.filePlay,
                size: 20,
                color: context.theme.colors.mutedForeground,
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
                    style: context.theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(download.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.body.sm.copyWith(
                      fontSize: 12,
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (findMeta(ref, download.package) != null)
              FButton.icon(
                variant: FButtonVariant.ghost,
                size: .sm,
                onPress: () => openDownloadDetail(context, ref, download),
                child: const Icon(FLucideIcons.info),
              ),
            FButton.icon(
              variant: FButtonVariant.ghost,
              size: .sm,
              onPress: () => confirmDeleteDownload(context, ref, download),
              child: Icon(
                FLucideIcons.trash2,
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Renders the backend's ISO timestamp as a short local date, falling back
  /// to the raw string when it cannot be parsed.
  static String _formatDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    final local = parsed.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
