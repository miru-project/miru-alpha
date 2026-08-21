import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

class DesktopFavoriteSearchBar extends HookConsumerWidget {
  const DesktopFavoriteSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritePageProvider);
    final searchQuery = useState(state.query);

    return SizedBox(
      height: 60,
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: FTextField(
              clearable: (value) => value.text.isNotEmpty,
              control: FTextFieldControl.managed(
                onChange: (value) {
                  searchQuery.value = value.text;
                  ref
                      .read(favoritePageProvider.notifier)
                      .filterWithKeyword(value.text);
                },
                initial: TextEditingValue(text: state.query),
              ),
              hint: 'common.search_for_favorites'.i18n,
              onSubmit: (value) {
                ref
                    .read(favoritePageProvider.notifier)
                    .filterWithKeyword(value);
              },
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
