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
    final currentType = useState(AnilistType.anime);

    // Reset status on anime/manga tab switch
    useEffect(() {
      void listener() {
        if (!tabController.indexIsChanging) {
          currentType.value = tabController.index == 0
              ? AnilistType.anime
              : AnilistType.manga;
          ref.read(trackingStatusFilterProvider.notifier).set(null);
        }
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    return MiruScaffold.mobile(
      snappingOffsets: const [
        AbsoluteSheetOffset(190),
        ProportionalToViewportSheetOffset(0.5),
        ProportionalToViewportSheetOffset(1.0),
      ],
      mobileHeader: SnapSheetNested.back(
        title: 'tracking.name'.i18n,
        suffix: FButton.icon(
          variant: .secondary,
          onPress: () => ref.read(anilistAccountProvider.notifier).logout(),
          child: const Icon(FLucideIcons.logOut),
        ),
      ),
      snapSheet: account.when(
        data: (user) => (user != null && isMobile)
            ? [
                MobileUserHeader(user: user),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 40,
                    child: MiruTabBar(
                      controller: tabController,
                      tabs: const [
                        Tab(text: 'Anime'),
                        Tab(text: 'Manga'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                HookBuilder(
                  builder: (context) {
                    final selectedStatus = ref.watch(
                      trackingStatusFilterProvider,
                    );
                    return FSelectTileGroup<String>.builder(
                      key: ValueKey(selectedStatus),
                      count: AnilistMediaListStatus.values.length + 1,
                      control: FMultiValueControl.managedRadio(
                        initial: selectedStatus ?? 'ALL',
                        onChange: (values) {
                          final val = values.firstOrNull;
                          ref
                              .read(trackingStatusFilterProvider.notifier)
                              .set(val == 'ALL' ? null : val);
                        },
                      ),
                      tileBuilder: (context, index) {
                        if (index == 0) {
                          return const FSelectTile(
                            title: Text('All'),
                            value: 'ALL',
                          );
                        }
                        final status = AnilistMediaListStatus.values[index - 1];
                        return FSelectTile(
                          title: Text(
                            AniListProvider.mediaListStatusToTranslate(
                              status,
                              currentType.value,
                            ),
                          ),
                          value: AniListProvider.mediaListStatusToQuery(status),
                        );
                      },
                    );
                  },
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
                _KeepAliveWrapper(
                  child: CollectionTab(type: AnilistType.anime),
                ),
                _KeepAliveWrapper(
                  child: CollectionTab(type: AnilistType.manga),
                ),
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
              const Icon(FLucideIcons.circleAlert, size: 48),
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
            FLucideIcons.clipboardClock,
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
            prefix: const Icon(FLucideIcons.logIn),
            child: const Text('Login with Anilist'),
          ),
        ],
      ),
    );
  }
}

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
