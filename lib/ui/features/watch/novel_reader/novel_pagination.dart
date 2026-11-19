import 'package:flutter/widgets.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_content.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_typography.dart';

/// One page of a paged reading mode.
///
/// [startLine] is the 1-based line the page opens on, which is what the reader's
/// "line N of M" readout shows while the page is on screen.
class NovelPage {
  const NovelPage({required this.startLine, required this.columnBlockIndices});

  final int startLine;

  /// Indices into the block list, one entry per column. A page has one entry in
  /// the single-column modes and two in [NovelReadMode.doubleColumn].
  final List<List<int>> columnBlockIndices;

  /// Every block drawn on this page, columns flattened left to right.
  Iterable<int> get blockIndices =>
      columnBlockIndices.expand((column) => column);
}

/// Everything the canvas measured, published so the provider can turn a scroll
/// offset or a page index back into a line number.
///
/// The canvas owns the measurement because only it knows the laid-out width and
/// the active text scaler; the provider owns the mapping because only it knows
/// where the reader has got to.
@immutable
class NovelLayout {
  const NovelLayout({
    required this.blockHeights,
    required this.blockFirstLines,
    required this.totalLine,
    required this.pages,
    this.blockLineCounts = const <int>[],
  });

  /// Height of each block, in layout order, including the gaps around it.
  final List<double> blockHeights;

  /// 1-based line each block starts on. Zero for blocks that carry no prose
  /// (the chapter header and embedded images).
  final List<int> blockFirstLines;

  /// Prose lines each block occupies. Zero for blocks that carry none.
  final List<int> blockLineCounts;

  /// Lines in the whole chapter.
  final int totalLine;

  /// Pages, in reading order. Empty in [NovelReadMode.webToon], which scrolls
  /// and has no pages.
  final List<NovelPage> pages;

  /// Cumulative top edge of each block, so an offset can be resolved to a block.
  List<double> get blockOffsets {
    final offsets = <double>[];
    var top = 0.0;
    for (final height in blockHeights) {
      offsets.add(top);
      top += height;
    }
    return offsets;
  }

  /// The 1-based line showing at [offset] in the continuous scroll.
  ///
  /// [lineExtent] is the reader's baseline-to-baseline distance, so the offset
  /// inside a block converts to whole lines.
  int lineForOffset(double offset, double lineExtent) {
    if (blockHeights.isEmpty || totalLine <= 0) return 0;
    final offsets = blockOffsets;
    for (var i = 0; i < offsets.length; i++) {
      final top = offsets[i];
      final isLast = i == offsets.length - 1;
      if (offset < top + blockHeights[i] || isLast) {
        final first = blockFirstLines[i];
        if (first <= 0) {
          // A block with no prose of its own: keep looking downward so the
          // reader is not reported as sitting on the chapter header.
          continue;
        }
        final within = (offset - top).clamp(0.0, blockHeights[i]);
        final into = lineExtent <= 0 ? 0 : (within / lineExtent).floor();
        return (first + into).clamp(1, totalLine);
      }
    }
    return totalLine;
  }
}

/// Height of [block] once wrapped to [width], including the vertical gaps the
/// canvas adds around it.
///
/// Measured with the very style the canvas renders with, and returned with the
/// gaps already added, so a page break is only ever placed between two blocks
/// rather than in the space between them.
double measureNovelBlock({
  required NovelContentBlock block,
  required double width,
  required NovelTypography typography,
  required TextDirection textDirection,
  required TextScaler textScaler,
  required bool isChapterHeader,
  String title = '',
  String eyebrow = '',
}) {
  if (isChapterHeader) {
    return measureNovelChapterHeader(
      width: width,
      typography: typography,
      textDirection: textDirection,
      textScaler: textScaler,
      title: title,
      eyebrow: eyebrow,
    );
  }
  return switch (block) {
    NovelChapterHeader(title: final t, eyebrow: final e) =>
      measureNovelChapterHeader(
        width: width,
        typography: typography,
        textDirection: textDirection,
        textScaler: textScaler,
        title: t,
        eyebrow: e,
      ),
    NovelJunction() || NovelSeriesBoundary() => NovelSpacing.boundaryExtent,
    NovelParagraph(text: final text) =>
      _measureProse(
            text,
            typography.body(color: const Color(0xFFFFFFFF)),
            width,
            textDirection,
            textScaler,
          ) +
          NovelSpacing.paragraphGap(typography.fontSize),
    NovelQuote(paragraphs: final paragraphs) => _measureQuote(
      paragraphs,
      typography,
      width,
      textDirection,
      textScaler,
    ),
    NovelImage() =>
      // The plate's own box, plus the hairline the decoration draws around it.
      NovelSpacing.imageHeight(typography.fontSize) +
          NovelSpacing.cardBorderWidth * 2 +
          NovelSpacing.paragraphGap(typography.fontSize),
  };
}

