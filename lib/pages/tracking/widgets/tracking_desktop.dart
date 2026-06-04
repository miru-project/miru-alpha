import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/provider/tracking/anilist_provider.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'anilist_media_card.dart';

class TrackingDesktop extends ConsumerWidget {
  final AnilistUser user;
  const TrackingDesktop({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _DesktopUserHeader(user: user),
        const FDivider(),
        Expanded(
          child: FTabs(
            expands: true,
            children: [
              FTabEntry(
                label: const Text('Anime'),
                child: const _DesktopCollectionView(type: AnilistType.anime),
              ),
              FTabEntry(
                label: const Text('Manga'),
                child: const _DesktopCollectionView(type: AnilistType.manga),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesktopUserHeader extends ConsumerWidget {
  final AnilistUser user;
  const _DesktopUserHeader({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Row(
        children: [
          FAvatar(
            image: NetworkImage(user.avatar.medium ?? ''),
            size: 120,
            fallback: Text(user.name[0].toUpperCase()),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: context.theme.typography.xl4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'User ID: ${user.id}',
                  style: context.theme.typography.md.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatChip(
                      icon: FLucideIcons.tv,
                      label:
                          '${user.statistics.anime.episodesWatched} Episodes',
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: FLucideIcons.bookOpen,
                      label: '${user.statistics.manga.chaptersRead} Chapters',
                    ),
                  ],
                ),
              ],
            ),
          ),
          FButton.icon(
            onPress: () => ref.read(anilistAccountProvider.notifier).logout(),
            child: const Icon(FLucideIcons.logOut),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return FBadge(
      style: .delta(
        // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.theme.colors.background),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _DesktopCollectionView extends ConsumerWidget {
  final AnilistType type;
  const _DesktopCollectionView({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collection = ref.watch(anilistCollectionProvider(type));

    return collection.when(
      data: (data) => data.isEmpty
          ? const Center(child: Text('Empty Collection'))
          : CustomScrollView(
              slivers: [
                for (final list in data) ..._buildStatusSection(context, list),
              ],
            ),
      loading: () => const Center(child: FCircularProgress.loader()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  List<Widget> _buildStatusSection(BuildContext context, AnilistList list) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 32, 40, 16),
          child: Text(
            list.status,
            style: context.theme.typography.xl2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 0.62,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final entry = list.entries[index];
            return AnilistMediaCard(entry: entry, type: type, isDesktop: true);
          }, childCount: list.entries.length),
        ),
      ),
    ];
  }
}
