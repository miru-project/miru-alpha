import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/provider/watch/novel_reader_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_content.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_pagination.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_typography.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Widest the prose column ever gets, matching the reference's `max-w-lg`.
///
/// A novel is a single column of text: past this the lines get too long to read
/// comfortably, and the page is centred in whatever space is left.
const double kNovelMaxProseWidth = 512;

/// Horizontal share of the canvas treated as a page-turn tap zone.
const double kNovelTapZoneExtent = 0.25;

/// The measured state of one canvas pass: where every block lands, and how wide
/// the drop cap is.
@immutable
class _CanvasMetrics {
  const _CanvasMetrics(this.layout, this.dropCapWidth);

  final NovelLayout layout;
  final double dropCapWidth;
}

/// The chapter page: paper, chapter header, prose, quotations and images.
///
/// The canvas is the only thing that measures the chapter, and it publishes the
/// result through [NovelReader.setLayout]; every position readout, the scrubber
/// and the history entry are derived from that single measurement instead of
/// being tracked independently.
class NovelReadingView extends HookConsumerWidget {
  const NovelReadingView({
    super.key,
    required this.blocks,
    required this.chapterTitle,
    required this.chapterOrdinal,
    required this.novelProvider,
    required this.onTapZone,
  });

  final List<NovelContentBlock> blocks;

  /// Chapter name, drawn under the eyebrow above the prose.
  final String chapterTitle;

  /// One-based chapter number, shown as the "Chapter One" eyebrow.
  final int chapterOrdinal;

  final NovelReaderProvider novelProvider;

  /// Reports a tap, as a fraction of the canvas width from the leading edge.
  final ValueChanged<double> onTapZone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(novelProvider);
    final reader = ref.read(novelProvider.notifier);
    final paper = NovelPaper.of(state.theme);
    final typography = NovelTypography(
      family: state.fontFamily,
      fontSize: state.fontSize,
      lineHeight: state.lineHeight,
    );
    final mode = state.readMode.resolved;
    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final mediaPadding = MediaQuery.paddingOf(context);
    final size = MediaQuery.sizeOf(context);

    // The page's padding is the same whether or not the chrome is showing. The
    // chrome floats over the prose, the way the manga reader's bars float over
    // the artwork, so revealing the HUD must not reflow the chapter under the
    // reader: that moved the text on every tap and repacked the paged modes.
    // Only the safe area is reserved, and only for the modes that present a
    // sheet of paper — a continuous scroll is full-bleed.
    final insetSafeArea = mode != NovelReadMode.webToon;
    final topInset = insetSafeArea ? mediaPadding.top : 0.0;
    final bottomInset = insetSafeArea ? mediaPadding.bottom : 0.0;
    final canvasWidth = math.min(size.width, kNovelMaxProseWidth);
    final margin = state.margin;
    final textWidth = math.max(0.0, canvasWidth - margin * 2);
    final pageHeight = math.max(0.0, size.height - topInset - bottomInset);

    // Built once and used for both the measurement and the render, so the packer
    // budgets for exactly the header that gets drawn.
    final eyebrowText = '${'reader.novel.chapter'.i18n} $chapterOrdinal';

    // The packer must measure at the width a block is actually drawn at, or the
    // two-column mode would measure every block full-width, find that far less
    // prose fits on a page, and then draw it twice as tall as the room it left.
    final measureWidth = mode == NovelReadMode.doubleColumn
        ? math.max(0.0, (textWidth - NovelSpacing.columnGap) / 2)
        : textWidth;

    final metrics = useMemoized(
      () => _CanvasMetrics(
        buildNovelLayout(
          blocks: blocks,
          pageHeight: pageHeight,
          columnWidth: measureWidth,
          headerWidth: textWidth,
          typography: typography,
          textDirection: textDirection,
          textScaler: textScaler,
          mode: mode,
          chapterTitle: chapterTitle,
          chapterEyebrow: eyebrowText,
        ),
        _measureDropCap(typography, textDirection, textScaler),
      ),
      [
        blocks,
        pageHeight,
        measureWidth,
        textWidth,
        typography.family,
        typography.fontSize,
        typography.lineHeight,
        textScaler,
        textDirection,
        mode,
        chapterTitle,
        eyebrowText,
      ],
    );

