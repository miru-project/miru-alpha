import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// The watch page's bookmark toggle, mounted in the episodes header row.
/// Backed by the same favorites store the detail page's favorite dialog
/// manages, so both surfaces always agree.
class WatchFavoriteButton extends ConsumerWidget {
  const WatchFavoriteButton({
    super.key,
    required this.favorited,
    required this.detail,
    required this.meta,
    required this.detailUrl,
  });

  final bool favorited;
  final Detail detail;
  final ExtensionMeta meta;
  final String detailUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    // The outer 44x44 box guarantees the Apple touch floor regardless of
    // the icon-content padding the variant style layers on top (the delta
    // constraints alone measured 38px inside the header row).
    return SizedBox(
      width: 44,
      height: 44,
      child: FButton.icon(
        variant: .outline,
        size: .xs,
        style: .delta(
          iconContentStyle: .delta(
            // Matches the header's other 44px outline buttons (sort, group
            // selector) — one visual family, one touch floor for the
            // cluster (review minor 2: Apple's 44pt floor).
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        ),
        onPress: () => _toggleFavorite(ref),
        child: Icon(
          favorited ? FLucideIcons.bookmarkCheck : FLucideIcons.bookmark,
          size: 16,
          color: favorited ? colors.primary : colors.mutedForeground,
          semanticLabel: favorited
              ? 'media.favorited'.i18n
              : 'media.add_to_favorites'.i18n,
        ),
      ),
    );
  }

  void _toggleFavorite(WidgetRef ref) {
    final favoritePage = ref.read(favoritePageProvider.notifier);
    if (favorited) {
      final existing = ref
          .read(favoritePageProvider)
          .favorites
          .firstWhereOrNull(
            (f) => f.url == detailUrl && f.package == meta.packageName,
          );
      if (existing != null) favoritePage.deleteFavorite(existing);
      return;
    }
    favoritePage.addFavorite(
      Favorite(
        package: meta.packageName,
        url: detailUrl,
        type: meta.type.name,
        title: detail.title,
        cover: detail.cover,
        date: DateTime.now(),
      ),
    );
  }
}
