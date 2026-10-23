import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/favorite_page_provider.dart';
import 'package:miru_alpha/provider/home/home_trending_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Pinned brand bar: a forui [FHeader] (wordmark + channel badge as the title,
/// search as the single header action) over an opaque hairline-backed surface
/// so rail content scrolls beneath it.
class HomeTopBar extends ConsumerWidget {
  const HomeTopBar({super.key});

  /// Pinned extent; [HomeViewMobile] sizes its sliver header with it.
  static const double extent = 48;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    return Container(
      height: extent,
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(bottom: BorderSide(color: colors.border, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      // The scaffold already absorbed the system top inset; FHeader applies
      // SafeArea itself, so strip it to avoid doubling it on a real phone.
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: FHeader(
          style: .delta(
            padding: EdgeInsetsGeometryDelta.value(
              // Same 16px gutter every dashboard section uses (the mock's
              // px-margin-mobile) — the brand and actions align with the
              // content below.
              const EdgeInsets.symmetric(horizontal: 16),
            ),
            constraints: const BoxConstraints(minHeight: 0),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Brand group shrinks as one unit: long locales (and raw test
              // keys) scale down instead of pushing the actions off the bar.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'common.home'.i18n,
                        style: context.theme.typography.display.xl2.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          suffixes: [
            FHeaderAction(
              // 12px padding around the 20px icon = the mockup's 44px targets.
              style: .delta(
                padding: EdgeInsetsGeometryDelta.value(
                  const EdgeInsets.all(12),
                ),
              ),
              icon: const Icon(FLucideIcons.search, size: 20),
              onPress: () => context.push('/search/input'),
              semanticsLabel: 'common.search_globally'.i18n,
            ),
            // No tune/"Filters and Sync" action: the dashboard reads
            // providers that the app's writers update directly (watching
            // writes history, favoriting writes favorites), so the data is
            // current without a manual sheet — pull-to-refresh remains the
            // one explicit refresh gesture.
          ],
        ),
      ),
    );
  }
}

/// Reloads every source the dashboard reads: extension catalogue, library
/// lists and the trending cache. Run by the home pull-to-refresh gesture —
/// there is no manual sheet; the local library data keeps itself current
/// because its writers update the providers directly.
Future<void> refreshDashboard(WidgetRef ref) async {
  await ref.read(extensionPageProvider.notifier).reloadRepos();
  await ref.read(favoritePageProvider.notifier).refreshFavoritesAndGroup();
  ref.invalidate(historyPageProvider);
  await ref.read(homeTrendingProvider.notifier).refresh();
  showSimpleToast('common.force_refresh_success'.i18n);
}