    // Publish the measurement, but not from here: a hooks `useEffect` runs
    // synchronously at the end of `build`, and writing provider state while the
    // tree is building is an error. The write waits for the frame the canvas was
    // laid out in, which is also when the measurement is actually valid.
    useEffect(() {
      final layout = metrics.layout;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // The reader can be gone by the time the frame ends — a chapter can be
        // switched from the tap that closed this canvas.
        if (!context.mounted) return;
        reader.setLayout(layout);
      });
      return null;
    }, [metrics.layout]);

    final tracker = useRef(_TapTracker());
    tracker.value.onTap = (position) {
      if (size.width <= 0) return;
      onTapZone(position.dx / size.width);
    };

    final content = switch (mode) {
      // The legacy page-turn values never reach the canvas: `mode` is already
      // resolved, so the arm is only here to keep the match exhaustive.
      NovelReadMode.rightToLeft ||
      NovelReadMode.rightToLeftFlip ||
      NovelReadMode.standardFlip => const SizedBox.shrink(),
      NovelReadMode.webToon => _ContinuousProse(
        blocks: blocks,
        paper: paper,
        typography: typography,
        textWidth: textWidth,
        margin: margin,
        chapterTitle: chapterTitle,
        eyebrowText: eyebrowText,
        dropCapWidth: metrics.dropCapWidth,
        scrollController: reader.scrollController,
      ),
      NovelReadMode.standard || NovelReadMode.doubleColumn => _PagedProse(
        layout: metrics.layout,
        blocks: blocks,
        paper: paper,
        typography: typography,
        textWidth: textWidth,
        margin: margin,
        chapterTitle: chapterTitle,
        eyebrowText: eyebrowText,
        dropCapWidth: metrics.dropCapWidth,
        pageController: reader.pageController,
        // A mode the UI does not offer, but which older builds persisted:
        // it means the same layout with the page order flipped, so a stored
        // setting still does what it said it did.
        reverse: state.readMode == NovelReadMode.rightToLeft,
      ),
    };

    return ColoredBox(
      color: paper.background,
      child: Padding(
        padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
        // A pointer listener rather than a `GestureDetector`: prose is
        // selectable, and `SelectionArea` enters the gesture arena with its own
        // tap recogniser, which would win and swallow every page turn. Listening
        // to the raw pointer is not an arena participant, so a tap reaches the
        // zones while a drag still belongs to the scroll view or page view.
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) => tracker.value.press(event.position),
          onPointerUp: (event) => tracker.value.release(event.position),
          onPointerCancel: (_) => tracker.value.cancel(),
          child: content,
        ),
      ),
    );
  }
}

/// Turns a press and a release into a tap, or into nothing.
///
/// Kept outside the widget so the tracking state survives rebuilds: a rebuild
/// between the press and the release must not forget where the finger went down.
class _TapTracker {
  Offset? _down;

  void Function(Offset position) onTap = (_) {};

  void press(Offset position) => _down = position;

  void cancel() => _down = null;

  void release(Offset position) {
    final down = _down;
    _down = null;
    if (down == null) return;
    // Past the platform's own slop is a drag: a scroll or a page swipe, which
    // the scroll view or page view has already handled.
    if ((position - down).distance > kTouchSlop) return;
    onTap(position);
  }
}

