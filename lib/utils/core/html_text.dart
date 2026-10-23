import 'package:flutter/widgets.dart';

final _tag = RegExp(r'<[^>]*>', multiLine: true);
final _tagName = RegExp(r'^<\s*/?\s*([a-zA-Z0-9]+)');
final _hexEntity = RegExp(r'&#x([0-9a-fA-F]+);');
final _decEntity = RegExp(r'&#(\d+);');
final _horizontalWs = RegExp(r'[ \t]+');

/// Converts the inline-HTML subset that extension descriptions ship
/// (`<i>`, `<b>`, `<br>`, entity codes …) into a styled [TextSpan] for
/// `Text.rich`, so `<i>title</i>` renders as italics instead of literal
/// angle brackets on screen.
///
/// Unknown tags disappear along with their brackets while their inner
/// text is kept, and an unclosed emphasis tag styles through the end of
/// the string — source descriptions are hand-written and frequently
/// unbalanced. Consecutive line breaks collapse to one.
TextSpan htmlToSpan(String source, {required TextStyle style}) {
  final children = <InlineSpan>[];
  var italic = 0;
  var bold = 0;

  void emit(String raw) {
    final text = _decodeEntities(raw.replaceAll(_horizontalWs, ' '));
    if (text.isEmpty) return;
    children.add(
      TextSpan(
        text: text,
        style: style.copyWith(
          fontStyle: italic > 0 ? FontStyle.italic : null,
          fontWeight: bold > 0 ? FontWeight.w600 : null,
        ),
      ),
    );
  }

  void emitBreak() {
    final last = children.isEmpty ? null : children.last;
    if (last is TextSpan && (last.text ?? '').endsWith('\n')) return;
    children.add(const TextSpan(text: '\n'));
  }

  var cursor = 0;
  for (final match in _tag.allMatches(source)) {
    emit(source.substring(cursor, match.start));
    cursor = match.end;

    final tag = match.group(0)!;
    final name = _tagName.firstMatch(tag)?.group(1)?.toLowerCase();
    if (name == null) continue;
    final closing = tag.startsWith('</') || tag.endsWith('/>');

    switch (name) {
      case 'i' || 'em':
        italic = closing ? (italic > 0 ? italic - 1 : 0) : italic + 1;
      case 'b' || 'strong':
        bold = closing ? (bold > 0 ? bold - 1 : 0) : bold + 1;
      case 'br':
        emitBreak();
      case 'p' ||
          'div' ||
          'li' ||
          'ul' ||
          'ol' ||
          'h1' ||
          'h2' ||
          'h3' ||
          'h4' ||
          'h5' ||
          'h6' ||
          'blockquote' ||
          'pre':
        // Block boundaries read as line breaks in plain text.
        emitBreak();
      default:
        // Unknown/self-closing tags (img, span, a …) drop their brackets
        // only; emit() below keeps the inner text they wrap.
        break;
    }
  }
  emit(source.substring(cursor));
  return TextSpan(style: style, children: children);
}

/// Decodes the entity codes sources actually emit, `&amp;` last so a
/// literal `&amp;lt;` does not double-decode.
String _decodeEntities(String text) => text
    .replaceAllMapped(
      _hexEntity,
      (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)),
    )
    .replaceAllMapped(
      _decEntity,
      (m) => String.fromCharCode(int.parse(m.group(1)!)),
    )
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'")
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&amp;', '&');
