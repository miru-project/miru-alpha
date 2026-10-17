import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
// FilterChip also exists in material_ui; this test drives the search one.
import 'package:material_ui/material_ui.dart' hide FilterChip;
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart';
import 'package:miru_alpha/ui/features/search/extension_filter_view.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_chip.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_select_controls.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

SelectFilter _select(Map<String, String> options, {String def = ''}) {
  return SelectFilter()
    ..title = 'Status'
    ..default_2 = def
    ..options.addAll({
      for (final e in options.entries) e.key: (FilterOption()..label = e.value),
    });
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size surface = const Size(420, 880),
}) async {
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    FTheme(
      data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
      child: MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('segmentedFits — the fit test from .agents/ui.md §3', () {
    // N × (widestLabel + 22) + 8 + 4(N-1) <= inner
    test('rejects fewer than two segments', () {
      expect(
        segmentedFits(count: 1, widestLabelWidth: 60, available: 400),
        isFalse,
      );
    });

    test('accepts four short labels in a phone-width dialog', () {
      // "Completed" measured at ~72px (xs2 is 10sp on touch) + 22 = 94 floor,
      // 4 x 94 + 8 + 12 = 396 <= 420.
      expect(
        segmentedFits(count: 4, widestLabelWidth: 72, available: 420),
        isTrue,
      );
    });

    test('rejects four labels that cannot fit', () {
      // Same count, 30px less room: the mock's 4-way Status row overflows.
      expect(
        segmentedFits(count: 4, widestLabelWidth: 90, available: 340),
        isFalse,
      );
    });

    test('rejects when the per-segment share is under the label floor', () {
      // Total may pass while a single column is still too narrow; the second
      // clause must catch it.
      expect(
        segmentedFits(count: 7, widestLabelWidth: 60, available: 420),
        isFalse,
      );
    });

    test('a wider container turns a rejected case into an accepted one', () {
      // 4 x (90 + 22) + 8 + 12 = 468, so 340 is short and 500 is enough.
      const widest = 90.0;
      expect(
        segmentedFits(count: 4, widestLabelWidth: widest, available: 340),
        isFalse,
      );
      expect(
        segmentedFits(count: 4, widestLabelWidth: widest, available: 500),
        isTrue,
      );
    });
  });

  group('FilterSelectField shape selection', () {
    testWidgets('N <= 4 that fits renders the segmented strip', (tester) async {
      // A 700px surface on purpose: widget tests use a fallback font where each
      // glyph is 1em wide, so "Completed" measures ~108px instead of ~60px and
      // the four segments would not fit a phone-width box in the test
      // environment. The fit rule itself is covered by the segmentedFits group.
      await _pump(
        tester,
        FilterSelectField(
          filter: _select({
            'all': 'All',
            'airing': 'Airing',
            'completed': 'Completed',
            'upcoming': 'Upcoming',
          }),
          selected: const ['completed'],
          onChanged: (_) {},
        ),
        surface: const Size(700, 880),
      );

      // Segments are all on screen at once and no popover field is used.
      expect(find.text('Airing'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('N >= 5 renders a dropdown instead of a strip', (tester) async {
      await _pump(
        tester,
        FilterSelectField(
          filter: _select({
            'size': 'Size',
            'id': 'Id',
            'seeders': 'Seeders',
            'leechers': 'Leechers',
            'downloads': 'Complete Downloads',
            'comments': 'Comments',
          }),
          selected: const [],
          onChanged: (_) {},
        ),
      );

      // The dropdown shows the current value and does not paint every option.
      expect(find.text('common.all'), findsOneWidget);
      expect(find.text('Complete Downloads'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('N >= 5 with long labels also renders a dropdown', (
      tester,
    ) async {
      await _pump(
        tester,
        FilterSelectField(
          filter: _select({
            'a': 'Anime Series',
            'b': 'Live Action',
            'c': 'Documentary',
            'd': 'Music Video',
            'e': 'Short Film',
          }),
          selected: const [],
          onChanged: (_) {},
        ),
      );

      expect(find.text('common.all'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty option map renders nothing', (tester) async {
      await _pump(
        tester,
        FilterSelectField(
          filter: _select(const {}),
          selected: const [],
          onChanged: (_) {},
        ),
      );

      expect(find.byType(FSelect), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a segment reports its key', (tester) async {
      String? picked;
      await _pump(
        tester,
        FilterSelectField(
          filter: _select({
            'all': 'All',
            'airing': 'Airing',
            'completed': 'Completed',
          }),
          selected: const [],
          onChanged: (k) => picked = k,
        ),
      );

      await tester.tap(find.text('Airing'));
      await tester.pumpAndSettle();

      expect(picked, 'airing');
    });

    testWidgets('a narrow container falls back to the dropdown', (
      tester,
    ) async {
      // Same 4 options that fit at 420, forced into 200px: the fit test must
      // switch shape rather than squeeze the labels.
      await _pump(
        tester,
        SizedBox(
          width: 200,
          child: FilterSelectField(
            filter: _select({
              'all': 'All',
              'airing': 'Airing',
              'completed': 'Completed',
              'upcoming': 'Upcoming',
            }),
            selected: const [],
            onChanged: (_) {},
          ),
        ),
      );

      // Segments are gone; the dropdown's "All" reset row is showing.
      expect(find.text('common.all'), findsOneWidget);
      expect(find.text('Upcoming'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('FilterMultiSelectField', () {
    testWidgets('renders pills and hides the count when nothing is selected', (
      tester,
    ) async {
      await _pump(
        tester,
        FilterMultiSelectField(
          options: const [
            ExtensionFilterOptionEntry('action', 'Action'),
            ExtensionFilterOptionEntry('fantasy', 'Fantasy'),
          ],
          selected: const [],
          onToggle: (_) {},
        ),
      );

      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Fantasy'), findsOneWidget);
      expect(find.textContaining('selected_count'), findsNothing);
    });

    testWidgets('marks the selected pills (count lives in the section label '
        'row, not here)', (tester) async {
      await _pump(
        tester,
        FilterMultiSelectField(
          options: const [
            ExtensionFilterOptionEntry('action', 'Action'),
            ExtensionFilterOptionEntry('fantasy', 'Fantasy'),
            ExtensionFilterOptionEntry('adventure', 'Adventure'),
          ],
          selected: const ['fantasy', 'adventure'],
          onToggle: (_) {},
        ),
      );

      // The mock puts "N selected" on the section header; the widget itself
      // only carries selection state on the pills.
      expect(find.textContaining('selected_count'), findsNothing);
      final fantasy = tester.widget<FilterChip>(
        find
            .ancestor(
              of: find.text('Fantasy'),
              matching: find.byType(FilterChip),
            )
            .first,
      );
      expect(fantasy.selected, isTrue);
      final action = tester.widget<FilterChip>(
        find
            .ancestor(
              of: find.text('Action'),
              matching: find.byType(FilterChip),
            )
            .first,
      );
      expect(action.selected, isFalse);
    });

    testWidgets('toggling reports the option key', (tester) async {
      String? toggled;
      await _pump(
        tester,
        FilterMultiSelectField(
          options: const [ExtensionFilterOptionEntry('action', 'Action')],
          selected: const [],
          onToggle: (k) => toggled = k,
        ),
      );

      await tester.tap(find.text('Action'));
      await tester.pumpAndSettle();

      expect(toggled, 'action');
    });
  });
}
