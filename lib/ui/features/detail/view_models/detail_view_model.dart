import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miru_alpha/data/repositories/detail_repository.dart';
import 'package:miru_alpha/data/services/detail_service.dart';
import 'package:miru_alpha/domain/models/detail.dart';

part 'detail_view_model.g.dart';

@riverpod
class DetailViewModel extends _$DetailViewModel {
  @override
  Future<DomainDetail?> build(String package, String detailUrl) async {
    final repository = DetailRepository(DetailService());
    try {
      return await repository.getDetail(package, detailUrl);
    } catch (e) {
      return null;
    }
  }

  Future<void> refresh() async {
    final package = state.value?.package;
    final detailUrl = state.value?.detailUrl;
    if (package == null || detailUrl == null) return;

    final repository = DetailRepository(DetailService());
    final detail = await repository.getDetail(package, detailUrl);
    state = AsyncValue.data(detail);
  }
}
