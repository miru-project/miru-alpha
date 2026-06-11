import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'widget/console_view.dart';
import 'widget/network_view.dart';

class DevToolPage extends HookConsumerWidget {
  const DevToolPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MiruScaffold(
      mobileHeader: const SnapSheetHeader(title: 'Developer Tool'),
      body: FTabs(
        children: [
          FTabEntry(label: const Text('Console'), child: const ConsoleView()),
          FTabEntry(label: const Text('Network'), child: const NetworkView()),
        ],
      ),
    );
  }
}