/// Width the drop cap reserves, measured from the cap's own glyph so the first
/// line of the paragraph starts exactly past it.
double _measureDropCap(
  NovelTypography typography,
  TextDirection textDirection,
  TextScaler textScaler,
) {
  final painter = TextPainter(
    text: TextSpan(
      text: 'W',
      style: typography.dropCap(color: const Color(0xFFFFFFFF)),
    ),
    textDirection: textDirection,
    textScaler: textScaler,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

/// Everything one layout pass shares between the two page modes.
class _ProseBody extends StatelessWidget {
  const _ProseBody({
    required this.paper,
    required this.typography,
    required this.textWidth,
    required this.margin,
    required this.dropCapWidth,
    required this.children,
  });

  final NovelPaper paper;
  final NovelTypography typography;
  final double textWidth;
  final double margin;
  final double dropCapWidth;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // The measure is `maxWidth`, not a `SizedBox` of `textWidth + margin * 2`.
    // A box that wide is wider than the page, so it only came out at `textWidth`
    // because the parent clamped it — the padding then took `margin` off a value
    // the parent had already squeezed. Anything laid out *inside* this body asked
    // for the full `textWidth` and came out 2*margin too wide, which in the
    // two-column mode made every column wider than the one the packer measured,
    // so the page no longer matched its own budget. Capping instead of clamping
    // makes the measure the same number everywhere.
    return Align(
      alignment: .topCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: margin),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: textWidth),
          child: DefaultTextStyle(
            style: typography.body(color: paper.foreground),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// The chapter header: the ordinal eyebrow, the chapter name, and the ❦ rule.
class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({
    required this.chapterTitle,
    required this.eyebrowText,
    required this.paper,
    required this.typography,
    required this.showTitle,
  });

  final String chapterTitle;

  /// The "Chapter One" line above the title, handed in so the render and the
  /// pagination pass measure the same words.
  final String eyebrowText;
  final NovelPaper paper;
  final NovelTypography typography;

  /// The continuous canvas shows the header once, at the top of the chapter; a
  /// paged page shows it only on the page that opens the chapter, so turning
  /// forward does not repeat it.
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    if (!showTitle) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(
        top: NovelSpacing.chapterHeaderTop(typography.fontSize),
        bottom: NovelSpacing.chapterHeaderBottom(typography.fontSize),
      ),
      child: Column(
        children: [
          Text(
            eyebrowText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: typography.eyebrow(color: paper.muted),
          ),
          const SizedBox(height: 8),
          Text(
            chapterTitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: typography.chapterTitle(color: paper.foreground),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Divider(color: paper.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '❦',
                  style: typography.ornament(color: paper.muted),
                ),
              ),
              Expanded(child: Divider(color: paper.border)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Builds the widget for one content block.
Widget _novelBlock(
  BuildContext context, {
  required int index,
  required NovelContentBlock block,
  required NovelPaper paper,
  required NovelTypography typography,
  required double dropCapWidth,
}) {
  return switch (block) {
    NovelParagraph(text: final text, dropCap: final dropCap) => _Paragraph(
      text: text,
      dropCap: dropCap,
      dropCapWidth: dropCapWidth,
      paper: paper,
      typography: typography,
    ),
    NovelQuote(paragraphs: final paragraphs) => _QuoteCard(
      paragraphs: paragraphs,
      paper: paper,
      typography: typography,
    ),
    NovelImage(url: final url) => _ChapterImage(
      url: url,
      paper: paper,
      typography: typography,
    ),
  };
}

/// One run of prose, justified, optionally opening with a drop cap.
class _Paragraph extends StatelessWidget {
  const _Paragraph({
    required this.text,
    required this.dropCap,
    required this.dropCapWidth,
    required this.paper,
    required this.typography,
  });

  final String text;
  final bool dropCap;
  final double dropCapWidth;
  final NovelPaper paper;
  final NovelTypography typography;

  @override
  Widget build(BuildContext context) {
    final style = typography.body(color: paper.foreground);
    // The gap below the paragraph is rendered, not just measured: every block
    // owns the space beneath it, which is what the pagination pass adds to each
    // block's measured height. Rendering it here too keeps the two in step and
    // gives the continuous mode the reference's `space-y-5` rhythm.
    final body = Padding(
      padding: EdgeInsets.only(
        bottom: NovelSpacing.paragraphGap(typography.fontSize),
      ),
      child: Text(text, textAlign: TextAlign.justify, style: style),
    );
    if (!dropCap) return body;
    // The cap is painted over the first lines rather than flowed around, so the
    // paragraph keeps a single justify pass and never re-wraps around a float.
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(left: dropCapWidth),
          child: body,
        ),
        Positioned(
          left: 0,
          top: 0,
          child: Text(
            text.characters.first,
            style: typography.dropCap(color: paper.foreground),
          ),
        ),
      ],
    );
  }
}

/// An inset quotation: a raised card, italic prose, an optional attribution.
class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.paragraphs,
    required this.paper,
    required this.typography,
  });

  final List<String> paragraphs;
  final NovelPaper paper;
  final NovelTypography typography;

  @override
  Widget build(BuildContext context) {
    final fontSize = typography.fontSize;
    final margin = NovelSpacing.quoteMargin(fontSize);
    return Container(
      margin: EdgeInsets.symmetric(vertical: margin),
      padding: EdgeInsets.all(NovelSpacing.quotePadding(fontSize)),
      decoration: BoxDecoration(
        color: paper.quoteSurface,
        borderRadius: .circular(fontSize),
        border: Border.all(
          width: NovelSpacing.cardBorderWidth,
          color: paper.quoteBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, paragraph) in paragraphs.indexed) ...[
            if (index > 0)
              SizedBox(height: NovelSpacing.paragraphGap(fontSize)),
            Text(paragraph, style: typography.quote(color: paper.foreground)),
          ],
        ],
      ),
    );
  }
}

