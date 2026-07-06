import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

class MobileFavoriteSearchBar extends HookConsumerWidget {
  const MobileFavoriteSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textValue = useState(const TextEditingValue(text: ''));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FTextField(
          clearable: (value) => value.text.isNotEmpty,
          control: FTextFieldControl.lifted(
            value: textValue.value,
            onChange: (value) {
              textValue.value = value;
              ref
                  .read(favoritePageProvider.notifier)
                  .filterWithKeyword(value.text);
            },
          ),
          prefixBuilder: (context, style, states) {
            return const Padding(
              padding: EdgeInsets.only(left: 12.0, right: 4),
              child: Icon(FLucideIcons.search),
            );
          },
          // suffixBuilder: (context, style, states) {
          //   return FTappable(
          //     onPress: () => isExpanded.value = !isExpanded.value,
          //     child: const Padding(
          //       padding: EdgeInsets.only(left: 4.0, right: 12),
          //       child: Icon(FLucideIcons.slidersHorizontal, size: 16),
          //     ),
          //   );
          // },
          hint: 'favorite.search_hint'.i18n,
          onSubmit: (value) {
            ref.read(favoritePageProvider.notifier).filterWithKeyword(value);
          },
        ),
        // AnimatedSize(
        //   duration: const Duration(milliseconds: 250),
        //   curve: Curves.easeInOut,
        //   child: Column(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       if (isExpanded.value) ...[
        //         const SizedBox(height: 12),
        //         SizedBox(
        //           width: 200,
        //           child: FSelect<String>.rich(
        //             label: Text('common.sort_by'.i18n),
        //             hint: durationLabel,
        //             format: (v) => v,
        //             control: .lifted(
        //               value: durationLabel,
        //               onChange: (newValue) {
        //                 late final Duration duration;
        //                 switch (newValue) {
        //                   case 'All':
        //                     duration = const Duration(days: 36500);
        //                   case 'Day':
        //                     duration = const Duration(days: 1);
        //                   case 'Week':
        //                     duration = const Duration(days: 7);
        //                   case 'Month':
        //                     duration = const Duration(days: 30);
        //                   case 'Year':
        //                     duration = const Duration(days: 365);
        //                   default:
        //                     duration = const Duration(days: 36500);
        //                 }
        //                 ref
        //                     .read(favoritePageProvider.notifier)
        //                     .filterWithDuration(duration);
        //               },
        //             ),
        //             children: const [
        //               FSelectItem(title: Text('All'), value: 'All'),
        //               FSelectItem(title: Text('Day'), value: 'Day'),
        //               FSelectItem(title: Text('Week'), value: 'Week'),
        //               FSelectItem(title: Text('Month'), value: 'Month'),
        //               FSelectItem(title: Text('Year'), value: 'Year'),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
