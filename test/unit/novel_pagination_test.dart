import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_content.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_pagination.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_typography.dart';

const _typography = NovelTypography(
  family: NovelFontFamily.serif,
  fontSize: 18,
  lineHeight: 1.6,
);

List<NovelContentBlock> _blocks(int count, {String? quote}) {
  return [
    for (var i = 0; i < count; i++)
      NovelParagraph('Paragraph number $i of the chapter.'),
    if (quote != null) NovelQuote(['> $quote'.substring(2)]),
  ];
}

NovelLayout _build({
  required List<NovelContentBlock> blocks,
  required double pageHeight,
  double columnWidth = 320,
  double? headerWidth,
  NovelReadMode mode = NovelReadMode.standard,
}) {
  return buildNovelLayout(
    blocks: blocks,
    pageHeight: pageHeight,
    columnWidth: columnWidth,
    // The header spans the page even when the prose is in columns.
    headerWidth: headerWidth ?? columnWidth * 2 + 24,
    typography: _typography,
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.noScaling,
    mode: mode,
  );
}

void main() {
  group('buildNovelLayout', () {
    test('counts lines for every paragraph and reports a chapter total', () {
      final layout = _build(blocks: _blocks(6), pageHeight: 400);

      expect(layout.totalLine, greaterThan(6));
      // One first line per content block, plus the chapter header's zero.
      expect(layout.blockFirstLines, hasLength(7));
      expect(layout.blockFirstLines.first, 0);
      expect(layout.blockFirstLines[1], 1);
    });

    test('an image and a quotation contribute no lines of their own', () {
      final layout = _build(
        blocks: [
          const NovelParagraph('A line of prose.'),
          const NovelQuote(['quoted']),
          const NovelImage('https://example.com/a.jpg'),
          const NovelParagraph('More prose.'),
        ],
        pageHeight: 400,
      );

      expect(layout.blockFirstLines[2], 0);
      expect(layout.blockFirstLines[3], 0);
      // The paragraph after them continues the chapter's line count.
      expect(layout.blockFirstLines[4], greaterThan(1));
    });

    test('the continuous mode packs no pages', () {
      final layout = _build(
        blocks: _blocks(8),
        pageHeight: 400,
        mode: NovelReadMode.webToon,
      );

      expect(layout.pages, isEmpty);
      expect(layout.totalLine, greaterThan(0));
    });

    test('a short chapter stays on a single page', () {
      final layout = _build(blocks: _blocks(2), pageHeight: 900);

      expect(layout.pages, hasLength(1));
      expect(layout.pages.single.columnBlockIndices, hasLength(1));
      expect(layout.pages.single.startLine, 1);
    });

    test('a page too short for the header and the prose splits, losing nothing', () {
      // The header is drawn across the top of the opening page, so on a short
      // page it can leave no room for the first paragraph. The chapter has to go
      // somewhere rather than be drawn over the bottom of the screen.
      final layout = _build(blocks: _blocks(2), pageHeight: 200);

      expect(layout.pages.length, greaterThan(1));
      final placed = <int>[
        for (final page in layout.pages) ...page.blockIndices,
      ];
      expect(placed, [0, 1]);
    });

    test('a long chapter is split into several pages with rising start lines', () {
      final layout = _build(blocks: _blocks(40), pageHeight: 300);

      expect(layout.pages.length, greaterThan(1));
      // Page 1 opens on line 1 and every later page opens strictly later.
      expect(layout.pages.first.startLine, 1);
      for (var i = 1; i < layout.pages.length; i++) {
        expect(
          layout.pages[i].startLine,
          greaterThan(layout.pages[i - 1].startLine),
        );
      }
    });

    test('every content block lands on exactly one page, in order', () {
      final blocks = _blocks(40);
      final layout = _build(blocks: blocks, pageHeight: 300);

      final placed = <int>[
        for (final page in layout.pages) ...page.blockIndices,
      ];
      expect(placed, List.generate(blocks.length, (i) => i));
    });

    test('a page never overflows its measured height', () {
      final layout = _build(blocks: _blocks(40), pageHeight: 300);

      for (final page in layout.pages) {
        var height = 0.0;
        for (final index in page.blockIndices) {
          height += layout.blockHeights[index + 1];
        }
        expect(height, lessThanOrEqualTo(300));
      }
    });

    test('the double-column mode puts at most two columns on a page', () {
      final layout = _build(
        blocks: _blocks(40),
        pageHeight: 300,
        mode: NovelReadMode.doubleColumn,
      );

      for (final page in layout.pages) {
        expect(page.columnBlockIndices.length, lessThanOrEqualTo(2));
      }
      // Two columns are not automatically fewer pages: a paragraph is the atom
      // the packer moves, and at a large type size on a phone one paragraph can
      // be taller than a half-width column, in which case the second column has
      // nothing to hold and the mode reads as a single column. What must hold
      // either way is that no block is lost or repeated.
      final placed = <int>[
        for (final page in layout.pages) ...page.blockIndices,
      ];
      expect(placed, List.generate(40, (i) => i));
    });

    test('a block taller than a page takes a full-width page of its own', () {
      final layout = _build(
        blocks: const [NovelImage('https://example.com/tall.jpg')],
        pageHeight: 10,
        mode: NovelReadMode.doubleColumn,
      );

      expect(layout.pages, hasLength(1));
      // Full width: the single column the block sits in spans the whole page,
      // which is how the canvas recognises a full-width page.
      expect(layout.pages.single.columnBlockIndices, hasLength(1));
      expect(layout.pages.single.columnBlockIndices.single, [0]);
    });

    test('an empty chapter has no lines and no pages to turn', () {
      final layout = _build(blocks: const [], pageHeight: 400);

      expect(layout.totalLine, 0);
      // No page at all, rather than one blank page the reader could turn into.
      expect(layout.pages, isEmpty);
    });
  });

  group('NovelLayout.lineForOffset', () {
    test('reports the line showing at a scroll offset', () {
      final layout = _build(blocks: _blocks(12), pageHeight: 400);

      expect(layout.lineForOffset(0, 18 * 1.6), greaterThanOrEqualTo(1));
      // Deeper into the chapter means a later line, never an earlier one.
      final total = layout.blockOffsets.last + layout.blockHeights.last;
      expect(
        layout.lineForOffset(total, 18 * 1.6),
        greaterThanOrEqualTo(layout.lineForOffset(0, 18 * 1.6)),
      );
    });

    test('clamps to the chapter instead of running past the last line', () {
      final layout = _build(blocks: _blocks(4), pageHeight: 400);

      expect(
        layout.lineForOffset(100000, 18 * 1.6),
        lessThanOrEqualTo(layout.totalLine),
      );
    });

    test('reports nothing before the chapter has been measured', () {
      const layout = NovelLayout(
        blockHeights: [],
        blockFirstLines: [],
        totalLine: 0,
        pages: [],
      );

      expect(layout.lineForOffset(0, 28.8), 0);
    });
  });
}
