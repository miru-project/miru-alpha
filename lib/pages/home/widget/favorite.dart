import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
import 'package:miru_app_new/provider/watch/main_provider.dart';
import 'package:miru_app_new/utils/router/page_entry.dart';
import 'package:miru_app_new/widgets/amination/animated_box.dart';
import 'package:miru_app_new/widgets/core/image_widget.dart';

class FavoritesHeader extends StatelessWidget {
  const FavoritesHeader({required this.padding, super.key});
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Favorites',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            FButton(
              onPress: () {
                context.go("/home/favorite");
              },
              variant: .ghost,
              child: const Text('View All'),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesGrid extends ConsumerWidget {
  const FavoritesGrid({
    required this.padding,
    required this.crossAxisCount,
    required this.childAspectRatio,
    super.key,
  });
  final EdgeInsetsGeometry padding;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorite = ref.watch(mainProvider).favorites;
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index >= favorite.length) return null;
          final item = favorite[index];
          return FavoriteCard(
            key: ValueKey(item.url),
            item: item,
            aspectRatio: childAspectRatio,
          );
        }, childCount: favorite.length > 4 ? 4 : favorite.length),
      ),
    );
  }
}

class FavoriteCard extends ConsumerWidget {
  const FavoriteCard({
    super.key,
    required this.item,
    required this.aspectRatio,
  });

  final Favorite item;
  final double aspectRatio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedBox(
      onTap: () {
        final meta = ref.read(extensionPageProvider).metaData;
        final extMeta = meta.where((e) => e.packageName == item.package).first;
        context.push(
          '/search/single/detail',
          extra: DetailParam(meta: extMeta, url: item.url),
        );
      },
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .max,

        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FCard.raw(
                child: ImageWidget.defaultErr(
                  title: item.title,
                  width: 210,
                  height: 280,
                  fit: BoxFit.cover,
                  imageUrl: item.cover ?? '',
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
