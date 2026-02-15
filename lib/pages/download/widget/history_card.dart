import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miru_app_new/miru_core/grpc_client.dart';
import 'package:miru_app_new/miru_core/proto/proto.dart' as proto;
import 'package:forui/forui.dart';

import 'package:miru_app_new/provider/download_provider.dart';

class DownloadHistoryCard extends ConsumerWidget {
  final proto.Download download;
  const DownloadHistoryCard({required this.download, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FCard(
      title: Text(download.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Package: ${download.package}"),
          Text("Status: ${download.status}"),
          Text("Date: ${download.date}"),
          if (download.savePath.isNotEmpty)
            Text(
              "Saved to: ${download.savePath}",
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FButton.icon(
            variant: .destructive,
            onPress: () async {
              await MiruGrpcClient.downloadClient.deleteDownload(
                proto.DeleteDownloadRequest()..id = download.id,
              );
              ref.invalidate(downloadProvider);
            },
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
