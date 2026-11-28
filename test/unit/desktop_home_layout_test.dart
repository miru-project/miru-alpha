import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/ui/features/home/widget/dashboard/home_banner.dart';
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/display_title.dart';
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/home_desktop_continue.dart';
import 'package:miru_alpha/ui/features/home/widget/desktop_dashboard/home_desktop_feed.dart';

/// Pure conversion logic behind the desktop main page.
///
/// These are the derived values the page's layout depends on: the scraped
/// title cleanup, the two grid column resolvers, and the hero dock's slot
/// count. They are computed, not rendered, so they stay covered while the
/// render tests below only assert the page builds.
void main() {
  group('displayTitle', () {
    test('strips bracketed group tags', () {
      expect(
        displayTitle('[ToonsHub] Daemons of the Shadow Realm S01E17'),
        'Daemons of the Shadow Realm S01E17',
      );
    });

    test('drops everything from the first quality token onward', () {
      expect(
        displayTitle('Daemons of the Shadow Realm S01E17 1080p WEB-DL H.264'),
        'Daemons of the Shadow Realm S01E17',
      );
    });

    test('removes a leading Watch site prefix', () {
      expect(displayTitle('Watch Frieren S01E01'), 'Frieren S01E01');
    });

    test('collapses doubled spaces left by stripped segments', () {
      expect(displayTitle('[A]  [B]  Show'), 'Show');
    });

    test('falls back to the trimmed raw string when nothing survives', () {
      expect(displayTitle('  1080p  '), '1080p');
      expect(displayTitle(''), '');
    });

    test('keeps a short title whose only token is early in the string', () {
      // The quality-token cut requires start > 3, so a 4-char title before a
      // quality token is preserved rather than truncated to nothing.
      expect(displayTitle('Show 1080p'), 'Show');
    });
  });

  group('grid column resolvers', () {
    test('continue row grows with the canvas, clamped 2..7', () {
      expect(HomeDesktopContinue.columnsFor(0), 2);
      expect(HomeDesktopContinue.columnsFor(500), 2);
      expect(HomeDesktopContinue.columnsFor(1036), 5);
      expect(HomeDesktopContinue.columnsFor(1400), 6);
      expect(HomeDesktopContinue.columnsFor(1624), 7);
      expect(HomeDesktopContinue.columnsFor(4000), 7);
    });

    test('poster grid follows the 2/4/5/7 breakpoint ladder', () {
      expect(HomeDesktopFeed.columnsFor(700), 2);
      expect(HomeDesktopFeed.columnsFor(900), 4);
      expect(HomeDesktopFeed.columnsFor(1036), 5);
      expect(HomeDesktopFeed.columnsFor(1400), 5);
      expect(HomeDesktopFeed.columnsFor(1624), 7);
      expect(HomeDesktopFeed.columnsFor(2200), 7);
    });
  });

  group('bannerDockSlots', () {
    test('clamps to at least one slot on a very narrow canvas', () {
      // (100 - 150) ~/ 72 is negative; the clamp is what keeps it sane.
      expect(bannerDockSlots(100), 1);
      expect(bannerDockSlots(0), 1);
    });

    test('grows by one slot per 72px of header budget', () {
      expect(bannerDockSlots(300), 2);
      expect(bannerDockSlots(444), 4);
    });

    test('caps at four slots on a wide canvas', () {
      expect(bannerDockSlots(1600), 4);
      expect(bannerDockSlots(4000), 4);
    });

    test('is monotonic across the range', () {
      var previous = bannerDockSlots(200);
      for (var w = 200.0; w <= 2000; w += 50) {
        final slots = bannerDockSlots(w);
        expect(slots, greaterThanOrEqualTo(previous));
        previous = slots;
      }
    });
  });
}
