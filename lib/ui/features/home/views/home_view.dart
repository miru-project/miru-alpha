import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/ui/core/scaffold/custom_silver_header.dart';
import 'package:miru_alpha/ui/core/scaffold/miru_scaffold.dart';
import 'package:miru_alpha/ui/core/scaffold/snapsheet_header.dart';
import 'package:miru_alpha/ui/features/home/widget/continue_watch.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_dashboard_view.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_top_bar.dart';
import 'package:miru_alpha/ui/features/home/widget/favorite.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key, this.navigationShell});

  final StatefulNavigationShell? navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DeviceUtil.deviceWidget(
      mobile: const HomeViewMobile(),
      desktop: const HomeViewDesktop(),
      context: context,
    );
  }
}

/// Mobile home: bento dashboard under a pinned brand bar, sharing one scroll
/// context so the bar stays while the sections scroll beneath it.
class HomeViewMobile extends ConsumerWidget {
  const HomeViewMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MiruScaffold.mobile(
      // The dashboard sections own their 16px gutter (the mock's
      // px-margin-mobile); forui's FScaffold child padding (12) stacked on
      // top of it and pushed every element to x=28 — measured live. Opt out
      // so the pinned top bar and all sections share the same 16px edge.
      childPad: false,
      sliverHeaders: [
        StaticSliverHeaderDelegate(
          maxExtent: HomeTopBar.extent,
          minExtent: HomeTopBar.extent,
          child: const HomeTopBar(),
        ),
      ],
      onRefresh: () => refreshDashboard(ref),
      slivers: const [SliverToBoxAdapter(child: HomeDashboardView())],
    );
  }
}

// Desktop implementation - sidebar is provided by MainPage wrapper
class HomeViewDesktop extends ConsumerWidget {
  const HomeViewDesktop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(
      applicationControllerProvider.select((s) => s.themeData),
    );

    return FTheme(
      data: themeData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FDivider(
            style: FDividerStyleDelta.delta(
              padding: EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
            ),
          ),
          Expanded(child: DesktopLibraryPage()),
        ],
      ),
    );
  }
}

// Desktop library page (reused from legacy)
class DesktopLibraryPage extends HookConsumerWidget {
  const DesktopLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    return CustomScrollView(
      key: const PageStorageKey('LibraryPageScrollDesktop'),
      slivers: [
        SliverToBoxAdapter(
          child: SnapSheetHeader(
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 20),
            title: 'common.your_library'.i18n,
            description: 'common.library_description'.i18n,
          ),
        ),
        SliverToBoxAdapter(
          child: ContinueWatchingSection(
            horizontalTitlePadding: 40,
            scrollController: scrollController,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        FavoritesGrid(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          crossAxisCount: (MediaQuery.of(context).size.width ~/ 250).clamp(
            2,
            10,
          ),
          childAspectRatio: 0.65,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}
