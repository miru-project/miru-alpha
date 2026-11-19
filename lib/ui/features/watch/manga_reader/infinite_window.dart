/// Pure index math for the manga reader's infinite webtoon window.
///
/// One [ChapterSegment] per loaded chapter; the list renders a flat sequence
/// of [WindowSlot]s. Nothing in here touches Flutter, so the index
/// consistency rules can be unit-tested exhaustively.
library;

enum SlotKind {
  /// Absolute start of the loaded window's series (nothing above it).
  seriesStart,

  /// A page of [WindowSlot.segmentIndex]'s chapter.
  page,

  /// Divider between two loaded chapters; the right-hand segment is
  /// [WindowSlot.segmentIndex].
  junction,

  /// The chapter segment has not finished loading.
  loading,

  /// The chapter segment failed to load; tapping retries.
  error,

  /// Absolute end of the series.
  seriesEnd,
}

/// One chapter loaded into the window. The item type is the chapter's
/// content unit: page image URLs for the manga webtoon, prose blocks for the
/// novel.
class ChapterSegment<T> {
  const ChapterSegment({
    required this.episodeIndex,
    required this.name,
    required this.url,
    required this.items,
    this.loading = false,
    this.failed = false,
  });

  /// Index into the group's episode list (the display order).
  final int episodeIndex;
  final String name;
  final String url;

  /// The chapter's items; null while loading or after an error.
  final List<T>? items;
  final bool loading;
  final bool failed;

  ChapterSegment<T> copyWith({List<T>? items, bool? loading, bool? failed}) {
    return ChapterSegment<T>(
      episodeIndex: episodeIndex,
      name: name,
      url: url,
      items: items ?? this.items,
      loading: loading ?? this.loading,
      failed: failed ?? this.failed,
    );
  }
}

class WindowSlot {
  const WindowSlot({
    required this.kind,
    required this.segmentIndex,
    this.pageIndex = -1,
  });

  final SlotKind kind;

  /// Which [ChapterSegment] this slot belongs to. For junctions it is the
  /// chapter *after* the divider; for series boundaries, the end segment.
  final int segmentIndex;

  /// Page index inside the segment's chapter, only for [SlotKind.page].
  final int pageIndex;
}

/// Ordered flat list for the window. Pure: same inputs, same slots.
List<WindowSlot> buildSlots<T>(
  List<ChapterSegment<T>> segments, {
  required bool atSeriesStart,
  required bool atSeriesEnd,
}) {
  final slots = <WindowSlot>[];
  if (atSeriesStart) {
    slots.add(const WindowSlot(kind: SlotKind.seriesStart, segmentIndex: 0));
  }
  for (var i = 0; i < segments.length; i++) {
    if (i > 0) {
      slots.add(WindowSlot(kind: SlotKind.junction, segmentIndex: i));
    }
    final seg = segments[i];
    final items = seg.items;
    if (items == null) {
      slots.add(
        WindowSlot(
          kind: seg.failed ? SlotKind.error : SlotKind.loading,
          segmentIndex: i,
        ),
      );
      continue;
    }
    for (var p = 0; p < items.length; p++) {
      slots.add(WindowSlot(kind: SlotKind.page, segmentIndex: i, pageIndex: p));
    }
  }
  if (atSeriesEnd) {
    slots.add(
      WindowSlot(kind: SlotKind.seriesEnd, segmentIndex: segments.length - 1),
    );
  }
  return slots;
}
