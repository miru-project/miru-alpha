import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detail_page_provider.g.dart';

class DetailPageProviderState {
  final int epGroupIdx;
  final int epIdx;

  DetailPageProviderState({required this.epGroupIdx, required this.epIdx});
  DetailPageProviderState copyWith({int? epGroupIdx, int? epIdx}) {
    return DetailPageProviderState(
      epGroupIdx: epGroupIdx ?? this.epGroupIdx,
      epIdx: epIdx ?? this.epIdx,
    );
  }
}

@riverpod
class DetailPageProvider extends _$DetailPageProvider {
  @override
  DetailPageProviderState build() {
    return DetailPageProviderState(epGroupIdx: 0, epIdx: 0);
  }

  void setEpGroup(int idx) {
    state = state.copyWith(epGroupIdx: idx);
  }
}
