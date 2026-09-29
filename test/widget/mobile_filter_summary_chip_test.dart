import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';
import 'package:miru_alpha/ui/features/search/widget/mobile_filter_summary_chip.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

ExtensionFilter _multiSelectFilter(Map<String, String> options) {
  return ExtensionFilter()
    ..multiSelect = (MultiSelectFilter()
      ..title = 'Genre'
      ..min = 1
      ..max = 8
      ..options.addAll({
        for (final entry in options.entries)
          entry.key: FilterOption()..label = entry.value,
      }));
}

class _FakeSearchPageSingle extends SearchPageSingleProvider {
  _FakeSearchPageSingle(this.filter, this.selectedKeys);

  final ExtensionFilter filter;
  final List<String> selectedKeys;

  @override
  SingleSearchPageState build() => SingleSearchPageState(
    filter: {'genre': filter},
    filterOrder: const ['genre'],
    selected: {'genre': selectedKeys},
  );
}

/// Mirrors the header row of the `/search/single` page: a fixed-width back
/// button, a flexible title, then the filter summary. Overflowing this row is
/// exactly what the summary chip must never do.
Widget _header() {
  return Row(
    children: [
      const SizedBox(width: 52),
      const Expanded(
        child: Text('Nyaa (Go variant)', overflow: TextOverflow.ellipsis),
      ),
      MobileFilterSummaryChip(onTap: () {}),
    ],
  );
}

Future<void> _pumpHeader(
  WidgetTester tester, {
  required List<String> selectedKeys,
  Map<String, String> options = const {
    'action': 'Action',
    'comedy': 'Comedy',
    'drama': 'Drama',
    'fantasy': 'Fantasy',
  },
  Size surface = const Size(382.7, 800),
}) async {
  final container = ProviderContainer(
    overrides: [
      searchPageSingleProviderProvider.overrideWith(
        () => _FakeSearchPageSingle(_multiSelectFilter(options), selectedKeys),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: FTheme(
        data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
        child: MediaQuery(
          data: MediaQueryData(size: surface),
          child: MaterialApp(
            home: Scaffold(body: SizedBox(height: 40, child: _header())),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('summary hides nothing while two or fewer filters are selected', (
    tester,
  ) async {
    await _pumpHeader(tester, selectedKeys: ['action', 'comedy']);

    expect(find.text('Action'), findsOneWidget);
    expect(find.text('Comedy'), findsOneWidget);
    expect(find.textContaining('+'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('summary caps labels and counts the rest as +N', (tester) async {
    await _pumpHeader(
      tester,
      selectedKeys: ['action', 'comedy', 'drama', 'fantasy'],
    );

    expect(find.text('Action'), findsOneWidget);
    expect(find.text('Comedy'), findsOneWidget);
    expect(find.text('+2'), findsOneWidget);
    expect(find.text('Drama'), findsNothing);
    expect(find.text('Fantasy'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('summary keeps long labels inside the header', (tester) async {
    await _pumpHeader(
      tester,
      selectedKeys: ['a', 'b', 'c'],
      options: const {
        'a': 'Unboundedly long option label',
        'b': 'Another very long option label',
        'c': 'Third long option label',
      },
    );

    expect(find.text('+1'), findsOneWidget);
    expect(find.text('Third long option label'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('summary leaves the header title visible', (tester) async {
    await _pumpHeader(
      tester,
      selectedKeys: ['action', 'comedy', 'drama', 'fantasy'],
    );

    expect(
      tester.getSize(find.text('Nyaa (Go variant)')).width,
      greaterThan(0),
    );
  });
}
