import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/pages/download/widget/index.dart';
import 'package:miru_app_new/provider/download_provider.dart';
import 'package:miru_app_new/widgets/error.dart';

class MobileDownloadPage extends StatelessWidget {
  const MobileDownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(child: MobileActiveDownloadSection()),
        SliverToBoxAdapter(child: MobileFinishedDownloadSection()),
      ],
    );
  }
}

class MobileFinishedDownloadSection extends ConsumerWidget {
  const MobileFinishedDownloadSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(downloadProvider);
    return state.when(
      loading: () => const Center(child: FCircularProgress()),
      error: (e, s) => ErrorDisplay.grpc(err: e, stack: s),
      data: (data) {
        final downloads = data.history;
        if (downloads.isEmpty) return const Text("No download history");
        return FTileGroup.builder(
          label: const Text("Downloads History"),
          count: downloads.length,
          tileBuilder: (context, index) {
            final item = downloads[index];
            return DownloadHistoryTile(download: item);
          },
        );
      },
    );
  }
}
