import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/tracking/anilist_provider.dart';
import 'package:miru_alpha/ui/core/amination/animated_box.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/features/extension/widget/text_cover.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_section_header.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// Gap between the strip's cards.
const _gap = 8.0;

/// "Quick Access" — the entries the user most likely wants on first open,
/// ordered by recency: the recently accessed extensions (label = the
/// extension's own name, tap dives straight into it), then favorites and the
/// tracker state. The Favorite Tags section below owns tag management, so
/// there is no Tags card.
class HomeQuickAccessGrid extends ConsumerWidget {
  const HomeQuickAccessGrid({super.key});

  /// Recent sources shown as their own cards before the stable entries.
  static const _maxRecent = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(extensionPageProvider.select((s) => s.metaData));
    // Most-recent-first package names, resolved against the installed
    // catalogue — a since-uninstalled source drops out.
    final recents = [
      for (final pkg in MiruSettings.getRecentExtensions())
        meta.where((m) => m.packageName == pkg).firstOrNull,
    ].nonNulls.take(_maxRecent).toList();

    final cards = <Widget>[
      for (final source in recents) _RecentSourceCard(meta: source),
      // No recent source yet: the generic browse-sources entry.
      if (recents.isEmpty) const _ExtensionCard(),
      const _FavoritesCard(),
      const _TrackersCard(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HomeSectionHeader(
            title: 'home.quick_access'.i18n,
            // Mockup: a plain muted "Shortcuts" label, not an action.
            trailing: Text(
              'home.shortcuts'.i18n,
              style: context.theme.typography.body.xs3.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (final (i, card) in cards.indexed) ...[
                Expanded(child: card),
                if (i != cards.length - 1) const SizedBox(width: _gap),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Visuals only — the tap lives on [AnimatedBox] in each card subclass, so
/// there is exactly one gesture handler per card.
class _CommandCard extends StatelessWidget {
  const _CommandCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  /// Content of the 32px chip: a glyph for the stable cards, the source's
  /// own icon for recent-extension cards.
  final Widget icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return MiruCard(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              key: const Key('homeGridIconChip'),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.background,
                border: Border.all(color: colors.border),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(child: icon),
            ),
            const SizedBox(height: 6),
            // Mockup: 11px semibold label, centered.
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.body.xs2.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            // Mockup: 10px muted value line ("18 Titles", "5 Active").
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.body.xs3.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A recently accessed extension: the source's own icon in the chip, its
/// name as the label, tap enters its catalogue directly.
class _RecentSourceCard extends StatelessWidget {
  const _RecentSourceCard({required this.meta});

  final ExtensionMeta meta;

  @override
  Widget build(BuildContext context) {
    return AnimatedBox.nopadding(
      onTap: () =>
          context.push('/search/single', extra: SearchPageParam(meta: meta)),
      child: _CommandCard(
        icon: _sourceIcon(meta),
        label: meta.name,
        value: searchVersionLabel(meta.version),
      ),
    );
  }
}

/// The source's icon, or the stable text-cover when it has none / fails.
Widget _sourceIcon(ExtensionMeta meta) {
  if (meta.icon != null && meta.icon!.isNotEmpty) {
    return ExtendedImage.network(
      MiruRequest.proxyUrl(meta.icon!).toString(),
      width: 16,
      height: 16,
      fit: BoxFit.contain,
      loadStateChanged: (state) =>
          state.extendedImageLoadState == LoadState.failed
          ? TextCover(seed: meta.name, size: 16)
          : null,
    );
  }
  return TextCover(seed: meta.name, size: 16);
}

class _FavoritesCard extends ConsumerWidget {
  const _FavoritesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(
      favoritePageProvider.select((s) => s.favorites),
    );
    final titles = favorites.length == 1
        ? 'home.title_one'.i18n
        : 'home.titles_value'.i18n.fill({'count': '${favorites.length}'});

    return AnimatedBox.nopadding(
      onTap: () => context.push('/home/favorite'),
      child: _CommandCard(
        icon: Icon(
          FLucideIcons.heart,
          size: 16,
          color: context.theme.colors.primary,
        ),
        label: 'home.local_favorites'.i18n,
        value: titles,
      ),
    );
  }
}

/// No recent source yet: the generic browse-sources entry.
class _ExtensionCard extends ConsumerWidget {
  const _ExtensionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(extensionPageProvider.select((s) => s.metaData));

    return AnimatedBox.nopadding(
      onTap: () => context.push('/extension'),
      child: _CommandCard(
        icon: Icon(
          FLucideIcons.puzzle,
          size: 16,
          color: context.theme.colors.primary,
        ),
        label: 'extension.name'.i18n,
        value: 'home.sources_value'.i18n.fill({'count': '${meta.length}'}),
      ),
    );
  }
}

class _TrackersCard extends ConsumerWidget {
  const _TrackersCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(anilistAccountProvider);
    final value = account.maybeWhen(
      data: (user) => user == null
          ? 'home.not_linked'.i18n
          : 'home.watch_read'.i18n.fill({
              'watch': '${user.statistics.anime.episodesWatched}',
              'read': '${user.statistics.manga.chaptersRead}',
            }),
      orElse: () => 'home.not_linked'.i18n,
    );

    return AnimatedBox.nopadding(
      onTap: () => context.push('/tracking'),
      child: _CommandCard(
        icon: Icon(
          FLucideIcons.refreshCw,
          size: 16,
          color: context.theme.colors.primary,
        ),
        label: 'home.trackers'.i18n,
        value: value,
      ),
    );
  }
}