/// An image embedded in the chapter, inset like a plate.
class _ChapterImage extends StatelessWidget {
  const _ChapterImage({
    required this.url,
    required this.paper,
    required this.typography,
  });

  final String url;
  final NovelPaper paper;
  final NovelTypography typography;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: NovelSpacing.imageHeight(typography.fontSize),
      // Bottom-only, to match the height the pagination pass measured. Every
      // block owns the gap *below* itself, so a plate is separated from the
      // paragraph above by that paragraph's own gap.
      margin: EdgeInsets.only(
        bottom: NovelSpacing.paragraphGap(typography.fontSize),
      ),
      decoration: BoxDecoration(
        borderRadius: .circular(8),
        border: Border.all(
          width: NovelSpacing.cardBorderWidth,
          color: paper.border,
        ),
      ),
      clipBehavior: .antiAlias,
      child: ImageWidget(imageUrl: url),
    );
  }
}

/// [NovelReadMode.webToon]: the whole chapter as one continuous scroll.
class _ContinuousProse extends StatelessWidget {
  const _ContinuousProse({
    required this.blocks,
    required this.paper,
    required this.typography,
    required this.textWidth,
    required this.margin,
    required this.chapterTitle,
    required this.eyebrowText,
    required this.dropCapWidth,
    required this.scrollController,
  });

