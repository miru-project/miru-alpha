import 'package:flutter/widgets.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_quick_access_grid.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_dynamic_feed.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_resume_rail.dart';
// import 'package:miru_alpha/ui/features/home/widget/dashboard/home_source_feed.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_tag_strip.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_trending_rail.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_type_switch.dart';

/// Vertical rhythm between dashboard sections: the mockup's `space-y-6`.
const kHomeSectionGap = 24.0;

/// Mobile bento dashboard in the mockup's section order: type switcher,
/// Continue Playing, Quick Access, favorite tags, Dynamic Feed, Trending and
/// the Source Feed.
class HomeDashboardView extends StatelessWidget {
  const HomeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: HomeTypeSwitch(),
        ),
        const SizedBox(height: kHomeSectionGap),
        const HomeResumeRail(),
        const SizedBox(height: kHomeSectionGap),
        const HomeQuickAccessGrid(),
        const SizedBox(height: kHomeSectionGap),
        const HomeTagStrip(),
        const SizedBox(height: kHomeSectionGap),
        const HomeDynamicFeed(),
        const SizedBox(height: kHomeSectionGap),
        const HomeTrendingRail(),
        const SizedBox(height: kHomeSectionGap),
        // WIP
        // const HomeSourceFeed(),
        // Clearance for the bottom navigation dock.
        const SizedBox(height: 200),
      ],
    );
  }
}