double _measureProse(
  String text,
  TextStyle style,
  double width,
  TextDirection textDirection,
  TextScaler textScaler,
) {
  if (text.isEmpty) return 0;
  return _layout(
    TextSpan(text: text, style: style),
    width,
    textDirection,
    textScaler,
  );
}

double _measureQuote(
  List<String> paragraphs,
  NovelTypography typography,
  double width,
  TextDirection textDirection,
  TextScaler textScaler,
) {
  final fontSize = typography.fontSize;
  final padding = NovelSpacing.quotePadding(fontSize);
  final border = NovelSpacing.cardBorderWidth;
  // The card insets the prose horizontally, so it wraps narrower than the page.
  final inner = (width - padding * 2 - border * 2).clamp(0.0, double.infinity);
  // Border, padding and the paragraphs, then the margin above and below.
  var height = padding * 2 + border * 2;
  final style = typography.quote(color: const Color(0xFFFFFFFF));
  for (final paragraph in paragraphs) {
    height += _measureProse(paragraph, style, inner, textDirection, textScaler);
    height += NovelSpacing.paragraphGap(fontSize);
  }
  return height + NovelSpacing.quoteMargin(fontSize) * 2;
}

/// Height of the chapter header: eyebrow, title and the ❦ rule.
///
/// The real strings are measured, not a stand-in. A probe word is one line, and
/// a chapter name is often two or three — measuring a stand-in under-reports a
/// long title by a hundred-odd pixels, which is a page overflow waiting to
/// happen.
double measureNovelChapterHeader({
  required double width,
  required NovelTypography typography,
  required TextDirection textDirection,
  required TextScaler textScaler,
  required String title,
  required String eyebrow,
}) {
  final fontSize = typography.fontSize;
  final probe = const Color(0xFFFFFFFF);
  return _measureProse(
        eyebrow,
        typography.eyebrow(color: probe),
        width,
        textDirection,
        textScaler,
      ) +
      _measureProse(
        title,
        typography.chapterTitle(color: probe),
        width,
        textDirection,
        textScaler,
      ) +
      // The ornament rule: one line of the ornament's own size.
      _measureProse(
        '❦',
        typography.ornament(color: probe),
        width,
        textDirection,
        textScaler,
      ) +
      // The two `SizedBox` gaps inside the header, which no measurement of text
      // can see.
      8 +
      16 +
      NovelSpacing.chapterHeaderTop(fontSize) +
      NovelSpacing.chapterHeaderBottom(fontSize);
}

double _layout(
  InlineSpan span,
  double width,
  TextDirection textDirection,
  TextScaler textScaler,
) {
  if (width <= 0) return 0;
  final painter = TextPainter(
    text: span,
    textDirection: textDirection,
    textScaler: textScaler,
  )..layout(maxWidth: width);
  final height = painter.height;
  painter.dispose();
  return height;
}

/// Share of a page held back when packing, to absorb the gap between measuring a
/// block and drawing it.
///
/// The pass measures with a `TextPainter` and the canvas draws with `Text`, and
/// the two agree on everything except the last fraction of a pixel per line:
/// `TextPainter` and `Text` round their line heights independently. Across a
/// page of a couple of dozen lines that drift is around ten pixels, which is
/// enough to overflow the page the reader is on. A couple of percent of the page
/// is far more than the drift and far too little to see: the page just ends a
/// line or two short, which is what a printed page does anyway.
const double kNovelPaginationTolerance = 0.02;

