import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';
import 'package:miru_alpha/ui/features/search/widget/mobile_filter_slivers.dart';

/// Mobile inline filter list.
///
/// Thin wrapper over [MobileFilterSliverBody] with immediate commit: every
/// chip/range edit applies to the results at once. Owns its scroll (sticky
/// [SliverPersistentHeader] sections, max 3 pinned), so it needs a bounded
/// height ancestor.
class MobileSearchFilterBar extends ConsumerWidget {
  const MobileSearchFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchPageSingleProviderProvider);
    if (state.filter.isEmpty) return const SizedBox.shrink();
    return const MobileFilterSliverBody(autoCommit: true);
  }
}
