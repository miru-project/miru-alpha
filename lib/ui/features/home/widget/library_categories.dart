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
        type: ExtensionType.bangumi,
      ),
      (
        icon: FLucideIcons.bookOpen,
        label: 'media.manga'.i18n,
        type: ExtensionType.manga,
      ),
      (
        icon: FLucideIcons.book,
        label: 'media.novel'.i18n,
        type: ExtensionType.fikushon,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Both labels shrink: the title is a localised string and the
            // manage button carries an upper-cased one, so neither may force
            // the row wider than the viewport.
            Flexible(
              child: Text(
                'common.collection'.i18n,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            FButton(
              size: .xs,
              variant: .secondary,
              onPress: () {},
              mainAxisSize: .min,
              builder:
                  (context, style, textStyle, iconStyle, progress, child) =>
                      Flexible(child: child ?? const SizedBox.shrink()),
              child: Text(
                'common.manage'.i18n.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
                  countOf(c.type).toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: context.theme.colors.mutedForeground.withAlpha(120),
                  ),
                ),
                onPress: () {
                  context.push('/home/favorite?type=${c.type.routeParam}');
                },
              ),
          ],
        ),
      ],
    );
  }
}
