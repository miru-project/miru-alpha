import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/ui/features/watch/novel_reader/novel_content.dart';

void main() {
  group('parseNovelContent', () {
    test('drops blank separators instead of rendering empty paragraphs', () {
      final blocks = parseNovelContent(['One', '', '', 'Two', '   ', 'Three']);

      expect(
        blocks.whereType<NovelParagraph>().map((b) => b.text),
        ['One', 'Two', 'Three'],
      );
    });

    test('gives the opening paragraph a drop cap and no other one', () {
      final blocks = parseNovelContent(['First', 'Second']);

      expect((blocks.first as NovelParagraph).dropCap, isTrue);
      expect((blocks.last as NovelParagraph).dropCap, isFalse);
    });

    test('does not put a drop cap on a chapter that opens with an image', () {
      final blocks = parseNovelContent([
        'https://example.com/a.jpg',
        'After the plate',
      ]);

      expect(blocks.first, isA<NovelImage>());
      expect((blocks.last as NovelParagraph).dropCap, isFalse);
    });

    test('treats a string that is only a URL as an image', () {
      final blocks = parseNovelContent(['  https://example.com/a.jpg  ']);

      expect(blocks.single, isA<NovelImage>());
      expect((blocks.single as NovelImage).url, 'https://example.com/a.jpg');
    });

    test('keeps prose that merely opens with a URL as prose', () {
      // The old rule was "starts with http", which turned any paragraph that
      // began with a bare link into a broken image.
      const text = 'https://example.com is where the letter came from.';
      final blocks = parseNovelContent([text]);

      expect(blocks.single, isA<NovelParagraph>());
      expect((blocks.single as NovelParagraph).text, text);
    });

    test('groups consecutive blockquote lines into one card and strips markers', () {
      final blocks = parseNovelContent([
        'Before.',
        '> first quoted line',
        '>second quoted line',
        'After.',
      ]);

      expect(blocks, hasLength(3));
      final quote = blocks[1] as NovelQuote;
      expect(quote.paragraphs, ['first quoted line', 'second quoted line']);
    });

    test('a bare blockquote marker closes the card instead of opening one', () {
      final blocks = parseNovelContent(['> quoted', '>', '> quoted again']);

      expect(blocks.whereType<NovelQuote>(), hasLength(2));
      expect(
        blocks.whereType<NovelQuote>().map((q) => q.paragraphs),
        [
          ['quoted'],
          ['quoted again'],
        ],
      );
    });

    test('a quotation spanning a blank separator is closed by it', () {
      final blocks = parseNovelContent(['> quoted', '', 'plain']);

      expect(blocks, hasLength(2));
      expect(blocks.first, isA<NovelQuote>());
      expect(blocks.last, isA<NovelParagraph>());
    });

    test('an empty chapter yields no blocks', () {
      expect(parseNovelContent(const []), isEmpty);
      expect(parseNovelContent(['', '   ']), isEmpty);
    });
  });
}
