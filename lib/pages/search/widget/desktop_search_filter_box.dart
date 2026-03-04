import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/network_provider.dart';
import 'package:miru_app_new/provider/search_page_single_provider.dart';
import 'package:miru_app_new/widgets/core/search_filter_card.dart';

class DesktopSearchSingleFilterBox extends HookConsumerWidget {
  const DesktopSearchSingleFilterBox({super.key, required this.meta});
  final ExtensionMeta meta;
  void refresh(WidgetRef ref) {
    ref.invalidate(fetchExtensionSearchLatestProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchPageSingleProviderProvider);
    final searchQuery = useState(state.query);
    return SizedBox(
      height: 75,
      child: SearchFilterCard(
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: FTextField(
                clearable: (value) => value.text.isNotEmpty,
                control: .managed(
                  onChange: (value) {
                    searchQuery.value = value.text;
                  },
                  initial: TextEditingValue(text: state.query),
                ),
                prefixBuilder: (context, style, states) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 4),
                    child: Icon(FIcons.search),
                  );
                },
                hint: 'Search ',
                onSubmit: (value) {
                  ref.invalidate(
                    fetchExtensionSearchLatestProvider.call(
                      meta.packageName,
                      1,
                      query: value,
                    ),
                  );
                  ref
                      .read(searchPageSingleProviderProvider.notifier)
                      .setQuery(value);
                },
              ),
            ),
            SizedBox(width: 8),
            FButton.icon(
              variant: .secondary,
              onPress: () {
                ref.invalidate(
                  fetchExtensionSearchLatestProvider.call(
                    meta.packageName,
                    1,
                    query: searchQuery.value,
                  ),
                );
                ref
                    .read(searchPageSingleProviderProvider.notifier)
                    .setQuery(searchQuery.value);
              },
              child: Icon(FIcons.refreshCcw),
            ),
          ],
        ),
      ),
    );
  }
}
