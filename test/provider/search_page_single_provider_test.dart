import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart' as proto;
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';

/// Helper to build an ExtensionFilter (select variant) with a plain Map for options.
ExtensionFilter mkFilter(String title, String def, Map<String, String> opts) {
  final f = ExtensionFilter();
  f.select = (SelectFilter()
    ..title = title
    ..default_2 = def
    ..options.addAll(
      opts.map((k, v) => MapEntry(k, FilterOption()..label = v)),
    ));
  return f;
}

void main() {
  group('SingleSearchPageState filter selection - proto round-trip', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('filterSelection is empty when no filters are set', () {
      final state = container.read(searchPageSingleProviderProvider);
      expect(state.filterSelection.selections, isEmpty);
    });

    test(
      'filterSelection maps selected option keys to proto.FilterSelectionValue',
      () {
        final notifier = container.read(
          searchPageSingleProviderProvider.notifier,
        );

        notifier.setFileNotifier({
          'type': mkFilter('Type', 'all', {
            'all': 'All',
            'manga': 'Manga',
            'bangumi': 'Bangumi',
          }),
          'language': mkFilter('Language', 'en', {
            'en': 'English',
            'ja': '日本語',
          }),
        });

        notifier.setSelected({
          'type': ['manga'],
          'language': ['ja'],
        });

        final sel = notifier.state.filterSelection;
        expect(sel.selections, isNotNull);
        expect(sel.selections.containsKey('type'), isTrue);
        expect(sel.selections.containsKey('language'), isTrue);
        expect(sel.selections['type']!.values, ['manga']);
        expect(sel.selections['language']!.values, ['ja']);
      },
    );

    test('appliedFilter is copied from filterSelection on commit', () {
      final notifier = container.read(
        searchPageSingleProviderProvider.notifier,
      );

      notifier.setFileNotifier({
        'quality': mkFilter('Quality', '1080p', {
          '1080p': '1080p',
          '720p': '720p',
        }),
      });
      notifier.setSelected({
        'quality': ['720p'],
      });
      notifier.commitFilters();

      final applied = notifier.state.appliedFilter;
      expect(applied, isNotNull);
      expect(applied!.selections.length, 1);
      expect(applied.selections['quality']!.values, ['720p']);
    });

    test('filterSelection excludes empty selections', () {
      final notifier = container.read(
        searchPageSingleProviderProvider.notifier,
      );

      notifier.setFileNotifier({
        'genre': mkFilter('Genre', '', {
          'action': 'Action',
          'comedy': 'Comedy',
        }),
      });

      final sel = notifier.state.filterSelection;
      expect(sel.selections.containsKey('genre'), isFalse);
    });

    test('applied filter copyWith round-trips', () {
      final state = SingleSearchPageState();
      final sel = proto.FilterSelection();
      sel.selections['type'] = (proto.FilterSelectionValue()
        ..values.add('manga'));

      final updated = state.copyWith(page: 2, appliedFilter: sel);
      expect(updated.appliedFilter, isNotNull);
      expect(updated.appliedFilter!.selections.length, 1);
      expect(updated.appliedFilter!.selections['type']!.values, ['manga']);
      expect(updated.page, 2);
    });
  });
}
