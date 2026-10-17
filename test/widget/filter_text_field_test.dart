import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';
import 'package:miru_alpha/ui/features/search/extension_filter_view.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_text_tile.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_dialog.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

ExtensionFilter _textFilter({
  String title = 'Author',
  String def = '',
  String hint = '',
}) {
  return ExtensionFilter()
    ..text = (TextFilter()
      ..title = title
      ..default_2 = def
      ..hint = hint);
}

ExtensionFilter _selectFilter() => ExtensionFilter()
  ..select = (SelectFilter()
    ..title = 'Type'
    ..options.addAll({
      'all': FilterOption()..label = 'All',
      'manga': FilterOption()..label = 'Manga',
    }));

/// A provider whose catalogue is exactly the given filters, so the widget and
/// the notifier can be exercised without a live extension.
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
  Map<String, ExtensionFilter> filters = const {},
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

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ProviderContainer? container,
  Size surface = const Size(420, 880),
}) async {
  final c = container ?? _container();
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: FTheme(
        data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
        child: MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ExtensionFilterView text variant', () {
    test('collapses a TextFilter into the normalized view', () {
      final view = ExtensionFilterView.from(
        _textFilter(title: 'Author', def: 'Fujimoto', hint: 'e.g. Fujimoto'),
      );

      expect(view.kind, ExtensionFilter_Kind.text);
      expect(view.isText, isTrue);
      expect(view.title, 'Author');
      expect(view.hint, 'e.g. Fujimoto');
      expect(view.options, isEmpty);
      // A text filter is single-valued.
      expect(view.min, 1);
      expect(view.max, 1);
      expect(view.defaultSelect, 'Fujimoto');
    });

    test('isText is false for every other variant', () {
      final select = ExtensionFilterView.from(
        ExtensionFilter()
          ..select = (SelectFilter()
            ..title = 'Type'
            ..options.addAll({'a': FilterOption()..label = 'A'})),
      );
      final multi = ExtensionFilterView.from(
        ExtensionFilter()
          ..multiSelect = (MultiSelectFilter()
            ..title = 'Genre'
            ..min = 1
            ..max = 3
            ..options.addAll({'a': FilterOption()..label = 'A'})),
      );
      final range = ExtensionFilterView.from(
        ExtensionFilter()
          ..range = (RangeFilter()
            ..title = 'Year'
            ..min = 1990
            ..max = 2025),
      );

      expect(select.isText, isFalse);
      expect(multi.isText, isFalse);
      expect(range.isText, isFalse);
    });
  });

  group('provider text-filter handling', () {
    test('setTextFilter stores the typed value as one selection', () {
      final c = _container(filters: {'author': _textFilter()});

      c
          .read(searchPageSingleProviderProvider.notifier)
          .setTextFilter('author', 'Fujimoto');

      expect(c.read(searchPageSingleProviderProvider).selected['author'], [
        'Fujimoto',
      ]);
    });

    test('setTextFilter trims surrounding whitespace', () {
      final c = _container(filters: {'author': _textFilter()});

      c
          .read(searchPageSingleProviderProvider.notifier)
          .setTextFilter('author', '  Fujimoto  ');

      expect(c.read(searchPageSingleProviderProvider).selected['author'], [
        'Fujimoto',
      ]);
    });

    test('setTextFilter clears on an empty value (empty is a real state)', () {
      final c = _container(filters: {'author': _textFilter()});

      final notifier = c.read(searchPageSingleProviderProvider.notifier);
      notifier.setTextFilter('author', 'Fujimoto');
      notifier.setTextFilter('author', '');

      expect(
        c.read(searchPageSingleProviderProvider).selected['author'],
        isEmpty,
      );
    });

    test('an empty text selection is not sent to the extension', () {
      final c = _container(filters: {'author': _textFilter()});

      c
          .read(searchPageSingleProviderProvider.notifier)
          .setTextFilter('author', '   ');

      // _updateFilters skips empty rows, so the extension keeps that filter
      // untouched instead of receiving a blank value.
      expect(
        c.read(searchPageSingleProviderProvider).filterSelection.selections,
        isEmpty,
      );
    });

    test('setTextFilter ignores a key that is not a text filter', () {
      final c = _container(filters: {'type': _selectFilter()});

      c
          .read(searchPageSingleProviderProvider.notifier)
          .setTextFilter('type', 'oops');

      expect(c.read(searchPageSingleProviderProvider).selected['type'], isNull);
    });

    test('the extension-declared default seeds the selection', () {
      final c = _container(filters: {'author': _textFilter(def: 'Fujimoto')});

      c.read(searchPageSingleProviderProvider.notifier).setFileNotifier({
        'author': _textFilter(def: 'Fujimoto'),
      });

      expect(c.read(searchPageSingleProviderProvider).selected['author'], [
        'Fujimoto',
      ]);
    });

    test('filterSummary shows the raw text value, not an option label', () {
      final c = _container(filters: {'author': _textFilter()});

      c
          .read(searchPageSingleProviderProvider.notifier)
          .setTextFilter('author', 'Fujimoto');

      // A text filter has no options map to translate through; if the summary
      // looked the value up in labelByKey it would silently drop it.
      expect(c.read(searchPageSingleProviderProvider).filterSummary, [
        'Fujimoto',
      ]);
    });
  });

  group('FilterTextField', () {
    testWidgets('is an inline field, not a popup trigger', (tester) async {
      await _pump(
        tester,
        FilterTextField(
          filter: _textFilter(title: 'Author').text,
          value: '',
          onChanged: (_) {},
        ),
      );

      // Inline: the field is present immediately, with no tap needed. A
      // popup-based design reported 0 interactive elements to marionette while
      // open, which made the surface unverifiable live.
      expect(find.byType(FTextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('labels the field with the filter title', (tester) async {
      await _pump(
        tester,
        FilterTextField(
          filter: _textFilter(title: 'Author').text,
          value: '',
          onChanged: (_) {},
        ),
      );

      expect(find.text('Author'), findsOneWidget);
    });

    testWidgets('shows the hint as the placeholder', (tester) async {
      await _pump(
        tester,
        FilterTextField(
          filter: _textFilter(hint: 'e.g. Fujimoto').text,
          value: '',
          onChanged: (_) {},
        ),
      );

      expect(find.text('e.g. Fujimoto'), findsOneWidget);
    });

    testWidgets('falls back to a generic placeholder without a hint', (
      tester,
    ) async {
      await _pump(
        tester,
        FilterTextField(
          filter: _textFilter().text,
          value: '',
          onChanged: (_) {},
        ),
      );

      expect(find.text('common.type_a_value'), findsOneWidget);
    });

    testWidgets('seeds the field with the applied value', (tester) async {
      await _pump(
        tester,
        FilterTextField(
          filter: _textFilter().text,
          value: 'Fujimoto',
          onChanged: (_) {},
        ),
      );

      expect(find.text('Fujimoto'), findsOneWidget);
    });

    testWidgets('submitting reports the typed value', (tester) async {
      String? reported;
      await _pump(
        tester,
        FilterTextField(
          filter: _textFilter(title: 'Author').text,
          value: '',
          onChanged: (v) => reported = v,
        ),
      );

      await tester.enterText(find.byType(FTextField), 'Fujimoto');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(reported, 'Fujimoto');
    });

    testWidgets('losing focus commits, so an edit is never silently dropped', (
      tester,
    ) async {
      String? reported;
      await _pump(
        tester,
        FilterTextField(
          filter: _textFilter(title: 'Author').text,
          value: '',
          onChanged: (v) => reported = v,
        ),
      );

      await tester.enterText(find.byType(FTextField), 'Fujimoto');
      // No submit: move focus away instead.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      expect(reported, 'Fujimoto');
    });

    testWidgets('trims on commit', (tester) async {
      String? reported;
      await _pump(
        tester,
        FilterTextField(
          filter: _textFilter(title: 'Author').text,
          value: '',
          onChanged: (v) => reported = v,
        ),
      );

      await tester.enterText(find.byType(FTextField), '  Fujimoto  ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(reported, 'Fujimoto');
    });

    testWidgets('does not re-report an unchanged value', (tester) async {
      var calls = 0;
      await _pump(
        tester,
        FilterTextField(
          filter: _textFilter(title: 'Author').text,
          value: 'Fujimoto',
          onChanged: (_) => calls++,
        ),
      );

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(calls, 0);
    });

    testWidgets('an external value change reaches the field', (tester) async {
      final c = _container(filters: {'author': _textFilter()});
      await _pump(
        tester,
        FilterTextField(
          filter: _textFilter().text,
          value: '',
          onChanged: (_) {},
        ),
        container: c,
      );

      // Simulate Clear / reset-to-default arriving from the provider.
      await _pump(
        tester,
        FilterTextField(
          filter: _textFilter().text,
          value: 'Fujimoto',
          onChanged: (_) {},
        ),
        container: c,
      );

      expect(find.text('Fujimoto'), findsOneWidget);
    });
  });

  group('text filter inside the filter body', () {
    testWidgets('renders as a field, not an empty chip row', (tester) async {
      await _pump(
        tester,
        const ExtensionFilterBody(),
        container: _container(filters: {'author': _textFilter()}),
      );

      // The regression this guards: before the text case was handled
      // explicitly, an unknown variant fell through to the multi-select Wrap
      // and rendered as an empty chip row — a filter with no way to set it.
      expect(find.byType(FilterTextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sits beside the other variants', (tester) async {
      await _pump(
        tester,
        const ExtensionFilterBody(),
        container: _container(
          filters: {'type': _selectFilter(), 'author': _textFilter()},
        ),
      );

      expect(find.byType(FilterTextField), findsOneWidget);
      // A 2-option select is a boolean in disguise (rules §2): it renders as
      // the switch row, not as chips or a strip — both option labels show as
      // its `off / on` description.
      expect(find.text('All / Manga'), findsOneWidget);
      expect(find.byType(FSwitch), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('typing reaches the provider and the header badge', (
      tester,
    ) async {
      final c = _container(filters: {'author': _textFilter()});
      await _pump(tester, const ExtensionFilterBody(), container: c);

      await tester.enterText(find.byType(FTextField), 'Fujimoto');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(c.read(searchPageSingleProviderProvider).selected['author'], [
        'Fujimoto',
      ]);
      // One selection -> the count badge next to the title reads 1.
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('clearing removes it from the badge', (tester) async {
      final c = _container(
        filters: {'author': _textFilter()},
        selected: {
          'author': ['Fujimoto'],
        },
      );
      await _pump(tester, const ExtensionFilterBody(), container: c);

      await tester.enterText(find.byType(FTextField), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(
        c.read(searchPageSingleProviderProvider).selected['author'],
        isEmpty,
      );
      expect(find.text('1'), findsNothing);
    });
  });
}
