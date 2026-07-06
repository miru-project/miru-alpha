import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/ui/features/search/view_models/search_view_model.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/ui/core/loading_state.dart';
import 'package:miru_alpha/ui/core/error_state.dart';
import 'package:miru_alpha/ui/features/search/search_page.dart';

class SearchView extends HookConsumerWidget {
  const SearchView({super.key, this.query});

  final String? query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(searchViewModelProvider);
    final searchQuery = useState(query ?? '');

    return viewModelAsync.when(
      loading: () => const LoadingState(),
      error: (error, stack) => ErrorState(
        message: 'search.load_failed'.i18n,
        child: Text(error.toString(), textAlign: TextAlign.center),
      ),
      data: (state) {
        return DeviceUtil.deviceWidget(
          context: context,
          mobile: _SearchViewMobile(query: searchQuery.value),
          desktop: _SearchViewDesktop(query: searchQuery.value),
        );
      },
    );
  }
}

class _SearchViewMobile extends HookConsumerWidget {
  const _SearchViewMobile({this.query});

  final String? query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = useState(query ?? '');
    final notifier = ref.read(searchViewModelProvider.notifier);

    useEffect(() {
      final q = query;
      if (q == null || q.isEmpty) {
        return null;
      }
      notifier.search(q);
      return null;
    }, [query]);

    return SearchPage(search: searchQuery.value);
  }
}

class _SearchViewDesktop extends HookConsumerWidget {
  const _SearchViewDesktop({this.query});

  final String? query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = useState(query ?? '');
    final notifier = ref.read(searchViewModelProvider.notifier);

    useEffect(() {
      final q = query;
      if (q == null || q.isEmpty) {
        return null;
      }
      notifier.search(q);
      return null;
    }, [query]);

    return SearchPage(search: searchQuery.value);
  }
}
