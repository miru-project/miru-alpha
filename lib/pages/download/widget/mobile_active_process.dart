import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/provider/download_provider.dart';
import 'package:miru_app_new/widgets/error.dart';
import 'download_tiles.dart';

class MobileActiveDownloadSection extends ConsumerWidget {
  const MobileActiveDownloadSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(downloadProvider);
    return state.when(
      data: (data) => FTileGroup.builder(
        label: const Text("Active Tasks"),
        count: data.active.length,
        tileBuilder: (context, index) {
          final item = data.active[index];
          return DownloadProcessTile(progress: item);
        },
      ),
      error: (err, stack) => ErrorDisplay.grpc(err: err, stack: stack),
      loading: () => const FCircularProgress(),
    );
  }
}
