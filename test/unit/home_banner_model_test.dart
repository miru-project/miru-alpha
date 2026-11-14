import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/model/home_banner_model.dart';

void main() {
  group('stripHtml', () {
    test('strips tags and decodes entities', () {
      expect(
        stripHtml('<i>The</i> adventure<br>is "over" &#039;now&#039;'),
        'The adventure\nis "over" \'now\'',
      );
    });

    test('smart quotes and dashes fold to plain text', () {
      expect(stripHtml('a \u201cb\u201d \u2014 c'), 'a "b" \u2014 c');
    });

    test('null and empty', () {
      expect(stripHtml(null), '');
      expect(stripHtml(''), '');
    });
  });

  group('HomeBannerItem.fromAnilistMedia', () {
    AnilistMedia media({
      String? banner,
      String type = 'ANIME',
      int? meanScore = 91,
    }) => AnilistMedia(
      id: 42,
      type: type,
      status: 'RELEASING',
      meanScore: meanScore,
      description: '<p>Long story</p>',
      bannerImage: banner,
      title: AnilistTitle(userPreferred: 'Frieren', english: 'Frieren EN'),
      coverImage: AnilistCoverImage(large: 'https://img/cover.jpg'),
    );

    test('banner artwork preferred, score scaled, url from media type', () {
      final item = HomeBannerItem.fromAnilistMedia(
        media(banner: 'https://img/banner.jpg'),
        2,
      );
      expect(item.rank, 2);
      expect(item.title, 'Frieren');
      expect(item.subtitle, 'Frieren EN');
      expect(item.backdrop, 'https://img/banner.jpg');
      expect(item.description, 'Long story');
      expect(item.score, 9.1);
      expect(item.externalUrl, 'https://anilist.co/anime/42');
    });

    test('cover image is the fallback when no banner', () {
      final item = HomeBannerItem.fromAnilistMedia(media(), 1);
      expect(item.backdrop, 'https://img/cover.jpg');
    });

    test('manga kind drives the catalogue url', () {
      final item = HomeBannerItem.fromAnilistMedia(media(type: 'MANGA'), 1);
      expect(item.externalUrl, 'https://anilist.co/manga/42');
    });

    test('null score stays null', () {
      final item = HomeBannerItem.fromAnilistMedia(media(meanScore: null), 1);
      expect(item.score, isNull);
    });
  });

  group('HomeBannerItem.fromTmdbResult', () {
    test('movie row maps title, backdrop, votes and url', () {
      final item = HomeBannerItem.fromTmdbResult(
        {
          'id': 5,
          'title': 'Dune',
          'original_title': 'Dune Part Two',
          'backdrop_path': '/abc.jpg',
          'overview': 'Sand worms',
          'vote_average': 8.2,
        },
        3,
        'movie',
        (path) => 'https://image.tmdb.org/t/p/w1280$path',
      );
      expect(item.rank, 3);
      expect(item.title, 'Dune');
      expect(item.subtitle, 'Dune Part Two');
      expect(item.backdrop, 'https://image.tmdb.org/t/p/w1280/abc.jpg');
      expect(item.description, 'Sand worms');
      expect(item.score, 8.2);
      expect(item.externalUrl, 'https://www.themoviedb.org/movie/5');
    });

    test('tv row uses name and falls back to the poster path', () {
      final item = HomeBannerItem.fromTmdbResult(
        {
          'id': 9,
          'name': 'Severance',
          'poster_path': '/p.jpg',
          'vote_average': 8.6,
        },
        1,
        'tv',
        (path) => 'https://image.tmdb.org/t/p/w1280$path',
      );
      expect(item.title, 'Severance');
      expect(item.backdrop, 'https://image.tmdb.org/t/p/w1280/p.jpg');
      expect(item.externalUrl, 'https://www.themoviedb.org/tv/9');
    });

    test('no artwork path keeps the backdrop null', () {
      final item = HomeBannerItem.fromTmdbResult(
        {'id': 1, 'name': 'X'},
        1,
        'tv',
        (path) => 'https://image.tmdb.org/t/p/w1280$path',
      );
      expect(item.backdrop, isNull);
    });
  });

  group('source/format catalogue', () {
    test('formats follow the source', () {
      expect(HomeBannerSource.tmdb.formats, const [
        HomeBannerFormat.movie,
        HomeBannerFormat.show,
      ]);
      expect(HomeBannerSource.anilist.formats, const [
        HomeBannerFormat.anime,
        HomeBannerFormat.manga,
      ]);
    });

    test('tmdb type maps show to tv', () {
      expect(HomeBannerFormat.movie.tmdbType, 'movie');
      expect(HomeBannerFormat.show.tmdbType, 'tv');
    });

    test('source labels', () {
      expect(HomeBannerSource.tmdb.label, 'TMDB');
      expect(HomeBannerSource.anilist.label, 'AniList');
    });
  });
}
