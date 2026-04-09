import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/provider/anilist_provider.dart';
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
            image: NetworkImage(user.avatar.large ?? ''),
            fallback: Text(user.name[0].toUpperCase()),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: context.theme.typography.sm.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ID: ${user.id}',
                  style: context.theme.typography.xs.copyWith(
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

    return collection.when(
      data: (data) => data.isEmpty
          ? const Center(child: Text('Empty Collection'))
          : CustomScrollView(
              slivers: [
                for (final list in data) ..._buildStatusSection(context, list),
                const SliverToBoxAdapter(child: SizedBox(height: 200)),
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
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            list.status,
            style: context.theme.typography.lg.copyWith(
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

class TrackingMobileTabBar extends StatelessWidget {
  final TabController controller;
  const TrackingMobileTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final style = context.theme.tabsStyle;
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: style.decoration,
        child: TabBar(
          tabs: const [
            Tab(text: 'Anime'),
            Tab(text: 'Manga'),
          ],
          controller: controller,
          padding: style.padding,
          indicator: style.indicatorDecoration,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          dividerHeight: 0,
          splashFactory: NoSplash.splashFactory,
          labelColor: context.theme.colors.foreground,
          unselectedLabelColor: context.theme.colors.mutedForeground,
          labelStyle: context.theme.typography.sm.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: context.theme.typography.sm,
        ),
      ),
    );
  }
}
