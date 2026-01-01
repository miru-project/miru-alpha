import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:miru_app_new/model/index.dart';
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
              style: FButtonStyle.outline(),
              child: const Text('View All'),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesGrid extends StatelessWidget {
  const FavoritesGrid({
    required this.history,
    required this.padding,
    required this.crossAxisCount,
    required this.childAspectRatio,
    super.key,
  });

  final List<History> history;
  final EdgeInsetsGeometry padding;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
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
          if (index >= history.length) return null;
          final item = history[index];
          return FavoriteCard(
            key: ValueKey(item.url),
            item: item,
            aspectRatio: childAspectRatio,
          );
        }, childCount: history.length > 4 ? 4 : history.length),
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

  final History item;
  final double aspectRatio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedBox(
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            item.episodeTitle,
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
