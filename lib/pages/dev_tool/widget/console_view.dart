import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:miru_alpha/provider/dev_tool_provider.dart';

class ConsoleView extends ConsumerWidget {
  const ConsoleView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devState = ref.watch(devToolProvider);
    final notifier = ref.read(devToolProvider.notifier);

    final filteredLogs = devState.filterPackage == null
        ? devState.logs
        : devState.logs
              .where((l) => l.package == devState.filterPackage)
              .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FButton(
            onPress: notifier.clearLogs,
            prefix: Icon(FIcons.trash),
            child: const Text('Clear'),
          ),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filteredLogs.length,
            itemBuilder: (context, index) {
              final log = filteredLogs[index];
              final time = DateFormat('HH:mm:ss.SSS').format(
                DateTime.fromMillisecondsSinceEpoch(log.timestamp.toInt()),
              );

              Color? textColor;
              IconData? icon;
              switch (log.level) {
                case 'warn':
                  textColor = Colors.orange;
                  icon = FIcons.triangleAlert;
                  break;
                case 'error':
                  textColor = Colors.red;
                  icon = FIcons.circleX;
                  break;
                default:
                  textColor = null;
                  icon = FIcons.info;
              }

              return FTile(
                prefix: Icon(icon, color: textColor),
                title: Text(
                  '[${log.package}] $time',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                subtitle: Text(
                  log.message,
                  style: TextStyle(color: textColor, fontFamily: 'monospace'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