/// Measures every block and packs the result into pages.
///
/// [pageHeight] is the drawable height of one page, and [columns] how many text
/// columns a page has. Blocks are packed greedily and never split, so a page
/// break always falls between two paragraphs — the way a printed book breaks.
/// A block taller than a whole column cannot be split without cutting a line
/// in half, so it takes a full-width page of its own.
NovelLayout buildNovelLayout({
  required List<NovelContentBlock> blocks,
  required double pageHeight,
  required double columnWidth,
  required double headerWidth,
  required NovelTypography typography,
  required TextDirection textDirection,
  required TextScaler textScaler,
  required NovelReadMode mode,
  String chapterTitle = '',
  String chapterEyebrow = '',
}) {
  final fontSize = typography.fontSize;
  final heights = <double>[];
  final firstLines = <int>[];
  final lineCounts = <int>[];

  // Chapter headers mark a chapter boundary and carry no prose. A block list
  // that already contains NovelChapterHeader blocks (the chained window) is
  // measured as-is; otherwise the single chapter's header is block 0 of the
  // layout, measured across the whole page rather than one column, because
  // that is where it is drawn. When headers are inline, heights[i] aligns
  // with blocks[i]; otherwise heights[i+1] does.
  final hasInlineHeaders = blocks.any((b) => b is NovelChapterHeader);
  final headerOffset = hasInlineHeaders ? 0 : 1;
  if (!hasInlineHeaders) {
    heights.add(
      measureNovelChapterHeader(
        width: headerWidth,
        typography: typography,
        textDirection: textDirection,
        textScaler: textScaler,
        title: chapterTitle,
        eyebrow: chapterEyebrow,
      ),
    );
    firstLines.add(0);
    lineCounts.add(0);
  }

  var line = 1;
  for (final block in blocks) {
    if (block is NovelChapterHeader) {
      heights.add(
        measureNovelChapterHeader(
          width: headerWidth,
          typography: typography,
          textDirection: textDirection,
          textScaler: textScaler,
          title: block.title,
          eyebrow: block.eyebrow,
        ),
      );
      firstLines.add(0);
      lineCounts.add(0);
      continue;
    }
    if (block is NovelJunction || block is NovelSeriesBoundary) {
      heights.add(NovelSpacing.boundaryExtent);
      firstLines.add(0);
      lineCounts.add(0);
      continue;
    }
    heights.add(
      measureNovelBlock(
        block: block,
        width: columnWidth,
        typography: typography,
        textDirection: textDirection,
        textScaler: textScaler,
        isChapterHeader: false,
      ),
    );
    if (block is NovelParagraph) {
      final lines = _countLines(
        block.text,
        typography.body(color: const Color(0xFFFFFFFF)),
        columnWidth,
        textDirection,
        textScaler,
        fontSize,
      );
      firstLines.add(line);
      lineCounts.add(lines);
      line += lines;
    } else {
      firstLines.add(0);
      lineCounts.add(0);
    }
  }

  final totalLine = line - 1;
  if (mode == NovelReadMode.webToon || pageHeight <= 0) {
    return NovelLayout(
      blockHeights: heights,
      blockFirstLines: firstLines,
      totalLine: totalLine,
      pages: const [],
      blockLineCounts: lineCounts,
    );
  }
  // The chapter header is drawn on whichever page opens the chapter, and the
  // first block is always on the first page, so the header's height has to come
  // out of that page's budget — otherwise page one is measured against the whole
  // page and then drawn a header taller than the room left for prose.
  final packed = _pack(
    blocks: blocks,
    heights: heights,
    firstLines: firstLines,
    pageHeight: pageHeight,
    columns: mode == NovelReadMode.doubleColumn ? 2 : 1,
    leadingHeight: heights.first,
    headerOffset: headerOffset,
  );
  return NovelLayout(
    blockHeights: heights,
    blockFirstLines: firstLines,
    totalLine: totalLine,
    pages: _validatePages(
      packed,
      heights,
      firstLines,
      pageHeight,
      heights.first,
      headerOffset: headerOffset,
    ),
    blockLineCounts: lineCounts,
  );
}

/// Re-checks every packed page against the budget and breaks up the ones that
/// overrun.
///
/// The packer fills columns against a running total, and a page that comes out
/// over budget is a page the reader cannot draw: the canvas spills past the
/// bottom of the screen. Rather than trust the running total, each page is
/// measured again once packing is done, and an over-budget page is broken up one
/// block per page.
///
/// A block is never split, so a page can only get shorter this way, and each
/// block is emitted exactly once, so nothing is lost or repeated. A block on its
/// own always fits: the packer only ever put it on a page it had measured room
/// for.
List<NovelPage> _validatePages(
  List<NovelPage> pages,
  List<double> heights,
  List<int> firstLines,
  double pageHeight,
  double leadingHeight, {
  int headerOffset = 1,
}) {
  if (pageHeight <= 0) return pages;
  final out = <NovelPage>[];

  for (final page in pages) {
    // The chapter header is drawn across the top of the opening page, so it is
    // part of that page's height and no other.
    var total = out.isEmpty ? leadingHeight : 0.0;
    for (final index in page.blockIndices) {
      total += heights[index + headerOffset];
    }
    if (total <= pageHeight) {
      out.add(page);
      continue;
    }
    for (final index in page.blockIndices) {
      final line = firstLines[index + headerOffset];
      out.add(
        NovelPage(
          startLine: line > 0 ? line : page.startLine,
          columnBlockIndices: [
            [index],
          ],
        ),
      );
    }
  }
  return out;
}

