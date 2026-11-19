import 'package:flutter/widgets.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/features/setting/widget/update_changelog.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

/// The release body exactly as the feed delivers it — markdown, not prose.
const _body = '''
## What's new

- **Readers** keep their place across a chapter junction
- [x] the last page of a chapter is no longer dropped

### Fixed

| Area | Symptom |
| ---- | ------- |
| Reader | wrong page after a junction |

```dart
final release = await fetchLatest();
```
''';

Future<void> _pump(
  WidgetTester tester,
  String body, {
  double? maxHeight,
}) async {
  await tester.pumpWidget(
    FTheme(
      data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            child: UpdateChangelog(markdown: body, maxHeight: maxHeight),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders the release body as structure, not as markdown source', (
    tester,
  ) async {
    await _pump(tester, _body);

    // Headings become headings.
    expect(find.textContaining("What's new"), findsOneWidget);
    expect(find.textContaining('Fixed'), findsOneWidget);
    // List items become list items.
    expect(
      find.textContaining('the last page of a chapter is no longer dropped'),
      findsOneWidget,
    );
    // The syntax itself never reaches the screen.
    expect(find.textContaining('## '), findsNothing);
    expect(find.textContaining('| ---- |'), findsNothing);
    // And the fenced block is rendered by the markdown widget rather than
    // printed with its backticks.
    expect(find.byType(MarkdownBody), findsOneWidget);
  });

  testWidgets('says so when the release shipped no notes', (tester) async {
    await _pump(tester, '   ');

    expect(find.byType(MarkdownBody), findsNothing);
    // `.i18n` resolves to the key in widget tests (no FlutterI18n delegate is
    // installed here) — what matters is that the blank branch renders *some*
    // text instead of an empty box.
    expect(find.text('settings.update.no_release_notes'), findsOneWidget);
  });

  testWidgets('sets release headings like content, not like a poster', (
    tester,
  ) async {
    // forui's `display` scale starts at 20 and `display.xl3` is 30: a GitHub
    // "## What's new" was rendering at 30px inside a 370px dialog, louder than
    // the dialog's own 15px title. The heading step has to come from the size,
    // not from volume.
    await _pump(tester, _body);

    final heading = tester
        .widget<EditableText>(
          find
              .descendant(
                of: find.byType(UpdateChangelog),
                matching: find.byType(EditableText),
              )
              .first,
        )
        .style
        .fontSize!;
    expect(heading, lessThanOrEqualTo(22));

    // And the body it heads still reads smaller than the heading.
    final bodies = tester
        .widgetList<EditableText>(
          find.descendant(
            of: find.byType(UpdateChangelog),
            matching: find.byType(EditableText),
          ),
        )
        .map((e) => e.style.fontSize!)
        .toList();
    expect(bodies.length, greaterThan(1));
    expect(bodies.first, greaterThan(bodies.last));
  });

  testWidgets('bounds the notes so the actions below stay reachable', (
    tester,
  ) async {
    await _pump(tester, _body * 40, maxHeight: 168);

    // A release body is unbounded; the box that holds it is not.
    expect(
      tester.getSize(find.byType(UpdateChangelog)).height,
      lessThanOrEqualTo(168),
    );
  });

  testWidgets('keeps the whole first line of a wrapped list item', (
    tester,
  ) async {
    // The shape GitHub emits for a long bullet: a bold lead-in, then a
    // continuation line indented under it. Dropping the first line would leave
    // the reader with a sentence that starts mid-clause.
    await _pump(tester, r'''## What's new

- **Readers** — the manga and webtoon infinite scrollers now keep their place
  across a chapter junction instead of snapping back to the first page.
- [x] Chapter chaining no longer drops the last page of a chapter
''');

    expect(find.textContaining('Readers'), findsOneWidget);
    expect(find.textContaining('now keep their place'), findsOneWidget);
    expect(
      find.textContaining('across a chapter junction instead of snapping'),
      findsOneWidget,
    );
  });
}
