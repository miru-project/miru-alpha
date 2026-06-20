import 'package:flutter/material.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/pages/download/widget/index.dart';
import 'package:miru_alpha/provider/download_provider.dart';
import 'package:miru_alpha/widgets/error.dart';
import 'package:miru_alpha/widgets/index.dart';

class MobileFinishedDownloadSection extends ConsumerWidget {
  const MobileFinishedDownloadSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(downloadProvider);
    return MiruScaffold.mobile(
      snapSheet: [SnapSheetNested.back(title: "download.history".i18n)],
      childPad: true,
      body: state.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (e, s) => ErrorDisplay.grpc(err: e, stack: s),
        data: (data) {
          final downloads = data.history;
          if (downloads.isEmpty) return Text("common.no_download_history".i18n);
          return FTileGroup.builder(
            label: Text("common.downloads_history".i18n),
            count: downloads.length,
            tileBuilder: (context, index) {
              final item = downloads[index];
              return DownloadHistoryTile(download: item);
            },
          );
        },
      ),
    );
  }
}
