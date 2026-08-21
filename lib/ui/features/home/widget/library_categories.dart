import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:go_router/go_router.dart';

class LibraryCategoryList extends ConsumerWidget {
  const LibraryCategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritePageProvider).favorites;
    int countOf(ExtensionType type) =>
        favorites.where((e) => stringToExtensionType(e.type) == type).length;

    final categories = [
      (
        icon: FLucideIcons.film,
        label: 'media.video'.i18n,
        count: countOf(ExtensionType.bangumi),
        route: '/home/favorite?type=media.video',
      ),
      (
        icon: FLucideIcons.bookOpen,
        label: 'media.manga'.i18n,
        count: countOf(ExtensionType.manga),
        route: '/home/favorite?type=media.manga',
      ),
      (
        icon: FLucideIcons.book,
        label: 'media.novel'.i18n,
        count: countOf(ExtensionType.fikushon),
        route: '/home/favorite?type=media.novel',
      ),
    ];

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
              size: .xs,
              variant: .secondary,
              onPress: () {},
              child: Text('common.manage'.i18n.toUpperCase()),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FTileGroup(
          children: [
            for (final c in categories)
              FTile(
                prefix: Icon(
                  c.icon,
                  size: 20,
                  color: context.theme.colors.mutedForeground.withAlpha(200),
                ),
                title: Text(c.label),
                details: Text(
                  c.count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: context.theme.colors.mutedForeground.withAlpha(120),
                  ),
                ),
                onPress: () {
                  context.push(c.route);
                },
              ),
          ],
        ),
      ],
    );
  }
}
