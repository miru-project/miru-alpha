import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart' hide FilterChip;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_dialog_panel.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_text_tile.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

ExtensionFilter _select(Map<String, String> options, {String def = ''}) =>
    ExtensionFilter()
      ..select = (SelectFilter()
        ..title = 'Status'
        ..default_2 = def
        ..options.addAll({
          for (final e in options.entries)
            e.key: (FilterOption()..label = e.value),
        }));

ExtensionFilter _multi(
  Map<String, String> options, {
  List<String> def = const [],
}) => ExtensionFilter()
  ..multiSelect = (MultiSelectFilter()
    ..title = 'Genres'
    ..min = 1
    ..max = 8
    ..default_4.addAll(def)
    ..options.addAll({
      for (final e in options.entries) e.key: (FilterOption()..label = e.value),
    }));

ExtensionFilter _text({String def = ''}) =>
    ExtensionFilter()
      ..text = (TextFilter()
        ..title = 'Uploader'
        ..default_2 = def
        ..hint = 'e.g. subsplease');

ExtensionFilter _range() => ExtensionFilter()
  ..range = (RangeFilter()
    ..title = 'Year'
    ..min = 1990
    ..max = 2025
    ..defaultMin = 2000
    ..defaultMax = 2025);

class _Fake extends SearchPageSingleProvider {
  _Fake(this.filters, [this.selected = const {}]);

  final Map<String, ExtensionFilter> filters;
  final Map<String, List<String>> selected;

  @override
  SingleSearchPageState build() => SingleSearchPageState(
    filter: filters,
    filterOrder: filters.keys.toList(),
    selected: selected,
  );
}

