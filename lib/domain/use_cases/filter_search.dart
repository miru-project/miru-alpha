import 'package:miru_alpha/domain/models/search.dart';

class FilterSearchUseCase {
  List<dynamic> call({
    required List<dynamic> extensions,
    DomainSearchFilter? filter,
  }) {
    if (filter == null) return extensions;

    var result = extensions;

    if (filter.lang != null && filter.lang!.isNotEmpty) {
      final base = filter.lang!.split(RegExp(r'[-_]')).first;
      result = result.where((e) {
        final extBase = e.lang.split(RegExp(r'[-_]')).first;
        return extBase == base;
      }).toList();
    }

    if (filter.type != null && filter.type != 'all') {
      result = result.where((e) => e.type == filter.type).toList();
    }

    if (filter.installedOnly) {
      // This requires installed packages context; keep as placeholder
      // and pass installed packages from ViewModel when needed.
    }

    if (filter.notInstalledOnly) {
      // Same as above; requires installed packages context.
    }

    return result;
  }
}
