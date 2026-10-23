import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/ui/features/download/widget/download_tiles.dart';
import 'package:miru_alpha/ui/features/history_favorite/shared/list_helpers.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_section_header.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/utils/core/date_format.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// "Source Feed" — newest finished downloads, one divided tile per item, so
/// the downloads page keeps a home entry point.
class HomeSourceFeed extends ConsumerWidget {
  const HomeSourceFeed({super.key});

  static const _maxRows = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(
      downloadProvider.select((s) => s.value?.history ?? const []),
    );
    final items = history.take(_maxRows).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HomeSectionHeader(
            title: 'home.source_feed'.i18n,
            trailing: items.isEmpty
                ? null
                : SearchPill(
                    label: 'home.view_all'.i18n,
                    selected: false,
                    icon: FLucideIcons.chevronRight,
                    onTap: () => context.push('/home/download'),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: items.isEmpty
              ? HomeEmpty(text: 'download.no_download_history'.i18n)
              : FTileGroup(
                  children: [
                    for (final download in items)
                      _feedTile(context, ref, download),
                  ],
                ),
        ),
      ],
    );
  }

  static FTile _feedTile(
    BuildContext context,
    WidgetRef ref,
    proto.Download download,
  ) {
    final meta = findMeta(ref, download.package);
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return FTile(
      prefix: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.background,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          switch (meta?.type) {
            ExtensionType.manga => FLucideIcons.bookOpen,
            ExtensionType.fikushon => FLucideIcons.bookMarked,
            _ => FLucideIcons.play,
          },
          size: 18,
          color: colors.primary,
        ),
      ),
      title: Text(meta?.name ?? download.package),
      // Mockup: "Solo Leveling · Ep 12 (SUB)" — the source's language moves
      // inline instead of a separate chip.
      subtitle: Text(
        meta == null
            ? download.title
            : '${download.title} (${meta.lang.toUpperCase()})',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      suffix: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            tryFormatTimeAgo(download.date) ?? formatShortDate(download.date),
            style: typography.body.xs3.copyWith(color: colors.mutedForeground),
          ),
          Icon(
            FLucideIcons.playCircle,
            size: 16,
            color: colors.mutedForeground,
          ),
        ],
      ),
      onPress: () => openDownloadDetail(context, ref, download),
    );
  }
}
