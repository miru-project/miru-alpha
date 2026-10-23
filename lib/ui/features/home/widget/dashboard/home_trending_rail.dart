import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/home/home_trending_provider.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_poster_rail.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_section_header.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:url_launcher/url_launcher.dart';

/// "Trending" — AniList's public trending catalogue. One source, so the
/// header shows a static source chip instead of a picker; a poster opens its
/// AniList page, the only destination this data has. The simplified mockup
/// carries no rank badges — only the score chip.
class HomeTrendingRail extends ConsumerWidget {
  const HomeTrendingRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(homeTrendingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HomeSectionHeader(
            title: 'home.trending'.i18n,
            // Mockup: the source selector hugs the title ("Trending
            // [Source: AniList]"). One source exists, so it stays a static
            // chip — a dropdown with a single entry would be a dead control.
            titleTrailing: HomeChip(
              label: 'extension.source'.i18n.fill({'name': 'AniList'}),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Riverpod reports a failed build as AsyncLoading carrying the error,
        // so the branch is chosen by shape rather than AsyncValue.when.
        if (trending.hasError)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HomeEmpty(
              text: 'home.trending_offline'.i18n,
              action: _retryButton(context, ref),
            ),
          )
        else if (trending.isLoading)
          const _TrendingSkeleton()
        else
          _TrendingData(items: trending.value ?? const []),
      ],
    );
  }

  Widget _retryButton(BuildContext context, WidgetRef ref) => FButton(
    variant: .outline,
    mainAxisSize: .min,
    onPress: () => ref.read(homeTrendingProvider.notifier).refresh(),
    child: Text('search.retry'.i18n),
  );
}

/// The loaded catalogue: poster rail with score chips.
class _TrendingData extends StatelessWidget {
  const _TrendingData({required this.items});

  static const _maxCards = 10;

  final List<AnilistMedia> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: HomeEmpty(text: 'home.trending_empty'.i18n),
      );
    }
    final shown = items.length < _maxCards ? items.length : _maxCards;
    return HomePosterRail(
      itemCount: shown,
      builder: (context, index) {
        final media = items[index];
        return HomePosterCard(
          key: ValueKey(media.id),
          title: media.title.userPreferred ?? media.title.romaji ?? '',
          cover: media.coverImage.large,
          overlay: media.meanScore == null
              ? null
              : HomeChip(
                  icon: FLucideIcons.star,
                  label: _score(media.meanScore!),
                ),
          subtitle: media.type == null ? null : _typeLabel(media.type!),
          onTap: () => _openOnAniList(context, media),
        );
      },
    );
  }

  /// AniList's meanScore is 0-100; the mockup's badge shows one decimal.
  String _score(int meanScore) => (meanScore / 10).toStringAsFixed(1);

  String _typeLabel(String type) => switch (type.toUpperCase()) {
    'MANGA' => searchExtensionTypeLabel(ExtensionType.manga),
    _ => searchExtensionTypeLabel(ExtensionType.bangumi),
  };

  Future<void> _openOnAniList(BuildContext context, AnilistMedia media) async {
    final kind = media.type?.toString().toLowerCase();
    final url = Uri.parse('https://anilist.co/${kind ?? 'anime'}/${media.id}');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      showSimpleToast('common.error'.i18n);
    }
  }
}

/// Three inset placeholders while the catalogue request is in flight.
class _TrendingSkeleton extends StatelessWidget {
  const _TrendingSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return SizedBox(
      height: kHomePosterRailHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, _) => Container(
          width: kHomePosterWidth,
          height: kHomePosterWidth * 3 / 2,
          decoration: BoxDecoration(
            color: colors.muted,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
        ),
      ),
    );
  }
}
