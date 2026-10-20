import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/provider/search/global_search_provider.dart';
import 'package:miru_alpha/provider/search/search_page_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/features/search/mobile_search_results.dart';
import 'package:miru_alpha/ui/features/search/mobile_search_suggest.dart';
import 'package:miru_alpha/ui/features/search/widget/search_field.dart';
import 'package:miru_alpha/ui/features/search/widget/search_page_header.dart';
import 'package:miru_alpha/ui/features/search/widget/search_results_header.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// The search page pushed as `/search/input`.
///
/// Every mobile search bar opens it, so it owns the whole query flow —
/// suggestions and recent searches while typing, aggregated results once the
/// query is submitted — and leaves the `/search` tab with the source list only.
/// Cancel and the system back gesture pop it.
class MobileSearchInputPage extends HookConsumerWidget {
  const MobileSearchInputPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(searchPageProvider.notifier);

    final controller = useTextEditingController(text: initialQuery ?? '');
    final focusNode = useFocusNode();
    final text = useValueListenable(controller).text;
    final focused = useState(false);

    // The query that was actually run. The field's live text deliberately
    // never reaches the provider: it keys every source's fetch, so a keystroke
    // would fan a fresh request per installed extension straight at the origin
    // servers. Only Enter / a suggestion tap submits.
    final submittedQuery = useState('');

    useEffect(() {
      void sync() => focused.value = focusNode.hasFocus;
      focusNode.addListener(sync);
      sync();
      return () => focusNode.removeListener(sync);
    }, [focusNode]);

    // Results stay up while the field holds something; emptying it (the clear
    // X) drops back to the suggestion list without fetching anything.
    final onResults = submittedQuery.value.isNotEmpty && text.trim().isNotEmpty;

    void cancel() {
      submittedQuery.value = '';
      controller.clear();
      focusNode.unfocus();
      if (context.canPop()) context.pop();
    }

    void submit(String value) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      // The field has to keep showing what was submitted: a tap on a
      // suggestion or a recent search writes the same way.
      controller.value = TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
      // A new query is a new list: hand it page one of every source again.
      ref.read(globalSearchPagesProvider.notifier).reset();
      notifier
        ..addHistory(trimmed)
        ..setQuery(trimmed);
      submittedQuery.value = trimmed;
      focusNode.unfocus();
    }

    /// Results → back to the query, so the suggestion list comes back without
    /// leaving the page.
    void backToQuery() {
      submittedQuery.value = '';
      controller.selection = TextSelection.collapsed(offset: text.length);
      focusNode.requestFocus();
    }

    return MiruScaffold.mobile(
      sliverHeaders: [
        searchHeaderSliver(
          context,
          extent: onResults ? 148 : 116,
          child: onResults
              ? SearchResultsHeader(
                  controller: controller,
                  focusNode: focusNode,
                  onSubmit: submit,
                  onBack: backToQuery,
                )
              : SearchPageHeader(
                  title: 'search.global_search'.i18n,
                  field: searchField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    onSubmit: submit,
                  ),
                  trailing: FButton(
                    variant: .ghost,
                    size: .sm,
                    mainAxisSize: .min,
                    onPress: cancel,
                    child: Text('common.cancel'.i18n),
                  ),
                ),
        ),
      ],
      body: onResults
          ? MobileSearchResultsBody(query: submittedQuery.value)
          : MobileSearchSuggest(query: text, onSubmit: submit),
    );
  }
}
