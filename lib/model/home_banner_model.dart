import 'package:miru_alpha/model/anilist_model.dart';

/// Where the home banner's catalogue comes from.
enum HomeBannerSource { tmdb, anilist }

/// The per-source catalogue slice the banner cycles through.
enum HomeBannerFormat { movie, show, anime, manga }

extension HomeBannerSourceX on HomeBannerSource {
  /// Display name of the source (badge + CTA wording).
  String get label => switch (this) {
    HomeBannerSource.tmdb => 'TMDB',
    HomeBannerSource.anilist => 'AniList',
  };

  /// Formats this source offers; a source switch resets to the first.
  List<HomeBannerFormat> get formats => switch (this) {
    HomeBannerSource.tmdb => const [
      HomeBannerFormat.movie,
      HomeBannerFormat.show,
    ],
    HomeBannerSource.anilist => const [
      HomeBannerFormat.anime,
      HomeBannerFormat.manga,
    ],
  };
}

extension HomeBannerFormatX on HomeBannerFormat {
  String get i18nKey => switch (this) {
    HomeBannerFormat.movie => 'home.banner.movie',
    HomeBannerFormat.show => 'home.banner.show',
    HomeBannerFormat.anime => 'home.banner.anime',
    HomeBannerFormat.manga => 'home.banner.manga',
  };

  /// TMDB's discover media type; meaningless for AniList formats.
  String get tmdbType => this == HomeBannerFormat.show ? 'tv' : 'movie';
}

/// One carousel slide: a catalogue entry unified across TMDB and AniList.
class HomeBannerItem {
  const HomeBannerItem({
    required this.title,
    required this.rank,
    this.subtitle,
    this.backdrop,
    this.description,
    this.score,
    this.anilistMediaId,
    this.episodeCount,
    this.chapterCount,
    this.externalUrl,
  });

  final String title;

  /// 1-based position in the source's ranking; renders the "#n Trending" badge.
  final int rank;

  /// Secondary title line (romaji / original title).
  final String? subtitle;

  /// Wide artwork (TMDB backdrop / AniList banner); falls back to the poster.
  final String? backdrop;

  final String? description;

  /// 0-10 rating.
  final double? score;

  /// AniList media id — set for AniList items only; the Bookmark CTA saves
  /// this to the account's Planning list. TMDB rows have no shelf equivalent.
  final int? anilistMediaId;

  /// Episode / chapter count when the source reports one (spec tag).
  final int? episodeCount;
  final int? chapterCount;

  /// Catalogue page opened by the banner CTA.
  final String? externalUrl;

  factory HomeBannerItem.fromAnilistMedia(AnilistMedia media, int rank) {
    final kind = (media.type ?? 'ANIME').toLowerCase();
    return HomeBannerItem(
      title: media.title.userPreferred ?? media.title.romaji ?? '',
      subtitle: media.title.english,
      rank: rank,
      backdrop: _firstNonEmpty([media.bannerImage, media.coverImage.large]),
      description: stripHtml(media.description),
      score: media.meanScore == null ? null : media.meanScore! / 10,
      anilistMediaId: media.id,
      episodeCount: media.episodes,
      chapterCount: media.chapters,
      externalUrl: 'https://anilist.co/$kind/${media.id}',
    );
  }

  /// TMDB discover result row (movie uses `title`, tv uses `name`).
  factory HomeBannerItem.fromTmdbResult(
    Map<String, dynamic> result,
    int rank,
    String mediaType,
    String Function(String path) backdropUrl,
  ) {
    final path = (result['backdrop_path'] ?? result['poster_path']) as String?;
    return HomeBannerItem(
      title: (result['title'] ?? result['name'] ?? '') as String,
      subtitle:
          (result['original_title'] ?? result['original_name']) as String?,
      rank: rank,
      backdrop: path == null || path.isEmpty ? null : backdropUrl(path),
      description: stripHtml(result['overview'] as String?),
      score: (result['vote_average'] as num?)?.toDouble(),
      externalUrl: 'https://www.themoviedb.org/$mediaType/${result['id']}',
    );
  }

  static String? _firstNonEmpty(List<String?> urls) =>
      urls.where((u) => u != null && u.isNotEmpty).firstOrNull;
}

/// Removes AniList/TMDB markup so a description reads as plain text.
String stripHtml(String? html) {
  if (html == null || html.isEmpty) return '';
  return html
      .replaceAll(RegExp(r'<br\s*/?>'), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('\u201c', '"')
      .replaceAll('\u201d', '"')
      .replaceAll('\u2018', "'")
      .replaceAll('\u2019', "'")
      .replaceAll('&#039;', "'")
      .replaceAll('&quot;', '"')
      .replaceAll('&mdash;', '\u2014')
      .replaceAll('&ndash;', '\u2013')
      .replaceAll('&', '&')
      .trim();
}