/// Greedy first-fit packing of measured blocks into columns, then into pages.
List<NovelPage> _pack({
  required List<NovelContentBlock> blocks,
  required List<double> heights,
  required List<int> firstLines,
  required double pageHeight,
  required int columns,
  double leadingHeight = 0,
  int headerOffset = 1,
}) {
  final pages = <NovelPage>[];
  // The usable height, with the measurement tolerance taken out.
  final usableHeight = pageHeight * (1 - kNovelPaginationTolerance);
  var startLine = 1;
  var openPage = <List<int>>[];

  /// Height already used in each column of the open page, parallel to it.
  var fills = <double>[];

  // The chapter header is drawn across the top of the page that opens the
  // chapter, above the columns rather than inside one, so it comes out of that
  // page's height instead of being counted against its first column.
  var budget = usableHeight - leadingHeight;

  void closePage() {
    // A page with no block on it is not a page: the packer opens one before it
    // knows what lands on it, and an empty one must not become a turn.
    if (openPage.any((column) => column.isNotEmpty)) {
      pages.add(
        NovelPage(
          startLine: startLine,
          columnBlockIndices: List.unmodifiable(
            openPage.map(List<int>.unmodifiable),
          ),
        ),
      );
    }
    openPage = <List<int>>[];
    fills = <double>[];
    // Only the opening page carries the header.
    budget = usableHeight;
  }

  void startPage(int line) {
    closePage();
    startLine = line;
  }

  /// First column of the open page with [height] of room, or -1 when the page is
  /// full.
  int targetColumn(double height) {
    for (var i = 0; i < columns; i++) {
      final used = i < fills.length ? fills[i] : 0.0;
      if (used + height <= budget) return i;
    }
    return -1;
  }

  for (var i = 0; i < blocks.length; i++) {
    final block = blocks[i];
    final height = heights[i + headerOffset];

    // A chapter header is drawn across the top of the page that opens its
    // chapter, above the columns rather than inside one, so it comes out of
    // that page's height instead of being counted against its first column.
    if (block is NovelChapterHeader) {
      startPage(startLine);
      // The header is drawn above the columns; the prose that shares a page
      // with it competes for what is left after it.
      openPage = <List<int>>[<int>[]];
      fills = <double>[height];
      budget = usableHeight - height;
      continue;
    }

    // A block with no prose of its own (an image, a quotation) opens the page
    // it lands on, so the reader is not reported on a line before the text.
    final line = firstLines[i + headerOffset] > 0
        ? firstLines[i + headerOffset]
        : startLine;

    // Taller than a whole column: it takes a full-width page of its own,
    // because the only way to fit it in a column is to cut a line in half.
    if (height > budget) {
      startPage(line);
      openPage = <List<int>>[
        <int>[i],
      ];
      closePage();
      startPage(line);
      continue;
    }

    var column = targetColumn(height);
    if (column < 0) {
      startPage(line);
      // Fresh page: the block fits by construction, because anything taller than
      // a page was handled above.
      column = targetColumn(height);
    }
    while (openPage.length <= column) {
      openPage.add(<int>[]);
      fills.add(0);
    }
    openPage[column].add(i);
    fills[column] += height;
  }
  closePage();
  return pages;
}

/// Number of baselines a paragraph occupies once wrapped to [width].
int _countLines(
  String text,
  TextStyle style,
  double width,
  TextDirection textDirection,
  TextScaler textScaler,
  double fontSize,
) {
  if (text.isEmpty) return 0;
  if (width <= 0) return 1;
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: textDirection,
    textScaler: textScaler,
  )..layout(maxWidth: width);
  final height = painter.height;
  painter.dispose();
  final extent = style.fontSize! * (style.height ?? 1.0) * textScaler.scale(1);
  if (height <= 0 || extent <= 0) return 1;
  return (height / extent).ceil().clamp(1, 1 << 20);
}
