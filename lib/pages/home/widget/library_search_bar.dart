import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

class LibrarySearchBar extends HookConsumerWidget {
  const LibrarySearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = useState('');
    return Row(
      children: [
        Expanded(
          child: FTextField(
            control: FTextFieldControl.managed(
              onChange: (value) {
                input.value = value.text;
                ref
                    .read(historyPageProvider.notifier)
                    .filterWithKeyword(input.value);
                ref
                    .read(favoritePageProvider.notifier)
                    .filterWithKeyword(input.value);
              },
            ),
            clearable: (value) => value.text.isNotEmpty,
            prefixBuilder: (context, style, states) => Padding(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: Icon(
                FLucideIcons.search,
                size: 18,
                color: context.theme.colors.mutedForeground,
              ),
            ),
            suffixBuilder: (context, style, variants) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FButton.icon(
                    variant: .ghost,
                    onPress: () {},
                    child: Icon(
                      FLucideIcons.puzzle,
                      size: 18,
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                ],
              );
            },
            hint: 'common.search_for_favorites'.i18n,
          ),
        ),
        const SizedBox(width: 8),
        FButton.icon(
          variant: .outline,
          onPress: () {},
          child: Icon(
            FLucideIcons.listFilter,
            size: 18,
            color: context.theme.colors.foreground,
          ),
        ),
      ],
    );
  }
}