  final List<NovelContentBlock> blocks;
  final NovelPaper paper;
  final NovelTypography typography;
  final double textWidth;
  final double margin;
  final String chapterTitle;
  final String eyebrowText;
  final double dropCapWidth;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final header = _ChapterHeader(
      chapterTitle: chapterTitle,
      eyebrowText: eyebrowText,
      paper: paper,
      typography: typography,
      showTitle: true,
    );
    return SelectionArea(
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.zero,
        itemCount: blocks.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _ProseBody(
              paper: paper,
              typography: typography,
              textWidth: textWidth,
              margin: margin,
              dropCapWidth: dropCapWidth,
              children: [header],
            );
          }
          return _ProseBody(
            paper: paper,
            typography: typography,
            textWidth: textWidth,
            margin: margin,
            dropCapWidth: dropCapWidth,
            children: [
              _novelBlock(
                context,
                index: index - 1,
                block: blocks[index - 1],
                paper: paper,
                typography: typography,
                dropCapWidth: dropCapWidth,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// [NovelReadMode.standard] and [NovelReadMode.doubleColumn]: the chapter
/// packed into fixed-height pages.
class _PagedProse extends StatelessWidget {
  const _PagedProse({
    required this.layout,
    required this.blocks,
    required this.paper,
    required this.typography,
    required this.textWidth,
    required this.margin,
    required this.chapterTitle,
    required this.eyebrowText,
    required this.dropCapWidth,
    required this.pageController,
    required this.reverse,
  });

  final NovelLayout layout;
  final List<NovelContentBlock> blocks;
  final NovelPaper paper;
  final NovelTypography typography;
  final double textWidth;
  final double margin;
  final String chapterTitle;
  final String eyebrowText;
  final double dropCapWidth;
  final PageController pageController;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    if (layout.pages.isEmpty) return const SizedBox.shrink();
    return PageView.builder(
      controller: pageController,
      reverse: reverse,
      itemCount: layout.pages.length,
      itemBuilder: (context, index) {
        final page = layout.pages[index];
        // Only the page that opens the chapter carries the header, so it is not
        // repeated on every page turn.
        final opensChapter =
            page.blockIndices.isNotEmpty && page.blockIndices.first == 0;
        return _PagedProsePage(
          page: page,
          blocks: blocks,
          paper: paper,
          typography: typography,
          textWidth: textWidth,
          margin: margin,
          chapterTitle: chapterTitle,
          eyebrowText: eyebrowText,
          dropCapWidth: dropCapWidth,
          showHeader: opensChapter,
        );
      },
    );
  }
}

/// One page of a paged mode: one or two columns of blocks.
class _PagedProsePage extends StatelessWidget {
  const _PagedProsePage({
    required this.page,
    required this.blocks,
    required this.paper,
    required this.typography,
    required this.textWidth,
    required this.margin,
    required this.chapterTitle,
    required this.eyebrowText,
    required this.dropCapWidth,
    required this.showHeader,
  });

  final NovelPage page;
  final List<NovelContentBlock> blocks;
  final NovelPaper paper;
  final NovelTypography typography;
  final double textWidth;
  final double margin;
  final String chapterTitle;
  final String eyebrowText;
  final double dropCapWidth;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final columns = page.columnBlockIndices;
    if (columns.isEmpty) return const SizedBox.shrink();
    // A single-entry page is either a full-width oversized block or the
    // single-column mode, so it uses the whole page width.
    if (columns.length == 1) {
      return _ProseBody(
        paper: paper,
        typography: typography,
        textWidth: textWidth,
        margin: margin,
        dropCapWidth: dropCapWidth,
        children: [
          if (showHeader)
            _ChapterHeader(
              chapterTitle: chapterTitle,
              eyebrowText: eyebrowText,
              paper: paper,
              typography: typography,
              showTitle: true,
            ),
          for (final index in columns.first)
            _novelBlock(
              context,
              index: index,
              block: blocks[index],
              paper: paper,
              typography: typography,
              dropCapWidth: dropCapWidth,
            ),
        ],
      );
    }
    final columnWidth = (textWidth - NovelSpacing.columnGap) / 2;
    // Routed through `_ProseBody` so the columns get the page margin and exactly
    // the measure the packer measured them at. Laying the row out directly gave
    // it the full page width, which made every column wider than the one the
    // pagination budget assumed.
    return _ProseBody(
      paper: paper,
      typography: typography,
      textWidth: textWidth,
      margin: margin,
      dropCapWidth: dropCapWidth,
      children: [
        // The title spans the whole measure, the way a printed book sets a
        // chapter opening over two columns — and a half-width title would be a
        // column of words that can outgrow the page.
        if (showHeader)
          _ChapterHeader(
            chapterTitle: chapterTitle,
            eyebrowText: eyebrowText,
            paper: paper,
            typography: typography,
            showTitle: true,
          ),
        Align(
          alignment: .topCenter,
          child: SizedBox(
            width: textWidth,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (index, column) in columns.indexed) ...[
                  if (index > 0) const SizedBox(width: NovelSpacing.columnGap),
                  Expanded(
                    child: _ProseBody(
                      paper: paper,
                      typography: typography,
                      textWidth: columnWidth,
                      margin: 0,
                      dropCapWidth: dropCapWidth,
                      children: [
                        for (final blockIndex in column)
                          _novelBlock(
                            context,
                            index: blockIndex,
                            block: blocks[blockIndex],
                            paper: paper,
                            typography: typography,
                            dropCapWidth: dropCapWidth,
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
