import 'package:flutter/widgets.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_banner.dart';
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/home_desktop_continue.dart';
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/home_desktop_feed.dart';

/// Horizontal gutter the desktop dashboard sections share (the mock's
/// `px-7`); the shell's own 12px childPad stacks on top of it.
const kDesktopHomeGutter = 28.0;

/// Vertical rhythm between sections: the mobile dashboard's
/// [kHomeSectionGap] equivalent for the wider canvas.
const kDesktopSectionGap = 28.0;

/// Bottom clearance so the last section clears the download dock overlay.
const kDesktopDockClearance = 88.0;

/// Desktop home, per the "Unified Command Center" mock — banner (TMDB /
/// AniList catalogue hero), Continue Playing & Reading grid, Shelves strip +
/// Favorites grid, and the download dock overlaying the bottom edge.
/// DESKTOP LAYOUT EXCLUSIVE by user directive — the mobile bento dashboard
/// never mounts these. The search surface stays in the shell's top bar
/// ("Search Globally" / Ctrl+K).
///
/// The mock drops the former "Your Library" text hero, the metrics bento and
/// the separate Trending grid (the banner carries the trending catalogue
/// now); those widgets remain in this folder unreferenced.
class HomeDesktopDashboard extends StatelessWidget {
  const HomeDesktopDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          key: const PageStorageKey('HomeDesktopDashboardScroll'),
          padding: const EdgeInsets.fromLTRB(
            kDesktopHomeGutter,
            24,
            kDesktopHomeGutter,
            kDesktopDockClearance,
          ),
          children: [
            HomeBannerSection(),
            SizedBox(height: kDesktopSectionGap),
            // (mock Chunk C density strip removed 2026-11-12: static labels
            // only — viewport mode badge + sort caption — zero controls.)
            HomeDesktopContinue(),
            SizedBox(height: kDesktopSectionGap),
            HomeDesktopFeed(),
          ],
        ),
      ],
    );
  }
}
