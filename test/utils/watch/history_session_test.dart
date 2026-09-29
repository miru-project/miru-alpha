import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/utils/watch/history_session.dart';

ExtensionEpisodeGroup _group(String title, List<String> urls) =>
    ExtensionEpisodeGroup(
      title: title,
      urls: [for (final url in urls) ExtensionEpisode(name: url, url: url)],
    );

Detail _detail(List<ExtensionEpisodeGroup> groups) => Detail(
  title: 'Show',
  detailUrl: 'https://detail',
  package: 'test.pkg',
  episodes: groups,
);

History _history({required String url, int group = 0, int episode = 0}) =>
    History(
      package: 'test.pkg',
      url: url,
      detailUrl: 'https://detail',
      type: 'bangumi',
      episodeGroupId: group,
      episodeId: episode,
      title: 'Show',
      episodeTitle: 'EP',
      progress: 10,
      totalProgress: 100,
      date: DateTime(2026, 1, 1),
    );

void main() {
  group('resolveHistoryEpisode', () {
    test('keeps the stored indices while they still match the saved URL', () {
      final detail = _detail([
        _group('S1', ['a', 'b', 'c']),
      ]);

      final ref = resolveHistoryEpisode(
        detail: detail,
        history: _history(url: 'b', group: 0, episode: 1),
      );

      expect(ref, (episodeIndex: 1, groupIndex: 0));
    });

    test('resolves by URL when the extension re-orders its episodes', () {
      // Saved against ['a','b','c']; index 1 now holds 'x', so trusting the
      // stored index would resume the wrong episode.
      final detail = _detail([
        _group('S1', ['x', 'a', 'b', 'c']),
      ]);

      final ref = resolveHistoryEpisode(
        detail: detail,
        history: _history(url: 'b', group: 0, episode: 1),
      );

      expect(ref, (episodeIndex: 2, groupIndex: 0));
    });

    test('finds the episode across a different group', () {
      final detail = _detail([
        _group('S1', ['a', 'b']),
        _group('S2', ['c', 'd']),
      ]);

      final ref = resolveHistoryEpisode(
        detail: detail,
        history: _history(url: 'd', group: 0, episode: 0),
      );

      expect(ref, (episodeIndex: 1, groupIndex: 1));
    });

    test('returns null when the episode is gone', () {
      final detail = _detail([
        _group('S1', ['a', 'b']),
      ]);

      expect(
        resolveHistoryEpisode(
          detail: detail,
          history: _history(url: 'zzz'),
        ),
        isNull,
      );
    });

    test('out-of-range stored indices do not throw', () {
      // The stored indices come from the database and may describe a list that
      // has since shrunk; the original implementation indexed straight in and
      // raised RangeError.
      final detail = _detail([
        _group('S1', ['a']),
      ]);

      expect(
        () => resolveHistoryEpisode(
          detail: detail,
          history: _history(url: 'a', group: 9, episode: 42),
        ),
        returnsNormally,
      );
      expect(
        resolveHistoryEpisode(
          detail: detail,
          history: _history(url: 'a', group: 9, episode: 42),
        ),
        (episodeIndex: 0, groupIndex: 0),
      );
    });

    test('negative stored indices do not throw', () {
      final detail = _detail([
        _group('S1', ['a', 'b']),
      ]);

      expect(
        resolveHistoryEpisode(
          detail: detail,
          history: _history(url: 'b', group: -1, episode: -1),
        ),
        (episodeIndex: 1, groupIndex: 0),
      );
    });

    test('null or empty episode lists resolve to null', () {
      final empty = Detail(
        title: 'Show',
        detailUrl: 'https://detail',
        package: 'test.pkg',
      );

      expect(
        resolveHistoryEpisode(
          detail: empty,
          history: _history(url: 'a'),
        ),
        isNull,
      );
      expect(
        resolveHistoryEpisode(
          detail: _detail(const []),
          history: _history(url: 'a'),
        ),
        isNull,
      );
    });
  });
}
