import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/detial_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// Detail-page tag chips: one chip per tag the extension's detail API ships
/// (an AniList extension returns its AniList tags here). TMDB genres only
/// fill in when the extension ships no tags of its own and [tmdbFallback] is
/// on — the mobile hero keeps that fallback, surfaces that never had a TMDB
/// dependency (desktop) opt out. Tapping a chip stars it into
/// [SettingKey.favoriteTags].
class DetailTagChips extends HookConsumerWidget {
  const DetailTagChips({
    super.key,
    required this.detail,
    required this.meta,
    required this.detailPr,
    this.tmdbFallback = true,
  });

  final Detail detail;
  final ExtensionMeta meta;
  final DetialProvider detailPr;

  /// Fetch TMDB genres when the extension ships no tags. Off for surfaces
  /// that never showed TMDB genres, so they gain only real metadata tags.
  final bool tmdbFallback;

  /// The extension's own detail tags — trimmed, deduped, with a tag naming
  /// the media type removed. The single definition every surface gates on.
  static List<String> metadataTagsOf(Detail detail, ExtensionType type) =>
      (detail.tags ?? const <String>[])
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty && tag != detailTypeLabel(type))
          .toSet()
          .toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final starred = useState<Set<String>>(
      MiruSettings.getFavoriteTags().toSet(),
    );

    // Metadata tags win: the source site tags this exact item, while a TMDB
    // genre list is only a best-effort title match.
    final metadataTags = metadataTagsOf(detail, meta.type);

    useEffect(() {
      // Cheapest path: no TMDB search when the extension already tagged the
      // item — the request would fetch genres the chips never render.
      if (!tmdbFallback || metadataTags.isNotEmpty) return null;
      final notifier = ref.read(detailPr.notifier);
      Future.microtask(() async {
        try {
          final mediaType = meta.type == ExtensionType.bangumi ? 'tv' : 'movie';
          await notifier.fetchTMDBDetail(detail.title, mediaType);
        } catch (_) {
          // TMDB is optional metadata: a failed lookup hides the chips
          // instead of failing the detail page.
        }
      });
      return null;
    }, const []);

    final tags = metadataTags.isNotEmpty
        ? metadataTags
        : ref
              .watch(
                detailPr.select(
                  (value) => value.tmdbDetail?.genres ?? const <String>[],
                ),
              )
              .where((genre) => genre != detailTypeLabel(meta.type))
              .toList();
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final tag in tags)
          SmallBadge(
            label: tag,
            variant: starred.value.contains(tag) ? .primary : .outline,
            onPress: () {
              starred.value = MiruSettings.toggleFavoriteTag(tag).toSet();
            },
          ),
      ],
    );
  }
}

/// Display label of an extension type. A metadata tag (or TMDB genre) equal
/// to it is filtered out — the media type is deliberately not rendered on
/// the detail page, so a type-named tag would be a duplicate with no source.
String detailTypeLabel(ExtensionType type) => switch (type) {
  ExtensionType.bangumi => 'media.video'.i18n,
  ExtensionType.manga => 'media.manga'.i18n,
  ExtensionType.fikushon => 'media.novel'.i18n,
  ExtensionType.all => 'common.all'.i18n,
};
