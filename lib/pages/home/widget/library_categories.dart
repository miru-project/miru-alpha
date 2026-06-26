import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

class LibraryCategoryList extends ConsumerWidget {
  const LibraryCategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'common.type'.i18n,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            FButton(
              variant: .ghost,
              onPress: () {},
              child: Text('common.manage'.i18n.toUpperCase()),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FTileGroup(
          children: [
            FTile(
              prefix: Icon(
                FLucideIcons.film,
                size: 20,
                color: context.theme.colors.mutedForeground.withAlpha(200),
              ),
              title: Text('media.video'.i18n),
              details: Text(
                '42',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: context.theme.colors.mutedForeground.withAlpha(120),
                ),
              ),
              onPress: () {},
            ),
            FTile(
              prefix: Icon(
                FLucideIcons.bookOpen,
                size: 20,
                color: context.theme.colors.mutedForeground.withAlpha(200),
              ),
              title: Text('media.manga'.i18n),
              details: Text(
                '76',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: context.theme.colors.mutedForeground.withAlpha(120),
                ),
              ),
              onPress: () {},
            ),
            FTile(
              prefix: Icon(
                FLucideIcons.book,
                size: 20,
                color: context.theme.colors.mutedForeground.withAlpha(200),
              ),
              title: Text('media.novel'.i18n),
              details: Text(
                '10',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: context.theme.colors.mutedForeground.withAlpha(120),
                ),
              ),
              onPress: () {},
            ),
          ],
        ),
      ],
    );
  }
}
