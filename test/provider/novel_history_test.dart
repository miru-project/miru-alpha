import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/watch/novel_reader_provider.dart';

void main() {
  group('NovelReaderState.historySnapshot', () {
    test('reports the measured position of a continuous chapter', () {
      const state = NovelReaderState(line: 29, totalLine: 189);

      expect(state.historySnapshot.progress, 29);
      expect(state.historySnapshot.totalProgress, 189);
    });

    test('reports pages for a paged chapter', () {
      const state = NovelReaderState(
        readMode: NovelReadMode.standard,
        page: 4,
        totalPage: 27,
        line: 120,
        totalLine: 556,
      );

      expect(state.historySnapshot.progress, 4);
      expect(state.historySnapshot.totalProgress, 27);
    });

    test('an unmeasured chapter is still recorded, at zero of one', () {
      // The novel reader only learns a chapter's length after the canvas
      // measures it. Before that there is no total at all, and
      // `prepareHistorySave` drops an entry with no total — which is how a
      // chapter opened and closed before it loaded vanished from history.
      const state = NovelReaderState();

      expect(state.totalProgress, 0);
      expect(state.historySnapshot.progress, 0);
      expect(state.historySnapshot.totalProgress, 1);
    });

    test('the fallback never reads as a finished chapter', () {
      const state = NovelReaderState();

      // A tracker treats 100% as "finished" and bumps the chapter, so the
      // fallback must stay strictly below it.
      final snapshot = state.historySnapshot;
      expect(snapshot.progress < snapshot.totalProgress, isTrue);
    });

    test('a measured total replaces the fallback', () {
      const state = NovelReaderState(line: 1, totalLine: 556);

      expect(state.historySnapshot.totalProgress, 556);
      expect(state.historySnapshot.totalProgress, isNot(1));
    });
  });
}
