import 'package:flutter/material.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/pages/download/widget/index.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/widgets/error.dart';

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
        if (downloads.isEmpty) return Text("no_download_history".i18n);
        return FTileGroup.builder(
          label: Text("downloads_history".i18n),
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
