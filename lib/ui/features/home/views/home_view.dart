import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/ui/core/scaffold/custom_silver_header.dart';
import 'package:miru_alpha/ui/core/scaffold/miru_scaffold.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_dashboard_view.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_top_bar.dart';
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/home_desktop_dashboard.dart';
import 'package:miru_alpha/utils/core/device_util.dart';

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

/// Desktop home: the wide-canvas recomposition of the same bento dashboard
/// (the sidebar shell lives in `MainPage`).
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
          const Expanded(child: HomeDesktopDashboard()),
        ],
      ),
    );
  }
}
