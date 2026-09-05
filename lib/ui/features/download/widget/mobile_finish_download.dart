import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/ui/core/empty_state.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/core/loading_state.dart';
import 'package:miru_alpha/ui/features/download/widget/mobile_completed_tile.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// Finished downloads, paginated.
///
/// This is the only place completed downloads live on mobile: the main
/// download screen is reserved for work still in flight, so a task that
/// finishes disappears from there and shows up here instead.
///
/// The backend serves history 20 rows per page, so this page drives
/// [DownloadNotifier.loadMoreHistory] from the scroll position — without it
/// older downloads simply look like they were deleted.
///
/// Content is passed as `slivers` rather than `body`: `MiruScaffold` renders
/// `body` inside a snap sheet without a scroll view, which silently clipped
/// the list once it grew past one screen.
class MobileFinishedDownloadSection extends ConsumerStatefulWidget {
  const MobileFinishedDownloadSection({super.key});

  @override
  ConsumerState<MobileFinishedDownloadSection> createState() =>
      _MobileFinishedDownloadSectionState();
}

class _MobileFinishedDownloadSectionState
    extends ConsumerState<MobileFinishedDownloadSection> {
  /// How close to the bottom (in pixels) triggers the next page.
  static const double _loadMoreInset = 240;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - _loadMoreInset) return;
    // `loadMoreHistory` ignores calls made while a page is in flight, so
    // firing on every scroll tick is cheap.
    ref.read(downloadProvider.notifier).loadMoreHistory();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(downloadProvider);

    return MiruScaffold.mobile(
      childPad: false,
      scrollController: _scrollController,
      sliverHeaders: [
        StaticSliverHeaderDelegate(
          maxExtent: 56,
          minExtent: 56,
          child: SnapSheetNested.back(title: 'download.downloads_history'.i18n),
        ),
      ],
      slivers: state.when(
        loading: () => const [SliverFillRemaining(child: LoadingState())],
        error: (error, stack) => [
          SliverFillRemaining(
            child: ErrorDisplay.grpc(err: error, stack: stack),
          ),
        ],
        data: (data) {
          // The history page mixes every stored row; only finished ones belong
          // here, in-flight work stays on the download screen.
          final downloads = data.completed;
          if (downloads.isEmpty) {
            return [
              SliverFillRemaining(
                child: EmptyState(
                  icon: FLucideIcons.clock,
                  message: 'download.no_completed_downloads'.i18n,
                ),
              ),
            ];
          }

          return [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverList.separated(
                itemCount: downloads.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) =>
                    MobileCompletedDownloadTile(download: downloads[index]),
              ),
            ),
            SliverToBoxAdapter(child: _HistoryFooter(state: data)),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ];
        },
      ),
    );
  }
}

/// Bottom-of-list status: a spinner while the next page loads, a terminal
/// note once the backend has run out of rows.
class _HistoryFooter extends StatelessWidget {
  const _HistoryFooter({required this.state});

  final DownloadState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMoreHistory) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: FCircularProgress()),
      );
    }

    if (!state.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'download.end_of_list'.i18n,
            style: context.theme.typography.body.xs.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
