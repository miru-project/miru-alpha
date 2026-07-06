import 'package:flutter/material.dart';
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
              prefixBuilder: (context, style, states) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 12.0, right: 4),
                      child: Icon(FLucideIcons.search),
                    ),
                    if (state.filterSummary.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FBadge(
                          variant: .secondary,
                          child: Text(
                            state.filterSummary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                );
              },
              hint: 'search.hint'.i18n,
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
