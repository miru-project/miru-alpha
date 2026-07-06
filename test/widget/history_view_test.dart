import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/ui/features/history/view_models/history_view_model.dart';
import 'package:miru_alpha/domain/models/history.dart';

class _FakeHistoryViewModel extends HistoryViewModel {
  _FakeHistoryViewModel(this._items);
  final List<DomainHistoryItem> _items;

  @override
  Future<List<DomainHistoryItem>> build() => Future.value(_items);
}

void main() {
  test('HistoryViewModel returns history items', () async {
    final historyItems = [
      DomainHistoryItem(
        id: '1',
        title: 'Test Title',
        package: 'test.package',
        progress: 0.5,
        cover: '',
        detailUrl: '',
        episodeIndex: 0,
        watchedDuration: 0,
        totalDuration: 0,
        watchedAt: DateTime.now(),
      ),
    ];

    final container = ProviderContainer(
      overrides: [
        historyViewModelProvider.overrideWith(() => _FakeHistoryViewModel(historyItems)),
      ],
    );

    addTearDown(container.dispose);

    final viewModel = container.read(historyViewModelProvider.notifier);
    final result = await viewModel.build();

    expect(result.length, 1);
    expect(result.first.title, 'Test Title');
    expect(result.first.package, 'test.package');
  });
}

