import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/ui/features/search/widget/search_field.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// The Library screen's search bar.
///
/// A plain forui [FTextField]: typing filters History and Favorites in place,
/// and submitting pushes `/search/input`, where suggestions, recents and the
/// History / Favorite cards live. No separate filter button — the filter
/// controls belong to the pages being searched, not to this bar.
class LibrarySearchBar extends HookConsumerWidget {
  const LibrarySearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final focusNode = useFocusNode();
    return searchField(
      controller: controller,
      focusNode: focusNode,
      hint: 'common.search_for_favorites'.i18n,
      onChange: (value) {
        ref.read(historyPageProvider.notifier).filterWithKeyword(value);
        ref.read(favoritePageProvider.notifier).filterWithKeyword(value);
      },
      onSubmit: (value) => _openSearch(context, value),
    );
  }

  /// `/search/input` shows the recents plus the History and Favorite cards for
  /// [query]; submitting an empty field just opens the page.
  void _openSearch(BuildContext context, String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      context.push('/search/input');
    } else {
      context.push('/search/input', extra: trimmed);
    }
  }
}
