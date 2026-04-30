import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/dev_tool_provider.dart';
import 'package:intl/intl.dart';

class NetworkView extends ConsumerWidget {
  const NetworkView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devState = ref.watch(devToolProvider);
    final notifier = ref.read(devToolProvider.notifier);

    final filteredRequests = devState.filterPackage == null
        ? devState.requests
        : devState.requests
              .where((r) => r.package == devState.filterPackage)
              .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FTileGroup.builder(
          // shrinkWrap: true,
          count: filteredRequests.length,
          tileBuilder: (context, index) {
            final req = filteredRequests[index];
            final time = DateFormat('HH:mm:ss.SSS').format(
              DateTime.fromMillisecondsSinceEpoch(req.timestamp.toInt()),
            );

            Color statusColor = Colors.green;
            if (req.status >= 400) {
              statusColor = Colors.red;
            } else if (req.status >= 300) {
              statusColor = Colors.orange;
            }

            return FTile(
              prefix: Container(width: 4, height: 40, color: statusColor),
              suffix: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    req.method,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  FBadge(child: Text(req.status.toString())),
                ],
              ),
              title: Text(
                req.url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '[${req.package}] ${req.duration}ms @ $time',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              onPress: () {
                _showRequestDetails(context, req);
              },
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FButton(
            onPress: notifier.clearRequests,
            prefix: Icon(FIcons.trash),
            child: const Text('Clear'),
          ),
        ),
      ],
    );
  }

  void _showRequestDetails(BuildContext context, dynamic req) {
    showFDialog(
      routeStyle: .delta(
        barrierFilter: () =>
            (animation) => .compose(
              outer: .blur(sigmaX: animation * 5, sigmaY: animation * 5),
              inner: ColorFilter.mode(context.theme.colors.barrier, .srcOver),
            ),
      ),
      context: context,
      builder: (context, style, animation) => FDialog(
        constraints: BoxConstraints(minWidth: 400, maxWidth: 700),
        title: const Text('Request Details'),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailSection('URL', req.url),
              _detailSection('Method', req.method),
              _detailSection('Status', req.status.toString()),
              _detailSection('Duration', '${req.duration}ms'),
              _detailSection('Request Headers', req.requestHeaders),
              _detailSection('Request Body', req.requestBody),
              _detailSection('Response Headers', req.responseHeaders),
              _detailSection('Response Body', req.responseBody),
            ],
          ),
        ),
        actions: [
          FButton(
            child: const Text('Close'),
            onPress: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _detailSection(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.all(4),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SingleChildScrollView(
              child: Text(
                value,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