ProviderContainer _container({
  required Map<String, ExtensionFilter> filters,
  Map<String, List<String>> selected = const {},
}) {
  final c = ProviderContainer(
    overrides: [
      searchPageSingleProviderProvider.overrideWith(
        () => _Fake(filters, selected),
      ),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

Future<void> _pumpPanel(
  WidgetTester tester, {
  required ProviderContainer container,
  Size surface = const Size(420, 880),
  bool staging = false,
}) async {
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  // Staging is the DIALOG's policy — `SearchFilterDialog.initState` calls
  // `beginFilterStaging()`. Tests that drive the panel bare (no dialog around
  // it) leave it off, which is the surface the desktop overlay also uses.
  if (staging) {
    container
        .read(searchPageSingleProviderProvider.notifier)
        .beginFilterStaging();
  }
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: FTheme(
        data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
        child: MaterialApp(home: Scaffold(body: ExtensionFilterPanel())),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ExtensionFilterPanel — flat mock sections', () {
    testWidgets('renders every variant as a labelled section, no accordion', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        container: _container(
          filters: {
            'type': _select({
              'all': 'All',
              'airing': 'Airing',
              'completed': 'Completed',
              'upcoming': 'Upcoming',
            }),
            'genre': _multi({'action': 'Action', 'fantasy': 'Fantasy'}),
            'uploader': _text(),
            'year': _range(),
          },
        ),
      );

      // Mock: flat sections with UPPERCASE headers, one control under each —
      // the old accordion/pin structure is gone from the dialog.
      expect(find.byType(FAccordion), findsNothing);
      expect(find.text('STATUS'), findsOneWidget);
      expect(find.text('GENRES'), findsOneWidget);
      expect(find.text('UPLOADER'), findsOneWidget);
      expect(find.text('YEAR'), findsOneWidget);
      expect(find.byType(FilterTextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty catalogue shows the no-filter message', (
      tester,
    ) async {
      await _pumpPanel(tester, container: _container(filters: {}));

      // i18n is not mounted in widget tests, so the raw key renders.
      expect(find.text('extension.no_filter'), findsOneWidget);
      expect(find.byType(FAccordion), findsNothing);
    });

    testWidgets('text filter name appears exactly once (section label + field '
        'without its own label)', (tester) async {
      await _pumpPanel(
        tester,
        container: _container(filters: {'uploader': _text()}),
      );

      // rules.md #23: exactly one widget renders each info line.
      expect(find.text('UPLOADER'), findsOneWidget);
      expect(find.text('Uploader'), findsNothing);
    });

    testWidgets('multi-select count sits on the section label row', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        container: _container(
          filters: {
            'genre': _multi({'action': 'Action', 'fantasy': 'Fantasy'}),
          },
          selected: {
            'genre': ['fantasy'],
          },
        ),
      );

      // Mock: `Genres & Tags ... 2 selected` on the header row.
      expect(find.text('search.selected_count'), findsOneWidget);
      expect(find.text('GENRES'), findsOneWidget);
    });

    testWidgets('count hides when the selection is cleared', (tester) async {
      await _pumpPanel(
        tester,
        container: _container(
          filters: {
            'genre': _multi({'action': 'Action'}),
          },
        ),
      );

      expect(find.textContaining('selected_count'), findsNothing);
    });
  });

  group(
    'ExtensionFilterPanel — staged edits (fetch on leaving the dialog)',
    () {
      testWidgets('toggling a chip stages it without committing', (
        tester,
      ) async {
        final c = _container(
          filters: {
            'genre': _multi({'action': 'Action', 'fantasy': 'Fantasy'}),
          },
        );
        await _pumpPanel(tester, container: c, staging: true);

        await tester.tap(find.text('Action'));
        await tester.pumpAndSettle();

        // Draft only: the selection is live, `appliedFilter` is not — nothing
        // fetched while the dialog is open.
        final state = c.read(searchPageSingleProviderProvider);
        expect(state.selected['genre'], ['action']);
        expect(state.appliedFilter?.selections['genre']?.values, isNull);
      });

      testWidgets('picking a dropdown option stages it without committing', (
        tester,
      ) async {
        final c = _container(
          filters: {
            'sort': _select({
              'size': 'Size',
              'id': 'Id',
              'seeders': 'Seeders',
              'leechers': 'Leechers',
              'downloads': 'Downloads',
            }),
          },
        );
        await _pumpPanel(
          tester,
          container: c,
          surface: const Size(700, 880),
          staging: true,
        );

        // N >= 5 -> dropdown: only the current value is painted, not the list.
        expect(find.text('common.all'), findsOneWidget);
        await tester.tap(find.text('common.all'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Seeders'));
        await tester.pumpAndSettle();

        final state = c.read(searchPageSingleProviderProvider);
        expect(state.selected['sort'], ['seeders']);
        expect(state.appliedFilter?.selections['sort']?.values, isNull);
      });

      testWidgets('a 2-option select renders the switch row and stages', (
        tester,
      ) async {
        final c = _container(
          filters: {
            'sub': _select({'off': 'No Subs', 'on': 'Subs Only'}, def: 'off'),
          },
          selected: {
            'sub': ['off'],
          },
        );
        await _pumpPanel(tester, container: c, staging: true);

        expect(find.byType(FSwitch), findsOneWidget);
        // description reads `off / on` in stable order.
        expect(find.text('No Subs / Subs Only'), findsOneWidget);

        await tester.tap(find.byType(FSwitch));
        await tester.pumpAndSettle();

        final state = c.read(searchPageSingleProviderProvider);
        expect(state.selected['sub'], ['on']);
        expect(state.appliedFilter?.selections['sub']?.values, isNull);
      });

      testWidgets('text committed through the field is staged, not applied', (
        tester,
      ) async {
        final c = _container(filters: {'uploader': _text()});
        await _pumpPanel(tester, container: c, staging: true);

        await tester.enterText(find.byType(FTextField), 'subsplease');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        final state = c.read(searchPageSingleProviderProvider);
        expect(state.selected['uploader'], ['subsplease']);
        expect(state.appliedFilter?.selections['uploader']?.values, isNull);
      });

      testWidgets('applyFilters publishes the whole draft in one go', (
        tester,
      ) async {
        final c = _container(
          filters: {
            'genre': _multi({'action': 'Action', 'fantasy': 'Fantasy'}),
            'sub': _select({'off': 'No Subs', 'on': 'Subs Only'}, def: 'off'),
          },
          selected: {
            'sub': ['off'],
          },
        );
        await _pumpPanel(tester, container: c, staging: true);

        // Three edits while the dialog is open…
        await tester.tap(find.text('Action'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Fantasy'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(FSwitch));
        await tester.pumpAndSettle();

        // …one commit when it is left.
        await c.read(searchPageSingleProviderProvider.notifier).applyFilters();
        await tester.pumpAndSettle();

        final state = c.read(searchPageSingleProviderProvider);
        expect(state.appliedFilter?.selections['genre']?.values, [
          'action',
          'fantasy',
        ]);
        expect(state.appliedFilter?.selections['sub']?.values, ['on']);
      });

      testWidgets('non-staged callers (desktop overlay) still commit at once', (
        tester,
      ) async {
        // Staging is the DIALOG's policy, not the notifier's: with it off, a
        // mutation publishes immediately, so the overlay's controls behave as
        // before.
        final c = _container(
          filters: {
            'genre': _multi({'action': 'Action', 'fantasy': 'Fantasy'}),
          },
        );
        await _pumpPanel(tester, container: c);

        await tester.tap(find.text('Action'));
        await tester.pumpAndSettle();

        final state = c.read(searchPageSingleProviderProvider);
        expect(state.appliedFilter?.selections['genre']?.values, ['action']);
      });
    },
  );

  group('ExtensionFilterPanel — 2-column dropdown pairing (rules §3)', () {
    Future<Offset> labelOf(WidgetTester tester, String label) async =>
        tester.getTopLeft(find.text(label));

    // Long labels so the pair decision is exercised from both sides:
    // (width - 10) / 2 >= widest + 32.
    Map<String, ExtensionFilter> twoLongDropdowns() => {
      'format': ExtensionFilter()
        ..select = (SelectFilter()
          ..title = 'Format'
          ..options.addAll({
            for (final k in ['tv', 'movie', 'ova', 'ona', 'special'])
              k: (FilterOption()..label = 'Feature Length'),
          })),
      'sort': ExtensionFilter()
        ..select = (SelectFilter()
          ..title = 'Sort'
          ..options.addAll({
            for (final k in ['a', 'b', 'c', 'd', 'e'])
              k: (FilterOption()..label = 'Download Popularity'),
          })),
    };

    testWidgets('wide panel puts two dropdown sections side by side', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        container: _container(filters: twoLongDropdowns()),
        surface: const Size(760, 880),
      );

      final format = await labelOf(tester, 'FORMAT');
      final sort = await labelOf(tester, 'SORT');
      // Same row => equal y.
      expect((format.dy - sort.dy).abs(), lessThan(2));
      expect(format.dx, lessThan(sort.dx));
    });

    testWidgets('narrow panel stacks them one per row', (tester) async {
      await _pumpPanel(
        tester,
        container: _container(filters: twoLongDropdowns()),
        surface: const Size(340, 880),
      );

      final format = await labelOf(tester, 'FORMAT');
      final sort = await labelOf(tester, 'SORT');
      // Stacked => clearly different y.
      expect(sort.dy - format.dy, greaterThan(40));
    });
  });
}
