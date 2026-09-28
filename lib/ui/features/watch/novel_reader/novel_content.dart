/// One laid-out unit of a novel chapter.
///
/// [ExtensionFikushonWatch.content] is a flat `List<String>` carrying no type
/// tag: each string is either a paragraph of prose or an image URL. The reader
/// needs more than that to build a page, so the list is split into these blocks
/// once, up front, and every view works from the result.
sealed class NovelContentBlock {
  const NovelContentBlock();
}

/// A run of prose.
final class NovelParagraph extends NovelContentBlock {
  const NovelParagraph(this.text, {this.dropCap = false});

  final String text;

  /// Whether this paragraph opens the chapter and carries the drop cap.
  final bool dropCap;

  @override
  String toString() => 'NovelParagraph(${text.length} chars, dropCap: $dropCap)';
}

/// An inset quotation — a letter, an excerpt — drawn as a raised card.
///
/// Built from a run of `>`-prefixed strings. Extensions that scrape HTML
/// normally keep the blockquote marker, and it is the only signal the flat
/// content list carries: nothing here decides that a paragraph is a quotation
/// because it merely reads like one.
final class NovelQuote extends NovelContentBlock {
  const NovelQuote(this.paragraphs);

  final List<String> paragraphs;

  @override
  String toString() => 'NovelQuote(${paragraphs.length} paragraphs)';
}

/// An image embedded in the chapter.
final class NovelImage extends NovelContentBlock {
  const NovelImage(this.url);

  final String url;

  @override
  String toString() => 'NovelImage($url)';
}

/// A string that is nothing but a URL.
///
/// Anchored end to end on purpose. The reader's original test was "does this
/// string start with `http`", which turns any paragraph that opens with a bare
/// link into a broken image; requiring the *whole* string to be a link leaves
/// prose that merely mentions a URL alone.
final _urlOnly = RegExp(r'^https?://\S+$', caseSensitive: false);

/// The blockquote marker, with its optional single following space.
final _quoteMarker = RegExp(r'^\s*>\s?');

/// Splits a chapter's flat content list into typed blocks.
///
/// Blank strings are separators, not content: they are dropped so the reader
/// never lays out an empty paragraph, which is what made the previous view
/// render a stray gap for every blank line the extension returned.
List<NovelContentBlock> parseNovelContent(Iterable<String> content) {
  final blocks = <NovelContentBlock>[];
  final quote = <String>[];

  void flushQuote() {
    if (quote.isEmpty) return;
    blocks.add(NovelQuote(List.unmodifiable(quote)));
    quote.clear();
  }

  for (final raw in content) {
    final text = raw.trim();

    if (text.isEmpty) {
      flushQuote();
      continue;
    }

    final quoted = _quoteMarker.firstMatch(text);
    if (quoted != null) {
      final body = text.substring(quoted.end).trim();
      if (body.isEmpty) {
        // A bare `>` closes the quotation rather than opening a new one.
        flushQuote();
      } else {
        quote.add(body);
      }
      continue;
    }

    flushQuote();
    if (_urlOnly.hasMatch(text)) {
      blocks.add(NovelImage(text));
    } else {
      blocks.add(NovelParagraph(text));
    }
  }
  flushQuote();

  if (blocks.isEmpty) return blocks;
  final first = blocks.first;
  if (first is! NovelParagraph) return blocks;
  return [
    NovelParagraph(first.text, dropCap: true),
    ...blocks.skip(1),
  ];
}
