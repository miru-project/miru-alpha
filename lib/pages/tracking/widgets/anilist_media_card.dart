import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'package:miru_alpha/widgets/grid_view/miru_grid_tile.dart';

class AnilistMediaCard extends StatelessWidget {
  final AnilistEntry entry;
  final AnilistType type;
  final bool isDesktop;

  const AnilistMediaCard({
    super.key,
    required this.entry,
    required this.type,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final title = entry.media.title.userPreferred ?? '';
    final subtitle =
        'Progress: ${entry.progress} / ${type == AnilistType.anime ? entry.media.episodes ?? '?' : entry.media.chapters ?? '?'}';
    final imageUrl = entry.media.coverImage.large;

    return Stack(
      children: [
        if (isDesktop)
          MiruDesktopGridTile(
            title: title,
            subtitle: subtitle,
            imageUrl: imageUrl,
          )
        else
          MiruMobileTile(title: title, subtitle: subtitle, imageUrl: imageUrl),
        if (entry.score > 0)
          Positioned(
            top: 10,
            right: 10,
            child: FBadge(
              child: Text(
                entry.score.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}
