import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/features/search/mobile_search_landing.dart';
import 'package:miru_alpha/ui/features/search/widget/search_field.dart';
import 'package:miru_alpha/ui/features/search/widget/search_filter_controls.dart';
import 'package:miru_alpha/ui/features/search/widget/search_page_header.dart';

/// Bottom-nav `/search` tab.
///
/// It only lists the configured sources; the field is a tap target that pushes
/// `/search/input`, which owns suggestions, recents and results. Keeping the
/// two apart is what stops the tab from becoming a second search screen.
///
/// Its header is three slivers: the big title (which collapses away on scroll,
/// the way the extension page's title does), the field (pinned) and the label +
/// pill filter bar (pinned). The caption, the cards and the Edit Filters action
/// scroll underneath in [MobileSearchLanding].
class MobileSearchPage extends HookConsumerWidget {
  const MobileSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final scrollPosition = useValueNotifier(0.0);

    return MiruScaffold.mobile(
      scrollController: scrollController,
      scrollThrottle: ScrollUpdateThrottle.low,
      onScrollChange: (offset, _) => scrollPosition.value = offset,
      sliverHeaders: [
        // Shrinks to nothing on scroll, exactly like the extension page's
        // title bar: the field below it is what has to stay reachable.
        FlexibleHeaderDelegate(
          scrollPosition: scrollPosition,
          maxExtent: kSearchTitleExtent,
          minExtent: 0,
          builder: (context, shrinkOffset, shrinkProgress) =>
              const SearchPageTitle(),
        ),
        searchHeaderSliver(
          context,
          extent: kSearchFieldExtent,
          child: SearchFieldRow(
            field: SearchFieldStub(onTap: () => context.push('/search/input')),
          ),
        ),
        searchHeaderSliver(
          context,
          extent: searchSourceFilterBarExtent(context),
          child: const SearchSourceFilterBar(),
        ),
      ],
      // Slivers, not `body`: one scroll context is what makes the title above
      // collapse while the cards move (a nested ListView would swallow the
      // gesture and leave the header stuck).
      slivers: mobileSearchSourceSlivers(context, ref),
    );
  }
}
