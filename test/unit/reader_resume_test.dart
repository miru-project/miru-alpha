import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/utils/watch/history_session.dart';

History _row({
  String package = 'pkg',
  String url = 'ep-1',
  int progress = 15,
  int totalProgress = 40,
}) {
  return History(
    package: package,
    url: url,
    detailUrl: 'detail',
    type: 'manga',
    episodeGroupId: 0,
    episodeId: 0,
    title: 'Title',
    episodeTitle: 'Chapter 1',
    progress: progress,
    totalProgress: totalProgress,
    date: DateTime(2026, 11, 15),
  );
}

void main() {
  group('findSavedReadingProgress', () {
    test('returns the position history reported for the episode', () {
      final saved = findSavedReadingProgress(
        history: [_row()],
        package: 'pkg',
        episodeUrl: 'ep-1',
      );

      expect(saved, isNotNull);
      expect(saved!.progress, 15);
      expect(saved.totalProgress, 40);
    });

    test('matches on package and episode url together', () {
      final history = [
        _row(package: 'other', url: 'ep-1'),
        _row(package: 'pkg', url: 'ep-2'),
      ];

      expect(
        findSavedReadingProgress(
          history: history,
          package: 'pkg',
          episodeUrl: 'ep-1',
        ),
        isNull,
      );
      expect(
        findSavedReadingProgress(
          history: history,
          package: 'other',
          episodeUrl: 'ep-1',
        ),
        isNotNull,
      );
    });

    test('an episode never read past its first page is not resumable', () {
      for (final (progress, total) in [(0, 1), (1, 40), (15, 0)]) {
        expect(
          findSavedReadingProgress(
            history: [_row(progress: progress, totalProgress: total)],
            package: 'pkg',
            episodeUrl: 'ep-1',
          ),
          isNull,
          reason: 'progress $progress of $total must not resume',
        );
      }
    });

    test('an empty episode url finds nothing', () {
      expect(
        findSavedReadingProgress(
          history: [_row()],
          package: 'pkg',
          episodeUrl: '',
        ),
        isNull,
      );
    });
  });
}
