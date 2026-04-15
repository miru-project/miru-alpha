import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/tracking/anilist_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'package:miru_alpha/widgets/core/tabbar.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'widgets/tracking_desktop.dart';
import 'widgets/tracking_mobile.dart';

class TrackingPage extends HookConsumerWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(anilistAccountProvider);
    final isMobile = DeviceUtil.isMobile;
    final tabController = useTabController(initialLength: 2);

    return MiruScaffold(
      snappingOffsets: const [
        AbsoluteSheetOffset(220),
        ProportionalToViewportSheetOffset(0.5),
        ProportionalToViewportSheetOffset(1.0),
      ],
      mobileHeader: SnapSheetNested.back(
        title: 'tracking.name'.i18n,
        suffix: FButton.icon(
          variant: .secondary,
          onPress: () => ref.read(anilistAccountProvider.notifier).logout(),
          child: const Icon(FIcons.logOut),
        ),
      ),
      snapSheet: account.when(
        data: (user) => (user != null && isMobile)
            ? [
                MobileUserHeader(user: user),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MiruTabBar(
                    controller: tabController,
                    tabs: const [
                      Tab(text: 'Anime'),
                      Tab(text: 'Manga'),
                    ],
                  ),
                ),
              ]
            : [],
        loading: () => [],
        error: (err, stack) => [],
      ),
      body: account.when(
        data: (user) {
          if (user == null) {
            return const _LoginPrompt();
          }
          if (isMobile) {
            return TabBarView(
              controller: tabController,
              children: const [
                CollectionTab(type: AnilistType.anime),
                CollectionTab(type: AnilistType.manga),
              ],
            );
          }
          return TrackingDesktop(user: user);
        },
        loading: () => const Center(child: FCircularProgress.loader()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(FIcons.circleAlert, size: 48),
              const SizedBox(height: 16),
              const Text('Error'),
              const SizedBox(height: 16),
              FButton(
                onPress: () =>
                    ref.read(anilistAccountProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginPrompt extends ConsumerWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FIcons.clipboardClock,
            size: 64,
            color: context.theme.colors.mutedForeground,
          ),
          const SizedBox(height: 16),
          Text(
            'Track your progress with Anilist',
            style: context.theme.typography.lg.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Login to sync your anime and manga progress.',
            style: context.theme.typography.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 32),
          FButton(
            onPress: () => ref.read(anilistAccountProvider.notifier).login(),
            prefix: const Icon(FIcons.logIn),
            child: const Text('Login with Anilist'),
          ),
        ],
      ),
    );
  }
}
