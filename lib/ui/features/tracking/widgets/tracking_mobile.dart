import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/provider/tracking/anilist_provider.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'anilist_media_card.dart';

class MobileUserHeader extends ConsumerWidget {
  final AnilistUser user;
  const MobileUserHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: .symmetric(horizontal: 16),
      child: Row(
        children: [
          FAvatar(
            image: ExtendedNetworkImageProvider(
              MiruRequest.proxyUrl(user.avatar.medium ?? '').toString(),
            ),
            fallback: Text(user.name[0].toUpperCase()),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: context.theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ID: ${user.id}',
                  style: context.theme.typography.body.xs.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CollectionTab extends ConsumerWidget {
  final AnilistType type;
  const CollectionTab({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collection = ref.watch(anilistCollectionProvider(type));
    final statusFilter = ref.watch(trackingStatusFilterProvider);

    return collection.when(
      data: (data) {
        final filtered = statusFilter == null
            ? data
            : data.where((list) => list.status == statusFilter).toList();

        return filtered.isEmpty
            ? const Center(child: Text('Empty Collection'))
            : CustomScrollView(
                slivers: [
                  for (final list in filtered)
                    ..._buildStatusSection(context, list),
                  const SliverToBoxAdapter(child: SizedBox(height: 200)),
                ],
              );
      },
      loading: () => const Center(child: FCircularProgress.loader()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  List<Widget> _buildStatusSection(BuildContext context, AnilistList list) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            AniListProvider.mediaListStatusToTranslate(
              AniListProvider.stringToMediaListStatus(list.status),
              type,
            ),
            style: context.theme.typography.body.lg.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 180,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.65,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final entry = list.entries[index];
            return AnilistMediaCard(entry: entry, type: type, isDesktop: false);
          }, childCount: list.entries.length),
        ),
      ),
    ];
  }
}
