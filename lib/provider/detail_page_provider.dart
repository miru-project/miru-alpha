import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detail_page_provider.g.dart';

class DetailPageProviderState {
  final int epGroupIdx;
  final int epIdx;

  DetailPageProviderState({required this.epGroupIdx, required this.epIdx});
}

@riverpod
class DetailPageProvider extends _$DetailPageProvider {
  @override
  DetailPageProviderState build() {
    return DetailPageProviderState(epGroupIdx: 0, epIdx: 0);
  }
}
