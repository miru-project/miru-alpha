import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/utils/core/html_text.dart';

void main() {
  const style = TextStyle(fontSize: 14);

  group('htmlToSpan', () {
    test('renders <i> as italic and strips the brackets', () {
      final span = htmlToSpan(
        'The second season of <i>Katainaka no Ossan</i>.',
        style: style,
      );
      expect(
        span.toPlainText(),
        'The second season of Katainaka no Ossan.',
      );
      final italic = span.children!.whereType<TextSpan>().firstWhere(
        (s) => s.text == 'Katainaka no Ossan',
      );
      expect(italic.style?.fontStyle, FontStyle.italic);
    });

    test('keeps an unclosed emphasis styled through the end', () {
      final span = htmlToSpan('<i>unbalanced text', style: style);
      expect(span.toPlainText(), 'unbalanced text');
      final only = span.children!.whereType<TextSpan>().single;
      expect(only.style?.fontStyle, FontStyle.italic);
    });

    test('<b>/<strong> apply semibold weight', () {
      final span = htmlToSpan('<b>a</b> and <strong>b</strong>', style: style);
      final bolds = span.children!
          .whereType<TextSpan>()
          .where((s) => s.style?.fontWeight == FontWeight.w600)
          .map((s) => s.text);
      expect(bolds, ['a', 'b']);
    });

    test('<br> becomes a line break and repeats collapse', () {
      final span = htmlToSpan('line<br><br>next', style: style);
      expect(span.toPlainText(), 'line\nnext');
    });

    test('unknown tags drop their brackets but keep inner text', () {
      final span = htmlToSpan(
        '<img src="x.jpg"><a href="/y">link</a> tail',
        style: style,
      );
      expect(span.toPlainText(), 'link tail');
    });

    test('decodes the common entities', () {
      final span = htmlToSpan(
        'a &amp; b &lt;tag&gt; &quot;q&quot; &#39;s&#39; x&nbsp;y',
        style: style,
      );
      expect(span.toPlainText(), 'a & b <tag> "q" ' "'s'" ' x y');
    });

    test('collapses horizontal whitespace, keeps plain text as-is', () {
      final span = htmlToSpan('plain  text\ntab\there', style: style);
      expect(span.toPlainText(), 'plain text\ntab here');
      expect(span.children, hasLength(1));
    });
  });
}
